defmodule Speech do
  require IEx
  
  @sessions [["082.2.55.O", "15/04/16"], ["087.2.55.O", "16/04/16"], ["084.2.55.O", "15/04/16"], ["085.2.55.O", "15/04/16"], ["086.2.55.O", "16/04/16"], ["089.2.55.O", "16/04/16"], ["090.2.55.O", "16/04/16"], ["083.2.55.O", "15/04/16"], ["088.2.55.O", "16/04/16"], ["091.2.55.O", "17/04/16"]]
  @list_speeches_url "http://www.camara.gov.br/sitcamaraws/SessoesReunioes.asmx/ListarDiscursosPlenario"
  @speech_url "http://www.camara.gov.br/SitCamaraWS/SessoesReunioes.asmx/obterInteiroTeorDiscursosPlenario"
  @user_agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.112 Safari/537.36" 

  def speeches_to_map(speeches) do
    speeches_to_map(speeches, [])
  end

  def speeches_to_map(speeches, acc) do
    case speeches do
      [ speech | _ ] ->
        { speeches_to_reduce, speeches_wo } = Enum.partition(speeches,fn(e) -> e.deputy == speech.deputy end)
      speeches_combined = Enum.reduce(speeches_to_reduce, [], fn s, acc ->
        [ List.first(s.speeches) | acc ]
      end)

      new_speech = %{deputy: speech.deputy, party: speech.party, uf: speech.uf, speeches: speeches_combined } 

      speeches_to_map(speeches_wo, [ new_speech | acc])

      [] -> acc
    end
  end

  def already_mapped?(speeches, speech) do
    Enum.any?(speeches, fn(e) -> e.deputy == speech.deputy && e.party == speech.party end)
  end

  # Fetch data for all the sessions
  def fetch_sessions_speeches do
    @sessions 
    |> Enum.map(&fetch_session_data(&1)) 
    |> Enum.map(&fetch_session_speeches(&1))
    |> reduce_speeches
    |> speeches_to_map
  end

  def fetch_speeches_to_json do
    fetch_sessions_speeches |> Poison.encode! |> save_to_file
  end

  def save_to_file(json_content) do
    {:ok, file} = File.open "speeches.json", [:write]
    IO.binwrite file, json_content
    File.close file
  end

  def reduce_speeches(sessions_speeches) do
    Enum.reduce(sessions_speeches, [], fn session_speeches, acc -> acc ++ session_speeches end)
  end

  def fetch_session_speeches(speeches_data) do
    speeches_data |> Enum.map(&fetch_session_speech(&1))
  end

  def fetch_session_speech(speech_data) do
    url_for_speech(speech_data.codigosessao, speech_data.numeroorador, speech_data.numeroquarto, speech_data.numeroinsercao)
    |> HTTPotion.get(headers: ["User-Agent": @user_agent ])
    |> parse_speech_response
  end

  # Returns array of metadata of session ocurring on that date
  def fetch_session_data([session_id, date]) do
    url_for_session(session_id, date)
    |> HTTPotion.get(headers: ["User-Agent": @user_agent ])
    |> parse_session_data(session_id)
  end

  # Returns an array of speech meta data
  def parse_session_data(%HTTPotion.Response{body: body, headers: _, status_code: 200}, session_id) do
    [{"discursos", [], speeches}] = Floki.find(body, "discursos")
    Enum.map(speeches, &extract_data_from_speech(&1, session_id))
  end

  def parse_speech_response(%HTTPotion.Response{body: body, headers: _, status_code: 200}) do
    session_body = Floki.find(body, "sessao")

    case session_body do
      [{"sessao", [],
          [{"nome", [], [deputy]},
            {"partido", [], [party]}, {"uf", [], [uf]},
            {"horainiciodiscurso", [], [_]},
            {"discursortfbase64", [], [speech]}]}] -> %{ deputy: deputy, party: String.strip(party), uf: uf, speeches: [decode_speech(speech)] }
      [{"sessao", [],
          [{"nome", [], [deputy]},
            {"partido", [], []}, {"uf", [], [uf]},
            {"horainiciodiscurso", [], [_]},
            {"discursortfbase64", [], [speech]}]}] -> %{ deputy: deputy, party: "SEM PARTIDO", uf: uf, speeches: [decode_speech(speech)] }
      [{"sessao", [],
          [{"nome", [], [deputy]},
            {"partido", [], []}, {"uf", [], []},
            {"horainiciodiscurso", [], [_]},
            {"discursortfbase64", [], [speech]}]}] -> %{ deputy: deputy, party: "SEM PARTIDO", uf: "ND", speeches: [decode_speech(speech)] }
    end
  end

  def extract_data_from_speech(raw_speech, session_id) do
    {"discurso", [],[
        { "orador", [], [{"numero", [], [numorador]} | _ ]},
        { "horainiciodiscurso", _, _ },
        { "txtindexacao", _, _ },
        { "numeroquarto", _, [numquarto] },
        { "numeroinsercao", _, [numinsercao]},
        { "sumario", _, _}
      ]} = raw_speech

    %{ numeroinsercao: numinsercao, numeroquarto: numquarto, numeroorador: numorador, codigosessao: session_id }
  end

  def url_for_session(session_id, date) do
    @list_speeches_url <> "?codigoSessao=" <> session_id <> "&dataIni=" <> date <> "&dataFim=" <> date <> "&parteNomeParlamentar=&siglaPartido=&siglaUF="
  end

  def url_for_speech(session_code, speaker_number, room_number, insertion_number) do
    @speech_url <> "?codSessao=" <> session_code <> "&numOrador="<> speaker_number <> "&numQuarto=" <> room_number <> "&numInsercao=" <> insertion_number
  end

  def decode_speech(speech) do
    {:ok, decoded } = Base.decode64(speech)
    decoded |> to_plain 
  end

  def to_plain(speech) do
    if !File.dir?(".temp"), do: File.mkdir ".temp"
    name = "/Users/paulodiniz/elixir/discurso_camara/speech/.temp/" <> random_name
    temp_name = name <> ".tmp"
    txt_name = name <> ".txt"
    File.write temp_name, speech
    System.cmd "textutil", [temp_name, "-convert", "txt"]
    {:ok, plain_text } = File.read txt_name
    File.rm temp_name
    File.rm txt_name

    plain_text
  end

  defp random_name do
    random_string <> "-" <> timestamp
  end

  defp random_string do
    :random.seed(:erlang.monotonic_time, :erlang.time_offset, :erlang.unique_integer)
    0x100000000000000 |> :random.uniform |> Integer.to_string(36) |> String.downcase
  end

  defp timestamp do
    {megasec, sec, _microsec} = :os.timestamp
    megasec*1_000_000 + sec |> Integer.to_string()
  end
end


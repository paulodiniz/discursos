defmodule Speech do
  require IEx
  
  @sessions [["082.2.55.O", "15/04/16"]]
  @list_speeches_url "http://www.camara.gov.br/sitcamaraws/SessoesReunioes.asmx/ListarDiscursosPlenario"
  @speech_url "http://www.camara.gov.br/SitCamaraWS/SessoesReunioes.asmx/obterInteiroTeorDiscursosPlenario"
  @user_agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.112 Safari/537.36" 

  def speeches_to_map(speeches) do
    Enum.reduce(speeches, [], fn speech, acc ->
      # check if acc has object with same name and party  
      # case yes, update speeches
      # case no, insert object to acc
      case Speech.already_mapped?(acc, speech) do
        true  -> update_speech(speeches, speech)
        false -> [ speech | acc ]
      end
    end)
  end

  def update_speech(speeches, speech) do
    old_speech_index = Enum.find_index(speeches, fn(e) -> e.deputy == speech.deputy && e.party == speech.party end)
    old_speech = Enum.at(speeches, old_speech_index)

    new_list = List.delete_at(speeches, old_speech_index)
    old_speech_index = Enum.find_index(new_list, fn(e) -> e.deputy == speech.deputy && e.party == speech.party end)
    List.update_at(new_list, old_speech_index, fn (elem) ->
      %{deputy: speech.deputy, party: speech.party, uf: speech.uf, speeches: ["ABC", "DEF"]}
    end)
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
            {"discursortfbase64", [], [speech]}]}] -> %{ deputy: deputy, party: party, uf: uf, speech: speech }
      [{"sessao", [],
          [{"nome", [], [deputy]},
            {"partido", [], []}, {"uf", [], [uf]},
            {"horainiciodiscurso", [], [_]},
            {"discursortfbase64", [], [speech]}]}] -> %{ deputy: deputy, party: "SEM PARTIDO", uf: uf, speech: speech }
      [{"sessao", [],
          [{"nome", [], [deputy]},
            {"partido", [], []}, {"uf", [], []},
            {"horainiciodiscurso", [], [_]},
            {"discursortfbase64", [], [speech]}]}] -> %{ deputy: deputy, party: "SEM PARTIDO", uf: "ND", speech: speech }
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
end

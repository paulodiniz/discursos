defmodule Speech do
  require IEx
  
  @sessions [["082.2.55.O", "15/04/16"]]
  @list_speeches_url "http://www.camara.gov.br/sitcamaraws/SessoesReunioes.asmx/ListarDiscursosPlenario"
  @user_agent  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.112 Safari/537.36" 

  # Fetch data for all the sessions
  def fetch_sessions_speeches do
    Enum.map(@sessions, &fetch_session_speeches(&1))
  end

  # Fetch metadata off all speeches in a sessions ocurring in a specific date
  def fetch_session_speeches([session_id, date]) do
    url_for_session(session_id, date)
    |> HTTPotion.get(headers: ["User-Agent": @user_agent ])
    |> parse_response(session_id)
  end

  def parse_response(%HTTPotion.Response{body: body, headers: headers, status_code: 200}, session_id) do
    [{"discursos", [], speeches}] = Floki.find(body, "discursos")
    Enum.map(speeches, &extract_data_from_speech(&1, session_id))
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

    { numinsercao, _ } = Integer.parse(numinsercao)
    { numquarto, _ } = Integer.parse(numquarto)
    { numorador, _ } = Integer.parse(numorador)

    %{ numeroinsercao: numinsercao, numeroquarto: numquarto, numeroorador: numorador, codigosessao: session_id }
  end

  def url_for_session(session_id, date) do
    @list_speeches_url <> "?codigoSessao=" <> session_id <> "&dataIni=" <> date <> "&dataFim=" <> date <> "&parteNomeParlamentar=&siglaPartido=&siglaUF="
  end
end

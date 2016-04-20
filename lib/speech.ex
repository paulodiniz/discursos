defmodule Speech do

  @sessions [["082.2.55.O", "15/04/16"]]
  @list_speeches_url "http://www.camara.gov.br/sitcamaraws/SessoesReunioes.asmx/ListarDiscursosPlenario"

  # Fetch data for all the sessions
  def fetch_sessions_speeches do
    Enum.map(@sessions, &fetch_session_speeches(&1))
  end

  # Fetch metadata off all speeches in a sessions ocurring in a specific date
  def fetch_session_speeches([session_id, date]) do
    url_for_session(session_id, date)
    |> HTTPotion.get(headers: ["User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.112 Safari/537.36"])
  end

  def url_for_session(session_id, date) do
    @list_speeches_url <> "?codigoSessao=" <> session_id <> "&dataIni=" <> date <> "&dataFim=" <> date <> "&parteNomeParlamentar=&siglaPartido=&siglaUF="
  end
end

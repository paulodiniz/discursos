defmodule Speech do

  @sessions [['082.2.55.O', '15/04/16']]
  @list_speeches_url "http://www.camara.gov.br/sitcamaraws/SessoesReunioes.asmx/ListarDiscursosPlenario"

  # Fetch data for all the sessions
  def fetch_session_speeches do
    Enum.map(@sessions, &fetch_session_speeches(&1, &2))
  end

  # Fetch metadata off all speeches in a sessions ocurring in a specific date
  def fetch_session_speeches(session_id, date) do
    #url_for_session(session_id, date)
  end

  def url_for_session(session_id, date) do
    @list_speeches_url <> "?codigoSessao=" <> session_id <> "&dataIni=" <> date <> "&dataFim=" <> date <> "&parteNomeParlamentar=&siglaPartido=&siglaUF="
  end
end

defmodule SpeechTest do
  use ExUnit.Case
  doctest Speech

  test "url for session" do
    assert Speech.url_for_session("25.82", "16/02/2013") == "http://www.camara.gov.br/sitcamaraws/SessoesReunioes.asmx/ListarDiscursosPlenario?codigoSessao=25.82&dataIni=16/02/2013&dataFim=16/02/2013&parteNomeParlamentar=&siglaPartido=&siglaUF="
  end
end

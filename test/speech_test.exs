defmodule SpeechTest do
  use ExUnit.Case
  doctest Speech

  test "url for session" do
    assert Speech.url_for_session("25.82", "16/02/2013") == "http://www.camara.gov.br/sitcamaraws/SessoesReunioes.asmx/ListarDiscursosPlenario?codigoSessao=25.82&dataIni=16/02/2013&dataFim=16/02/2013&parteNomeParlamentar=&siglaPartido=&siglaUF="
  end

  test "extract info from speech" do
    raw_speech = {"discurso", [],
      [{"orador", [],
          [{"numero", [], ["1"]}, {"nome", [], ["EDUARDO CUNHA (PRESIDENTE)"]},
            {"partido", [], ["PMDB        "]}, {"uf", [], ["RJ"]}]},
        {"horainiciodiscurso", [], ["15/4/2016 09:00:00"]},
        {"txtindexacao", [],
          ["USO DA PALAVRA, DCR 1/2015, DENÚNCIA POR CRIME DE RESPONSABILIDADE, DILMA ROUSSEFF, PRESIDENTE DA REPÚBLICA, IMPEACHMENT, COMISSÃO ESPECIAL, PARECER, ADMISSIBILIDADE, ESCLARECIMENTO."]},
        {"numeroquarto", [], ["4"]}, {"numeroinsercao", [], ["0"]},
        {"sumario", [],
          ["Esclarecimentos ao Plenário sobre inscrição de Deputados para uso da palavra."]}]}

    speech = Speech.extract_data_from_speech(raw_speech, '0.88')
    assert speech.numeroquarto == "4"
    assert speech.numeroinsercao == "0"
    assert speech.numeroorador == "1"
    assert speech.codigosessao == '0.88'
  end

  test "reducing" do
    assert Speech.reduce_speeches([['1', '2'], ['3', '5'], ['6']]) == ['1', '2', '3', '5', '6']
  end

  test 'speeches to map' do
    speeches = [%{deputy: "Eduardo Cunha", party: "PMDB", speeches: ["ABC"], uf: "RJ"}, %{deputy: "Arlindo", party: "PT", speeches: ["My speech"]}, %{deputy: "Eduardo Cunha", party: "PMDB", speeches: ["DEF"], uf: "RJ"}]
    assert Speech.speeches_to_map(speeches) == [%{deputy: "Eduardo Cunha", party: "PMDB", speeches: ["DEF", "ABC"], uf: "RJ"}, %{deputy: "Arlindo", party: "PT", speeches: ["My speech"]}]
  end

  test 'already mapped?' do
    assert Speech.already_mapped?([%{deputy: 'a', party: 'b'}, %{deputy: 'd', party: 'e'}], %{deputy: 'a', party: 'b'}) == true
  end
end

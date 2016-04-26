defmodule AnalyserTest do
  use ExUnit.Case
  doctest Analyser

  test "reduces" do
    speeches = [%{"deputy" => "RONALDO LESSA", "party" => "PDT",
        "speeches" => ["\tO SR. RONALDO LESSA (PDT-AL.) - Sr. Presidente, Srs. Deputados, chegamos a uma época da vida que achamos que não vai passar por nada mais difícil do que passou. Melhorou, porque a decisão já está tomada, é menos ruim. Ou talvez fosse melhor, se eu tivesse que decidir. Mas falo por dois motivos, Sr. Presidente, rapidamente.\n\tPrimeiro, pelo clamor da sociedade, que é pela mudança. Por isso, tentei ver se o PDT abria a questão, mas o PDT já tinha fechado,
        sob a alegação irrefutável, que eu não podia discutir, de que não havia crime de responsabilidade para se tirar a Presidente da República. Isso é inquestionável, principalmente para quem já foi Chefe do Executivo. Portanto, voto \"não\".\n\tE voto \"não\" também em nome dos nordestinos, do povo do Brasil! (Manifestação no plenário.)\n\tO SR. FELIPE BORNIER - Deputado Ronaldo Lessa, do PDT de Alagoas: voto \"não\". Total: 137 votos contrários ao impedimento da
        Presidente.\n\t\n"],
      "uf" => "AL"},
    %{"deputy" => "MARX BELTRÃO", "party" => "PMDB",
      "speeches" => ["\tO SR. MARX BELTRÃO (Bloco/PMDB-AL.) - Diante da impossibilidade de novas eleições, em favor dos 10 milhões de desempregados no nosso País; em favor de melhorar a economia do nosso País; em favor da minha querida cidade de Coruripe; em homenagem aos jovens do nosso País, à minha geração, à geração dos meus filhos, à geração que clama por esperança e por dias melhores; pelo bem da Nação e, acima de tudo, pelo bem do meu Estado de Alagoas,
      eu voto \"sim\" pelo impeachment da Presidente.\n\tO SR. BETO MANSUR - Marx Beltrão, do PMDB de Alagoas: voto \"sim\". Total: 365 votos.\n\t(Manifestação no plenário: Não vai ter golpe!)\n\t\n"],
    "uf" => "AL"},
  %{"deputy" => "CÍCERO ALMEIDA", "party" => "PMDB",
    "speeches" => ["\tO SR. CÍCERO ALMEIDA (Bloco/PMDB-AL.) - Sr. Presidente, Srs. Deputados, este momento não estava na minha programação. Eu tenho certeza de que a população alagoana que votou em mim durante os últimos 15 anos não tinha como objetivo que eu participasse deste momento.\n\tMas eu tenho uma gratidão e uma dívida para com Deus, para com o povo alagoano e para com uma senhora que está nos assistindo agora: minha mãe, com 83 anos de idade. Agradeço a Deus, pela
    vida que me devolveu inúmeras vezes; agradeço à população alagoana, por tudo o que fez por mim durante os últimos 15 anos. \nPortanto, pela lealdade especialmente ao meu povo e à minha capital, meu voto é \"sim\", pelo impeachment.\n\tO SR. BETO MANSUR - Deputado Cícero Almeida, do PMDB do Estado de Alagoas: voto \"sim\". Total acumulado: 363 votos.\n\t\n"],
  "uf" => "AL"}]

    god_parties = Analyser.word_on_parties(speeches, "Deus")
    assert god_parties == %{"PMDB" => 2, "PDT" => 0}

    assert Analyser.word_on_deputies(speeches, "Deus") == %{"PMDB" => {1, 2}, "PDT" => {0, 1}}
  end

end


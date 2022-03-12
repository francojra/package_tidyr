# Pacote tidyr - Tidyverse -----------------------------------------------------------------------------------------------------------------
# Autoria do script: Jeanne Franco ---------------------------------------------------------------------------------------------------------
# Data: 11/03/2022 -------------------------------------------------------------------------------------------------------------------------
# Fonte: Curso R ---------------------------------------------------------------------------------------------------------------------------

# O pacote tidyr ---------------------------------------------------------------------------------------------------------------------------

## Dentro do tidyverse, uma base tidy é uma base fácil de se trabalhar, isto é, fácil de 
## se fazer manipulação de dados,  fácil de se criar visualizações, fácil de se ajustar 
## modelos e por aí vai.

## Na prática, uma base tidy é aquela que se encaixa bem no framework do tidyverse, 
## pois os pacotes como o dplyr e o ggplot2 foram desenvolvidos para funcionar bem 
## com bases tidy. E assim como esses pacotes motivaram o uso de bases tidy, 
## o conceito tidy motiva o surgimento de novos frameworks, como o tidymodels para modelagem.

## As duas propriedades mais importantes de uma base tidy são:

## - cada coluna é uma variável;

## - cada linha é uma observação.

## Essa definição proporciona uma maneira consistente de se referir a variáveis 
## (nomes de colunas) e observações (índices das linhas).

## O pacote {tidyr} possui funções que nos ajudam a transformar uma base bagunçada 
## em uma base tidy. Ou então, nos ajudam a bagunçar um pouquinho a nossa base 
## quando isso nos ajudar a produzir o resultados que queremos.

## Vamos ver aqui algumas de suas principais funções:

## - separate() e unite(): para separar variáveis concatenadas em uma única coluna ou uni-las.

## - pivot_wider() e pivot_longer(): para pivotar a base.

## - nest() e unnest(): para criar list columns.

## Como motivação para utilizar esssas funções, vamos utilizar a nossa boa e velha base imdb.

library(dplyr)
library(tidyr)
library(ggplot2)

imdb <- readr::read_rds("imdb.rds")
View(imdb)

# separate() e unite() ---------------------------------------------------------------------------------------------------------------------

## A função separate() separa duas ou mais variáveis que estão concatenadas em uma mesma coluna. 
## A sintaxe da função está apresentada abaixo.

dados %>% 
  separate( 
    col = coluna_velha, 
    into = c("colunas", "novas"),
    sep = "separador"
  )

## Como exemplo, vamos transformar a coluna generos da base IMDB em três colunas, cada uma 
## com um dos gêneros do filme. Lembrando que os valores da coluna generos estão no seguinte 
## formato:

imdb %>% pull(generos) %>% head()

## Veja que agora, temos 3 colunas de gênero. Filmes com menos de 3 gêneros recebem NA na 
## coluna genero2 e/ou genero3. Os gêneros sobressalentes são descartados, assim como a
## coluna generos original.

imdb_1 <- imdb %>% 
  separate( 
    col = generos,
    into = c("genero1", "genero2", "genero3"), 
    sep = "\\|"
  )

View(imdb_1)

## A função unite() realiza a operação inversa da função separate(). 
## Ela concatena os valores de várias variáveis em uma única coluna. A sintaxe é a seguinte:

dados %>% 
  unite(
    col = coluna_nova, 
    colunas_para_juntar, 
    sep = "separador" 
  )

## Como exemplo, vamos agora transformar as colunas ator1, ator2 e ator3 em uma única coluna 
## atores. Lembrando que essas colunas estão no formato abaixo.

imdb %>% select(starts_with("ator")) %>% head(3)

## Veja que agora a coluna atores possui os 3 atores concatenados. Se a ordem das colunas 
## ator1, ator2 e ator3 nos trazia a informação de protagonismo, essa informação passa a 
## ficar implícita nesse novo formato. As 3 colunas originais são removidas da base resultante.

imdb_2 <- imdb %>% 
  unite(
    col = "elenco",
    starts_with("ator"), 
    sep = " - "
  ) 

View(imdb_2)

# Pivotagem --------------------------------------------------------------------------------------------------------------------------------

## O conceito de pivotagem no tidyverse se refere a mudança da estrutura da base, geralmente 
## para alcançar o formato tidy.

## Geralmente realizamos pivotagem quando nossas linhas não são unidades observacionais ou 
## nossas colunas não são variáveis. Ela é similiar à pivotagem do Excel, mas um pouco mais 
## complexa.

## O ato de pivotar resulta em transformar uma base de dados long em wide e vice-versa.

## Uma base no formato long possui mais linhas e pode ter menos colunas, enquanto no 
## formato wide poussi menos linhas e pode ter mais colunas.

## Antigamente, utilizávamos as funções gather() e spread() para fazer as operações de pivotagem.

## Agora, no lugar de gather(), utilizamos a função pivot_longer(). Abaixo, transformamos as 
## colunas ator1, ator2 e ator3 em duas colunas: ator_atriz e protagonismo.

imdb %>% 
  pivot_longer(
    cols = starts_with("ator"), 
    names_to = "protagonismo",
    values_to = "ator_atriz"
  ) %>% 
  select(titulo, ator_atriz, protagonismo) %>% 
  head(6)

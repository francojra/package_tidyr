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

# Funções separate() e unite() ---------------------------------------------------------------------------------------------------------------------

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
    names_to = "protagonismo", # Se apresenta na coluna
    values_to = "ator_atriz" # Se apresenta nas linhas da coluna
  ) %>% 
  select(titulo, ator_atriz, protagonismo) %>% 
  head(6)

## Se considerarmos que na análise da base IMDB cada observação deve ser um filme, então 
## essa nova base já não mais tidy, pois agora cada filme aparece em três linhas diferentes, 
## uma vez para cada um de seus atores.

## Nesse sentido, embora possa parecer que a variável protagonismo estava implícita na base 
## original, ela não é uma variável de fato. Todos filmes têm um ator_1, um ator_2 e um ator_3.
## Não existe nenhuma informação sobre o filme que podemos tirar da coluna protagonismo,
## pois ela qualifica apenas os atores, não o filme em si.

## A função pivot_wider() faz a operação inversa da pivot_longer(). 
## Se aplicarmos as duas funções em sequência, voltamos para a base original.

imdb_3 <- imdb %>% 
  pivot_longer(
    cols = starts_with("ator"), 
    names_to = "ator_protagonismo",
    values_to = "ator_nome"
  ) 

View(imdb_3)

imdb_4 <- imdb_3 %>%
  pivot_wider(
    names_from = "ator_protagonismo",
    values_from = "ator_nome"
  ) %>% 
  head(4)

View(imdb_4)

## A base imdb não possui nenhuma variável que faça sentido aplicarmos diretamente a 
## função pivot_wider(). Vamos então considerar a seguinte tabela derivada da base imdb:

tab_romance_terror <- imdb %>%
  filter(ano >= 2010) %>%
  mutate(
    genero = case_when(
      stringr::str_detect(generos, "Romance") ~ "Romance",
      stringr::str_detect(generos, "Horror") ~ "Horror",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(genero)) %>%
  group_by(ano, genero) %>%
  summarise(receita_media = mean(receita, na.rm = TRUE))
tab_romance_terror 

## Essa tabela possui a receita média dos filmes de romance e terror nos anos de 2010 a 2016.

## Para apresentar essa tabela em uma reunião, por exemplo, pode ficar ser mais agradável 
## ter os anos nas colunas e não nas linhas. Para isso, basta utilizarmos a função pivot_wider().

tab_romance_terror %>% 
  pivot_wider(
    names_from = ano,
    values_from = receita_media
  )

#  List columns ----------------------------------------------------------------------------------------------------------------------------

## Um terceiro conceito de dados tidy é que cada célula da tabela possui um valor. No entanto, 
## quando estamos programando, muitas vezes vale apena abandonar essa definição e guardarmos
## objetos mais complexos nas células de uma tabela.

## Utilizando as chamadas list columns podemos guardar virtualmente qualquer objeto em nossas 
## tibbles, como gráficos, resultados de modelos ou até mesmo outras tabelas.

## Uma forma de trabalhar com list columns consiste em utilizarmos as funções

## - nest(): para criar uma list column;

## - unnest(): para desfazer uma list column.

## A forma mais simples de utilizarmos uma list column é aninhar a nossa base com relação 
## a uma variável.

imdb_nest <- imdb %>%
  group_by(ano) %>%
  nest() %>% 
  arrange(ano)

head(imdb_nest, 8)

## A base imdb_nest possui duas colunas ano e data e uma linha para cada ano. Na coluna data, 
## temos o restante da base imdb, recortada para cada um dos anos.

## Abaixo, acessamos os dados do único filme de 1916 (primeira linha da base imdb_nest).

imdb_nest$data[[1]]

## Imagine que queiramos fazer, para cada ano, um gráfico de dispersão da receita contra 
## o orçamento dos filmes lançados no ano.

## Com a base no formato de list columns, basta criarmos uma função para gerar o gráfico 
## e utilizarmos a função purrr::map().

## Abaixo, construímos a função fazer_grafico_dispersao(), que será aplicada a cada uma 
##das bases contidas na coluna data da base imdb_nest. Os gráficos, respectivamos a cada 
## ano, são salvos na coluna grafico.

fazer_grafico_dispersao <- function(tab) {
  tab %>%
    ggplot(aes(x = orcamento, y = receita)) +
    geom_point()
}

imdb_graficos <- imdb_nest %>% 
  mutate(
    grafico = purrr::map(data, fazer_grafico_dispersao)
  )

head(imdb_graficos, 6)

## Para acessar cada um dos gráficos, basta rodar o código abaixo.

imdb_graficos$grafico[[74]] # Pegando o gráfico referente ao ano de 2000

## Ou, escolhendo diretamente pelo ano

imdb_graficos %>% 
  filter(ano == 2000) %>% 
  pull(grafico)

## A função unnest() remove a estrutura de list column. Fazendo a operação abaixo, 
## voltamos para a base imdb original.

imdb_nest %>%
  unnest(cols = "data")

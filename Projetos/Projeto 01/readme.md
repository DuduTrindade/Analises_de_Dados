![](https://github.com/DuduTrindade/Analises_de_Dados/blob/main/Projetos/Projeto%2001/img/titulo.png)


## Introdução
Este projeto analisa um negócio de varejo fictício especializado em produtos eletrônicos, incluindo dispositivos móveis, computadores e acessórios tecnológicos. 
A empresa atende tanto clientes individuais quanto empresariais, operando através de uma plataforma online e uma rede de lojas físicas estrategicamente localizadas em 
diversas regiões e países. Com uma ampla gama de produtos e um alcance geográfico significativo, a empresa se dedica a oferecer soluções tecnológicas de alta qualidade 
para uma base de clientes diversificada. Retornar ao [início.](https://github.com/DuduTrindade/Analises_de_Dados/tree/main)

## Situação Problema
A empresa de varejo fictícia TechGlobal Solutions especializada em produtos eletrônicos está enfrentando múltiplos desafios que estão impactando a eficiência operacional e a 
rentabilidade. Com uma base de clientes diversificada e uma ampla gama de produtos distribuídos por várias regiões e países, a empresa precisa de insights detalhados para 
tomar decisões informadas. Esses insights são essenciais para entender melhor os clientes, otimizar o estoque, melhorar as estratégias de marketing, reduzir as devoluções e 
aumentar as vendas.

## Objetivo da Análise com SQL
A análise de dados utilizando SQL será fundamental para resolver esses problemas e fornecer insights valiosos que ajudam a aumentar as vendas de várias maneiras. 
As seguintes análises serão realizadas:
*	Análise de Clientes
*	Análise de Produtos e Vendas
*	Análise de Devoluções
*	Análise Geográfica
*	Análise de Performance das Lojas

Com base nesses insights, a empresa pode tomar decisões informadas para otimizar suas operações, melhorar a experiência do cliente e aumentar a lucratividade.

## Estrutura do Conjunto de Dados

O conjunto de dados é composto pelas seguintes tabelas:
*	Clientes: Contém informações demográficas dos clientes.
*	Devoluções: Registra as devoluções de produtos.
*	Itens: Detalha os itens vendidos em cada venda.
*	Localidades: Armazena informações geográficas das lojas.
*	Lojas: Contém informações sobre as lojas.
*	Produtos: Armazena informações sobre os produtos vendidos.
*	Vendas: Registra as vendas realizadas.

Neste projeto estou utilizando o Sistema de Gerenciamento de Banco de Dados (SGBD) SQL Server da Microsoft, mas você poderá utilizar qualquer outro SGBD relacional.
Abaixo segue o diagrama do banco chamado Vendas e seus respectivos relacionamentos.

![](https://github.com/DuduTrindade/Analises_de_Dados/blob/main/Projetos/Projeto%2001/img/DIAGRAMA%20VENDAS.png)

## Análises e Insights

### Análise de Clientes
**Pergunta 1**: Qual é a distribuição de clientes por estado civil?

~~~SQL

-- CTE para calcular a quantidade total de clientes por Estado Civil.
WITH Total_Estado_Civil AS
(
	SELECT 
		CASE
			WHEN Estado_Civil = 'C' THEN 'Solteiro(a)'
			ELSE 'Casado(a)'
		END	Estado_Civil,
		COUNT(*) AS [Total Estado Civil] -- Conta o número de clientes em cada estado civil.		
	FROM Clientes
	GROUP BY Estado_Civil
),

-- CTE para calcular o total geral de clientes na tabela.
Total_Clientes AS
(
	SELECT 
		COUNT(*) AS [Total Clientes]
	FROM Clientes 
)

-- Consulta principal para combinar os resultados das duas CTEs.
SELECT
	TE.Estado_Civil,
	TE.[Total Estado Civil],
	TC.[Total Clientes],
	-- Calcula a porcentagem de clientes por estado civil.
	(100.0 * [Total Estado Civil]) / [Total Clientes] AS [% Por Estado Civil]
FROM Total_Estado_Civil TE
CROSS JOIN Total_Clientes TC
~~~
![](https://github.com/DuduTrindade/Analises_de_Dados/blob/main/Projetos/Projeto%2001/img/pergunta%2001.png)

**Insight**: Identificar quais estados civis são mais comuns entre os clientes, permitindo segmentações específicas.

**Pergunta 2**: Quantos clientes temos em cada país?

~~~SQL
SELECT 
	L.País,
	COUNT(C.ID_Cliente) AS [Clientes Por País]
FROM Clientes C INNER JOIN Localidades L ON C.Id_Localidade = L.Id_Localidade
GROUP BY L.País
ORDER BY [Clientes Por País] DESC;
~~~

![](https://github.com/DuduTrindade/Analises_de_Dados/blob/main/Projetos/Projeto%2001/img/pergunta%2002.png)

**Insight**: Identificar a distribuição geográfica dos clientes pode ajudar a adaptar estratégias de marketing para diferentes regiões.

**Pergunta 3**: Qual é a distribuição de clientes por gênero em cada faixa etária?
~~~SQL
/*
Faixas etárias usadas na distribuição:
[1]	0-17 anos
[2]	18-25 anos
[3]	26-35 anos
[4]	36-45 anos
[5]	46-55 anos
[6]	56-65 anos
[7]	66 anos ou mais
*/
WITH CTE_Distribuicao_Genero (Genero, Faixa_Etaria)
AS
(
	SELECT 
		Genero,
		-- Calcula a faixa etária com base na diferença de anos entre a data de nascimento e a data atual.
		CASE 
			WHEN  DATEDIFF(YEAR, Data_Nascimento, GETDATE()) <= 17 THEN 1
			WHEN  DATEDIFF(YEAR, Data_Nascimento, GETDATE()) BETWEEN 18 AND 25 THEN 2
			WHEN  DATEDIFF(YEAR, Data_Nascimento, GETDATE()) BETWEEN 26 AND 35 THEN 3
			WHEN  DATEDIFF(YEAR, Data_Nascimento, GETDATE()) BETWEEN 36 AND 45 THEN 4
			WHEN  DATEDIFF(YEAR, Data_Nascimento, GETDATE()) BETWEEN 46 AND 55 THEN 5
			WHEN  DATEDIFF(YEAR, Data_Nascimento, GETDATE()) BETWEEN 56 AND 65 THEN 6
			ELSE  7
		END Faixa_Etaria
	FROM Clientes
)
SELECT
	Genero,
	CASE
		WHEN Faixa_Etaria = 1 THEN '0-17'  -- Faixa 1 corresponde ao intervalo '0-17 anos'.
		WHEN Faixa_Etaria = 2 THEN '18-25' -- Faixa 2 corresponde ao intervalo '18-25 anos'.
		WHEN Faixa_Etaria = 3 THEN '26-35' -- Faixa 3 corresponde ao intervalo '26-35 anos'.
		WHEN Faixa_Etaria = 4 THEN '36-45' -- Faixa 4 corresponde ao intervalo '36-45 anos'.
		WHEN Faixa_Etaria = 5 THEN '46-55' -- Faixa 5 corresponde ao intervalo '46-55 anos'.
		WHEN Faixa_Etaria = 6 THEN '56-65'  -- Faixa 6 corresponde ao intervalo '56-65 anos'.
		ELSE '66+'						 -- Faixa 7 corresponde ao intervalo '66 anos ou mais'.
	END	Faixa_Etaria,
	COUNT(Faixa_Etaria) AS Total_Genero
FROM CTE_Distribuicao_Genero
GROUP BY Faixa_Etaria, Genero
ORDER BY Faixa_Etaria, Total_Genero DESC;

~~~

![](https://github.com/DuduTrindade/Analises_de_Dados/blob/main/Projetos/Projeto%2001/img/pergunta%2003.png)

**Insight**: Entender a distribuição de gênero em diferentes faixas etárias pode ajudar a criar campanhas de marketing mais direcionadas.


**Pergunta 4**: Qual é o nível educacional mais comum entre os clientes?
~~~SQL
SELECT 
	Nivel_Escolar AS Nivel_Educacional,
	COUNT(*) AS QTDE
FROM Clientes
GROUP BY Nivel_Escolar
ORDER BY QTDE DESC; 
~~~

![](https://github.com/DuduTrindade/Analises_de_Dados/blob/main/Projetos/Projeto%2001/img/pergunta%2004.png)

**Insight**: Entender o nível educacional pode ajudar a criar campanhas de marketing mais eficazes e ajustar a linguagem e o tom das comunicações.

### Análise de Produtos e Vendas

**Pergunta 5**: Quais são os produtos mais vendidos?

~~~SQL
SELECT TOP 10
	P.Produto AS Nome,
	COUNT(I.Qtd_Vendida) AS Qtde_Vendas,
	SUM(I.Qtd_Vendida * P.Preço_Unitario) AS Total
 FROM Produtos P INNER JOIN Itens I ON P.SKU = I.SKU
GROUP BY P.Produto	
ORDER BY Total DESC;
~~~
![](https://github.com/DuduTrindade/Analises_de_Dados/blob/main/Projetos/Projeto%2001/img/pergunta%2005.png)

**Insight**: Identificar os produtos que têm maior demanda para otimizar o estoque e promover os itens mais populares.


**Pergunta 6**: Qual é a receita total por marca?

~~~SQL
SELECT 
	P.Marca,
	SUM(P.Preço_Unitario * I.Qtd_Vendida) AS [Total Vendido]
FROM Produtos P INNER JOIN Itens I ON P.SKU = I.SKU
GROUP BY P.Marca
ORDER BY 2 DESC;	
~~~

![](https://github.com/DuduTrindade/Analises_de_Dados/blob/main/Projetos/Projeto%2001/img/pergunta%2006.png)


**Insight**: Calcular a receita total gerada por cada marca para identificar os produtos mais lucrativos.


**Pergunta 7**: Qual é a receita média por venda?

~~~SQL
SELECT
 -- Calcula a média da receita total de cada venda (Total_Vendas), obtida na subconsulta.
	AVG(Total_Vendas) AS Receita_Média
FROM (
-- Subconsulta para calcular a receita total de cada venda
	SELECT 
		V.Id_Venda,
		SUM(P.Preço_Unitario * I.Qtd_Vendida) AS Total_Vendas
	FROM Vendas V 
	INNER JOIN Itens I ON V.Id_Venda = I.Id_Venda
	INNER JOIN Produtos P ON P.SKU = I.SKU
	GROUP BY V.Id_Venda
) AS Receita_Vendas_Media;
~~~

![](https://github.com/DuduTrindade/Analises_de_Dados/blob/main/Projetos/Projeto%2001/img/pergunta%2007.png)

**Insight**: Calcular a receita média por venda ajuda a avaliar o ticket médio e otimizar estratégias de precificação.


**Pergunta 8**: Quais produtos têm a maior margem de lucro?

~~~SQL
SELECT 
	Produto,
	Preço_unitario,
	Custo_Unitario,
	(Preço_unitario - Custo_Unitario) AS 'Margem_Lucro(R$)',
	((Preço_unitario - Custo_Unitario) / Preço_unitario) * 100 AS 'Margem_Lucro(%)'
FROM PRODUTOS
WHERE ((Preço_unitario - Custo_Unitario) / Preço_unitario) * 100 >= 80
ORDER BY 5 DESC;
~~~

![](https://github.com/DuduTrindade/Analises_de_Dados/blob/main/Projetos/Projeto%2001/img/pergunta%2008.png)


**Insight**: Identificar produtos com maior margem de lucro pode ajudar a focar em produtos mais rentáveis.

### Análise de Devoluções

**Pergunta 9**: Qual é o motivo de devolução mais comum?

~~~SQL
SELECT 
	Motivo_Devolucao,
	COUNT(*) AS Qtde_Totais_Devolucao
FROM Devolucoes
GROUP BY Motivo_Devolucao
ORDER BY Qtde_Totais_Devolucao DESC;
~~~
![](https://github.com/DuduTrindade/Analises_de_Dados/blob/main/Projetos/Projeto%2001/img/pergunta%2009.png)

**Insight**: Analisar os motivos das devoluções para identificar problemas comuns com produtos ou processos de venda.

**Pergunta 10**: Quais produtos tem as maiores quantidades de devoluções?

~~~SQL
SELECT TOP 20
	P.Produto,
	COUNT(D.Qtd_Devolvida) AS Quant_Devolucoes
FROM Devolucoes D INNER JOIN Produtos P ON D.SKU = P.SKU
GROUP BY P.Produto
ORDER BY Quant_Devolucoes DESC;
~~~

![](https://github.com/DuduTrindade/Analises_de_Dados/blob/main/Projetos/Projeto%2001/img/pergunta%2010.png)

**Insight**: Identificar produtos que são frequentemente devolvidos, o que pode indicar problemas de qualidade ou expectativas dos clientes.

**Pergunta 11**: Quais são as maiores taxas de devoluções por produto?

~~~SQL
-- -- CTE para calcular o total de devoluções por produto
WITH Devolucoes_Totais AS (
	SELECT
		D.SKU,
		SUM(D.Qtd_Devolvida) AS Totais_Devolucao
	FROM Devolucoes D 
	GROUP BY D.SKU
),

-- CTE para calcular o total de vendas por produto
Vendas_Totais AS (
	SELECT
		I.SKU,
		SUM(I.Qtd_Vendida) AS Total_Vendido
	FROM Itens I INNER JOIN Vendas V ON V.Id_Venda = I.Id_Venda
	GROUP BY I.SKU
)

---- Seleção principal das 20 produtos com a maior taxa de devolução
SELECT TOP 20
	P.Produto,
	VT.Total_Vendido,
	DT.Totais_Devolucao,
	(SUM(DT.Totais_Devolucao) * 100.0 / SUM(VT.Total_Vendido)) AS [Taxa_Devolucao%]
FROM Produtos P 
INNER JOIN Vendas_Totais VT ON P.SKU = VT.SKU
INNER JOIN Devolucoes_Totais DT ON DT.SKU = P.SKU
GROUP BY P.Produto,VT.Total_Vendido, DT.Totais_Devolucao
ORDER BY [Taxa_Devolucao%] DESC;
~~~
![](https://github.com/DuduTrindade/Analises_de_Dados/blob/main/Projetos/Projeto%2001/img/pergunta%2011.png)

**Insight**: Calcular a taxa de devolução pode ajudar a identificar problemas com produtos específicos.

>0**Pergunta 12**: Qual loja tem a maior taxa de devoluções?

~~~SQL
-- CTE para calcular o total de devoluções por loja
WITH Devolucoes_Totais AS (
	SELECT
		D.ID_Loja,
		SUM(D.Qtd_Devolvida) AS Totais_Lojas_Devolucao
	FROM Devolucoes D 
	GROUP BY D.ID_Loja
),

-- CTE para calcular o total de vendas por loja
Vendas_Totais AS (
	SELECT
		V.ID_Loja,
		SUM(I.Qtd_Vendida) AS Total_Lojas_Vendas
	FROM Itens I INNER JOIN Vendas V ON V.Id_Venda = I.Id_Venda
	GROUP BY V.ID_Loja
)

-- Seleção principal das 20 lojas com a maior taxa de devolução
SELECT TOP 20
	L.ID_Loja,
	Total_Lojas_Vendas,
	Totais_Lojas_Devolucao,
	DT.Totais_Lojas_Devolucao * 100.0 / VT.Total_Lojas_Vendas AS [Taxa_Devolucao_por_Loja%]
FROM Lojas L
INNER JOIN Vendas_Totais VT ON VT.ID_Loja = L.ID_Loja
INNER JOIN Devolucoes_Totais DT ON DT.ID_Loja = L.ID_Loja
GROUP BY L.ID_Loja, Totais_Lojas_Devolucao, Total_Lojas_Vendas
ORDER BY [Taxa_Devolucao_por_Loja%] DESC;
~~~

![](https://github.com/DuduTrindade/Analises_de_Dados/blob/main/Projetos/Projeto%2001/img/pergunta%2012.png)

**Insight**: Identificar lojas com altas taxas de devolução pode apontar para problemas específicos de atendimento ou produto.




































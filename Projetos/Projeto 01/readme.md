![](https://github.com/DuduTrindade/Analises_de_Dados/blob/main/Projetos/Projeto%2001/img/titulo.png)


## Introdução
Este projeto analisa um negócio de varejo fictício especializado em produtos eletrônicos, incluindo dispositivos móveis, computadores e acessórios tecnológicos. 
A empresa atende tanto clientes individuais quanto empresariais, operando através de uma plataforma online e uma rede de lojas físicas estrategicamente localizadas em 
diversas regiões e países. Com uma ampla gama de produtos e um alcance geográfico significativo, a empresa se dedica a oferecer soluções tecnológicas de alta qualidade 
para uma base de clientes diversificada.

## Situações Problemas
A empresa de varejo fictícia TechGlobal Solutions especializada em produtos eletrônicos está enfrentando múltiplos desafios que estão impactando a eficiência operacional e a 
rentabilidade. Com uma base de clientes diversificada e uma ampla gama de produtos distribuídos por várias regiões e países, a empresa precisa de insights detalhados para 
tomar decisões informadas. Esses insights são essenciais para entender melhor os clientes, otimizar o estoque, melhorar as estratégias de marketing, reduzir as devoluções e 
aumentar as vendas.

## Objetivo da Análise de Dados (SQL)
A análise de dados, utilizando SQL, pode ser fundamental para resolver esses problemas e fornecer insights valiosos que ajudam a aumentar as vendas de várias maneiras. 
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
WITH CTE_Distribuicao_EstadoCivil
AS
(
	SELECT 
		CASE WHEN Estado_Civil = 'C' THEN 'Solteiro(a)'
			ELSE 'Casado(a)'
		END	Estado_Civil,
		COUNT(*) AS [Total Estado Civil],
		(SELECT COUNT(*) FROM Clientes) AS [Total Clientes]
	FROM Clientes
	GROUP BY Estado_Civil
)
SELECT
	*,
	(100.0 * [Total Estado Civil]) / [Total Clientes] AS [% Por Estado Civil]
FROM CTE_Distribuicao_EstadoCivil
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
		WHEN Faixa_Etaria = 1 THEN '0-17'
		WHEN Faixa_Etaria = 2 THEN '18-25'
		WHEN Faixa_Etaria = 3 THEN '26-35'
		WHEN Faixa_Etaria = 4 THEN '36-45'
		WHEN Faixa_Etaria = 5 THEN '46-55'
		WHEN Faixa_Etaria = 6 THEN '56-65'
		ELSE '66+'
	END	Faixa_Etaria,
	COUNT(Faixa_Etaria) AS Total_Genero
FROM CTE_Distribuicao_Genero
GROUP BY Faixa_Etaria, Genero
ORDER BY Faixa_Etaria,
		 Total_Genero DESC;
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








































-- ############# Análise de Clientes #################
-- Pergunta 1: Qual é a distribuição de clientes por estado civil?

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

-- Pergunta 2: Quantos clientes temos em cada país?

SELECT 
	L.País,
	COUNT(C.ID_Cliente) AS [Clientes Por País]
FROM Clientes C INNER JOIN Localidades L ON C.Id_Localidade = L.Id_Localidade
GROUP BY L.País
ORDER BY [Clientes Por País] DESC;

-- Pergunta 3: Qual é a distribuição de clientes por gênero em cada faixa etária?

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

-- Pergunta 4: Qual é o nível educacional mais comum entre os clientes?

SELECT 
	Nivel_Escolar AS Nivel_Educacional,
	COUNT(*) AS QTDE
FROM Clientes
GROUP BY Nivel_Escolar
ORDER BY QTDE DESC; 


-- ############# Análise de Produtos e Vendas #################

-- Pergunta 5: Quais são os produtos mais vendidos?

 SELECT TOP 10
	P.Produto AS Nome,
	COUNT(I.Qtd_Vendida) AS Qtde_Vendas,
	SUM(I.Qtd_Vendida * P.Preço_Unitario) AS Total
 FROM Produtos P INNER JOIN Itens I ON P.SKU = I.SKU
GROUP BY P.Produto	
ORDER BY Total DESC;

--Pergunta 6: Qual é a receita total por marca?
SELECT 
	P.Marca,
	SUM(P.Preço_Unitario * I.Qtd_Vendida) AS [Total Vendido]
FROM Produtos P INNER JOIN Itens I ON P.SKU = I.SKU
GROUP BY P.Marca
ORDER BY 2 DESC;

-- Pergunta 7: Qual é a receita média por venda?

SELECT
	AVG(Total_Vendas) AS Receita_Média
FROM (
	SELECT 
		V.Id_Venda,
		SUM(P.Preço_Unitario * I.Qtd_Vendida) AS Total_Vendas
	FROM Vendas V 
	INNER JOIN Itens I ON V.Id_Venda = I.Id_Venda
	INNER JOIN Produtos P ON P.SKU = I.SKU
	GROUP BY V.Id_Venda
) AS Receita_Vendas_Media;


--  Pergunta 8: Quais produtos têm a margem de lucro acima de 80%?

SELECT 
	Produto,
	Preço_unitario,
	Custo_Unitario,
	(Preço_unitario - Custo_Unitario) AS 'Margem_Lucro(R$)',
	((Preço_unitario - Custo_Unitario) / Preço_unitario) * 100 AS 'Margem_Lucro(%)'
FROM PRODUTOS
WHERE ((Preço_unitario - Custo_Unitario) / Preço_unitario) * 100 >= 80
ORDER BY 5 DESC;

-- ############# Análise de Devoluções #################

--Pergunta 9: Qual é o motivo de devolução mais comum?

SELECT 
	Motivo_Devolucao,
	COUNT(*) AS Qtde_Totais_Devolucao
FROM Devolucoes
GROUP BY Motivo_Devolucao
ORDER BY Qtde_Totais_Devolucao DESC;

-- Pergunta 10: Quais produtos tem a maiores quantidades de devoluções?

SELECT TOP 20
	P.Produto,
	SUM(D.Qtd_Devolvida) AS Quant_Devolucoes
FROM Devolucoes D INNER JOIN Produtos P ON D.SKU = P.SKU
GROUP BY P.Produto
ORDER BY Quant_Devolucoes DESC;

-- Pergunta 11: Qual é a taxa de devolução por produto?
WITH Devolucoes_Totais AS (
	SELECT
		D.SKU,
		SUM(D.Qtd_Devolvida) AS Totais_Devolucao
	FROM Devolucoes D 
	GROUP BY D.SKU
),
Vendas_Totais AS (
	SELECT
		I.SKU,
		SUM(I.Qtd_Vendida) AS Total_Vendido
	FROM Itens I INNER JOIN Vendas V ON V.Id_Venda = I.Id_Venda
	GROUP BY I.SKU
)
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

-- Pergunta 12: Qual loja tem a maior taxa de devoluções?

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


















































































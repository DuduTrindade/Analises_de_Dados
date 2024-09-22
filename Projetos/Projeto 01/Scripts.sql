
-- ############# An�lise de Clientes #################
-- Pergunta 1: Qual � a distribui��o de clientes por estado civil?

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

-- Pergunta 2: Quantos clientes temos em cada pa�s?

SELECT 
	L.Pa�s,
	COUNT(C.ID_Cliente) AS [Clientes Por Pa�s]
FROM Clientes C INNER JOIN Localidades L ON C.Id_Localidade = L.Id_Localidade
GROUP BY L.Pa�s
ORDER BY [Clientes Por Pa�s] DESC;

-- Pergunta 3: Qual � a distribui��o de clientes por g�nero em cada faixa et�ria?

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

-- Pergunta 4: Qual � o n�vel educacional mais comum entre os clientes?

SELECT 
	Nivel_Escolar AS Nivel_Educacional,
	COUNT(*) AS QTDE
FROM Clientes
GROUP BY Nivel_Escolar
ORDER BY QTDE DESC; 


-- ############# An�lise de Produtos e Vendas #################

-- Pergunta 5: Quais s�o os produtos mais vendidos?

 SELECT TOP 10
	P.Produto AS Nome,
	COUNT(I.Qtd_Vendida) AS Qtde_Vendas,
	SUM(I.Qtd_Vendida * P.Pre�o_Unitario) AS Total
 FROM Produtos P INNER JOIN Itens I ON P.SKU = I.SKU
GROUP BY P.Produto	
ORDER BY Total DESC;

--Pergunta 6: Qual � a receita total por marca?
SELECT 
	P.Marca,
	SUM(P.Pre�o_Unitario * I.Qtd_Vendida) AS [Total Vendido]
FROM Produtos P INNER JOIN Itens I ON P.SKU = I.SKU
GROUP BY P.Marca
ORDER BY 2 DESC;

-- Pergunta 7: Qual � a receita m�dia por venda?

SELECT
	AVG(Total_Vendas) AS Receita_M�dia
FROM (
	SELECT 
		V.Id_Venda,
		SUM(P.Pre�o_Unitario * I.Qtd_Vendida) AS Total_Vendas
	FROM Vendas V 
	INNER JOIN Itens I ON V.Id_Venda = I.Id_Venda
	INNER JOIN Produtos P ON P.SKU = I.SKU
	GROUP BY V.Id_Venda
) AS Receita_Vendas_Media;


--  Pergunta 8: Quais produtos t�m a margem de lucro acima de 80%?

SELECT 
	Produto,
	Pre�o_unitario,
	Custo_Unitario,
	(Pre�o_unitario - Custo_Unitario) AS 'Margem_Lucro(R$)',
	((Pre�o_unitario - Custo_Unitario) / Pre�o_unitario) * 100 AS 'Margem_Lucro(%)'
FROM PRODUTOS
WHERE ((Pre�o_unitario - Custo_Unitario) / Pre�o_unitario) * 100 > 40
ORDER BY 5 DESC;









































































































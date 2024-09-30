
-- ############# An�lise de Clientes #################
-- Pergunta 1: Qual � a distribui��o de clientes por estado civil?

-- CTE para calcular a quantidade total de clientes por Estado Civil.
WITH Total_Estado_Civil AS
(
	SELECT 
		CASE
			WHEN Estado_Civil = 'C' THEN 'Solteiro(a)'
			ELSE 'Casado(a)'
		END	Estado_Civil,
		COUNT(*) AS [Total Estado Civil] -- Conta o n�mero de clientes em cada estado civil.		
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


-- Pergunta 2: Quantos clientes temos em cada pa�s?

SELECT 
	L.Pa�s,
	COUNT(C.ID_Cliente) AS [Clientes Por Pa�s]
FROM Clientes C INNER JOIN Localidades L ON C.Id_Localidade = L.Id_Localidade
GROUP BY L.Pa�s
ORDER BY [Clientes Por Pa�s] DESC;

-- Pergunta 3: Qual � a distribui��o de clientes por g�nero em cada faixa et�ria?

/*
Faixas et�rias usadas na distribui��o:
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
		-- Calcula a faixa et�ria com base na diferen�a de anos entre a data de nascimento e a data atual.
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
 -- Calcula a m�dia da receita total de cada venda (Total_Vendas), obtida na subconsulta.
	AVG(Total_Vendas) AS Receita_M�dia
FROM (
-- Subconsulta para calcular a receita total de cada venda
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
WHERE ((Pre�o_unitario - Custo_Unitario) / Pre�o_unitario) * 100 >= 80
ORDER BY 5 DESC;

-- ############# An�lise de Devolu��es #################

--Pergunta 9: Qual � o motivo de devolu��o mais comum?

SELECT 
	Motivo_Devolucao,
	COUNT(*) AS Qtde_Totais_Devolucao
FROM Devolucoes
GROUP BY Motivo_Devolucao
ORDER BY Qtde_Totais_Devolucao DESC;

-- Pergunta 10: Quais produtos tem a maiores quantidades de devolu��es?

SELECT TOP 20
	P.Produto,
	SUM(D.Qtd_Devolvida) AS Quant_Devolucoes
FROM Devolucoes D INNER JOIN Produtos P ON D.SKU = P.SKU
GROUP BY P.Produto
ORDER BY Quant_Devolucoes DESC;

-- Pergunta 11: Qual � a taxa de devolu��o por produto?

-- -- CTE para calcular o total de devolu��es por produto
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

---- Sele��o principal das 20 produtos com a maior taxa de devolu��o
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

-- Pergunta 12: Qual loja tem a maior taxa de devolu��es?

-- CTE para calcular o total de devolu��es por loja
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

-- Sele��o principal das 20 lojas com a maior taxa de devolu��o
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

-- Pergunta 13: Qual � a receita total de vendas por pa�s ao longo dos anos?

-- CTE (Common Table Expression) para agrega��o de vendas por ano e pa�s
WITH Vendas_agregadas AS
(
	SELECT 
		YEAR(V.Data_Venda) AS Ano,
		LC.Pa�s,

		-- Soma o pre�o unit�rio dos produtos vendidos para calcular o total de vendas no ano
		SUM(P.Pre�o_Unitario) AS Total_Vendas_Ano
	FROM Vendas V
	INNER JOIN Itens I ON V.Id_Venda = I.Id_Venda
	INNER JOIN Lojas L ON L.ID_Loja = V.ID_Loja
	INNER JOIN Localidades LC ON LC.ID_Localidade = L.id_Localidade
	INNER JOIN Produtos P ON P.SKU = I.SKU
	GROUP BY YEAR(V.Data_Venda), LC.Pa�s
	
)
-- Seleciona os resultados da CTE para realizar c�lculos adicionais
SELECT
	Ano,
	Pa�s,
	Total_Vendas_Ano AS Total_Ano_Atual,

	-- Fun��o LAG usada para pegar o total de vendas do ano anterior
	LAG(Total_Vendas_Ano, 1, Total_Vendas_Ano) OVER (PARTITION BY Pa�s ORDER BY Ano) AS Total_Ano_Anterior,

	-- C�lculo do crescimento percentual ano a ano (YoY)
	-- (Total_Ano_Atual / Total_Ano_Anterior) - 1 indica a varia��o percentual de crescimento
	(Total_Vendas_Ano / LAG(Total_Vendas_Ano, 1, Total_Vendas_Ano) OVER (PARTITION BY Pa�s ORDER BY Ano) -1) AS Crescimento_Percentual
FROM Vendas_agregadas
ORDER BY Ano, Pa�s

-- Pergunta 14: Qual � a m�dia de vendas mensais por continente?

-- Seleciona o continente e a m�dia mensal de vendas
SELECT
	Mensal_Vendas.Continente, -- Seleciona o continente calculado na subconsulta
	AVG(Mensal_Vendas.Total_Vendas_Mensal) AS Media_Mensal_Vendas -- Calcula a m�dia de vendas mensais por continente
FROM (

	-- Subconsulta para calcular o total de vendas mensais por continente
	SELECT 
		LC.Continente,
		YEAR(V.Data_Venda) AS Ano,
		MONTH(V.Data_Venda) AS Mes,
		SUM(I.Qtd_Vendida * P.Pre�o_Unitario) AS Total_Vendas_Mensal
	FROM Vendas V 
	INNER JOIN Itens I ON V.Id_Venda = I.Id_Venda
	INNER JOIN Produtos P ON P.SKU = I.SKU
	INNER JOIN Lojas L ON L.ID_Loja = V.ID_Loja
	INNER JOIN Localidades LC ON LC.ID_Localidade = L.id_Localidade
	GROUP BY LC.Continente, YEAR(V.Data_Venda), MONTH(V.Data_Venda) 
) AS Mensal_Vendas 
GROUP BY Mensal_Vendas.Continente;

-- Pergunta 15: Qual � a m�dia de devolu��es por pa�s duarante os anos?
WITH Media_Devolucao_Pais AS
(
	SELECT 
		LC.Pa�s AS Pais,
		YEAR(D.Data_Devolucao) AS Ano,
		SUM(D.Qtd_Devolvida) AS Qtde_Devolvida
	FROM Devolucoes D
	INNER JOIN Lojas L ON L.ID_Loja = D.ID_Loja
	INNER JOIN Localidades LC ON LC.ID_Localidade = L.id_Localidade
	GROUP BY LC.Pa�s, YEAR(D.Data_Devolucao)
)

SELECT
	MDP.Pais,
	AVG(MDP.Qtde_Devolvida) AS Media_Devolucoes
FROM Media_Devolucao_Pais MDP
GROUP BY MDP.Pais;

-- Pergunta 16: Qual � a receita total de vendas por continente e tipo de loja?

WITH Receita_Total_Continente AS
(
	SELECT
		LC.Continente,
		L.Tipo,
		SUM(I.Qtd_Vendida * P.Pre�o_Unitario)AS Total_Continente
	FROM Vendas V
	INNER JOIN Itens I ON I.Id_Venda = V.Id_Venda
	INNER JOIN Produtos P ON P.SKU = I.SKU
	INNER JOIN Lojas L ON L.ID_Loja = V.ID_Loja
	INNER JOIN Localidades LC ON LC.ID_Localidade = L.id_Localidade
	GROUP BY LC.Continente, L.Tipo
)
SELECT 
	 R.Continente,
	 R.Tipo,	 
	 FORMAT(R.Total_Continente,	'C0') AS Valor_Tipo_Loja,
	 FORMAT(SUM(R.Total_Continente) OVER(PARTITION BY R.Continente), 'C0') AS Total_Continente	
FROM Receita_Total_Continente R











































SELECT 
	-- -------------------------------------------------------------------------------------------------------------------------------------------------
	-- BASICO
	-- -------------------------------------------------------------------------------------------------------------------------------------------------
	FP.COD_FORNECEDOR
	,CF.DESCRICAO AS NO_FORNECEDOR
	,FP.COD_PRODUTO
	,CP.DESCRICAO AS NO_PRODUTO
	-- -------------------------------------------------------------------------------------------------------------------------------------------------
	-- CRITICA DE CENTRALIZACAO PARA A ORBIS
	-- -------------------------------------------------------------------------------------------------------------------------------------------------
	,convert(int,AFP.COD_FORNECEDOR) AS FORNECEDOR_CENTRALIZACAO_ORBIS
	,ISNULL(CF1.DESCRICAO,'') AS NO_FORNECEDOR_CENTRALIZACAO_ORBIS
	,(CASE
		WHEN afp.ModelArmazenagem = 0 THEN 'Direto'
		WHEN afp.ModelArmazenagem = 1 THEN 'CrossDocking'
		WHEN afp.ModelArmazenagem = 2 THEN 'Armazenagem'
		WHEN afp.ModelArmazenagem = 3 THEN 'PickingUnitario'
	END) AS TIPO_ABASTECIMENTO_ORBIS
	,convert(int,AFP.FORNECEDOR_COMPRAS) as FORNECEDOR_PRINCIPAL_COMPRA
	,ISNULL(CF2.DESCRICAO,'') AS NO_FORNECEDOR_PRINCIPAL_COMPRA
	,(CASE
		WHEN AFP.COD_FORNECEDOR = '' then 'Produto não está centralizado para CD'
		WHEN AFP.COD_FORNECEDOR = 18055 then 'Fornecedor de centralização para a loja 5 não pode ser 18055'
		WHEN AFP.COD_FORNECEDOR <> AFP.FORNECEDOR_COMPRAS THEN 'Fornecedor principal diferente do fornecedor de centralização - Não gerará pedido'
		ELSE ''
	END) AS ERRO_CENTRALIZACAO_ORBIS
	-- -------------------------------------------------------------------------------------------------------------------------------------------------
	-- CRITICA DE CENTRALIZACAO PARA AS LOJAS
	-- -------------------------------------------------------------------------------------------------------------------------------------------------
	,convert(int,AFP2.COD_FORNECEDOR) AS FORNECEDOR_CENTRALIZACAO_LOJAS
	,CF3.DESCRICAO AS NO_FORNECEDOR_CENTRALIZACAO_LOJAS
	,(CASE
		WHEN AFP2.ModelArmazenagem = 0 THEN 'Direto'
		WHEN AFP2.ModelArmazenagem = 1 THEN 'CrossDocking'
		WHEN AFP2.ModelArmazenagem = 2 THEN 'Armazenagem'
		WHEN AFP2.ModelArmazenagem = 3 THEN 'PickingUnitario'
	END) AS TIPO_ABASTECIMENTO_LOJAS
	,(CASE
		WHEN AFP2.COD_FORNECEDOR = '' then 'Produto não centralizado para loja'
		WHEN AFP2.COD_FORNECEDOR <> 18055 then 'Se produto centralizado, fornecedor de centralização para lojas deve ser 18055'
		ELSE ''
	END) AS ERRO_CENTRALIZACAO_LOJAS
	-- -------------------------------------------------------------------------------------------------------------------------------------------------
	--
	-- -------------------------------------------------------------------------------------------------------------------------------------------------
FROM
	BI.DBO.BI_CAD_FORNECEDOR_PRODUTO AS FP
	INNER JOIN BI.dbo.BI_CAD_PRODUTO AS CP
		ON FP.COD_PRODUTO = CP.COD_PRODUTO
	INNER JOIN BI.dbo.BI_CAD_FORNECEDOR AS CF
		ON FP.COD_FORNECEDOR = CF.COD_FORNECEDOR
	--loja orbis
	LEFT JOIN AX2009_INTEGRACAO.DBO.TAB_PRODUTO_FORNECEDOR_PREFERENCIAL AS AFP	
		ON 1=1
		AND AFP.COD_LOJA IN (5)
		AND AFP.COD_PRODUTO = FP.COD_PRODUTO	
	LEFT JOIN BI.DBO.BI_CAD_FORNECEDOR AS CF1
		ON AFP.COD_Fornecedor = CF1.COD_FORNECEDOR						
	LEFT JOIN BI.DBO.BI_CAD_FORNECEDOR AS CF2
		ON AFP.FORNECEDOR_COMPRAS = CF2.COD_FORNECEDOR	
	--demais lojas
	LEFT JOIN AX2009_INTEGRACAO.DBO.TAB_PRODUTO_FORNECEDOR_PREFERENCIAL AS AFP2	
		ON 1=1
		AND AFP2.COD_LOJA IN (1)
		AND AFP2.COD_PRODUTO = FP.COD_PRODUTO	
	LEFT JOIN BI.DBO.BI_CAD_FORNECEDOR AS CF3
		ON AFP2.COD_Fornecedor = CF3.COD_FORNECEDOR						
	LEFT JOIN BI.DBO.BI_CAD_FORNECEDOR AS CF4
		ON AFP2.FORNECEDOR_COMPRAS = CF4.COD_FORNECEDOR	
WHERE 1=1
	AND CP.FORA_LINHA = 'N'
	AND FP.COD_FORNECEDOR IN (241,623,683,1022,1789,2273,14682,16146,16517,17035,17575,17748,17761,18154,18374,62379,100060,100093,101613,101689,101870,102639,102733,102778,102902,103014,103211,103265,103419,103922,104073,104267,104451,104454,104482,104486,104489,104514,104541,104550,104568,75,2419,100091,103517,104357,542,104382,103266,19,2524,14593,16482,17543,17473,18115,2265,14680,104099,100454,104147,104242,104342,104273,205,104377,103425,2210,102966,104181,100147,101497,101670,102307,102364,103030,103336,104446,104263,16188,13970,14185,104612,104264,104355,104601,104379,104605,104098,104407,103427,104207,18123,102747,104351,18193,104312,6,458,643,15125,1583,1887,2214,2346,13912,13977,14450,16274,16481,16904,16946,17763,17797,17992,18126,18359,18438,101636,101859,101949,101979,101987,102316,102382,102572,102667,102751,103053,103095,103241,103395,103460,103683,103704,104004,104039,104090,104093,104109,104111,104170,2084,104205,104224,104230,104231,104261,104272,104346,104347,104356,104381,104383,104409,104440,104441,104534,14103,15198,14325,101714,15351)
	AND FP.COD_FORNECEDOR = 623
ORDER BY
	FP.COD_FORNECEDOR
	,FP.COD_PRODUTO
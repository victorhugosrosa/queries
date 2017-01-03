SELECT
	CP.COD_PRODUTO		
	,CP.DESCRICAO AS NO_PRODUTO
	,CP.FORA_LINHA
	
	,BI.dbo.fn_FormataVlr_Excel(PV_05.VLR_VENDA) AS PV_05
	,PV_05.COD_USUARIO AS USER_PV_05
	,PV_05.NO_COMPRADOR as NOME_PV_05
	,PV_05.DTA_GRAVACAO AS DATA_GRAVACAO_PV_05

	,BI.dbo.fn_FormataVlr_Excel(PV_29.VLR_VENDA) AS PV_29
	,PV_29.COD_USUARIO AS USER_PV_29
	,PV_29.NO_COMPRADOR as NOME_PV_29
	,PV_29.DTA_GRAVACAO AS DATA_GRAVACAO_PV_29
	

FROM
	BI.dbo.BI_CAD_PRODUTO AS CP
	-- -------------------------------------------------
	--
	-- -------------------------------------------------
	LEFT JOIN
	(	
		select  
			COD_PRODUTO
			,VALOR as VLR_VENDA
			,DTA_GRAVACAO
			,DESCRICAO
			,COD_USUARIO
			,NO_COMPRADOR
		from (
			select PV.COD_PRODUTO
				  ,PV.VALOR
				  ,PV.DTA_GRAVACAO
				  ,PV.DTA_INI
				  ,PV.DTA_FIM
				  ,PV.DESCRICAO
				  ,PV.COD_USUARIO
				  ,CC.NO_COMPRADOR
				  ,RANK() over (partition by cod_loja, COD_PRODUTO ORDER BY DTA_INI DESC) AS SEQ
			from BI.dbo.BI_PRECO_VENDA AS PV with (NOLOCK) 
			LEFT JOIN BI.dbo.COMPRAS_CAD_COMPRADOR AS CC
				ON 1=1
				AND PV.COD_USUARIO = CC.COD_USUARIO
			where 1 = 1
			and cast(PV.[DTA_INI] as DATE) <= CAST(getdate() as DATE) 
			and cast(PV.[DTA_FIM] as DATE) >= CAST(getdate() as DATE) 
			and PV.COD_PRODUTO <> 0 
			and PV.TIPO = 0
			and PV.inativo is null
			And PV.COD_LOJA = 5
			AND PV.COD_PRODUTO IN (SELECT DISTINCT COD_PRODUTO FROM CADASTRO_CAD_PRODUTO_METADADOS TPM WHERE COD_METADADO = 4 AND VLR_METADADO = 1)
			) as TAB
		where 1 = 1
			and SEQ = 1
	) AS PV_05
		ON CP.COD_PRODUTO = PV_05.COD_PRODUTO
	-- -------------------------------------------------
	--
	-- -------------------------------------------------
	LEFT JOIN
	(	
		select  
			COD_PRODUTO
			,VALOR as VLR_VENDA
			,DTA_GRAVACAO
			,DESCRICAO
			,COD_USUARIO
			,NO_COMPRADOR
		from (
			select PV.COD_PRODUTO
				  ,PV.VALOR
				  ,PV.DTA_GRAVACAO
				  ,PV.DTA_INI
				  ,PV.DTA_FIM
				  ,PV.DESCRICAO
				  ,PV.COD_USUARIO
				  ,CC.NO_COMPRADOR
				  ,RANK() over (partition by cod_loja, COD_PRODUTO ORDER BY DTA_INI DESC) AS SEQ
			from BI.dbo.BI_PRECO_VENDA AS PV with (NOLOCK) 
			LEFT JOIN BI.dbo.COMPRAS_CAD_COMPRADOR AS CC
				ON 1=1
				AND PV.COD_USUARIO = CC.COD_USUARIO
			where 1 = 1
			and cast(PV.[DTA_INI] as DATE) <= CAST(getdate() as DATE) 
			and cast(PV.[DTA_FIM] as DATE) >= CAST(getdate() as DATE) 
			and PV.COD_PRODUTO <> 0 
			and PV.TIPO = 0
			and PV.inativo is null
			And PV.COD_LOJA = 29
			AND PV.COD_PRODUTO IN (SELECT DISTINCT COD_PRODUTO FROM CADASTRO_CAD_PRODUTO_METADADOS TPM WHERE COD_METADADO = 4 AND VLR_METADADO = 1)
			) as TAB
		where 1 = 1
			and SEQ = 1
	) AS PV_29
		ON CP.COD_PRODUTO = PV_29.COD_PRODUTO


WHERE 1=1
	AND CP.COD_PRODUTO IN (SELECT DISTINCT COD_PRODUTO FROM CADASTRO_CAD_PRODUTO_METADADOS TPM WHERE COD_METADADO = 4 AND VLR_METADADO = 1)
	AND PV_05.VLR_VENDA > PV_29.VLR_VENDA

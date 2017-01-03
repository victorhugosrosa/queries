/*
DECLARE @MOTIVO_PRECO_BLOQ AS TABLE
(
	COD_LOJA INT
	,COD_PRODUTO INT
	,MOTIVO VARCHAR(100)
)

INSERT INTO @MOTIVO_PRECO_BLOQ
SELECT
	[COD_LOJA]
	,[COD_PRODUTO]
	,case
		when [COD_MOTIVO]=1 then 'Proibido Alterar PV e PO - ' + [OBS]
		when [COD_MOTIVO]=2 then 'Proibido Alterar PV - ' + [OBS]
		when [COD_MOTIVO]=3 then 'Proibido Alterar PO - ' + [OBS]
		when [COD_MOTIVO]=4 then 'Alteração Casada - ' + [OBS]
		when [COD_MOTIVO]=5 then 'Reajuste só com Pesquisa - ' + [OBS]
		else 'Falar com a Nat - '
	END as MOTIVO  
FROM
	[BI].[dbo].[BI_PRECO_BLOQUEADO_EXPANDIDO] 
where 1=1

SELECT * FROM [BI].[dbo].[BI_PRECO_BLOQUEADO_EXPANDIDO] 

SELECT
	COD_LOJA
	,COD_PRODUTO
	,STUFF((select DISTINCT
				T.MOTIVO + ' | ' 
			from
				@MOTIVO_PRECO_BLOQ AS T
			where  1=1
				and T.COD_LOJA = PB.COD_LOJA
				and T.COD_PRODUTO = PB.COD_PRODUTO
			for xml path('')
		),1,0,'') MOTIVOS
FROM
	@MOTIVO_PRECO_BLOQ AS PB
ORDER BY
	COD_PRODUTO
	,COD_LOJA
*/
	
rsData.Open "  SELECT " & _
"  	PB.[COD_LOJA] " & _
"  	,PB.[COD_PRODUTO] " & _
"  	,STUFF((select DISTINCT " & _
"  				ISNULL(M.NO_MOTIVO,'Falar com a Nat') + ' - ' + TPB.[OBS] + '  |  '  " & _
"  			from " & _
"  				[BI].[dbo].[BI_PRECO_BLOQUEADO_EXPANDIDO] AS TPB " & _
"  				LEFT JOIN [BI].[dbo].[BI_PRECO_BLOQUEADO_MOTIVO] AS M " & _
"  					ON TPB.COD_MOTIVO = M.COD_MOTIVO " & _
"  			where  1=1 " & _
"  				and TPB.COD_LOJA = PB.COD_LOJA " & _
"  				and TPB.COD_PRODUTO = PB.COD_PRODUTO " & _
"  			for xml path('') " & _
"  		),1,0,'') MOTIVOS	 " & _
"  FROM " & _
"  	[BI].[dbo].[BI_PRECO_BLOQUEADO_EXPANDIDO] AS PB " & _
"  where 1=1 " & _
"  AND COD_PRODUTO IN " & getProdutoToSQL
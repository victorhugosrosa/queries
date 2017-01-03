-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- conferencia base zanthus
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
select 
	 CodLoja as Loja
	,QtdCliente as [Qtd Vc]
	,QtdCupom as [Qtd Tkt]
	,ISNULL(QtdCliente/nullif(convert(numeric(8,2),QtdCupom),0),0) as [%Id Cli]
	,VlrCliente as [Vlr Vc]
	,VlrCupom as [Qtd Tkt]
	,ISNULL(VlrCliente/nullif(VlrCupom,0),0) as [%Id Fat]
from 
  (
	SELECT 
	 M00ZA AS CodLoja
	--,M00AF AS Data
	,sum(case when [M01AV] = '0' then 0 else 1 end) as QtdCliente
	,COUNT(M00AD) AS QtdCupom
	,sum(case when [M01AV] = '0' then 0 else M01AK end) as VlrCliente
	,SUM(M01AK) as VlrCupom
    
	FROM  ZeusRetail.dbo.Zan_M01 as c with (NOLOCK)

	where 1 = 1
	and CONVERT(date,M00AF) between convert(date,'20131201') and convert(date,'20131201')
	AND M00ZA = 1
	group by  M00ZA
		   --,M00AF
  ) as s
  
 where 1=1
 --order by Data

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- conferencia base dtm
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT 
	C.idLoja, 
	CONVERT(DATETIME,C.datVenda) datVenda,
	COUNT(DISTINCT CONVERT(VARCHAR,C.numcupom) + CONVERT(VARCHAR,C.numCaixa) + CONVERT(VARCHAR,C.idLoja) + CONVERT(VARCHAR,C.datVenda)) QtdVenda,
	SUM(CONVERT(REAL,C.vlrTotal)) VlrVenda,
	ISNULL(A.QtdCliIdentif,0) QtdCliIdentif, 
	ISNULL(A.VlrVendaCliIdentif,0) VlrVendaCliIdentif
FROM
	[DTM].[DBO].[CUPOM_PRODUTO] C
LEFT JOIN
	(
		SELECT 
			idLoja, 
			CONVERT(DATETIME,datVenda) datVenda,
			SUM(CONVERT(REAL,vlrTotal)) VlrVendaCliIdentif,
			COUNT(DISTINCT CONVERT(VARCHAR,numcupom) + CONVERT(VARCHAR,numCaixa) + CONVERT(VARCHAR,idLoja) + CONVERT(VARCHAR,datVenda)) QtdCliIdentif
		FROM
			[DTM].[DBO].[CUPOM_PRODUTO] CP
		WHERE 
			ISNULL(REPLACE(idCliente,' ',''),'') <> ''
			AND 
			CONVERT(DATE,DATVENDA) BETWEEN CONVERT(DATE,'20131201') AND CONVERT(DATE,'20131201')
		GROUP BY
			idLoja, 
			datVenda			
	) A ON
		A.idLoja = C.idLoja
		AND
		A.datVenda = CONVERT(DATETIME,C.datVenda)
WHERE 1 = 1
	--AND idLoja IN (1)
	AND CONVERT(DATE,c.DATVENDA) BETWEEN CONVERT(DATE,'20131201') AND CONVERT(DATE,'20131201')
group by
	C.idLoja, 
	CONVERT(DATETIME,C.datVenda) ,
	ISNULL(A.QtdCliIdentif,0),
	ISNULL(A.VlrVendaCliIdentif,0)
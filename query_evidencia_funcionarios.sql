select *
		, DATEDIFF ( MONTH , DTA_ADMISSAO , DTA_TRAB_ATE ) AS MESES_TRABALHADOS
		, DATEDIFF ( DAY , DTA_ADMISSAO , DTA_TRAB_ATE ) AS DIAS_TRABALHADOS
		--, CONVERT(nvarchar(6), DTA_ADMISSAO, 112) as ANO_MES_ADMISSAO

from 
	(
		SELECT COD_LOJA
			  ,case when [DTA_DEMISSAO] is null then 'Ativo' ELSE 'Inativo' end as Estado
			  , id as ID_SISTEMA
			  , RANK () OVER (PARTITION BY no_funcionario
							ORDER BY id DESC ) as 'Rank'
			  , no_funcao as [Cargo]
			  , no_departamento as [Departamento]
			  , MATRICULA as [COD_FUNC]
			  , cod_departamento as COD_CC -- [CC]
			  , no_funcionario as NOME
			  , CONVERT (DATE, [DTA_ADMISSAO]) AS DTA_ADMISSAO
			  , CONVERT (DATE, ISNULL([DTA_DEMISSAO],GETDATE())) AS DTA_TRAB_ATE
			  
		  FROM bi.dbo.VW_FUNCIONARIO--[192.168.0.6].INTRANET.dbo.[TAB_FUNCIONARIOS]
		  WHERE 1=1
		  	  AND MATRICULA IS NOT NULL
			  AND SITUACAO <> 'CESSAO'
			  AND [FLG_ADP] = 1

	) as s
where 1=1
and Rank = 1
and DATEDIFF ( MONTH , DTA_ADMISSAO , DTA_TRAB_ATE )  >= 0
order by NOME
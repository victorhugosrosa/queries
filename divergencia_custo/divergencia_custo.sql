SELECT distinct 'zeus' as base, cod_produto, cod_fornecedor, des_referencia FROM [192.168.0.6].ZEUS_RTG.DBO.TAB_PRODUTO_FORNECEDOR
WHERE 1=1
AND COD_PRODUTO IN (1022991,521758,521857)
AND COD_FORNECEDOR = 16102

--union all

SELECT distinct 'ax' as base, cod_produto, cod_fornecedor, des_referencia FROM AX2009_INTEGRACAO.dbo.TAB_PRODUTO_REFERENCIA_CalC
WHERE 1=1
AND COD_PRODUTO IN (1022991,521758,521857)
AND COD_FORNECEDOR = 16102




select * from VW_CUSTOS_ATIVOS where cod_produto in (1018435,1018446,1018464) and cod_fornecedor = 17095
select * from [192.168.0.6].ZEUS_RTG.DBO.TAB_PRODUTO_FORNECEDOR where cod_produto in (1018435,1018446,1018464) and cod_fornecedor = 17095

SELECT
	'BI_ESTOQUE_PRODUTO_DIA' as no_tabela
	,index_id
	,avg_fragmentation_in_percent
	,record_count
FROM sys.dm_db_index_physical_stats
    (DB_ID(N'BI'), OBJECT_ID(N'DBO.BI_ESTOQUE_PRODUTO_DIA'), NULL, NULL , 'SAMPLED')

SELECT
	'BI_VENDA_PRODUTO' as no_tabela
	,index_id
	,avg_fragmentation_in_percent
	,record_count
FROM sys.dm_db_index_physical_stats
    (DB_ID(N'BI'), OBJECT_ID(N'DBO.BI_VENDA_PRODUTO'), NULL, NULL , 'SAMPLED')

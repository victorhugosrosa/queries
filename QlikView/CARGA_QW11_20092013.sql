USE [BI]
GO
/****** Object:  StoredProcedure [dbo].[CARGA_QW11]    Script Date: 09/20/2013 17:32:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[CARGA_QW11]
	@dataIni [varchar](8),
	@dataFim [varchar](8),
	@full [INT] = 0
WITH EXECUTE AS CALLER
AS
BEGIN
	--exec CARGA_QW10 '20111003','20111109'
	--Atualização do Bi-10 Venda Produto
	declare @Caminho as varchar(5000)
	set @Caminho = '\\192.168.0.14\bi\QlikServer\Bi_Loja_Outros\Cargas\dados Bi-11\'
	
	--Venda de Produto dia
	declare @CMDSQL01 as varchar(8000)
	declare @Arquivo01 as varchar(5000)
	set @CMDSQL01 = 'EXECUTE BI.dbo.QW_RUPTURA ""'+@dataIni+'"", ""'+@dataFim+'""'
	set @Arquivo01 = @Caminho + 'PROD_MOV_' + LEFT(RIGHT(CAST(@dataIni AS VARCHAR(8)),4),2) + '.txt'
	exec BCP  @CMDSQL01 , @Arquivo01
	
	IF @full = 1 
	BEGIN
		declare @CMDSQL02 as varchar(8000)
		declare @Arquivo02 as varchar(5000)
		set @CMDSQL02 = 'SELECT [COD_PRODUTO],[DESCRICAO] FROM BI.DBO.BI_CAD_PRODUTO'
		set @Arquivo02 = @Caminho + 'CAD_PRODUTO.txt'
		exec BCP  @CMDSQL02 , @Arquivo02
		
		declare @CMDSQL03 as varchar(8000)
		declare @Arquivo03 as varchar(5000)
		set @CMDSQL03 = 'EXECUTE BI.dbo.QW_RUPTURA_SEM_REC'
		set @Arquivo03 = @Caminho + 'PROD_MOV_SEM_REC.txt'
		exec BCP  @CMDSQL03 , @Arquivo03
	END
	
	
	
/*
	--Carga de Produtos
	declare @CMDSQL03 as varchar(8000)
	declare @Arquivo03 as varchar(5000)
	set @CMDSQL03 = 'EXECUTE BI.dbo.QW_CAD_PRODUTO_BI10'
	set @Arquivo03 = @Caminho + '06-CAD_PRODUTO.txt'
	exec BCP  @CMDSQL03 , @Arquivo03
*/

END



USE [BI]
GO

/****** Object:  Table [dbo].[BI_ESTOQUE_META]    Script Date: 03/02/2016 21:23:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BI_ESTOQUE_META](
	[COD_LOJA] [int] NOT NULL,
	[ANO] [int] NOT NULL,
	[MES] [int] NOT NULL,
	[META_ESTOQUE] [numeric](18, 2) NULL,
 CONSTRAINT [PK_BI_ESTOQUE_META] PRIMARY KEY CLUSTERED 
(
	[COD_LOJA] ASC,
	[ANO] ASC,
	[MES] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO



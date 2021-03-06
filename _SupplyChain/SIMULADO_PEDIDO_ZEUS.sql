	DECLARE @TAB_PRODUTOS_N_UN AS TABLE
		(
			COD_PRODUTO INT
		)

		INSERT INTO @TAB_PRODUTOS_N_UN
		SELECT DISTINCT
			COD_PRODUTO
		FROM
			BI.DBO.CADASTRO_CAD_PRODUTO_METADADOS AS PM
		WHERE 1=1 
			AND COD_METADADO IN (16,17) AND VLR_METADADO = '1'
	-- -------------------------------------------------------------------------------------------------------------------
	--
	-- -------------------------------------------------------------------------------------------------------------------
		SELECT
			ID , COD_FORNECEDOR , P.COD_LOJA, P.COD_PRODUTO , LP.CLASSIF_PRODUTO_LOJA AS ABC_VLR, ABC_S.ABC_LOJA AS ABC_SUPPLY ,T.COD_PRODUTO AS NOTAVEL_OU_ULTRA
		FROM
			BI.DBO.COMPRAS_PEDIDOS  AS P
			INNER JOIN BI.DBO.BI_LINHA_PRODUTOS AS LP
				ON 1=1
				AND P.COD_PRODUTO = LP.COD_PRODUTO
				AND P.COD_LOJA = LP.COD_LOJA
			LEFT JOIN BI.DBO.[SUPPLY_PRODUTO_ABC_LOJA] AS ABC_S
				ON 1=1
				AND P.COD_PRODUTO = ABC_S.COD_PRODUTO
				AND P.COD_LOJA = ABC_S.COD_LOJA
			LEFT JOIN @TAB_PRODUTOS_N_UN AS T
				ON P.COD_PRODUTO = T.COD_PRODUTO
		WHERE 1 = 1
		AND ID IN ('06RKPQ8A1MYK0KQOXTMZ','1JPCEFLWYFJ3WQGJ51F5','1WVNTW6RVHB94QRUY4LV','2E6AXFKH5CG2UDDP1PED','32UYT4UMDUWPL71T47GX','3S07PZMZFGGGHU2EA4AD','4CWSWC1P6NKOI64UCL5G','4EPS3U34XGYL4KQT7UGT','4FGD7D1ZM87QF96IFKFR','4HVT0SDU18RR1L4FCIVL','5WAKZ1JZJC7HNSMQVZQJ','6KS1OM4Y6782MQPNFEEB','6N7OESATGCAHZDF9MK6R','7MFYE7ALZ6OD27RW2ASD','8BZKU4EABEK3KSPDFPU7','8ZECY5TNJXYS3N7KDCXS','AS59E8JH7BL5KXPQ3U0Y','AT4FIRPY2EDT2VZ7BM15','AV2LTCKZYPMRL20SQ9PI','AW9720X635F6I1PT024G','BQ2JHD7NUD4ITSF00NQ1','DKEYIE281XF8H8A716JP','DKSSOGHW1716O9GN8ZHY','DS5X6NKV6735G7MNJKE7','E0W8PX5D3R9HZ1N7S8P4','E8LCGBZBHCLJ3PM2DBFL','F70AFTOQY24D13YLSYPA','FDPES74TL213SHRQEZHK','GKCTQE14T5SJNWSAKEDH','HIXJDKTC43Z9Q4YOIOO9','HQMCI9R9CTDLWHUP7V9Z','J700Y57NK2Y2Z9H79A6D','JMAGXMW0Z1FW1IA5KB0L','JOQTPEJQBDQ92FKGHAUB','JUGT7F4KI1QIVCH4ZJBW','JVTUXHCV2FH6VD7JDOT4','K5D6RB52HYM3HASCOHIY','KT0GYKVPKEJD6E25UQ8N','M0KEXM6CKFJDSQVGU4SP','M8MEN4XS9S7X3T72ZPE0','ML07N2BLNWV25NC1D13G','ODJ3IWQLJOB98V952GVU','PW9GHGISVUD85QEEQOLZ','PWZ4VJBNDX4B55VHIHUQ','Q9WG0N6E60LXO8AD1CWO','QIK4ICCDSMULFX9PR98S','SW9AMMQZKPQLNNPPMDEW','UW974GXW4A22GCZV5X12','UYPSCQ2Y1TJKPX332DDD','VS8DNMTIKHZJCXHW9DGB','VY9EETMBNGUX3L4SLC5J','W443SI18AQP81JE28T6Y','XI9IC6OSJA5EVIYYN4Z1','XTA8P1Z9HP88JDCKL8EC','XZ7C21X0KU960A9FWP35','Y0D7CDJXCZBB8L5EJYEB','YX42PNRC16Q557IM8ZJU')
		-- ------------------------------------------------------------------------------------------------------
		AND ISNULL(FLG_ERRO_FORNECEDOR_PRINCIPAL,0) = 0
		AND ISNULL(FLG_ERRO_TIPO_ABASTECIMENTO,0)   = 0
		AND ISNULL(FLG_ERRO_SEM_CUSTO	,0)		  = 0
		AND ISNULL(FLG_COMPRA,1)	= 1				
		AND QTD_EMBALAGEM > 0
		-- ------------------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	SELECT
		YEAR(DATA) AS ANO
		,MONTH(DATA) AS MES	
		,VP.COD_LOJA
		,CP.COD_FORNECEDOR
		--,CF.DES_FANTASIA
		,CP.NO_DEPARTAMENTO
		,CP.NO_SECAO
		,CP.NO_GRUPO
		,CP.COD_PRODUTO
		,CP.DESCRICAO
		,CP.FORA_LINHA
		--,M.VLR_MRG
		,BI.dbo.fn_FormataVlr_Excel(SUM(VALOR_TOTAL)) AS VLR_VENDA
		,BI.dbo.fn_FormataVlr_Excel(SUM(QTDE_PRODUTO)) AS QTD_VENDA
	FROM 
		BI_VENDA_PRODUTO AS VP INNER JOIN BI_CAD_PRODUTO AS CP ON (VP.COD_PRODUTO = CP.COD_PRODUTO)
			--INNER JOIN BI_CAD_FORNECEDOR AS CF ON (CP.COD_FORNECEDOR = CF.COD_FORNECEDOR)
				--INNER JOIN BI_MARGEM_PRODUTO_MES AS M ON (VP.COD_PRODUTO = M.COD_PRODUTO AND M.MES = 10 AND M.ANO = 2014)
	WHERE 1 = 1
		AND CP.COD_FORNECEDOR in (18055,103256)
		AND CP.COD_DEPARTAMENTO NOT IN (6)
		AND CONVERT(DATE,DATA) BETWEEN CONVERT(DATE,'20130101') AND CONVERT(DATE,'20141231')
		AND CP.COD_PRODUTO IN (SELECT DISTINCT COD_PRODUTO FROM CADASTRO_CAD_PRODUTO_METADADOS AS M WHERE M.COD_METADADO = 4 AND VLR_METADADO = 1)
		--AND CP.COD_PRODUTO IN (53686,90339,187121,220095,277938,429085,429092,429108,512534,512541,512572,512589,512664,512701,512732,520300,522007,558808,558815,558822,558839,561549,561556,561563,561570,561587,561594,561600,561617,561624,577014,649711,649735,701112,983464,990812,990813,990814,990815,990816,990818,990819,990820,990821,990822,990823,990824,990825,991415,991420,991512,991713,991714,991715,991716,991717,991718,991719,991721,992604,992606,992691,992692,992693,992798,992800,992802,992851,993610,994070,994072,994073,994074,994076,994077,994081,994082,994083,994724,994725,995605,995606,998483,998484,998485,998486,998487,1000090,1000091,1000093,1000100,1000101,1000102,1000103,1000104,1000105,1000106,1000107,1000108,1000109,1000110,1000111,1000112,1000113,1000114,1000115,1000116,1000117,1000118,1000119,1000120,1000121,1000122,1000123,1000124,1000125,1000126,1000127,1000128,1000250,1000251,1000252,1000253,1000254,1000964,1000965,1000966,1000967,1001328,1001329,1001330,1001332,1001333,1001334,1001336,1001337,1001338,1001340,1001341,1001342,1001343,1001357,1001358,1001359,1001360,1001361,1001362,1001363,1001364,1001365,1001366,1001367,1001368,1001369,1001370,1001371,1001372,1001373,1001377,1001378,1001381,1001383,1001384,1001385,1001386,1001387,1001388,1001390,1001391,1001392,1001393,1001396,1001397,1001398,1001399,1001401,1001403,1001573,1001745,1001746,1001747,1001748,1001749,1001750,1001751,1001764,1001782,1001783,1001784,1001785,1001787,1001788,1001795,1001796,1001797,1001798,1001799,1001800,1001801,1001802,1001803,1001804,1001805,1001806,1001807,1001808,1001809,1001810,1001812,1001816,1001817,1001818,1001819,1001825,1001826,1001827,1001832,1001864,1001867,1002041,1002042,1002043,1002044,1002176,1002177,1002178,1002179,1002180,1002181,1002182,1002184,1002186,1002191,1002192,1002193,1002194,1002195,1002196,1002198,1002199,1002213,1002214,1002215,1002216,1002217,1002218,1002219,1002221,1002222,1002224,1002405,1002406,1002407,1002408,1002409,1002410,1002411,1002412,1002413,1002414,1002415,1002416,1002418,1002419,1002420,1002421,1002422,1002433,1002434,1002435,1002436,1002437,1002438,1002439,1002440,1002442,1002443,1002444,1002445,1002446,1002447,1002448,1002449,1002450,1002451,1002452,1002453,1002454,1002456,1002457,1002458,1002459,1002460,1002461,1002468,1002470,1002472,1002473,1002474,1002475,1002476,1002477,1002478,1002479,1002480,1002481,1002482,1002483,1002485,1002486,1002487,1002500,1002543,1002544,1002545,1002546,1002547,1002568,1002652,1002661,1002664,1002667,1002668,1002669,1002670,1002671,1002672,1002680,1002681,1002682,1002683,1002684,1002685,1002686,1002687,1002688,1002689,1002772,1002773,1002775,1002776,1002777,1002778,1002781,1002784,1002785,1002786,1002787,1002788,1002789,1002790,1002791,1003198,1003199,1003200,1003201,1003202,1003204,1003211,1003212,1003213,1003214,1003215,1004057,1004058,1004059,1004060,1004061,1004062,1004063,1004089,1007684,1007685,1007686,1007691,1007692,1007700,1007701,1007702,1007703,1007704,1007705,1007706,1007707,1007708,1007709,1007710,1007711,1007712,1007713,1007716,1007717,1007718,1007719,1007720,1007721,1008544,1008545,1008546,1008547,1008549,1008550,1008551,1008552,1008553,1008554,1008555,1008562,1008564,1008566,1008568,1008570,1008576,1008578,1008580,1008582,1008584,1008586,1008588,1008591,1008594,1008599,1008600,1008601,1008602,1008604,1008605,1008606,1008607,1008608,1008610,1008611,1008612,1008613,1008614,1008615,1008616,1008617,1008618,1008619,1008620,1008622,1008623,1008624,1008625,1008626,1008627,1008628,1008629,1008630,1008631,1008632,1008633,1008634,1008635,1008636,1008637,1008638,1008639,1008640,1008641,1008642,1008643,1008646,1008647,1008648,1008649,1008650,1008651,1010047,1010048,1010049,1010050,1010051,1010052,1010053,1010054,1010055,1010056,1010057,1010058,1010059,1011363,1011364,1011365,1011366,1011381,1011383,1011385,1011387,1011389,1011391,1011394,1011395,1011398,1011399,1011401,1011404,1011405,1011406,1011407,1011408,1011409,1011410,1011411,1011412,1011413,1011414,1011415,1011418,1013796,1013834,1013835,1013836,1013837,1013838,1013839,1013840,1013841,1013842,1013960,1014426,1014776,1014779,1014780,1014781,1014782,1014783,1014784,556545,1000089,1002774,1004090,995607,1000052,1001335,1001752,1012819,1012818,1012827,1012828,1012829,1012830,1012831,1012832,1012833,1012834,1012835,1012836,1001786,1015341,1015241,1015333,1015325,1015242,1015315,1015334,1015335,1015326,1015243,1015244,1015214,1015327,1015328,1015329,1015330,1015331,1015215,1015216,1015217,1015218,1015219,1015220,1015225,1015226,1015227,1015228,1015246,1015247,1015248,1015249,1015250,1015251,1015336,1000092,1001400,1001402,1001374,1001375,1001376,292900,1001382,994714,994715,244305,1008609,1008548,1008556,1008557,1008558,1008560,1008572,1008573,1008621,1008603,1008644,1008645,556484,1015151,1015152,1015153,1015154,1015119,1015120,1015121,1015122,1015123,1015124,1015125,1015080,1015081,1015082,1015083,1015084,1015085,1002455,1002462,1002463,1002441,1002655,1002660,1002656,1002657,1002658,1002659,1002662,1002663,1002665,1002653,1002654,1002646,1002647,1002648,1002649,1002673,1002674,1002675,1002676,1002677,1003203,1009176,1009177,1009178,1009179,1009191,1009192,1009193,1009194,1009195,1009196,1009197,1009198,1009263,1009265,1009266,1009267,156363,250245,1015169,1015170,1015171,1015172,1015173,1015174,1015175,1015176,1015177,1015178,1015179,1015180,1015181)
	GROUP BY
		YEAR(DATA)
		,MONTH(DATA)		
		,VP.COD_LOJA
		,CP.COD_FORNECEDOR
		--,CF.DES_FANTASIA
		,CP.NO_DEPARTAMENTO
		,CP.NO_SECAO
		,CP.NO_GRUPO
		,CP.COD_PRODUTO
		,CP.DESCRICAO
		,CP.FORA_LINHA
		--,M.VLR_MRG
	ORDER BY
		SUM(VALOR_TOTAL) DESC
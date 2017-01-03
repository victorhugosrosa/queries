		SELECT
			txtCpf 
			
			,(CASE
				WHEN [txtSexo] = 'FEMININO' THEN 'Feminino'
				WHEN [txtSexo] = 'MASCULINO' THEN 'Masculino'
			END)
			,DATEDIFF(year,[datNascimento],GETDATE()) as idade
			,(CASE
				WHEN DATEDIFF(year,[datNascimento],GETDATE()) < 18 THEN '00-17'
				WHEN DATEDIFF(year,[datNascimento],GETDATE()) BETWEEN 18 AND 25 THEN '18-25'
				WHEN DATEDIFF(year,[datNascimento],GETDATE()) BETWEEN 26 AND 35 THEN '26-35'
				WHEN DATEDIFF(year,[datNascimento],GETDATE()) BETWEEN 36 AND 45 THEN '36-45'
				WHEN DATEDIFF(year,[datNascimento],GETDATE()) BETWEEN 46 AND 55 THEN '46-55'
				WHEN DATEDIFF(year,[datNascimento],GETDATE()) > 55 THEN '56-99'
			END)
		FROM
			[DTM].[dbo].[CLIENTES] AS C
		WHERE 1=1
			AND [txtSexo] IN ('FEMININO','MASCULINO')

select * from [192.168.0.6].zeus_rtg.dbo.tab_cliente where 1 = 1 and flg_empresa = 'N' and des_email is not null and des_email not like ''
and convert(double precision,num_cgc) not in (select convert(double precision,CPF) from [192.168.0.6].intranet.dbo.tab_funcionarios)


select sj.name,js.step_name,js.step_id,js.database_name, js.command
from msdb..sysjobsteps js join msdb..sysjobs sj
on sj.job_id=js.job_id
where command like '%CARGA_COMPRA_PRODUTO_PARAMETRO_NOVO%'



select * from msdb.dbo.sysjobs j join msdb.dbo.sysjobsteps st on st.job_id = j.job_id where st.command like '%CARGA_COMPRA_PRODUTO_PARAMETRO_NOVO%'
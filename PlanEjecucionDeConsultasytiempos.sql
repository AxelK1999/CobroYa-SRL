--EXPLAIN ANALYZE: Muestra el plan de ejecución junto con tiempos reales de ejecución.

EXPLAIN ANALYZE select Empresas.Nom_empresa, COUNT(Cuota.PK_Num_Cuota) as nro_cuotas ,SUM(Cuota.Importe) as importe_total, SUM(Cuota.Importe * FP.Comision) as importe_rendir from Cuota 
inner join Convenio on Convenio.pk_num_Con = Cuota.FK_Nro_Convenio
inner join FormaPago as FP on FP.PK_Id_Pago = Convenio.FK_Id_Pago
inner join DeudorEmpresa as DyE on DyE.FK_Dni_deu = Convenio.FK_Dni_deuC
inner join Empresas on Empresas.PK_Cuit = DyE.FK_Cuit
where EXTRACT(MONTH FROM Cuota.Fecha_Pago) = 9
group by Empresas.Nom_empresa

--EXPLAIN (FORMAT JSON): Muestra el plan de ejecución de una consulta..

EXPLAIN (FORMAT JSON) select empleados.pk_dni_emp as dni_empleado, empleados.nom_emp as nombre, empleados.ape_emp as apellido, count(*) as convenios_firmados  from empleados
inner join empresas on empleados.pk_dni_emp = empresas.fk_dni -- TODO
inner join DeudorEmpresa on empresas.pk_cuit = DeudorEmpresa.FK_Cuit
inner join deudores on DeudorEmpresa.FK_Dni_deu = deudores.pk_dni_deu 
inner join convenio on deudores.pk_dni_deu = convenio.fk_dni_deuc
GROUP BY dni_empleado, nombre, apellido


SELECT * FROM pg_stat_activity;
SHOW config_file; -- Muestra ubicacion de archivo de configuracion 
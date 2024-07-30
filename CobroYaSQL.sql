-- CREACION DE TABLA --
create table Empleados(
	PK_Dni_emp float not null, -- DNI del empleado
	Nom_emp varchar(25) not null, -- nombre
	Ape_emp varchar(25)not null, --apellido
	primary key(PK_Dni_emp)
);
create table Localidad(
	PK_Cod_Postal int not null, --codigo postal
	Ciudad varchar(15), --ciudad
	primary key (PK_Cod_Postal)
);
create table Empresas(
	PK_Cuit float not null, --cuit empresa que contrato a cobroYA
	Nom_empresa varchar(25) not null, --nombre empresa
	Correo varchar(35)not null, --correo
	FK_dni float not null, --dni del empleado a cargo
	FK_CodPostE int not null, -- código postal del ciudad
	primary key(PK_Cuit),
	foreign key (FK_dni) references Empleados(PK_Dni_emp), --Empleado a cargo de conveios y cobro a deudores de empresa(cliente) a cargo
	foreign key (FK_CodPostE) references Localidad(PK_Cod_Postal)
);

create table DeudorEmpresa(
	PK_id serial,
	FK_Cuit float not null,
	FK_Dni_deu int not null,
	primary key(PK_id),
	foreign key (FK_Dni_deu) references Deudores(PK_Dni_deu), --Empleado a cargo de conveios y cobro a deudores de empresa(cliente) a cargo
	foreign key (FK_Cuit) references Empresas(PK_Cuit)
);

create table Deudores(
	PK_Dni_deu int not null, --dni
	Fecha_nac date not null, -- fecha nacimiento
	Ape_deu varchar(25)not null, --apellido
	Nom_Deu varchar(25) not null, --nombre
	Direccion varchar(25)not null, --direccion
	--FK_Cuit float not null, -- cuit de la empresa a la que debe
	FK_CodPostD int not null, -- código postal de la ciudad
	primary key(PK_Dni_deu),
	--foreign key (FK_Cuit) references Empresas(PK_Cuit),
	foreign key (FK_CodPostD) references Localidad(PK_Cod_Postal)
);
create table Email(
	PK_Mail varchar(35) not null, --correo electrónico
	FK_Dni_deu int not null, -- dni del cliente deudor
	primary key(PK_Mail,FK_Dni_deu),
	foreign key (FK_Dni_deu) references Deudores(PK_Dni_deu)
);
create table Telefono(
	PK_Num_Tel float not null, --numero de teléfono
	Tipo varchar(8) not null, -- tipo de telefono
	FK_Dni_deuT int not null, -- dni del deudor
	primary key(PK_Num_Tel,FK_Dni_deuT),
	foreign key(FK_Dni_deuT) references Deudores(PK_Dni_deu)
);
create table FormaPago(
	PK_Id_Pago serial, --id de pago
	Fecha_Baja date,-- fecha de baja
	Comision int not null, -- porcentaje o una cantidad fija de dinero que se cobra como tarifa adicional por realizar una transacción 
	Cant_Cuotas int not null,-- cantidad de cuotas
	Intereses varchar(10) not null, --intereses
	primary key(PK_Id_Pago)
);

CREATE TYPE estadoConvenio AS ENUM ('A', 'C', 'F'); -- Activo Cancelado Finalizado

create table Convenio(
	PK_Num_Con serial, --id del convenio
	Fecha_Con date not null,--fecha de la firma del convenio
	estado estadoConvenio not null, --activo(al dia con las cuotas pero pendientes), cancelado(crea otro comvenio sin haber finalizado el mismo/no pago ultima cuota), finalizado(paga toda las cuotas)
	montoPagar float not null, 
	recargo float DEFAULT 0, -- recargo por retrasos o falta en terminos en el pago (acordado) aplicadas en la cuota correspondiente (puede ser aplicada de forma incremental segun pasado cienrtas fechas como tardia de pago)
	FK_Id_Pago int not null,--id de la forma de pago
	FK_Dni_deuC int not null,-- deni del cliente deudor
	primary key(PK_Num_Con),
	foreign key (FK_Dni_deuC) references Deudores(PK_Dni_deu),
	foreign key (FK_Id_Pago) references FormaPago(PK_Id_Pago)
);
create table Cuota( 
	PK_Num_Cuota int not null,-- numero de cuota del convenio
	Fecha_Pago date,-- fecha de cuando se pagó
	Vencimiento varchar(10) Not null,-- Implica una sancion de no cumplir con fechas pactadas (corte de servicio - recargo adicional - etc)
	Importe float not null,-- importe (monto a ser pagado por cuota)
	FK_Nro_Convenio int not null,--id del convenio
	primary key(PK_Num_Cuota,FK_Nro_Convenio),
	foreign key (FK_Nro_Convenio) references Convenio(PK_Num_Con)
);
------------------------------------------------
--Se debe revocar el permiso de creación predeterminado en el esquema public desde el rol public (heredado por nuevos roles de forma predeterminada) mediante la siguiente instrucción SQL:
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
--La siguiente declaración revoca la capacidad del rol público de conectarse a la base de datos:
REVOKE ALL ON DATABASE Gestion_Lotes FROM PUBLIC;
SELECT rolname FROM pg_roles; --Permite ver en un listado todo los usuarios creado en la BD.
----------------------- => 

--	  ROLES						PERMISOS  
--	empleado : insert select update [Cuota] [Convenio] [Telefono] [Email] [Deudores] [Empresas] [FormaPago]
--			   select [Empleados] (datos presonales no deberia de poder ver un usuario los datos de otro)

	--Creacion de rol
	CREATE ROLE empleado
	--Asignacion de privilegios
	GRANT select, insert, update ON Cuota TO empleado;
	GRANT select, insert ON Convenio TO empleado;
	GRANT select, insert, update ON Telefono TO empleado;
	GRANT select, insert, update ON Email TO empleado;
	GRANT select, insert, update ON Deudores TO empleado;
	GRANT select, insert, update ON Empresas TO empleado;
	GRANT select, insert ON FormaPago TO empleado;

-- auditor : select [ALL]
	CREATE ROLE auditor;
	
	GRANT select ON Cuota TO auditor;
	GRANT select ON Convenio TO auditor;
	GRANT select ON Telefono TO auditor;
	GRANT select ON Email TO auditor;
	GRANT select ON Deudores TO auditor;
	GRANT select ON Empresas TO auditor;
	GRANT select ON FormaPago TO auditor;
	GRANT select ON Empleados TO auditor;
	
	GRANT select ON audit_log TO auditor;
	
-----------------	
	REVOKE ALL PRIVILEGES ON audit_log FROM empleado;
	DROP ROLE auditor;
-----------------
-- USUARIOS:
	
	CREATE USER maria_23456789 WITH PASSWORD 'fas515fawfa51agasg3a';
	CREATE USER juan_12345678 WITH PASSWORD 'lfsdjf15gñsaagsdadg5';
	
	GRANT maria_23456789 TO empleado;
	GRANT juan_12345678 TO empleado;
	
	CREATE USER Mirko_42272933 WITH PASSWORD 'ghfdh161asv1e8svss1b';
	GRANT Mirko_42272933 TO auditor;
	
-----------------
--CONSULTAR USUARIOS Y ROLES EXISTENTES : 
SELECT * FROM pg_user;
SELECT * FROM pg_roles;
SELECT * FROM information_schema.table_privileges WHERE grantee = 'auditor';
-----------------
--LOG : 

	CREATE TABLE audit_log (
		action text,
		event_time timestamp,
		user_name text,
		table_name text,
		data jsonb
	);
	
--TRIGGER(FUNCIONES) :

-- Crear una función para el trigger que capture datos antiguos y nuevos
	CREATE OR REPLACE FUNCTION log_audit_trigger()
	RETURNS TRIGGER AS $$
	DECLARE
		old_data jsonb;
		new_data jsonb;
	BEGIN
		IF TG_OP = 'INSERT' THEN
			new_data = to_jsonb(NEW);
			INSERT INTO audit_log (action, event_time, user_name, table_name, data)
			VALUES ('INSERT', now(), current_user, TG_RELNAME, new_data);
		ELSIF TG_OP = 'UPDATE' THEN
			old_data = to_jsonb(OLD);
			INSERT INTO audit_log (action, event_time, user_name, table_name, data)
			VALUES ('UPDATE', now(), current_user, TG_RELNAME, old_data);
		ELSIF TG_OP = 'DELETE' THEN
			old_data = to_jsonb(OLD);
			INSERT INTO audit_log (action, event_time, user_name, table_name, data)
			VALUES ('DELETE', now(), current_user, TG_RELNAME, old_data);
		END IF;
		RETURN NEW;
	END;
	$$ LANGUAGE plpgsql;
--------------
	--crear las cantidad de cuotas de antemano, de ser cancelado => se eliminaran la no pagadas dejando la ultima pendiente unicamnte 

	CREATE OR REPLACE FUNCTION generar_cuotas_trigger() RETURNS TRIGGER AS $$
	DECLARE
		vencimiento_actual date := NEW.Fecha_Con + INTERVAL '1 month';
		nro_cuota integer;
		importe_cuota float;
	BEGIN
	
		SELECT Cant_Cuotas INTO nro_cuota
		FROM FormaPago
		WHERE PK_Id_Pago = NEW.FK_Id_Pago;
		
		importe_cuota := NEW.montoPagar / nro_cuota;

		FOR i IN 1..nro_cuota LOOP
			INSERT INTO Cuota (PK_Num_Cuota, Vencimiento, Importe, FK_Nro_Convenio)
			VALUES (i, vencimiento_actual, importe_cuota, NEW.PK_Num_Con);

			vencimiento_actual := vencimiento_actual + INTERVAL '1 month';
		END LOOP;

		RETURN NEW;
	END;
	$$ LANGUAGE plpgsql;

	CREATE TRIGGER insertar_cuotas_trigger
	AFTER INSERT ON Convenio
	FOR EACH ROW
	EXECUTE FUNCTION generar_cuotas_trigger();
	
	--PRUEBA : 
	insert into Convenio(Fecha_Con, estado, montoPagar, recargo, FK_Id_Pago, FK_Dni_deuC) values (now(), 'A', 600000, 13000, 1, 222222222)
	select * from Convenio
	select * from cuota where cuota.FK_Nro_Convenio = 27

------------------ Restablecimiento de estado anterior sobre algun registro(para tener en cuenta de ser necesario) ---------------

--Como camvertir un dato dentro de un tipo jsonb al tipo que se desee :
SELECT data->'pk_dni_emp' as dni FROM audit_log;
SELECT (data->>'pk_dni_emp')::integer as dni_numero FROM audit_log;
select * from audit_log

CREATE OR REPLACE FUNCTION mostrarDniInteger()
	RETURNS integer AS $$ --de ser disparador => TRIGGER en lugar de integer
	DECLARE
		apellido integer;
	BEGIN
		SELECT (data->>'pk_dni_emp')::integer into apellido FROM audit_log;
		return apellido;--operaciones I-U-D para restablecer estado anterior
	END;
$$ LANGUAGE plpgsql;

select mostrarDniInteger() as most

------------------------------ TRIGGERS -------------------------------------------------------------

-- Crear un trigger en la tabla que deseas auditar, before(antes)/after(despues): 
CREATE TRIGGER audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON Empleados 
FOR EACH ROW
EXECUTE FUNCTION log_audit_trigger();
----------------------
--prueba:
insert into Empleados (PK_Dni_emp,Nom_emp, Ape_emp) values (42272923,'Axel','Kaechele')
select * from Empleados
select * from audit_log 
----------------------
CREATE TRIGGER audit_trigger
before INSERT OR UPDATE OR DELETE ON Cuota 
FOR EACH ROW
EXECUTE FUNCTION log_audit_trigger();

CREATE TRIGGER audit_trigger
before INSERT OR UPDATE OR DELETE ON Localidad 
FOR EACH ROW
EXECUTE FUNCTION log_audit_trigger();

CREATE TRIGGER audit_trigger
before INSERT OR UPDATE OR DELETE ON Empresas 
FOR EACH ROW
EXECUTE FUNCTION log_audit_trigger();

CREATE TRIGGER audit_trigger
before INSERT OR UPDATE OR DELETE ON DeudorEmpresa 
FOR EACH ROW
EXECUTE FUNCTION log_audit_trigger();

CREATE TRIGGER audit_trigger
before INSERT OR UPDATE OR DELETE ON Deudores 
FOR EACH ROW
EXECUTE FUNCTION log_audit_trigger();

CREATE TRIGGER audit_trigger
before INSERT OR UPDATE OR DELETE ON Email 
FOR EACH ROW
EXECUTE FUNCTION log_audit_trigger();

CREATE TRIGGER audit_trigger
before INSERT OR UPDATE OR DELETE ON Telefono 
FOR EACH ROW
EXECUTE FUNCTION log_audit_trigger();

CREATE TRIGGER audit_trigger
before INSERT OR UPDATE OR DELETE ON FormaPago 
FOR EACH ROW
EXECUTE FUNCTION log_audit_trigger();

CREATE TRIGGER audit_trigger
before INSERT OR UPDATE OR DELETE ON Convenio 
FOR EACH ROW
EXECUTE FUNCTION log_audit_trigger();



--------------------------------------------------CARGA DE DATOS----------------------------------------------------------------------------------------

--FECHA ACtual para los datos 17/08/2023
-- Insertar datos en la tabla Empleados
INSERT INTO Empleados (PK_Dni_emp, Nom_emp, Ape_emp)
VALUES
    (12345678, 'Juan', 'Pérez'),
    (23456789, 'María', 'Gómez');

-- Insertar datos en la tabla Localidad
INSERT INTO Localidad (PK_Cod_Postal, Ciudad)
VALUES
    (1010, 'Buenos Aires'),
    (2000, 'Rosario');

-- Insertar datos en la tabla Empresas
INSERT INTO Empresas (PK_Cuit, Nom_empresa, Correo, FK_dni, FK_CodPostE)
VALUES
    (20123456789, 'Empresa A', 'empresaA@example.com', 12345678, 1010),
    (30234567890, 'Empresa B', 'empresaB@example.com', 23456789, 2000);

INSERT INTO Deudores (PK_Dni_deu, Fecha_nac, Ape_deu, Nom_Deu, Direccion, FK_CodPostD)
VALUES
    (34567890, '1990-01-15', 'López', 'Ana', 'Calle 123', 1010),
    (45678901, '1985-05-20', 'Martínez', 'Carlos', 'Av. Principal', 2000),
    (111111111, '1992-03-10', 'Gomez', 'Carlos', '123 Main St', 1010),
    (222222222, '1988-08-22', 'Rodriguez', 'Luisa', '456 Elm St', 1010),
    (333333333, '1995-05-05', 'Perez', 'Laura', '789 Oak St', 1010),
    (444444444, '1990-01-15', 'Fernandez', 'Diego', '555 Maple St', 1010),
    (555555555, '1985-11-30', 'Gonzalez', 'Maria', '777 Pine St', 1010),
    (666666666, '1998-06-25', 'Martinez', 'Juan', '999 Birch St', 1010),
    (777777777, '1993-09-18', 'Lopez', 'Ana', '111 Cedar St', 1010),
    (888888888, '1987-04-08', 'Diaz', 'Sergio', '222 Oak St', 1010),
    (999999999, '1997-07-12', 'Castro', 'Carolina', '333 Elm St', 2000),
    (101010101, '1994-02-28', 'Rivera', 'Andres', '444 Maple St', 2000),
    (111111122, '1991-12-05', 'Sanchez', 'Isabel', '555 Pine St', 2000),
    (121212123, '1989-10-20', 'Ramirez', 'Daniel', '666 Birch St', 2000),
    (131313134, '1996-08-14', 'Torres', 'Natalia', '777 Cedar St', 2000),
    (141414145, '1992-06-09', 'Flores', 'Pedro', '888 Oak St', 1010),
    (151515156, '1986-03-02', 'Mendoza', 'Julia', '999 Elm St', 1010),
    (161616167, '1999-01-17', 'Vargas', 'Mariano', '111 Maple St', 2000),
    (171717178, '1993-11-28', 'Reyes', 'Valentina', '222 Pine St', 1010),
    (181818189, '1988-09-22', 'Hernandez', 'Elena', '333 Birch St', 2000),
    (191919200, '1997-07-05', 'Silva', 'Gustavo', '444 Cedar St', 2000),
    (202020211, '1994-04-30', 'Chavez', 'Renata', '555 Oak St', 2000);

-- Combinaciones para Empresa A (PK_Cuit = 20123456789)
INSERT INTO DeudorEmpresa (FK_Cuit, FK_Dni_deu)
VALUES
    (20123456789, 34567890), -- Ana López
    (20123456789, 111111111), -- Carlos Gomez
    (20123456789, 222222222), -- Luisa Rodriguez
    (20123456789, 333333333), -- Laura Perez
    (20123456789, 444444444), -- Diego Fernandez
    (20123456789, 555555555), -- Maria Gonzalez
    (20123456789, 666666666), -- Juan Martinez
    (20123456789, 777777777), -- Ana Lopez
    (20123456789, 888888888), -- Sergio Diaz
    (20123456789, 141414145), -- Pedro Flores
    (20123456789, 151515156); -- Julia Mendoza

-- Combinaciones para Empresa B (PK_Cuit = 30234567890)
INSERT INTO DeudorEmpresa (FK_Cuit, FK_Dni_deu)
VALUES
    (30234567890, 45678901), -- Carlos Martínez
    (30234567890, 999999999), -- Carolina Castro
    (30234567890, 101010101), -- Andres Rivera
    (30234567890, 111111122), -- Isabel Sanchez
    (30234567890, 121212123), -- Daniel Ramirez
    (30234567890, 131313134), -- Natalia Torres
    (30234567890, 161616167), -- Mariano Vargas
    (30234567890, 181818189), -- Elena Hernandez
    (30234567890, 191919200), -- Gustavo Silva
    (30234567890, 202020211); -- Renata Chavez

-----------------------------
-- Insertar datos en la tabla Email
INSERT INTO Email (PK_Mail, FK_Dni_deu)
VALUES
    ('ana@example.com', 34567890),
    ('carlos@example.com', 45678901),
	('carlos@gmail.com', 111111111),
	('luisa@yahoo.com', 222222222),
	('laura@hotmail.com', 333333333),
	('diego@gmail.com', 444444444),
	('maria@gmail.com', 555555555),
	('juan@yahoo.com', 666666666),
	('ana@hotmail.com', 777777777),
	('sergio@gmail.com', 888888888),
	('carolina@yahoo.com', 999999999),
	('andres@hotmail.com', 101010101),
	('isabel@gmail.com', 111111122),
	('daniel@yahoo.com', 121212123),
	('natalia@hotmail.com', 131313134),
	('pedro@gmail.com', 141414145),
	('julia@yahoo.com', 151515156),
	('mariano@hotmail.com', 161616167),
	('valentina@gmail.com', 171717178),
	('elena@yahoo.com', 181818189),
	('gustavo@hotmail.com', 191919200),
	('renata@gmail.com', 202020211);

-- Insertar datos en la tabla Telefono
INSERT INTO Telefono (PK_Num_Tel, Tipo, FK_Dni_deuT)
VALUES
    (11223344, 'Celular', 34567890),
    (22334455, 'fijo', 45678901),
	(1111111111, 'Celular', 111111111),
	(2222222222, 'fijo', 222222222),
	(3333333333, 'fijo', 333333333),
	(4444444444, 'Celular', 444444444),
	(5555555555, 'fijo', 555555555),
	(6666666666, 'fijo', 666666666),
	(7777777777, 'Celular', 777777777),
	(8888888888, 'fijo', 888888888),
	(9999999999, 'fijo', 999999999),
	(1010101010, 'Celular', 101010101),
	(1111111222, 'fijo', 111111122),
	(1212121233, 'fijo', 121212123),
	(1313131344, 'Celular', 131313134),
	(1414141455, 'fijo', 141414145),
	(1515151566, 'fijo', 151515156),
	(1616161677, 'Celular', 161616167),
	(1717171788, 'fijo', 171717178),
	(1818181899, 'fijo', 181818189),
	(1919192000, 'Celular', 191919200),
	(2020202111, 'fijo', 202020211);

-- Insertar datos en la tabla FormaPago
INSERT INTO FormaPago (Comision, Cant_Cuotas, Intereses)
VALUES -- Puede añadirse el soporte a mas cantidad de cuotas si se desea
    (0.20, 3,'0.2'), -- Intereses de empresa por servicio de cuotas (empresa contratada para cobrar a personas con o sin tarjetas de credito con opcion de cuotas)
    (0.25, 6,'0.5'),
	(0.15, 1,'0');

-- Insertar datos en la tabla Convenio
-- Reset serial:
SELECT setval( (SELECT pg_get_serial_sequence('Convenio', 'pk_num_con') ), 1, false);

-- id (serial) - fecha - estado (A,C,F) - MontoPagar - recargo - idFP - DniDEU
INSERT INTO Convenio (Fecha_Con, estado, montoPagar, recargo, FK_Id_Pago, FK_Dni_deuC) VALUES ('2023-04-01', 'C', 75560, 5000, 1, 111111111);
INSERT INTO Convenio (Fecha_Con, estado, montoPagar, recargo, FK_Id_Pago, FK_Dni_deuC) VALUES ('2023-07-03', 'A', 30186, 3000, 1, 111111111);
INSERT INTO Convenio (Fecha_Con, estado, montoPagar, recargo, FK_Id_Pago, FK_Dni_deuC)
VALUES
    ('2023-08-01', 'A', 64000, 4500, 1, 34567890),
    ('2022-05-05','F', 450000, 25000, 2, 45678901);
INSERT INTO Convenio (Fecha_Con, estado, montoPagar, recargo, FK_Id_Pago, FK_Dni_deuC) VALUES ('2023-02-04', 'F', 72000, 4800, 2, 222222222);
INSERT INTO Convenio (Fecha_Con, estado, montoPagar, recargo, FK_Id_Pago, FK_Dni_deuC) VALUES ('2022-01-01', 'F', 18000, 0, 3, 333333333);
INSERT INTO Convenio (Fecha_Con, estado, montoPagar, recargo, FK_Id_Pago, FK_Dni_deuC) VALUES ('2023-04-10', 'F', 90000, 0, 3, 444444444);
INSERT INTO Convenio (Fecha_Con, estado, montoPagar, recargo, FK_Id_Pago, FK_Dni_deuC) VALUES ('2023-07-20', 'F', 6000, 0, 3, 555555555);
INSERT INTO Convenio (Fecha_Con, estado, montoPagar, recargo, FK_Id_Pago, FK_Dni_deuC) VALUES ('2021-12-05', 'F', 25000, 0, 3, 666666666);
INSERT INTO Convenio (Fecha_Con, estado, montoPagar, recargo, FK_Id_Pago, FK_Dni_deuC) VALUES ('2023-03-15', 'F', 11000, 0, 3, 777777777); 
INSERT INTO Convenio (Fecha_Con, estado, montoPagar, recargo, FK_Id_Pago, FK_Dni_deuC) VALUES ('2023-07-25', 'F', 240000, 10000, 1, 888888888);
INSERT INTO Convenio (Fecha_Con, estado, montoPagar, recargo, FK_Id_Pago, FK_Dni_deuC) VALUES ('2022-04-10', 'F', 45000, 1500, 1, 999999999);
INSERT INTO Convenio (Fecha_Con, estado, montoPagar, recargo, FK_Id_Pago, FK_Dni_deuC) VALUES ('2023-06-12', 'F', 60000, 2000, 1, 101010101);
INSERT INTO Convenio (Fecha_Con, estado, montoPagar, recargo, FK_Id_Pago, FK_Dni_deuC) VALUES ('2022-07-30', 'C', 36000, 1200, 2, 111111122);
INSERT INTO Convenio (Fecha_Con, estado, montoPagar, recargo, FK_Id_Pago, FK_Dni_deuC) VALUES ('2022-10-15', 'A', 36000, 0, 1, 111111122);
INSERT INTO Convenio (Fecha_Con, estado, montoPagar, recargo, FK_Id_Pago, FK_Dni_deuC) VALUES ('2022-02-15', 'F', 9000, 0, 3, 121212123);
INSERT INTO Convenio (Fecha_Con, estado, montoPagar, recargo, FK_Id_Pago, FK_Dni_deuC) VALUES ('2022-08-05', 'A', 96000, 0, 2, 141414145);
INSERT INTO Convenio (Fecha_Con, estado, montoPagar, recargo, FK_Id_Pago, FK_Dni_deuC) VALUES ('2021-06-20', 'F', 70000, 0, 3, 151515156);
INSERT INTO Convenio (Fecha_Con, estado, montoPagar, recargo, FK_Id_Pago, FK_Dni_deuC) VALUES ('2023-03-22', 'F', 130000, 0, 1, 161616167);
INSERT INTO Convenio (Fecha_Con, estado, montoPagar, recargo, FK_Id_Pago, FK_Dni_deuC) VALUES ('2022-01-10', 'F', 108000, 4000, 2, 171717178);
INSERT INTO Convenio (Fecha_Con, estado, montoPagar, recargo, FK_Id_Pago, FK_Dni_deuC) VALUES ('2021-06-25', 'F', 10000, 0, 3, 181818189);
INSERT INTO Convenio (Fecha_Con, estado, montoPagar, recargo, FK_Id_Pago, FK_Dni_deuC) VALUES ('2023-09-01', 'F', 14000, 0, 3, 191919200);
INSERT INTO Convenio (Fecha_Con, estado, montoPagar, recargo, FK_Id_Pago, FK_Dni_deuC) VALUES ('2023-08-15', 'F', 40000, 0, 3, 202020211);

--select * from Convenio
--TRUNCATE TABLE Cuota;
--select * from Cuota
-- Insertar datos en la tabla Cuota
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (1, '2023-04-01', '2023-05-01', 25186, 1);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (2, '2023-05-10', '2023-06-01', 25186, 1);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (3, NULL, '2023-07-01', 25186, 1);

INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (1, '2023-07-03', '2023-08-03', 10062, 2);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (2, NULL, '2023-09-03', 10062, 2); 
-- la ultima cuata debe crearse al ser pagada la anterior
-- Convenio cancelado 1
----------------------
--('2023-08-01', 1, 34567890),
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (1, '2023-08-01', '2023-09-01', 21333.33, 3);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (2, NULL, '2023-10-01', 21333.33, 3);
-- Cuota pendetes: 1
----------------------
--('2022-05-05', 2, 45678901);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (1, '2022-05-05', '2022-06-05', 75000, 4);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (2, '2022-07-02', '2022-07-05', 75000, 4);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (3, '2022-08-01', '2022-08-05', 75000, 4);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (4, '2022-09-04', '2022-09-05', 75000, 4);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (5, '2022-09-28', '2022-10-05', 75000, 4);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (6, '2022-10-26', '2022-11-05', 75000, 4);
----------------------
--('2023-02-04', 2, 222222222)
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (1, '2023-02-04', '2023-03-04', 12000, 5);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (2, '2023-04-02', '2023-04-04', 12000, 5);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (3, '2023-05-01', '2023-05-04', 12000, 5);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (4, '2023-05-27', '2023-06-04', 12000, 5);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (5, '2023-06-20', '2023-07-04', 12000, 5);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (6, '2023-07-25', '2023-08-04', 12000, 5);
----------------------
--('2022-01-01', 3, 333333333)
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (1, '2022-01-01', '2022-02-01', 18000, 6);
----------------------
--('2023-04-10', 3, 444444444)
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (1, '2023-04-10', '2023-05-10', 90000, 7);
----------------------
--('2023-07-20', 3, 555555555)
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (1, '2023-07-20', '2023-08-20', 6000, 8);
----------------------
--('2021-12-05', 3, 666666666)
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (1, '2021-12-05', '2022-01-05', 25000, 9);
----------------------
--('2023-03-15', 3, 777777777)
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (1, '2023-03-15', '2023-04-15', 11000, 10);
----------------------
--('2023-07-25', 1, 888888888)
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (1, '2023-07-25', '2023-08-25', 80000, 11);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (2, '2023-08-20', '2023-09-25', 80000, 11);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (3, '2023-10-15', '2023-10-25', 80000, 11);
----------------------
--('2022-04-10', 1, 999999999)
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (1, '2022-04-10', '2022-05-10', 15000, 12);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (2, '2023-05-10', '2022-06-10', 15000, 12);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (3, '2023-05-12', '2022-07-10', 15000, 12);
----------------------
--('2023-06-12', 1, 101010101)
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (1, '2023-06-12', '2023-07-12', 20000, 13);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (2, '2023-08-05', '2023-08-12', 20000, 13);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (3, '2023-09-06', '2023-09-12', 20000, 13);
----------------------
--('2022-07-30', 2, 111111122)
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (1, '2022-07-30', '2022-08-30', 12000, 14);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (2, '2023-09-28', '2022-09-30', 12000, 14);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (3, NULL, '2022-10-30', 12000, 14);
--cancelado
--('2022-10-15', 1, 111111122)
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (1, '2022-10-15', '2022-11-16', 12000, 15);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (2, '2022-11-12', '2022-12-15', 12000, 15);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (3, NULL, '2023-01-15', 12000, 15);
----------------------
--('2022-02-15', 3, 121212123)
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (1, '2022-02-15', '2022-03-15', 9000, 16);
----------------------
--('2022-08-05', 2, 141414145)
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (1, '2022-08-05', '2022-09-05', 16000, 17);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (2, '2022-09-30', '2022-10-05', 16000, 17);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (3, '2022-10-25', '2022-11-05', 16000, 17);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (4, '2022-11-27', '2022-12-05', 16000, 17);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (5, '2023-01-02', '2023-01-05', 16000, 17);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (6, NULL, '2023-02-05', 16000, 17);
----------------------
--('2021-06-20', 3, 151515156)
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (1, '2021-06-20', '2021-07-20', 70000, 18);
----------------------
--('2023-03-22', 1, 161616167)
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (1, '2023-03-22', '2023-04-22', 130000, 19);
----------------------
--('2022-01-10', 2, 171717178)
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (1, '2022-01-10', '2022-02-10', 18000, 20);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (2, '2022-02-28', '2022-03-10', 18000, 20);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (3, '2022-04-05', '2022-04-10', 18000, 20);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (4, '2022-05-02', '2022-05-10', 18000, 20);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (5, '2022-07-03', '2022-07-10', 18000, 20);
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (6, '2022-08-03', '2022-08-10', 18000, 20);
----------------------
--('2021-06-25', 3, 181818189)
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (1, '2021-06-25', '2021-07-25', 10000, 21);
----------------------
--('2023-09-01', 3, 191919200)
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (1, '2023-09-01', '2023-10-01', 14000, 22);
----------------------
--('2023-08-15', 3, 202020211)
INSERT INTO Cuota (PK_Num_Cuota, Fecha_Pago, Vencimiento, Importe, FK_Nro_Convenio) VALUES (1, '2023-08-15', '2023-09-15', 40000, 23);



------------------------------------------------------------CONSULTAS--------------------------------------------------------------------------------
select * from convenio
select * from cuota
delete * from 

--VISTA MONTO_ADEUDADO
create view Vista_Montos_Deuda as
    select deu.pk_dni_deu DNI, deu.nom_deu NOMBRE_DEUDOR, deu.ape_deu APELLIDO_DEUDOR, deu.fk_codpostd CODIGO_POSTAL, sum(cu.importe) as MONTO_DEUDA
    from deudores as deu
        inner join convenio as conv on deu.pk_dni_deu = conv.fk_dni_deuc 
        inner join cuota as cu  on cu.fk_nro_convenio = conv.pk_num_con
    group by deu.nom_deu, deu.pk_dni_deu



create view Vista_Montos_Deuda1 as --(se ejecuta una vez)
    select deu.fk_codpostd , deu.pk_dni_deu as DNI, deu.nom_deu NOMBRE_DEUDOR, deu.ape_deu APELLIDO_DEUDOR, sum(cu.importe) MONTO_DEUDA
    from deudores as deu
        inner join convenio as conv on deu.pk_dni_deu = conv.fk_dni_deuc 
        inner join cuota as cu  on cu.fk_nro_convenio = conv.pk_num_con
    group by deu.nom_deu, deu.pk_dni_deu
-------------------------------------------------------------------
--PUNTO 6.A : Todas las empresas que contrataron cobroYA
select nom_empresa Empresa, pk_cuit Cuit, loc.ciudad as direccion from empresas as emp
inner join localidad as loc
on emp.fk_codposte = loc.pk_cod_postal 
order by direccion;
--------------------------------------------------------------------
--PUNTO 6.B : Empresas por localidad
select empresas.fk_codposte as codigo_postal, count(*) as cantidad_tot, localidad.ciudad from empresas 
inner join localidad on fk_codposte = pk_cod_postal 
group by empresas.fk_codposte, localidad.ciudad;
---------------------------------------------------------------------
--PUNTO 6.C : Lista de clientes que an firmado un convenio
select nom_deu Nombre_Dueudor,conv.fecha_con Fecha_Firma_Conv, de.MONTO_DEUDA Deuda_Total 
    from deudores as deu
    inner join convenio as conv on conv.fk_dni_deuc = deu.pk_dni_deu
    inner join Vista_Montos_Deuda as de on de.DNI = conv.fk_dni_deuc
--------------------------------------------------------------------
--PUNTO 6.D : Forma de pago mas elegida
create view cant as  -->crea vista de cantidad(se ejecuta una vez)
	select fp.pk_id_pago, fp.comision, fp.cant_cuotas, fp.intereses, count(co.fk_id_pago) as cantidad from convenio co
	inner join formapago fp on fp.pk_id_pago = co.fk_id_pago
	group by fp.pk_id_pago, fp.comision, fp.cant_cuotas, fp.intereses having count(co.fk_id_pago)>0
---------------------------------------------------------------------
select pk_id_pago,comision,cant_cuotas,intereses,cantidad from cant 
where cantidad = (select max(cantidad) from cant)
----------------------------------------------------------------------
--PUNTO 6.E : Clientes con deudas entre 25000 y 75000
select vs.nombre_deudor, vs.dni, tel.pk_num_tel, vs.monto_deuda
    from Vista_Montos_Deuda as vs
    inner join telefono as tel on tel.fk_dni_deut = vs.dni
    where vs.monto_deuda between 25000 and 75000 
    group by vs.nombre_deudor, vs.dni, tel.pk_num_tel, vs.monto_deuda order by vs.nombre_deudor
----------------------------------------------------------------------
--PUNTO F : Cliente que mas debe de la localidad de Buenos Aires
select dni,nombre_deudor,apellido_deudor,monto_deuda, deu.fk_codpostd as codigo_postal from Vista_Montos_Deuda1 as Deu
inner join localidad as loc on Deu.fk_codpostd = loc.pk_cod_postal
group by dni,nombre_deudor,apellido_deudor,monto_deuda,codigo_postal 
having monto_deuda = (select max(monto_deuda) from Vista_Montos_Deuda1 where fk_codpostd = 2000)
----------------------------------------------------------------------
--PUNTO G : Forma de pago que no haya sido selecionada por ningun cliente (fecha baja == null => activa actualmente)
select pk_id_pago id_forma_pago, fecha_baja, comision, cant_cuotas, intereses from convenio co
right join formapago fp on fp.pk_id_pago = co.fk_id_pago
where pk_num_con is null

-----------------------------------------------------------------------
--PUNTO H : Lista de convenios que han sido cancelados

--Si no existe el el estado del convenio:
select conveniosCuotaAdeudada.* from

(SELECT *
FROM Convenio c
JOIN Cuota cu ON c.PK_Num_Con = cu.FK_Nro_Convenio
WHERE cu.Fecha_Pago IS NULL -- Cuota pendiente de pago
ORDER BY c.PK_Num_Con) as conveniosCuotaAdeudada

inner join

(select max(pk_num_con), Convenio.fk_dni_deuc from Convenio inner JOIN Deudores ON Convenio.FK_Dni_deuC = Deudores.PK_Dni_deu
group by Convenio.fk_dni_deuc) as utimosConvenioDeu

on utimosConvenioDeu.fk_dni_deuc = conveniosCuotaAdeudada.fk_dni_deuc AND conveniosCuotaAdeudada.pk_num_con < utimosConvenioDeu.max

--Teneidno en cuenta el campo estado del convenio : 
SELECT DISTINCT c.*, d.Nom_Deu
FROM Convenio c
JOIN Cuota cu ON c.PK_Num_Con = cu.FK_Nro_Convenio
JOIN Deudores d ON c.FK_Dni_deuC = d.PK_Dni_deu
where c.estado = 'C'


select * from DeudorEmpresa
------------------------------------------------------------------
--PUNTO I : Deuda total por empresa
select emp.nom_empresa Nombre_Empresa, emp.pk_cuit as cuit, sum(vs.monto_deuda) as Deuda_Total 
    from empresas as emp
	inner join DeudorEmpresa as DyE on DyE.fk_cuit = emp.pk_cuit
    inner join Vista_Montos_Deuda as vs on vs.dni = DyE.fk_dni_deu
    group by emp.nom_empresa, emp.pk_cuit

------------------------------------------------------------------
--PUNTO J : Empleado que logro firmar mayor cantidad de convevnios
create view convenios as --> crea vista de convenios (solo se ejecuta una vez)
	select empleados.pk_dni_emp as dni_empleado, empleados.nom_emp as nombre, empleados.ape_emp as apellido, count(*) as convenios_firmados  from empleados
	inner join empresas on empleados.pk_dni_emp = empresas.fk_dni -- TODO
	inner join DeudorEmpresa on empresas.pk_cuit = DeudorEmpresa.FK_Cuit
	inner join deudores on DeudorEmpresa.FK_Dni_deu = deudores.pk_dni_deu 
	inner join convenio on deudores.pk_dni_deu = convenio.fk_dni_deuc
	GROUP BY dni_empleado, nombre, apellido
-- =>
select nombre,apellido,dni_empleado,convenios_firmados from convenios 
where (select max(convenios_firmados)from convenios) = convenios_firmados
-------------------------------------------------------------------
--REPORTE: Informe por mes a cada empresa la cantidad de cuotas cobradas a su favor, importe total cobrado, importe total a rendir(que sera el resultado de quitar al importe cobrado por cuota, el porcentaje de comision)
CREATE OR REPLACE FUNCTION cuotas_cobradas_a_favor_por_empresa( fechaMes NUMERIC )
RETURNS TABLE (
    mes NUMERIC,
    empresa varchar(25),
	cuotas_cobradas bigint,
	importe_total FLOAT,
	importe_total_rendir FLOAT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        fechaMes as mes,
        Empresas.Nom_empresa as empresa, COUNT(Cuota.PK_Num_Cuota) as cuotas_cobradas ,SUM(Cuota.Importe) as importe_total, SUM(Cuota.Importe * FP.Comision) as importe_total_rendir from Cuota 
		inner join Convenio on Convenio.pk_num_Con = Cuota.FK_Nro_Convenio
		inner join FormaPago as FP on FP.PK_Id_Pago = Convenio.FK_Id_Pago
		inner join DeudorEmpresa as DyE on DyE.FK_Dni_deu = Convenio.FK_Dni_deuC
		inner join Empresas on Empresas.PK_Cuit = DyE.FK_Cuit
		where EXTRACT(MONTH FROM Cuota.Fecha_Pago) = fechaMes
		group by Empresas.Nom_empresa;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM cuotas_cobradas_a_favor_por_empresa(9);

--------------------------------------
--Consulta fuera de la funcion: 
select Empresas.Nom_empresa, COUNT(Cuota.PK_Num_Cuota) as nro_cuotas ,SUM(Cuota.Importe) as importe_total, SUM(Cuota.Importe * FP.Comision) as importe_rendir from Cuota 
inner join Convenio on Convenio.pk_num_Con = Cuota.FK_Nro_Convenio
inner join FormaPago as FP on FP.PK_Id_Pago = Convenio.FK_Id_Pago
inner join DeudorEmpresa as DyE on DyE.FK_Dni_deu = Convenio.FK_Dni_deuC
inner join Empresas on Empresas.PK_Cuit = DyE.FK_Cuit
where EXTRACT(MONTH FROM Cuota.Fecha_Pago) = 9
group by Empresas.Nom_empresa





--------------------------------------------------------------------------------------------------------
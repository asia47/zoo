USE master
GO

DROP DATABASE IF EXISTS temporal_prueba_db
GO

CREATE DATABASE temporal_prueba_db
go

USE temporal_prueba_db
go

CREATE TABLE empleado (
	id integer PRIMARY KEY not null,
	tipo varchar(20) not null,
	nombre varchar(20) not null,
	dni varchar(12) not null,
	ValidFrom datetime2 GENERATED ALWAYS AS ROW START,
	ValidTo datetime2 GENERATED ALWAYS AS ROW END,
	PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
) WITH (
	SYSTEM_VERSIONING = ON 
	(HISTORY_TABLE = dbo.empleado_history)
)
GO

INSERT INTO empleado (id, tipo, nombre, dni)
	VALUES
		(1, 'Cuidador', 'Manuel Charlín', '23785264N'),
		(2, 'Veterinario', 'Paco Vázquez', '23785265O'),
		(3, 'Limpiador', 'Álvaro Cotino', '23785266P'),
		(4, 'Mantenimiento', 'Álvaro Lapuerta', '23489877Q')
GO

DELETE FROM empleado
	where id = 2
go

UPDATE empleado 
	SET nombre = 'Alvaro Laventana'
	where id = 4
go

SELECT * FROM empleado
go

SELECT * FROM empleado_history
go

use master
go
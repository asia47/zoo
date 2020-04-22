use master
go

-- primary, fg_antiguo, fg_2016, fg_2017, fg_2018
DROP DATABASE IF EXISTS ppartition
GO

-- vamos a particionar una tabla en distintos filegroups
-- en función de la fecha_alta para eso necesitamos tantos
-- filegroups como particiones queramos hacer
CREATE DATABASE ppartition ON PRIMARY (
	NAME = 'ppartition_db_prim',
	FILENAME = 'C:\db_data\ppartition_db_prim.mdf',
	SIZE = 30MB,
	MAXSIZE = 2GB,
	FILEGROWTH = 512MB
), FILEGROUP fg_antiguo (
	NAME = 'ppartition_db_fg_antiguo_dat',
	FILENAME = 'C:\db_data\ppartition_db_fg_antiguo_dat.ndf',
	SIZE = 30MB,
	MAXSIZE = 2GB,
	FILEGROWTH = 512MB
), FILEGROUP fg_2018 (
	NAME = 'ppartition_db_fg_2018_dat',
	FILENAME = 'C:\db_data\ppartition_db_fg_2018_dat.ndf',
	SIZE = 30MB,
	MAXSIZE = 2GB,
	FILEGROWTH = 512MB
), FILEGROUP fg_2019 (
	NAME = 'ppartition_db_fg_2019_dat',
	FILENAME = 'C:\db_data\ppartition_db_fg_2019_dat.ndf',
	SIZE = 30MB,
	MAXSIZE = 2GB,
	FILEGROWTH = 512MB
), FILEGROUP fg_2020_etc (
	NAME = 'ppartition_db_fg_2020_etc_dat',
	FILENAME = 'C:\db_data\ppartition_db_fg_2020_etc_dat.ndf',
	SIZE = 30MB,
	MAXSIZE = 2GB,
	FILEGROWTH = 512MB
) LOG ON (
	NAME = 'ppartition_db_log',
	FILENAME = 'C:\db_data\ppartition_db_log.ldf',
	SIZE = 10MB,
	MAXSIZE = 512MB,
	FILEGROWTH = 100MB
)
GO

USE ppartition
GO

-- Para particionar necesitamos crear una fuinción de partición
CREATE PARTITION FUNCTION fecha_alta_func (datetime)
AS RANGE RIGHT
	FOR VALUES('2018-01-01', '2019-01-01', '2020-01-01')
GO

-- Luego aplicamos la función de partición a un nuevo 
-- esquema de partición
CREATE PARTITION SCHEME fecha_alta_sch
AS PARTITION fecha_alta_func
	TO (fg_antiguo, fg_2018, fg_2019, fg_2020_etc)
GO

-- Ahora creamos la tabla a particionar en función del
-- atributo fecha_alta, aplicando el esquema anterior
CREATE TABLE altas_personal (
	id integer,
	nombre varchar(50),
	apellidos varchar(100),
	fecha_alta datetime,
	PRIMARY KEY (id, fecha_alta)
) ON fecha_alta_sch (fecha_alta)
GO

-- INTRODUCIMOS DATOS EN LA TABLA PARTICIONADA
INSERT INTO altas_personal VALUES
	(1, 'Pedro', 'Ruiz', '2016-01-01'),
	(2, 'Lucas', 'Rodriguez', '2017-05-05'),
	(3, 'Manuel', 'Iglesias', '2017-08-11'),
	(4, 'Antonio', 'García', '2018-11-09'),
	(5, 'Pepito', 'Perez', '2019-05-14'),
	(6, 'Romualdo', 'Espinosa', '2020-01-06'),
	(7, 'Maria', 'García', '2020-02-14')
GO

-- COMPROBAMOS
SELECT *, $PARTITION.fecha_alta_func(fecha_alta) AS 'partición'
	FROM altas_personal
GO

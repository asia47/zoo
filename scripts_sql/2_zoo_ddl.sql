-- DDL zoo
-- Tercero en ejecutar

USE zoo
GO

-- CREACION DE TABLAS
-- borrado de tablas


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'animal_espectaculo_cuidador' AND type = 'U')
	DROP TABLE animal_espectaculo_cuidador
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'animal_veterinario' AND type = 'U')
	DROP TABLE animal_veterinario
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'animal_cuidador' AND type = 'U')
	DROP TABLE animal_cuidador
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'recinto_limpiador' AND type = 'U')
	DROP TABLE recinto_limpiador
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'recinto_mantenimiento' AND type = 'U')
	DROP TABLE recinto_mantenimiento
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'espectaculo' AND type = 'U')
	DROP TABLE espectaculo
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'animal' AND type = 'U')
	DROP TABLE animal
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'empleado' AND type = 'U')
	DROP TABLE empleado
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'recinto' AND type = 'U')
	DROP TABLE recinto
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'tarifa' AND type = 'U')
	DROP TABLE tarifa
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'turno' AND type = 'U')
	DROP TABLE turno
GO

--  entidades primarias
CREATE TABLE turno (
	id integer PRIMARY KEY not null,
	fecha_inicio datetime not null,
	fecha_fin datetime not null,
	hora_inicio varchar(8) not null default '09:00:00',
	hora_fin varchar(8) not null default '17:00:00'
)
GO

CREATE TABLE tarifa (
	id integer PRIMARY KEY not null,
	precio money not null default 0,
	nombre varchar(20)
)
GO

CREATE TABLE recinto (
	id integer PRIMARY KEY not null,
	nombre varchar(20),
	localizacion varchar(5) not null,
	dimension integer not null
)
ON zoo_db_fg1
GO

CREATE TABLE empleado (
	id integer PRIMARY KEY not null,
	tipo varchar(20) not null,
	nombre varchar(20) not null,
	dni varchar(12) not null,
	nss varchar(12) not null,
	telefono integer not null,
	direccion varchar(50) not null,
	id_turno integer FOREIGN KEY REFERENCES turno(id) not null
)
ON zoo_db_fg1
GO

CREATE TABLE animal (
	id integer PRIMARY KEY not null,
	nombre varchar(30) not null,
	especie varchar(20),
	sexo char(1),
	color varchar(20),
	fecha_nacimiento date,
	nacimiento_en_cautiverio bit,
	imagen varbinary(max) FILESTREAM NULL,
	imagen_id uniqueidentifier ROWGUIDCOL NOT NULL UNIQUE DEFAULT newsequentialid(),
	id_padre integer FOREIGN KEY REFERENCES animal(id),
	id_madre integer FOREIGN KEY REFERENCES animal(id),
	id_recinto integer FOREIGN KEY REFERENCES recinto(id)
)
ON zoo_db_fg1
filestream_on fs_files
GO

CREATE TABLE espectaculo (
	id integer PRIMARY KEY not null,
	nome varchar(20) not null,
	fecha datetime not null,
	id_tarifa integer FOREIGN KEY REFERENCES tarifa(id) not null,
	id_recinto integer FOREIGN KEY REFERENCES recinto(id) not null
)
ON zoo_db_fg1
GO

--  relaciones
CREATE TABLE recinto_mantenimiento (
	id_mantenimiento integer FOREIGN KEY REFERENCES empleado(id) not null,
	id_recinto integer FOREIGN KEY REFERENCES recinto(id) not null
)
GO

CREATE TABLE recinto_limpiador (
	id_limpiador integer FOREIGN KEY REFERENCES empleado(id) not null,
	id_recinto integer FOREIGN KEY REFERENCES recinto(id) not null
)
GO

CREATE TABLE animal_cuidador (
	id_cuidador integer FOREIGN KEY REFERENCES empleado(id) not null,
	id_animal integer FOREIGN KEY REFERENCES animal(id) not null
)
GO

CREATE TABLE animal_veterinario (
	id_veterinario integer FOREIGN KEY REFERENCES empleado(id) not null,
	id_animal integer FOREIGN KEY REFERENCES animal(id) not null
)
GO

CREATE TABLE animal_espectaculo_cuidador (
	id_cuidador integer FOREIGN KEY REFERENCES empleado(id) not null,
	id_espectaculo integer FOREIGN KEY REFERENCES espectaculo(id) not null,
	id_animal integer FOREIGN KEY REFERENCES animal(id) not null,
	horario varchar(50) not null
)
GO


USE master
GO

-- ZOO_CREATE
-- Segundo en ejecutar

-- CREACION SIMPLE DE LA BD
/*USE master
GO

DROP DATABASE IF EXISTS zoo
GO

CREATE DATABASE zoo
GO*/

--CREACIÓN DETALLADA DE LA BASE DE DATOS

USE master
GO

DROP DATABASE IF EXISTS zoo
GO

CREATE DATABASE zoo ON PRIMARY (
	NAME = 'zoo_db_prim',
	FILENAME = 'C:\db_data\zoo_db_prim.mdf',
	SIZE = 30MB,
	MAXSIZE = 2GB,
	FILEGROWTH = 512MB
), FILEGROUP zoo_db_fg1 (
	NAME = 'zoo_db_fg1_dat1',
	FILENAME = 'C:\db_data\zoo_db_fg1_dat1.ndf',
	SIZE = 30MB,
	MAXSIZE = 2GB,
	FILEGROWTH = 512MB
), (
	NAME = 'zoo_db_fg1_dat2',
	FILENAME = 'C:\db_data\zoo_db_fg1_dat2.ndf',
	SIZE = 30MB,
	MAXSIZE = 2GB,
	FILEGROWTH = 512MB
), FILEGROUP fs_files CONTAINS FILESTREAM DEFAULT (
	NAME = 'fs_files',
	FILENAME = 'C:\db_data\fs_files'	
) LOG ON (
	NAME = 'zoo_db_log',
	FILENAME = 'C:\db_data\zoo_db_log.ldf',
	SIZE = 10MB,
	MAXSIZE = 512MB,
	FILEGROWTH = 100MB
)
GO

USE master
GO



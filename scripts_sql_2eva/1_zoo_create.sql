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

-- fg_esp_antiguo, fg_esp_2019, fg_esp_2020

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
),FILEGROUP fg_esp_antiguo (
	NAME = 'fg_esp_antiguo',
	FILENAME = 'C:\db_data\fg_esp_antiguo.ndf',
	SIZE = 30MB,
	MAXSIZE = 2GB,
	FILEGROWTH = 512MB
), FILEGROUP fg_esp_2019 (
	NAME = 'fg_esp_2019',
	FILENAME = 'C:\db_data\fg_esp_2019.ndf',
	SIZE = 30MB,
	MAXSIZE = 2GB,
	FILEGROWTH = 512MB
), FILEGROUP fg_esp_2020 (
	NAME = 'fg_esp_2020',
	FILENAME = 'C:\db_data\fg_esp_2020.ndf',
	SIZE = 30MB,
	MAXSIZE = 2GB,
	FILEGROWTH = 512MB
), FILEGROUP fs_files CONTAINS FILESTREAM DEFAULT (
	NAME = 'fs_files',
	FILENAME = 'C:\db_data\fs_files'	
), FILEGROUP zoo_db_fg_mem CONTAINS MEMORY_OPTIMIZED_DATA (
	NAME = 'zoo_db_fg_mem',
	FILENAME = 'C:\db_data\zoo_db_fg_mem',
	MAXSIZE = UNLIMITED
) LOG ON (
	NAME = 'zoo_db_log',
	FILENAME = 'C:\db_data\zoo_db_log.ldf',
	SIZE = 10MB,
	MAXSIZE = 512MB,
	FILEGROWTH = 100MB
) WITH FILESTREAM (
	non_transacted_access = full,
	directory_name = 'cont_rrcc_de_filetables'	-- contenedor de recursos compartidos de filetables
)
GO

USE master
GO



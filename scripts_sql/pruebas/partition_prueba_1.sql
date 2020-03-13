use master
go

-- primary, fg_antiguo, fg_2016, fg_2017, fg_2018
DROP DATABASE IF EXISTS ppartition
GO

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
), FILEGROUP fg_2016 (
	NAME = 'ppartition_db_fg_2016_dat',
	FILENAME = 'C:\db_data\ppartition_db_fg_2016_dat.ndf',
	SIZE = 30MB,
	MAXSIZE = 2GB,
	FILEGROWTH = 512MB
), FILEGROUP fg_2017 (
	NAME = 'ppartition_db_fg_2017_dat',
	FILENAME = 'C:\db_data\ppartition_db_fg_2017_dat.ndf',
	SIZE = 30MB,
	MAXSIZE = 2GB,
	FILEGROWTH = 512MB
), FILEGROUP fg_2018 (
	NAME = 'ppartition_db_fg_2018_dat',
	FILENAME = 'C:\db_data\ppartition_db_fg_2018_dat.ndf',
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
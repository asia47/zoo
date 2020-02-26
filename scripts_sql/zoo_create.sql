-- ZOO_CREATE

-- CREACION SIMPLE DE LA BD
/*USE master
GO

DROP DATABASE IF EXISTS zoo
GO

CREATE DATABASE zoo
GO*/

--CREACI�N DETALLADA DE LA BASE DE DATOS

USER master
GO

DROP DATABASE IF EXISTS zoo
GO

CREATE DATABASE zoo ON PRIMARY (
	NAME = 'zoo_db',
	FILENAME = 'C:\db_data\zoo_db.mdf',
	SIZE = 30MB,
	MAXSIZE = 2GB,
	FILEGROUTH = 512MB
) LOG ON (
	NAME = 'zoo_db_log',
	FILENAME = 'C:\db_data\zoo_db_log.ldf',
	SIZE = 10MB,
	MAXSIZE = 512MB,
	FILEGROWTH = 100MB
)
GO
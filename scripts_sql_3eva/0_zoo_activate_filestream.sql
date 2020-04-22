-- Primero en ejecutarse
-- Necesitamos que el filestream esté activado en la configuración del sql server (ver Configuration Manager)
-- Sólo es necesario ejecutarlo una vez en cada sql server diferente

USE master
GO

EXEC sp_configure filestream_access_level, 2
	RECONFIGURE
GO

USE master
GO
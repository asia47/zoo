
USE zoo
GO

/*

-- PARA COMPROBAR QUE LA TABLA TEMPORAL EMPLEADO FUNCIONA

SELECT * FROM empleado
GO

SELECT * FROM empleado_history
GO

-- COMPROBAMOS LA TABLA MEMORY OPTIMIZED
SELECT * FROM nombre_visitante_actual
GO

-- COMPROBAMOS QUE LA TABLA ESPECTACULO ESTá PARTIOCIONADA
SELECT *, 
		$PARTITION.fecha_espectaculo_func(fecha) 
			AS 'número de partición'
	FROM espectaculo
GO

*/

USE master
GO



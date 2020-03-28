
USE zoo
GO

/*

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

-- PRUEBAS DE LA TEMPORAL TABLE EMPLEADO (VEMOS QUE FUNCIONA)

USE zoo
GO

SELECT id, tipo, nombre, valid_from, valid_to FROM empleado
UNION
SELECT id, tipo, nombre, valid_from, valid_to FROM empleado_history
	ORDER BY valid_from
GO

SELECT id, tipo, nombre, valid_from, valid_to
	FROM empleado
GO

/*
1	Cuidador	Manuel Charlín	2020-03-28 16:12:41.4183512	9999-12-31 23:59:59.9999999
2	Veterinario	Paco Vázquez	2020-03-28 16:12:41.4183512	9999-12-31 23:59:59.9999999
3	Limpiador	Álvaro Cotino	2020-03-28 16:12:41.4183512	9999-12-31 23:59:59.9999999
4	Mantenimiento	Alvaro Laventana	2020-03-28 16:12:43.5789935	9999-12-31 23:59:59.9999999
*/

SELECT id, tipo, nombre, valid_from, valid_to
	FROM empleado_history
GO

/*
4	Mantenimiento	Álvaro Lapuerta	2020-03-28 16:12:41.4183512	2020-03-28 16:12:43.5789935
5	Mantenimiento	Pepe Gotera	2020-03-28 16:12:45.6076888	2020-03-28 16:12:47.6527380
5	Mantenimiento	Paco Gotera	2020-03-28 16:12:47.6527380	2020-03-28 16:12:49.6955366
*/

-- AS OF <date_time> -- Returns values for a specific data and time.

SELECT id, tipo, nombre, valid_from, valid_to
	FROM empleado
	FOR SYSTEM_TIME AS OF '2020-03-28 16:12:41.4183512'
GO

/*
1	Cuidador	Manuel Charlín	2020-03-28 16:12:41.4183512	9999-12-31 23:59:59.9999999
2	Veterinario	Paco Vázquez	2020-03-28 16:12:41.4183512	9999-12-31 23:59:59.9999999
3	Limpiador	Álvaro Cotino	2020-03-28 16:12:41.4183512	9999-12-31 23:59:59.9999999
4	Mantenimiento	Álvaro Lapuerta	2020-03-28 16:12:41.4183512	2020-03-28 16:12:43.5789935
*/

SELECT id, tipo, nombre, valid_from, valid_to
	FROM empleado
	FOR SYSTEM_TIME AS OF '2020-03-28 16:12:45.6076888'
GO

/*
1	Cuidador	Manuel Charlín	2020-03-28 16:12:41.4183512	9999-12-31 23:59:59.9999999
2	Veterinario	Paco Vázquez	2020-03-28 16:12:41.4183512	9999-12-31 23:59:59.9999999
3	Limpiador	Álvaro Cotino	2020-03-28 16:12:41.4183512	9999-12-31 23:59:59.9999999
4	Mantenimiento	Alvaro Laventana	2020-03-28 16:12:43.5789935	9999-12-31 23:59:59.9999999
5	Mantenimiento	Pepe Gotera	2020-03-28 16:12:45.6076888	2020-03-28 16:12:47.6527380
*/

SELECT id, tipo, nombre, valid_from, valid_to
	FROM empleado
	FOR SYSTEM_TIME AS OF '2020-03-28 16:12:47.6527380'
GO

/*
1	Cuidador	Manuel Charlín	2020-03-28 16:12:41.4183512	9999-12-31 23:59:59.9999999
2	Veterinario	Paco Vázquez	2020-03-28 16:12:41.4183512	9999-12-31 23:59:59.9999999
3	Limpiador	Álvaro Cotino	2020-03-28 16:12:41.4183512	9999-12-31 23:59:59.9999999
4	Mantenimiento	Alvaro Laventana	2020-03-28 16:12:43.5789935	9999-12-31 23:59:59.9999999
5	Mantenimiento	Paco Gotera	2020-03-28 16:12:47.6527380	2020-03-28 16:12:49.6955366
*/

-- FROM <start_date_time> TO <end_date_time> -- Returns a range of values between the 
-- specified date and time.

-- mostramos el estado de la tabla en el momento (FROM) '2020-03-28 16:12:44' mas todos los 
-- cambios realizados sobre ese tabla desede (FROM) '2020-03-28 16:12:44' hasta (TO)
-- '2020-03-28 16:12:48'
-- Si alguno de los cambios coincidiera en tiempo con los valores especificados en FROM o TO
-- no se mostrará en el resultado

SELECT id, tipo, nombre, valid_from, valid_to
	FROM empleado
	FOR SYSTEM_TIME FROM '2020-03-28 16:12:44' TO '2020-03-28 16:12:48'
GO

/*
1	Cuidador	Manuel Charlín	2020-03-28 16:12:41.4183512	9999-12-31 23:59:59.9999999
2	Veterinario	Paco Vázquez	2020-03-28 16:12:41.4183512	9999-12-31 23:59:59.9999999
3	Limpiador	Álvaro Cotino	2020-03-28 16:12:41.4183512	9999-12-31 23:59:59.9999999
4	Mantenimiento	Alvaro Laventana	2020-03-28 16:12:43.5789935	9999-12-31 23:59:59.9999999
5	Mantenimiento	Pepe Gotera	2020-03-28 16:12:45.6076888	2020-03-28 16:12:47.6527380
5	Mantenimiento	Paco Gotera	2020-03-28 16:12:47.6527380	2020-03-28 16:12:49.6955366
*/

-- BETWEEN <start_date_time> AND <end_date_time> -- Returns a range of values between 
-- the specified date and time.
SELECT id, tipo, nombre, valid_from, valid_to
	FROM empleado
	FOR SYSTEM_TIME BETWEEN '2020-03-28 16:12:44' AND '2020-03-28 16:12:47.6527380'
GO

/*
1	Cuidador	Manuel Charlín	2020-03-28 16:12:41.4183512	9999-12-31 23:59:59.9999999
2	Veterinario	Paco Vázquez	2020-03-28 16:12:41.4183512	9999-12-31 23:59:59.9999999
3	Limpiador	Álvaro Cotino	2020-03-28 16:12:41.4183512	9999-12-31 23:59:59.9999999
4	Mantenimiento	Alvaro Laventana	2020-03-28 16:12:43.5789935	9999-12-31 23:59:59.9999999
5	Mantenimiento	Pepe Gotera	2020-03-28 16:12:45.6076888	2020-03-28 16:12:47.6527380
5	Mantenimiento	Paco Gotera	2020-03-28 16:12:47.6527380	2020-03-28 16:12:49.6955366
*/

-- CONTAINED IN (<start_date_time>, <end_date_time>) -- Returns a range of values based 
-- in the supplied date and time values.

-- este solo muestra los cambios

SELECT id, tipo, nombre, valid_from, valid_to
	FROM empleado
	FOR SYSTEM_TIME CONTAINED IN ('2020-03-28 16:12:41', '2020-03-28 16:12:48')
GO

/*
4	Mantenimiento	Álvaro Lapuerta	2020-03-28 16:12:41.4183512	2020-03-28 16:12:43.5789935
5	Mantenimiento	Pepe Gotera	2020-03-28 16:12:45.6076888	2020-03-28 16:12:47.6527380
*/

-- ALL – Return all values

-- DEVUELVE EL MISMO VALOR QUE LA UNION DE LAS 2 TABLAS (empleado y empleado_history)
/*
SELECT id, tipo, nombre, valid_from, valid_to FROM empleado
UNION
	SELECT id, tipo, nombre, valid_from, valid_to FROM empleado_history
GO
*/

SELECT id, tipo, nombre, valid_from, valid_to
	FROM empleado
	FOR SYSTEM_TIME ALL
GO

/*
1	Cuidador	Manuel Charlín	2020-03-28 16:12:41.4183512	9999-12-31 23:59:59.9999999
2	Veterinario	Paco Vázquez	2020-03-28 16:12:41.4183512	9999-12-31 23:59:59.9999999
3	Limpiador	Álvaro Cotino	2020-03-28 16:12:41.4183512	9999-12-31 23:59:59.9999999
4	Mantenimiento	Álvaro Lapuerta	2020-03-28 16:12:41.4183512	2020-03-28 16:12:43.5789935
4	Mantenimiento	Alvaro Laventana	2020-03-28 16:12:43.5789935	9999-12-31 23:59:59.9999999
5	Mantenimiento	Paco Gotera	2020-03-28 16:12:47.6527380	2020-03-28 16:12:49.6955366
5	Mantenimiento	Pepe Gotera	2020-03-28 16:12:45.6076888	2020-03-28 16:12:47.6527380
*/

USE master
GO



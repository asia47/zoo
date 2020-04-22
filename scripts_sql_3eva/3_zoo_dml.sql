--zoo dml
-- Cuarto en ejecutar
USE zoo
GO

-- INSERTS

INSERT INTO turno (id, fecha_inicio, fecha_fin, hora_inicio, hora_fin)
	VALUES 
		(1, '2020-01-01', '2020-12-31', '09:00:00', '17:00:00'),
		(2, '2020-01-01', '2020-12-31', '17:00:00', '01:00:00'),
		(3, '2020-01-01', '2020-12-31', '01:00:00', '09:00:00')
GO

INSERT INTO tarifa (id, precio, nombre)
	VALUES
		(1, 15, 'Básica'),
		(2, 20, 'Normal'),
		(3, 25, 'VIP')
GO

INSERT INTO recinto (id, nombre, localizacion, dimension)
	VALUES 
		(1, 'Paquistán', '4B', '100100'),
		(2, 'Irán', '3C', '200300'),
		(3, 'Irak', '2Z', '400200')
GO

INSERT INTO empleado (id, tipo, nombre, dni, nss, telefono, direccion, id_turno)
	VALUES
		(1, 'Cuidador', 'Manuel Charlín', '23785264N', '128723763', '986873789', 'O Freixo 12', 1),
		(2, 'Veterinario', 'Paco Vázquez', '23785265O', '128723764', '986873780', 'O Medrón 23', 2),
		(3, 'Limpiador', 'Álvaro Cotino', '23785266P', '128723765', '986873781', 'Parameán 10', 3),
		(4, 'Mantenimiento', 'Álvaro Lapuerta', '23489877Q', '123678456', '986673982', 'O Testal', 2)
GO

/*INSERT INTO animal 
	(id, nombre, especie, sexo, color, fecha_nacimiento, nacimiento_en_cautiverio, id_padre, id_madre, id_recinto)
	VALUES
		(1, 'Copito de nieve', 'Orangután', 'M', 'Blanco', '2000-02-03', 0, null, null, 1)
GO */

INSERT INTO animal
	(id, nombre, especie, sexo, color, fecha_nacimiento, nacimiento_en_cautiverio, imagen, imagen_id, id_padre, id_madre, id_recinto)
	SELECT 1, 'Copito de nieve', 'Orangután', 'M', 'Blanco', '2000-02-03', 0, BulkColumn, newid(), null, null, 1
		FROM openrowset(BULK 'C:\Users\clientedb\Desktop\zoo_git\imagenes\copito.jpg', SINGLE_BLOB) AS f
GO

INSERT INTO animal
	(id, nombre, especie, sexo, color, fecha_nacimiento, nacimiento_en_cautiverio, imagen, imagen_id, id_padre, id_madre, id_recinto)
	SELECT 2, 'Rita', 'Orangután', 'H', 'Azul', '2001-02-03', 0, BulkColumn, newid(), null, null, 1
		FROM openrowset(BULK 'C:\Users\clientedb\Desktop\zoo_git\imagenes\rita.jpg', SINGLE_BLOB) AS f
GO

INSERT INTO animal
	(id, nombre, especie, sexo, color, fecha_nacimiento, nacimiento_en_cautiverio, imagen, imagen_id, id_padre, id_madre, id_recinto)
	SELECT 3, 'Copito de nieve junior', 'Orangután', 'H', 'Negro', '2015-02-03', 0, BulkColumn, newid(), null, null, 1
		FROM openrowset(BULK 'C:\Users\clientedb\Desktop\zoo_git\imagenes\copito_jr.jpg', SINGLE_BLOB) AS f
GO

INSERT INTO espectaculo (id, nome, fecha, id_tarifa, id_recinto)
	VALUES 
		(1, 'Orangutanes volando', '2018-01-04', 1, 1),
		(2, 'Orangutanes bailando', '2019-02-05', 3, 3),
		(3, 'Orangutanes cantando', '2020-03-06', 2, 2)
GO

INSERT INTO recinto_mantenimiento(id_mantenimiento, id_recinto)
	VALUES 
		(1, 1),
		(2, 2)
GO

INSERT INTO recinto_limpiador (id_limpiador, id_recinto)
	VALUES 
		(1, 1),
		(2, 2)
GO

INSERT INTO animal_cuidador (id_animal, id_cuidador)
	VALUES 
		(1, 1),
		(2, 2)
GO

INSERT INTO animal_veterinario(id_animal, id_veterinario)
	VALUES 
		(1, 1),
		(2, 2)
GO

INSERT INTO animal_espectaculo_cuidador (id_animal, id_espectaculo, fecha_espectaculo, id_cuidador, horario)
	VALUES 
		(1, 1, '2018-01-04', 1, 'Todos los días de 19:00 a21:00'),
		(2, 2, '2019-02-05', 2, 'Todos los sábados a las 16:00')

GO

INSERT INTO nombre_visitante_actual (id, nombre, num_entradas_compradas)
	VALUES (1, 'Maria', 4)
GO

-- UPDATES PARA QUE LA TABLA TEMPORAL EMPLEADO TENGA ALGUN REGISTRO

WAITFOR DELAY '00:00:02' -- esperamos 2 segundos
GO

UPDATE empleado 
	SET nombre = 'Alvaro Laventana'
	WHERE id = 4
GO

WAITFOR DELAY '00:00:02' -- esperamos 2 segundos
GO

INSERT INTO empleado (id, tipo, nombre, dni, nss, telefono, direccion, id_turno)
	VALUES
		(5, 'Mantenimiento', 'Pepe Gotera', '48111633Y', '428723763', '981676665', 'O Corgo 19', 1)
GO

WAITFOR DELAY '00:00:02' -- esperamos 2 segundos
GO

UPDATE empleado 
	SET nombre = 'Paco Gotera'
	WHERE id = 5
GO

WAITFOR DELAY '00:00:02' -- esperamos 2 segundos
GO

DELETE FROM empleado
	WHERE id = 5
GO

-- ENCRIPTACIÖN DE COLUMNA --------------------------------------------------------------------
/*
vamos a encriptar la columna dni de la tabla empleado, para que solo el administrador de la BD
pueda ver su contenido claramente
*/


-- Paso 1 (step 3) Creamos la master key a nivel de SQL server
USE master
GO

IF NOT EXISTS (
    SELECT * FROM sys.symmetric_keys
		WHERE name = '##MS_ServiceMasterKey##'
) BEGIN
    CREATE MASTER KEY ENCRYPTION BY 
		PASSWORD = 'MSSQLSerivceMasterKey'
END
GO

-- Paso 2 (Step 4 C Create MSSQL Database level master key)
USE zoo
GO

IF NOT EXISTS (
	SELECT * FROM sys.symmetric_keys 
		WHERE name LIKE '%MS_DatabaseMasterKey%'
) BEGIN        
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Abcd1234.'
END
GO

--Paso 3 (Step 5 C Create MSSQL asymmetric Key)
USE zoo
GO

IF NOT EXISTS (
	SELECT * FROM sys.asymmetric_keys
		WHERE name = 'asymkey1_zoo'
) BEGIN
    CREATE ASYMMETRIC KEY asymkey1_zoo
		WITH ALGORITHM = RSA_2048 
		ENCRYPTION BY PASSWORD = N'Abcd1234.'
END
GO

--Paso 4 (Step 6 C Change your table structure)
ALTER TABLE empleado 
	ADD dni_encriptado varbinary(MAX) NULL
GO

/*
SELECT * FROM empleado
GO
*/

-- Paso 5 (Step 7 C init the encrypted data into the newly column)
UPDATE empleado
SET 
	dni_encriptado = ENCRYPTBYASYMKEY(ASYMKEY_ID('asymkey1_zoo'), dni)
GO

/*
SELECT * FROM empleado
GO
*/

-- paso 6 (desencriptamos columna)
/*
SELECT 
    *,
    dni_desencriptado = CONVERT(
		varchar(12),
		DECRYPTBYASYMKEY(
			ASYMKEY_ID('asymkey1_zoo'), 
			dni_encriptado,
			N'Abcd1234.'
		)
	)
	FROM empleado
GO
*/

-- paso 7 (eliminamos columna dni)

ALTER TABLE empleado
	DROP COLUMN dni
go

/*
SELECT * FROM empleado
GO
*/

USE master
GO



			
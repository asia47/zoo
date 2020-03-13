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

/*
INSERT INTO animal 
	(id, nombre, especie, sexo, color, fecha_nacimiento, nacimiento_en_cautiverio, id_padre, id_madre, id_recinto)
	VALUES
		(2, 'Rita', 'Orangután', 'H','Azul', '2001-02-03', 0, null, null, 1)
GO


INSERT INTO animal 
	(id, nombre, especie, sexo, color, fecha_nacimiento, nacimiento_en_cautiverio, id_padre, id_madre, id_recinto)
	VALUES
		(3, 'Copito de nieve junior', 'Orangután', 'H','Negro', '2015-02-03', 1, 1, 2, 1)
GO
*/

INSERT INTO espectaculo (id, nome, fecha, id_tarifa, id_recinto)
	VALUES 
		(1, 'Orangutanes volando', '2018-01-01', 1, 1),
		(2, 'Orangutanes bailando', '2018-02-02', 3, 3),
		(3, 'Orangutanes cantando', '2018-02-03', 2, 2)
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

INSERT INTO animal_espectaculo_cuidador (id_animal, id_espectaculo, id_cuidador, horario)
	VALUES 
		(1, 1, 1, 'Todos los días de 19:00 a21:00'),
		(2, 2, 2, 'Todos los sábados a las 16:00')

GO

INSERT INTO nombre_visitante_actual (id, nombre, num_entradas_compradas)
	VALUES (1, 'Maria', 4)
GO

-- UPDATES

UPDATE empleado 
	SET nombre = 'Alvaro Laventana'
	where id = 4
go

USE master
GO







			
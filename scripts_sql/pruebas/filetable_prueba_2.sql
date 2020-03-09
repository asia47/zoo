-- una filateble es una tabla de una bd que a traves de filestream nos permite
-- listar el contenido de un recurso compartido creado desde el propio sqlserver

use master
go

-- creamos la bd con filestream preparada para tener una filetable

drop database if exists dbpruebafiletable
go

create database dbpruebafiletable
on primary (
	name = dbpruebafiletable_data, 
	filename = 'C:\db_data\dbpruebafiletable_data.mdf'
), filegroup dbpruebafiletable_fg contains filestream (
	name = dbpruebafiletable_fg,
	filename = 'C:\db_data\dbpruebafiletable_container'
)
log on (
	name = dbpruebafiletable_log,
	filename = 'C:\db_data\dbpruebafiletable_log.ldf'
)
-- creamos un recurso compartido a través del sqlserver en red en:
-- \\localhost\MSSQLSERVER\contenedor_de_filetables
-- dentro de este directorio se van a crear una subcarpeta por 
--cada filetable de esta base de datos
with filestream (
	non_transacted_access = full,
	directory_name = 'contenedor_de_filetables'
)
go

--creamos la filetable: 
-- \\localhost\MSSQLSERVER\contenedor_de_filetables\filetable1
use dbpruebafiletable
go

create table filetable1 
as filetable
with (
	filetable_directory = 'filetable1', 
	filetable_collate_filename = database_default
)
go

create table filetable2 -- este es el nombre de la tabla (se guarda en el mdf)
as filetable
with (
	filetable_directory = 'pepe', -- este es el nombre del recurso compartido
	filetable_collate_filename = database_default
)
go

-- creamos o copiamos un par de archivos en el recurso compartido: 
-- \\localhost\MSSQLSERVER\contenedor_de_filetables\filetable1

--ahora listamos lo que hay en el recurso compartido
-- \\localhost\MSSQLSERVER\contenedor_de_filetables\filetable1
select * from filetable1
go

select * from filetable2
go

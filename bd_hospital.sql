USE master
DROP DATABASE IF EXISTS bd_hospital;

/********************************** CREAR BASE DE DATOS **************************/

CREATE DATABASE bd_hospital;
GO
USE bd_hospital;
GO

/********************************** CREAR TABLAS **********************************/

-- ready
CREATE TABLE tipoSeguro(
	idTipoSeguro int identity(0,1),
	tipo varchar(15),
constraint pk_tipoSeg primary key (idTipoSeguro)
);

--ready
CREATE TABLE seguro(
	idSeguro int identity(0,1),
	nombre varchar(50),
constraint pk_seguro primary key (idSeguro)
);

CREATE TABLE paciente(
	idPaciente int,
	nombre varchar(30) not null,
	apellido varchar(30) not null,
	sexo varchar(10) not null,
	direccion varchar(50),
	telefono varchar(15),
	fechaNacimiento date not null,
	idSeguro int,
	idTipo int,
constraint pk_paciente primary key (idPaciente),
constraint fk_seg_pac foreign key (idSeguro) references seguro (idSeguro),
constraint fk_tipo_pac foreign key (idTipo) references tipoSeguro (idTipoSeguro)
);

--ready
CREATE TABLE especialidad(
	idEspecialidad int identity(1,10),
	nombre varchar(50) not null,
	descripcion varchar(200),
constraint pk_espec primary key (idEspecialidad)
);

CREATE TABLE medico(
	idMedico int,
	nombre varchar(30) not null,
	apellido varchar(30) not null,
	sexo varchar(10) not null,
	direccion varchar(50),
	telefono varchar(15),
	registroMedico varchar(15) not null,
	idEspecialidad int,
constraint pk_medico primary key (idMedico),
constraint fk_espec_med foreign key (idEspecialidad) references especialidad (idEspecialidad)
);

CREATE TABLE cita(
	idCita int identity(100,1),
	fecha date,
	hora time,
	idPaciente int,
	idMedico int,
constraint pk_cita primary key (idCita),
constraint fk_pac_cita foreign key (idPaciente) references paciente(idPaciente),
constraint fk_med_cita foreign key (idMedico) references medico (idMedico)
);

CREATE TABLE enfermero(
	idEnfermero int,
	nombre varchar(30) not null,
	apellido varchar(30) not null,
	sexo varchar(10) not null,
	direccion varchar(50),
	telefono varchar(15),
	cargo varchar(20),
	registro varchar(15) not null,
constraint pk_enfermero primary key (idEnfermero)
);

--ready
CREATE TABLE diagnostico(
	codDiagnostico varchar(3),
	nombre varchar(150),
constraint pk_diagn primary key (codDiagnostico)
);

-- ready
CREATE TABLE planta(
	idPlanta varchar(2),
	nombre varchar(20) not null,
constraint pk_planta primary key (idPlanta)
);

--ready
CREATE TABLE cama(
	idCama int UNIQUE,
	idPlanta varchar(2),
constraint pk_cama primary key (idcama),
constraint fk_planta_cama foreign key (idPlanta) references planta(idPlanta)
);

-- ready
CREATE TABLE servicio(
	codServicio int,
	nombre varchar(50),
constraint pk_servicio primary key (codServicio)
);

CREATE TABLE ingreso(
	codIngreso int identity(1,1),
	fechaIngreso datetime not null,
	motivo text not null,
	idPaciente int not null,
	idEnfermero int not null,
	idMedico int not null,
	codServicio int,
constraint pk_ingreso primary key (codIngreso),
constraint fk_pac_ingreso foreign key (idPaciente) references paciente (IdPaciente),
constraint fk_enf_ingreso foreign key (idEnfermero) references enfermero (idEnfermero),
constraint fk_med_ingreso foreign key (idMedico) references medico (idMedico),
constraint fk_serv_ingreso foreign key (codServicio) references servicio (codServicio),
);

CREATE TABLE alta(
	codAlta int identity(1,1),
	fechaAlta datetime not null,
	motivo text not null,
	valorPagar money,
	idPaciente int not null,
	idMedico int not null,
	idEnfermero int not null,
constraint pk_alta primary key (codAlta),
constraint fk_pac_alta foreign key (idPaciente) references paciente (IdPaciente),
constraint fk_enf_alta foreign key (idEnfermero) references enfermero (idEnfermero),
constraint fk_med_alta foreign key (idMedico) references medico (idMedico),
);

-- ready
CREATE TABLE procedimiento(
	codProcedimiento int identity(10,1),
	nombre varchar(50) not null,
constraint pk_proc primary key (codProcedimiento),
);

CREATE TABLE tratamiento(
	codTratamiento int identity(100,1),
	idPaciente int not null,
	idProcedimiento int not null,
constraint pk_tto primary key (codTratamiento),
constraint fk_pac_tto foreign key (idPaciente) references paciente (IdPaciente),
constraint fk_proc_tto foreign key (idProcedimiento) references procedimiento (codProcedimiento)
);

CREATE TABLE historiaClinica (
  idHistoria int not null,
  idPaciente int not null,
  codDiagnostico varchar(3) not null,
constraint pk_hc primary key (idHistoria),
constraint fk_pac_hc foreign key (idPaciente) references paciente (IdPaciente),
constraint fk_diagn_hc foreign key (codDiagnostico) references diagnostico (codDiagnostico),
);

create table pacienteCama
(
	idPacienteCama int identity,
	fechaAsignacion datetime,
	fechaSalida datetime,
	idCama int,
	idHistoria int,
constraint pk_pacCama primary key (idPacienteCama),
constraint fk_cama_pacCama foreign key (idCama) references cama(idCama),
constraint fk_hc_pacCama foreign key (idHistoria) references historiaClinica(idHistoria)
);

CREATE TABLE revisionMedica(
	idRevision int,
	fechaRevision datetime not null,
	idHistoria int not null,
	observaciones text,
constraint pk_revision primary key (idREvision),
constraint fk_hc_revision foreign key (idHistoria) references historiaClinica(idHistoria)
);


/********************************** STORE PROCEDURES **********************************/

--SP TABLA PACIENTE
GO
CREATE PROC ingresarActualizar_Pac(
	@idPaciente int,
	@nombre varchar(30),
	@apellido varchar(30),
	@sexo varchar(10),
	@direccion varchar(50),
	@telefono varchar(15),
	@fechaNacimiento date,
	@idSeguro varchar(20),
	@idTipo int
)
as
if not exists (select idPaciente from paciente where idPaciente=@idPaciente)
-- INSERTAR
insert into paciente(idPaciente, nombre, apellido, sexo, direccion, telefono, fechaNacimiento, idSeguro, idTipo)
values (@idPaciente, @nombre, @apellido, @sexo, @direccion, @telefono, @fechaNacimiento, @idSeguro, @idTipo)
else
--ACTUALIZAR
update paciente set nombre=@nombre, apellido=@apellido, sexo=@sexo, direccion=@direccion,
		    telefono=@telefono, fechaNacimiento=@fechaNacimiento, idSeguro=@idSeguro, idTipo=@idTipo
where idPaciente=@idPaciente

GO
--ELIMINAR
CREATE PROC eliminarPaciente
	@idPaciente int
as
delete from paciente where idPaciente=@idPaciente

--CONSULTAR
GO
CREATE PROC consultar_paciente
	@nombre varchar(30)
as
--SELECT
select idPaciente DOCUMENTO, nombre NOMBRE, apellido APELLIDO, sexo SEXO, direccion DIRECCIÓN, telefono TELÉFONO,
	   fechaNacimiento 'FECHA NACIMIENTO', idSeguro 'CÓD. SEGURO', idTipo TIPO
from paciente where nombre like '%' + @nombre + '%';

--CONSULTAR DATOS PACIENTE
GO
CREATE PROC datos_paciente
as
select p.idPaciente DOCUMENTO, p.nombre NOMBRE, p.apellido APELLIDO, p.sexo SEXO, p.direccion DIRECCIÓN, p.telefono TELÉFONO, P.fechaNacimiento 'FECHA NACIMIENTO', s.nombre SEGURO, t.tipo TIPO
from paciente p inner join
seguro s on p.idSeguro=s.idSeguro inner join
tipoSeguro t on p.idTipo=t.idTipoSeguro


--SP TABLA MEDICO
GO
CREATE PROC ingresarActualizar_medico(
	@idMedico int,
	@nombre varchar(30),
	@apellido varchar(30),
	@sexo varchar(10),
	@direccion varchar(50),
	@telefono varchar(15),
	@registroMedico varchar(15),
	@idEspecialidad int
)
as
if not exists (select idMedico from medico where idMedico=@idMedico)
-- INSERTAR
insert into medico(idMedico, nombre, apellido, sexo, direccion, telefono, registroMedico, idEspecialidad)
values (@idMedico, @nombre, @apellido, @sexo, @direccion, @telefono, @registroMedico, @idEspecialidad)
else
--ACTUALIZAR
update medico set nombre=@nombre, apellido=@apellido, sexo=@sexo, direccion=@direccion,
				  telefono=@telefono, registroMedico=@registroMedico, idEspecialidad=@idEspecialidad
where idMedico=@idMedico

GO
--ELIMINAR
CREATE PROC eliminarMedico
	@idMedico int
as
delete from medico where idMedico=@idMedico

--CONSULTAR
GO
CREATE PROC consultar_medico
	@nombre varchar(30)
as
--SELECT
select idMedico DOCUMENTO, nombre NOMBRE, apellido APELLIDO, sexo SEXO, direccion DIRECCIÓN, telefono TELÉFONO, registroMedico REGISTRO, idEspecialidad 'CÓD. ESPECIALIDAD'
from medico where nombre like '%' + @nombre + '%';

--CONSULTAR DATOS MÉDICO
GO
CREATE PROC datos_medico
as
select m.nombre NOMBRE, m.apellido APELLIDO, m.sexo SEXO, m.direccion DIRECCIÓN, m.telefono TELÉFONO, m.registroMedico REGISTRO, e.nombre ESPECIALIDAD
from medico m INNER JOIN especialidad e on m.idEspecialidad=e.idEspecialidad


--SP TABLA CITA
GO
CREATE PROC ingresarActualizar_cita(
	@idCita int,
	@fecha date,
	@hora time,
	@idPaciente int,
	@idMedico int
)
as
if not exists (select idCita from cita where idCita=@idCita)
--INSERTAR
insert into cita (fecha, hora, idPaciente, idMedico)
values (@fecha, @hora, @idPaciente, @idMedico)
else
--ACTUALIZAR
update cita set fecha=@fecha, hora=@hora, idPaciente=@idPaciente, idMedico=@idMedico

--ELIMINAR
GO
CREATE PROC eliminar_cita
	@idCita int
as
delete from cita where idCita=@idCita

--CONSULTAR
GO
CREATE PROC consultar_cita(
	@idCita int,
	@idPaciente int
)
as
--SELECT
select idCita CÓDIGO, fecha FECHA, hora HORA, cita.idPaciente IDENTIFICACIÓN,
	   p.nombre + ' ' + p.apellido PACIENTE, m.nombre + ' ' + m.apellido MÉDICO
from cita
inner join paciente p on cita.idPaciente=p.idPaciente
inner join medico m on cita.idMedico=m.idMedico
where idCita=@idCita or cita.idPaciente=@idPaciente;


--SP TABLA ENFERMERO
GO
CREATE PROC ingresarActualizar_enfermero(
	@idEnfermero int,
	@nombre varchar(30),
	@apellido varchar(30),
	@sexo varchar(10),
	@direccion varchar(50),
	@telefono varchar(15),
	@cargo varchar(15),
	@registro varchar(15)
)
as
if not exists (select idEnfermero from enfermero where idEnfermero=@idEnfermero)
-- INSERTAR
insert into enfermero(idEnfermero, nombre, apellido, sexo, direccion, telefono, cargo, registro)
values (@idEnfermero, @nombre, @apellido, @sexo, @direccion, @telefono, @cargo, @registro)
else
--ACTUALIZAR
update enfermero set nombre=@nombre, apellido=@apellido, sexo=@sexo, direccion=@direccion,
					 telefono=@telefono, cargo=@cargo, registro=@registro
where idEnfermero=@idEnfermero

GO
--ELIMINAR
CREATE PROC eliminarEnfermero
	@idEnfermero int
as
delete from enfermero where idEnfermero=@idEnfermero

--CONSULTAR
GO
CREATE PROC consultar_enfermero
	@nombre varchar(30)
as
--SELECT (LIKE)
select idEnfermero DOCUMENTO, nombre NOMBRE, apellido APELLIDO, sexo SEXO, direccion DIRECCIÓN, telefono TELÉFONO, cargo CARGO, registro REGISTRO
from enfermero where nombre like '%' + @nombre + '%';

--SP TABLA INGRESO
GO
CREATE PROC ingresarActualizar_ingreso(
	@codIngreso int,
	@fechaIngreso datetime,
	@motivo text,
	@idPaciente int,
	@idEnfermero int,
	@idMedico int,
	@codServicio int
)
as
if not exists (select codIngreso from ingreso where codIngreso=@codIngreso)
-- INSERTAR
insert into ingreso(fechaIngreso, motivo, idPaciente, idEnfermero, idMedico, codServicio)
values (@fechaIngreso, @motivo, @idPaciente, @idEnfermero, @idMedico, @codServicio)
else
--ACTUALIZAR
update ingreso set fechaIngreso=@fechaIngreso, motivo=@motivo, idPaciente=@idPaciente,
				   idEnfermero=@idEnfermero, idMedico=@idMedico, codServicio=@codServicio
where codIngreso=@codIngreso

GO
--ELIMINAR
CREATE PROC eliminarIngreso
	@codIngreso int
as
delete from ingreso where codIngreso=@codIngreso

--CONSULTAR
GO
CREATE PROC consultar_ingreso
	@codIngreso int
as
--SELECT
select * from ingreso where codIngreso=@codIngreso;


--SP TABLA ALTA
GO
CREATE PROC ingresarActualizar_alta(
	@codAlta int,
	@fechaAlta datetime,
	@motivo text,
	@valorPagar money,
	@idPaciente int,
	@idMedico int,
	@idEnfermero int
)
as
if not exists (select codAlta from alta where codAlta=@codAlta)
-- INSERTAR
insert into alta(fechaAlta, motivo, valorPagar, idPaciente, idMedico, idEnfermero)
values (@fechaAlta, @motivo, @valorPagar, @idPaciente, @idMedico, @idEnfermero)
else
--ACTUALIZAR
update alta set fechaAlta=@fechaAlta, motivo=@motivo, valorPagar=@valorPagar,
				idPaciente=@idPaciente, idMedico=@idMedico, idEnfermero=@idEnfermero
where codAlta=@codAlta

GO
--ELIMINAR
CREATE PROC eliminarAlta
	@codAlta int
as
delete from alta where codAlta=@codAlta

--CONSULTAR
GO
CREATE PROC consultar_alta
	@codAlta int
as
--SELECT
select * from alta where codAlta=@codAlta;


--SP TRATAMIENTO
GO
CREATE PROCEDURE ingresarActualizar_tratamiento(
	@codTratamiento int,
	@idPaciente int,
	@idProcedimiento int
)
as
if not exists (select codTratamiento from tratamiento where codTratamiento=@codTratamiento)
--INSERTAR
insert into tratamiento (idPaciente, idProcedimiento)
values (@idPaciente, @idProcedimiento)
else
--ACTUALIZAR
update tratamiento set idPaciente=@idPaciente,
					   idProcedimiento=@idProcedimiento
WHERE codTratamiento=@codTratamiento

GO
--ELIMINAR
CREATE PROC eliminar_tratamiento
	@codTratamiento int
as
delete from tratamiento WHERE codTratamiento=@codTratamiento

--CONSULTAR
GO
CREATE PROC consultar_tratamiento
	@codTratamiento int
as
--SELECT
select * from tratamiento where codTratamiento=@codTratamiento;


--SP HISTORIA CLINICA
GO
CREATE PROC	ingresarActualizar_historia(
	@idHistoria int,
	@idPaciente int,
	@codDiagnostico varchar(4)
)
as
if not exists (select idHistoria from historiaClinica where idHistoria=@idHistoria)
--INSERTAR
insert into historiaClinica (idHistoria, idPaciente, codDiagnostico)
values (@idHistoria, @idPaciente, @codDiagnostico)
else
--ACTUALIZAR
update historiaClinica set idHistoria=@idHistoria, idPaciente=@idPaciente, codDiagnostico=@codDiagnostico
where idHistoria=@idHistoria

GO
--ELIMINAR
CREATE PROC eliminar_historiaClinica
	@idHistoria int
as
delete from historiaClinica where idHistoria=@idHistoria

--CONSULTAR
GO
CREATE PROC consultar_historiaClinica
	@IdHistoria int
as
--SELECT
select * from historiaClinica where idHistoria=@IdHistoria;


--SP PACIENTE_CAMA
GO
CREATE PROC ingresarActualizar_PacienteCama(
	@idPacienteCama int,
	@fechaAsignacion datetime,
	@fechaSalida datetime,
	@idCama int,
	@idHistoria int
)
as
if not exists (select idPacienteCama from pacienteCama where idPacienteCama=@idPacienteCama)
--INSERT
insert into pacienteCama (fechaAsignacion, fechaSalida, idCama, idHistoria)
values (@fechaAsignacion, @fechaSalida, @idCama, @idHistoria)
else
--ACTUALIZAR
update pacienteCama set fechaAsignacion=@fechaAsignacion, fechaSalida=@fechaSalida,
						idCama=@idCama, idHistoria=@idHistoria
where idPacienteCama=@idPacienteCama

GO
--ELIMINAR
CREATE PROC eliminar_pacienteCama
	@idPacienteCama int
as
delete from pacienteCama where idPacienteCama=@idPacienteCama

--CONSULTAR
GO
CREATE PROC consultar_pacienteCama
	@idPacienteCama int
as
--SELECT
select * from pacienteCama where idPacienteCama=@idPacienteCama;


--SP REVISION MEDICA
GO
CREATE PROCEDURE ingresarActualizar_revisionMedica(
	@idRevision int,
	@fechaRevision datetime,
	@idHistoria int,
	@observaciones text
)
as
if not exists (select idRevision from revisionMedica where idRevision=@idRevision)
--INSERTAR
insert into revisionMedica (idRevision, fechaRevision, idHistoria, observaciones)
values (@idRevision, @fechaRevision, @idHistoria, @observaciones)
else
--ACTUALIZAR
update revisionMedica set idRevision=@idRevision, fechaRevision=@fechaRevision,
						  idHistoria=@idHistoria, observaciones=@observaciones
where idRevision=@idRevision

GO
--ELIMINAR
CREATE PROC eliminar_revisionMedica
	@idRevision int
as
delete from revisionMedica where idRevision=@idRevision

--CONSULTAR
GO
CREATE PROC consultar_revisionMedica
	@idRevision int
as
--SELECT
select * from revisionMedica where idRevision=@idRevision;



/********************************** INSERTAR DATOS **********************************/
GO
USE bd_hospital
GO

--TABLA TIPO SEGURO
INSERT INTO tipoSeguro VALUES ('Seleccionar...'), ('Complementario'), ('Contributivo'), ('Prepagada'), ('Subsidiado');

select * from tipoSeguro

--TABLA SEGURO
INSERT INTO seguro VALUES ('Seleccionar...'), ('Capresoca EPS'), ('Colsalud'), ('Colsanitas'), ('Comparta EPS-S'), ('Convida EPS'), ('Coomeva EPS'),
						  ('Coosalud'), ('Humana vivir EPS'), ('Nueva EPS'), ('Salud total EPS'), ('Salud vida EPS'), ('EPS Suramericana');

select * from seguro


--TABLA ESPECIALIDADES
INSERT INTO especialidad VALUES ('Alergología','Estudia la alergia y sus manifestaciones'),
								('Análisis clínicos','Confirmar o descartar el diagnóstico de enfermedades mediante el análisis de fluidos y tejidos del paciente'),
								('Anestesiología y reanimación','Atención antes, durante y despues de una intervención o procedimiento'),
								('Angiología y cirugía vascular','Diagnóstico y tratamiento de enfermedades exclusivamente debidas a problemas en los vasos sanguíneos'),
								('Cardiología','Estudio, diagnóstico y tratamiento del corazón y el aparato circulatorio; sin recurrir a cirugía'),
								('Cirugía cardiovascular','Intervenir el sistema circulatorio, especialmente del corazón y los vasos sanguíneos'),
								('Cirugía general y del aparato digestivo','Se encarga de intervenir en el aparato digestivo'),
								('Cirugía ortopédica y traumatología','Se encarga de los problemas relacionados con enfermedades y trastornos en el aparato locomotor'),
								('Cirugía pediátrica','Especializada en las enfermedades que pueden presentar el feto, el infante, el niño, el adolescente y el joven adulto'),
								('Cirugía torácica','Estudio e intervención quirúrgica de los problemas en el tórax'),
								('Dermatología','Estudio y tratamiento de los problemas en la piel y estructuras tegumentarias'),
								('Endocrinología','Estudio el sistema endocrino y las enfermedades asociadas'),
								('Farmacología clínica','Estudia las propiedades de los fármacos, su mecanismo de acción, acción terapéutica, efectos secundarios, indicaciones y contraindicaciones'),
								('Fisiatría','Funcionalidad ergonómica y ocupacional. Enfermedad motriz discapacitante'),
								('Gastroenterología','Estudia el sistema digestivo (esófago, estómago, hígado, vía biliares, páncreas, los intestinos, colon y recto)'),
								('Geriatría','Se encarga de las personas de edades avanzadas aquejadas de enfermedades asociadas a la vejez'),
								('Ginecología y obstetricia','Ser encarga del sistema reproductor femenino, interviniendo en el embarazo, parto y el post-parto'),
								('Hematología y hemoterapia','Trata a las personas que sufren enfermedades relacionadas con la sangre'),
								('Infectología','Trata enfermedades debidas a la acción de algún agente patógeno'),
								('Inmunología','Se ocupa del estudio del sistema inmunológico'),
								('Medicina general','Se encarga de mantener la salud en todos los aspectos, analizando y estudiando el cuerpo humano en forma global'),
								('Medicina interna','Afectaciones por varias patologías, que suponen un tratamiento complejo'),
								('Medicina nuclear','Uso de técnicas radiológicas, como radiofármacos y radiotrazadores, para diagnosticar y tratar enfermedades'),
								('Microbiología y parasitología','Estudio y analisis de microorganismos y parásitos que suponen algún tipo de condición médica en el organismo'),
								('Nefrología','Estudio de la estructura y función del aparato urinario'),
								('Neumología','Se centra en el aparato respiratorio (pulmones, pleura y mediastino)'),
								('Neurocirugía','Manejo quirúrgico de determinadas enfermedades que afectan al sistema nervioso'),
								('Neurología','Trata las enfermedades debidas a un mal funcionamiento del sistema nervioso'),
								('Nutriología','Estudia la alimentación humana y su relación con los procesos químicos, metabólicos y biológicos'),
								('Odontología','Aborda las enfermedades del aparato estomatognático'),
								('Oftalmología','Estudia desórdenes y enfermedades del globo ocular, su musculatura, los párpados y el sistema lagrimal'),
								('Oncología médica','Atención hacia el enfermo de cáncer'),
								('Oncología radioterápica','Enfocada al tratamiento con radiaciones de pacientes con cáncer'),
								('Otorrinolaringología','encargada del estudio del oído y las vías respiratorias'),
								('Pediatría','Estudia al niño y las enfermedades, desde el nacimiento hasta la adolescencia'),
								('Psiquiatría','Estudia los trastornos mentales de origen genético o neurológico'),
								('Toxicología','Identifica, estudia y describe las dosis, naturaleza y gravedad de aquellas sustancias que pueden suponer algún perjuicio orgánico en el cuerpo humano'),
								('Traumatología','Trata las lesiones del aparato locomotor, ya sean debidas a un accidente o a un mal de origen congénito'),
								('Urología','Trata las patologías que afectan al sistema urinario, además del aparato reproductor masculino');
SELECT * FROM especialidad;


--TABLA DIAGÓSTICO
INSERT INTO diagnostico VALUES  ('A00','COLERA'),
								('A01','FIEBRES TIFOIDEA Y PARATIFOIDEA'),
								('A09','DIARREA Y GASTROENTERITIS DE PRESUNTO ORIGEN INFECCIOSO'),
								('A15','TUBERCULOSIS RESPIRATORIA CONFIRMADA BACTERIOLOGICA E HISTOLOGICAMENTE'),
								('A37','TOS FERINA (TOS CONVULSIVA)'),
								('A82','RABIA'),
								('A90','FIEBRE DEL DENGUE (DENGUE CLASICO)'),
								('A91','FIEBRE DEL DENGUE HEMORRAGICO'),
								('A95','FIEBRE AMARILLA'),
								('A96','FIEBRE HEMORRAGICA POR ARENAVIRUS'),
								('B01','VARICELA'),
								('B05','SARAMPION'),
								('B06','RUBEOLA [SARAMPION ALEMAN]'),
								('B15','HEPATITIS AGUDA TIPO A'),
								('B16','HEPATITIS AGUDA TIPO B'),
								('B26','PAROTIDITIS INFECCIOSA'),
								('B54','PALUDISMO (MALARIA) NO ESPECIFICADO'),
								('B55','LEISHMANIASIS'),
								('C11','TUMOR MALIGNO DE LA NASOFARINGE'),
								('C15','TUMOR MALIGNO DEL ESOFAGO'),
								('C18','TUMOR MALIGNO DEL COLON'),
								('C34','TUMOR MALIGNO DE LOS BRONQUIOS Y DEL PULMON'),
								('C43','MELANOMA MALIGNO DE LA PIEL'),
								('C50','TUMOR MALIGNO DE LA MAMA'),
								('C61','TUMOR MALIGNO DE LA PROSTATA'),
								('C91','LEUCEMIA LINFOIDE'),
								('D06','CARCINOMA IN SITU DEL CUELLO DEL UTERO'),
								('D17','TUMORES BENIGNOS LIPOMATOSOS'),
								('D27','TUMOR BENIGNO DEL OVARIO'),
								('E02','HIPOTIROIDISMO SUBCLINICO POR DEFICIENCIA DE YODO'),
								('E06','TIROIDITIS'),
								('E14','DIABETES MELLITUS, NO ESPECIFICADA'),
								('E15','COMA HIPOGLICEMICO NO DIABETICO'),
								('E66','OBESIDAD'),
								('E73','INTOLERANCIA A LA LACTOSA'),
								('E84','FIBROSIS QUISTICA'),
								('F20','ESQUIZOFRENIA'),
								('F33','TRASTORNO DEPRESIVO RECURRENTE'),
								('G00','MENINGITIS BACTERIANA, NO CLASIFICADA EN OTRA PARTE'),
								('G04','ENCEFALITIS, MIELITIS Y ENCEFALOMIELITIS'),
								('G24','DISTONIA'),
								('G40','EPILEPSIA'),
								('G61','POLINEUROPATIA INFLAMATORIA'),
								('H00','ORZUELO Y CALACIO'),
								('H10','CONJUNTIVITIS'),
								('H40','GLAUCOMA'),
								('H60','OTITIS EXTERNA'),
								('I20','ANGINA DE PECHO'),
								('I26','EMBOLIA PULMONAR'),
								('I42','CARDIOMIOPATIA'),
								('I47','TAQUICARDIA PAROXISTICA'),
								('I70','ATEROSCLEROSIS'),
								('I80','FLEBITIS Y TROMBOFLEBITIS'),
								('I84','HEMORROIDES'),
								('I95','HIPOTENSION'),
								('J01','SINUSITIS AGUDA'),
								('J02','FARINGITIS AGUDA'),
								('J03','AMIGDALITIS AGUDA'),
								('J04','LARINGITIS Y TRAQUEITIS AGUDAS'),
								('J18','NEUMONIA, ORGANISMO NO ESPECIFICADO'),
								('J30','RINITIS ALERGICA Y VASOMOTORA'),
								('J32','SINUSITIS CRONICA'),
								('J40','BRONQUITIS, NO ESPECIFICADA COMO AGUDA O CRONICA'),
								('J45','ASMA'),
								('K20','ESOFAGITIS'),
								('K25','ULCERA GASTRICA'),
								('K37','APENDICITIS, NO ESPECIFICADA'),
								('K40','HERNIA INGUINAL'),
								('K42','HERNIA UMBILICAL'),
								('K51','COLITIS ULCERATIVA'),
								('K58','SINDROME DEL COLON IRRITABLE'),
								('K65','PERITONITIS'),
								('L02','ABSCESO CUTANEO, FURUNCULO Y CARBUNCO'),
								('L29','PRURITO'),
								('L51','ERITEMA MULTIFORME'),
								('L55','QUEMADURA SOLAR'),
								('L70','ACNE'),
								('L80','VITILIGO'),
								('M10','GOTA'),
								('M15','POLIARTROSIS'),
								('M86','OSTEOMIELITIS'),
								('N04','SINDROME NEFROTICO'),
								('N17','INSUFICIENCIA RENAL AGUDA'),
								('N20','CALCULO DEL RIÑON Y DEL URETER'),
								('N30','CISTITIS'),
								('O16','HIPERTENSION MATERNA, NO ESPECIFICADA'),
								('P20','HIPOXIA INTRAUTERINA'),
								('Q90','SINDROME DE DOWN'),
								('Q96','SINDROME DE TURNER'),
								('R07','DOLOR DE GARGANTA Y EN EL PECHO'),
								('R11','NAUSEA Y VOMITO'),
								('R51','CEFALEA'),
								('S01','HERIDA DE LA CABEZA'),
								('S13','LUXACION, ESGUINCE Y TORCEDURA DE ARTICULACIONES Y LIGAMENTOS CUELLO'),
								('S42','FRACTURA DEL HOMBRO Y DEL BRAZO'),
								('S53','LUXACION, ESGUINCE Y TORCEDURA DE ARTICULACIONES Y LIGAMENTOS DEL CODO'),
								('S62','FRACTURA A NIVEL DE LA MUÑECA Y DE LA MANO'),
								('S72','FRACTURA DEL FEMUR'),
								('T16','CUERPO EXTRAÑO EN EL OIDO'),
								('T17','CUERPO EXTRAÑO EN LAS VIAS RESPIRATORIAS'),
								('T18','CUERPO EXTRAÑO EN EL TUBO DIGESTIVO'),
								('T34','CONGELAMIENTO CON NECROSIS TISULAR'),
								('T36','ENVENENAMIENTO POR ANTIBIOTICOS SISTEMICOS'),
								('T40','ENVENENAMIENTO POR NARCOTICOS Y PSICODISLEPTICOS (ALUCINOGENOS)'),
								('T41','ENVENENAMIENTO POR ANESTESICOS Y GASES TERAPEUTICOS'),
								('T51','EFECTO TOXICO DEL ALCOHOL'),
								('T54','EFECTO TOXICO DE SUSTANCIAS CORROSIVAS'),
								('T55','EFECTO TOXICO DE DETERGENTES Y JABONES'),
								('T68','HIPOTERMIA'),
								('W19','CAIDA NO ESPECIFICADA'),
								('W42','EXPOSICION AL RUIDO'),
								('W53','MORDEDURA DE RATA'),
								('W84','OBSTRUCCION NO ESPECIFICADA DE LA RESPIRACION'),
								('X10','CONTACTO CON BEBIDAS, ALIMENTOS, GRASAS Y ACEITES PARA COCINAR, CALIENTES'),
								('X14','CONTACTO CON AIRE Y GASES CALIENTES'),
								('X40','ENVENENAMIENTO ACCIDENTAL POR, Y EXPOSICION A ANALGESICOS NO NARCOTICOS, ANTIPIRETICOS Y ANTIRREUMATICOS'),
								('X43','ENVENENAMIENTO ACCIDENTAL POR, Y EXPOSICION A OTRAS DROGAS QUE ACTUAN SOBRE EL SISTEMA NERVIOSO AUTONOMO'),
								('X44','ENVENENAMIENTO ACCIDENTAL POR, Y EXPOSICION A OTRAS DROGAS, MEDICAMENTOS Y SUSTANCIAS BIOLOGICAS Y LOS NO ESPECIFICADOS'),
								('X45','ENVENENAMIENTO ACCIDENTAL POR, Y EXPOSICION AL ALCOHOL'),
								('X60','ENVENENAMIENTO AUTOINFLIGIDO INTENCIONALMENTE POR, Y EXPOSICION A ANALGESICOS NO NARCOTICOS, ANTIPIRETICOS Y ANTIRREUMATICOS'),
								('X63','ENVENENAMIENTO AUTOINFLIGIDO INTENCIONALMENTE POR, Y EXPOSICION A OTRAS DROGAS QUE ACTUAN SOBRE EL SISTEMA NERVIOSO AUTONOMO'),
								('X64','ENVENENAMIENTO AUTOINFLIGIDO INTENCIONALMENTE POR, Y EXPOSICION A OTRAS DROGAS, MEDICAMENTOS Y SUSTANCIAS BIOLOGICAS Y LOS NO ESPECIFICADOS'),
								('Y40','EFECTOS ADVERSOS DE ANTIBIOTICOS SISTEMICOS'),
								('Y45','EFECTOS ADVERSOS DE DROGAS ANALGESICAS, ANTIPIRETICAS Y ANTIINFLAMATORIAS'),
								('Y58','EFECTOS ADVERSOS DE VACUNAS BACTERIANAS'),
								('Y85','SECUELAS DE ACCIDENTES DE TRANSPORTE'),
								('Z93','ABERTURAS ARTIFICIALES'),
								('Z94','ORGANOS Y TEJIDOS TRASPLANTADOS');

SELECT * FROM diagnostico


--TABLA PROCEDIMIENTO
INSERT INTO procedimiento VALUES('Anestesia general'),
								('Anestesia local'),
								('Anestesia tópica (superficie)'),
								('Antiveneno'),
								('Biopsia'),
								('Bloqueo epidural'),
								('Cirugía general'),
								('Cirugía guiada por imágenes'),
								('Cistoscopia'),
								('Colonoscopia'),
								('Cuidados paliativos'),
								('Curación'),
								('Ecografía ginecológica'),
								('Electrocardiograma'),
								('Electroencefalograma'),
								('Endoscopia'),
								('Fisioterapia'),
								('Fotofluorografía de tórax'),
								('Hemodiálisis'),
								('Hidroterapia'),
								('Imagen de resonancia magnética'),
								('Inmunoterapia del cáncer'),
								('Intubacion'),
								('Laparoscopia'),
								('Laringoscopia'),
								('Lobotomía'),
								('Nebulización'),
								('Oftalmoscopia'),
								('Otoscopia'),
								('Psicoterapia'),
								('Quimioterapia'),
								('Radiocirugía'),
								('Radiografía'),
								('Radioterapia de fuente no sellada'),
								('Sigmoidoscopia'),
								('Terapia citoluminiscente'),
								('Terapia de choque'),
								('Terapia de choque de insulina'),
								('Terapia de inhalación'),
								('Terapia de potenciación de la insulina'),
								('Terapia de radiación'),
								('Terapia de reemplazo de opiáceos'),
								('Terapia de rehidratación oral'),
								('Terapia inmunosupresora'),
								('Terapia intravenosa'),
								('Terapia magnética'),
								('Terapia respiratoria'),
								('Tomografía computarizada'),
								('Tomografía por emisión de positrones'),
								('Tratamientos de células madre'),
								('Vacunación');
SELECT * FROM procedimiento;

--TABLA PLANTA
INSERT INTO planta values ('A', 'PLANTA BAJA'), ('B', 'PISO PRINCIPAL'), ('C', 'PISO 2');

SELECT * FROM planta;

--TABLA SERVICIO
INSERT INTO servicio VALUES (10, 'Cirugía'), (20, 'Consulta médica'), (30, 'Hospitalización'),
							(40, 'Imagenología'), (50, 'Laboratorio'), (60, 'Medicina externa'),
							(70, 'Procedimientos menores'), (80, 'Programas especiales'), (90, 'Urgencias');
SELECT * FROM servicio;


--TABLA CAMA
INSERT INTO cama (idCama, idPlanta) VALUES (101, 'A'), (102, 'A'), (103, 'A'), (104, 'A'), (105, 'A'), (106, 'A'), (107, 'A'), (108, 'A'),
										   (201, 'B'), (202, 'B'), (203, 'B'), (204, 'B'), (205, 'B'), (206, 'B'), (207, 'B'), (208, 'B'),
										   (301, 'C'), (302, 'C'), (303, 'C'), (304, 'C'), (305, 'C'), (306, 'C'), (307, 'C'), (308, 'C');
SELECT * FROM cama;
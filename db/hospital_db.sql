CREATE DATABASE "Hospital";

\c "Hospital";

CREATE SCHEMA general;

CREATE TABLE general.Persona(
  idPersona int PRIMARY KEY,
  nombre varchar(50) NOT NULL,
  materno varchar(50) NOT NULL,
  paterno varchar(50) NOT NULL,
  ciudad varchar(50) NOT NULL,
  estado varchar(50) NOT NULL,
  calle varchar(50) NOT NULL,
  num int NOT NULL, CHECK(num>0),
  nacimiento date 
);

SET search_path TO general;
SHOW search_path

CREATE TABLE Especialidad(
  idEspecialidad int PRIMARY KEY,
  nombreEspecialidad varchar(30) NOT NULL
);

CREATE TABLE Tener(
  idEspecialidad int REFERENCES Especialidad(idEspecialidad),
  idMedico int REFERENCES Medico(idMedico)
);

CREATE TABLE Medico(
  idMedico int PRIMARY KEY, 
  supervisor int REFERENCES Medico(idMedico),
  idPersona int REFERENCES Persona(idPersona)
);

CREATE TABLE Consultar(
  idPersona int REFERENCES Persona(idPersona),
  idMedico int REFERENCES Medico(idMedico),
  fechaConsulta date NOT NULL ,
  numConsulta int NOT NULL CHECK (numConsulta>0),
  precioConsulta int NOT NULL  CHECK(precioConsulta=70 or precioConsulta=100),
  consultorio int NOT NULL CHECK (consultorio>0)
  
);

CREATE TABLE Ingresar(
  idPersona int REFERENCES Persona(idPersona),
  idMedico int REFERENCES Medico(idMedico),
  fechaIngreso date NOT NULL,
  numIngreso int NOT NULL,
  motivo TEXT,
  habitacion int NOT NULL,
  tipoCama int,
  
CHECK(habitacion>0 and tipoCama<=5 and tipoCama>0 and numIngreso>0)
);

-- Ex A
-- Find the number of consults that every doctor has done per year and quarter.

select extract(year from fechaconsulta) año, date_part('quarter', fechaconsulta) trimestre, c.idmedico,
	count(c.numconsulta) cantidad_consultas
from general.consultar c
group by 1,2,3
order by 1,2,3

-- Ex B
-- Patient information who received a consult the day of their brithday. 
select p.*, fechaconsulta
from general.consultar c natural join general.persona p
where extract(month from fechaconsulta) = extract(month from nacimiento)
	and extract(day from fechaconsulta) = extract(day from nacimiento)


-- Ex C
-- All information of the doctor who has the biggest number of consults. 
select p.*, count(c.numconsulta) cantidad_consultas, t.idespecialidad, e.nombreespecialidad
from general.consultar c natural left join general.medico m natural join general.persona p
	natural left outer join general.tener t join general.especialidad e on
	t.idespecialidad = e.idespecialidad
group by p.idpersona, t.idespecialidad, e.nombreespecialidad
order by cantidad_consultas desc limit 1
		
-- Ex D
-- Patient information who got into the hospital during the fourth quarter of 2019 and their assigned doctor's information (doctor ID is enough).

select p.*, i.idmedico
from general.ingresar i natural join general.persona p 
where extract(year from fechaingreso) = 2019 and
	date_part('quarter', fechaingreso) = 4

-- Ex E
-- Information of doctor who has been patient, their doctor during the consult and the consult date.

select distinct p.*, pacientesmedicos.idmedico, pacientesmedicos.materno, 
	pacientesmedicos.paterno,pacientesmedicos.fechaconsulta
from (select c.idpersona, c.idmedico, nombre, materno, paterno, fechaconsulta 
	  from general.consultar c join general.medico m
	  	on c.idmedico = m.idmedico join general.persona p 
	  	on p.idpersona = m.idpersona) pacientesmedicos join 
		 general.persona p on pacientesmedicos.idpersona = p.idpersona
order by 1

-- Ex F
-- Patients who did not have any consult. 
select distinct p.*
from general.persona p natural left join general.consultar c
where c.numconsulta is null

-- Ex G
-- Patients who had a consult in all consulting room (we can assume that there are only 5 rooms). @TODO: review.
-- Suponemos que la cantidad de consultorios es 5
select c.idpersona, count(distinct c.consultorio)
from general.consultar c
group by c.idpersona
having count(distinct c.consultorio) = 5

-- Ex H
-- Patients who got into the hospital at least on time, came from Ohio and their lastname is 'Prendiville'
select distinct p.idpersona, p.paterno
from general.ingresar i natural join general.persona p
where estado = 'Ohio' and p.paterno = 'Prendiville'


-- Ex I
-- Year and quarter during the biggest number of consults have been done. 
select extract(year from fechaconsulta) año, date_part('quarter', fechaconsulta) trimestre, count(c.numconsulta)
from general.consultar c
group by 1,2
order by 3 desc limit 1


-- Ex J
-- Consults done by speciality during 2019 (choose a month interval)
-- Supongo que quiere saber qué numero de consultas y no la cantidad de consultas que se impartieron
-- por tipo de especialidad. 
select e.nombreespecialidad, extract(month from c.fechaconsulta) mes, c.numconsulta
from general.consultar c join general.tener t
	on c.idmedico = t.idmedico natural join  general.especialidad e
where extract(year from c.fechaconsulta) = 2019 and
		extract(month from c.fechaconsulta) between 7 and 12
group by 1,2,3
order by 1,2 asc

-- Ex K
-- Patient information who have been attended by all doctors.
select p.idpersona, count(distinct c.idmedico) cant_medicos
from general.consultar c join general.persona p on c.idpersona = p.idpersona,
	general.medico m
group by 1
having count(distinct c.idmedico) > count( distinct m.idmedico)
order by 1

-- Ex L
-- Patient information with the biggest number of entries to the hospital
-- Primero seleccionamos el valor maximo y luego la info de los pacientes con ese valor
select p.*
from (select count(i.numingreso), p.*
	from general.ingresar i natural join general.persona p
	group by p.idpersona
	order by 1 desc limit 1) max_value,
	general.ingresar i natural join general.persona p
group by 1, max_value.count
having count(i.numingreso) = max_value.count

-- Ex M
-- ¿Cuál es la fecha de ingreso más antigua en el hospital?
select current_date - i.fechaingreso dias, i.numingreso, i.fechaingreso
from general.ingresar i
order by 1 desc limit 1


-- Ex N
-- Find all doctors who live in the same city as their supervisor.
-- En este caso no hay ninguno que cumpla la condición, a excepción de aquellos que se tienen a sí 
-- mismo como supervisor
select medicos.idpersona
from (general.medico m natural join general.medico natural join general.persona p) medicos,
		(general.medico m natural join general.medico natural join general.persona p) supervisores
where medicos.idsupervisor = supervisores.idmedico and
	medicos.ciudad = supervisores.ciudad and
	medicos.calle = supervisores.calle
-- Da lo mismo que hacer esto este caso particular a esto
select *
from general.medico m
where m.idmedico = m.idsupervisor

-- Ex O
-- Fullname of patients (grouped by speciality) who got into the hospital the last 30 days.
-- lo hago con 30 dias porque no hay nadie de ingreso tan reciente
-- supongo que con agrupados se refiere a que se muestren juntos, los ordeno segun el
-- id de especialidad
select t.idespecialidad, p.nombre, p.paterno, p.materno
from general.ingresar i natural join general.persona p natural join general.tener t
where (current_date - i.fechaingreso)<30
order by 1 asc

-- Ex P
-- Total of patients grouped by year and speciality in every consulting room by type of bed.

yde pacientes que se han tenido por año y especialidad en cada habitación por tipo de cama.
select extract(year from i.fechaingreso) año, e.nombreespecialidad, 
	i.habitacion, i.tipocama, count(i.idpersona) cant_pacientes
from general.ingresar i natural join general.tener t natural join general.especialidad e 
	join general.persona p on p.idpersona = i.idpersona, 
	extract(year from i.fechaingreso) anio
group by 1,2,3,4
order by 3,4


-- Ex Q
-- Number of consulting patient whose age is between 35 and 55 years old., grouped by year and speciality 
 Cantidad de pacientes, por año y especialidad, que hayan tomado consulta y que tenga entre 35 y 55 años
--de edad (puedes modificar este rango).
select extract(year from c.fechaconsulta) año, e.nombreespecialidad, count(c.idpersona) cant_pacientes
from general.consultar c natural join general.tener t natural join general.especialidad e 
	join general.persona p on p.idpersona = c.idpersona, 
	extract(year from c.fechaconsulta) anio
where floor((current_date - p.nacimiento)/365.25) between 30 and 35
group by 1,2
order by 1,2


-- Ejercicio R
--Información de los pacientes y número de consultas que tuvieron, para aquellos que hayan asistido a
--consulta un número mayor de veces que el promedio de consultas durante el primer trimestre de un año
--que tú elijas (puedes cambiar el número de trimestre).
select count(c.numconsulta) "#consultas", p.*
from (select count(distinct c.idpersona) "personas", 
	count(c.numconsulta) "total_consultas"
	from general.consultar c
	where extract(year from fechaconsulta) = 2020 and
	date_part('quarter', fechaconsulta) = 1) info,
	general.persona p natural join general.consultar c
group by p.idpersona,info.total_consultas, info.personas
having count(c.numconsulta) > info.total_consultas/info.personas
order by 1 desc

-- Ejercicio S
-- Supongo que con distribución quieren saber la cantidad de personas, no quienes (no su IDs)
-- pero sacando el count puedo hallarlo
select estado, extract(year from fechaingreso) año, 
	date_part('quarter', fechaingreso) trimestre,
	count(i.idpersona)
from general.ingresar i natural join general.persona, 
	extract(year from fechaingreso) año, 
	date_part('quarter', fechaingreso) trimestre
group by 1,2,3
order by 1,2,3 asc

-- Ejercicio T
-- Pacientes que haya tenido el mismo número de ingresos y de consultas al hospital.
select p.idpersona, count(distinct c.numconsulta) num_consultas, count(distinct i.numingreso) num_ingresos
from general.consultar c join general.ingresar i on c.idpersona = i.idpersona
	join general.persona p on i.idpersona = p.idpersona
group by 1
having count(distinct c.numconsulta) = count(distinct i.numingreso) 
order by 1



-- Ejercicio U 
--Obtener una lista de los pacientes cuyo apellido materno comience con las letras A, D, G, J, L, P o R
select distinct p.idpersona, p.materno
from general.consultar c join general.persona p on
		p.idpersona = c.idpersona
where p.materno ~* '^[adgjlpr]'
order by 1

-- Ejercicio V
select extract(year from fechaconsulta) año,
	date_part('quarter', fechaconsulta) trimestre,
	e.nombreespecialidad, sum(precioconsulta) ingreso
from general.consultar c join general.tener t on
		t.idmedico = c.idmedico
		join general.especialidad e on
		e.idespecialidad = t.idespecialidad, 
	extract(year from fechaconsulta) año, 
	date_part('quarter', fechaconsulta) trimestre
group by 1,2,3 
order by 1,2,3
	
	
-- Ejercicio W 
-- la info del médico que atiende se supone suficiente con el idmedico
select p.*, i.habitacion ubicacionPorHabitacion, m.idpersona idmedico
from general.persona p join general.ingresar i on 
	p.idpersona = i.idpersona join general.medico m
	on i.idmedico = m.idmedico
where motivo like '%COVID-19%' 

-- Ejercicio X
select p.idpersona, p.nombre, (current_date - i.fechaingreso) "Dias hospitalizados", motivo
from general.persona p join general.ingresar i on 
	p.idpersona = i.idpersona
where motivo like '%COVID-19%'
order by 1 asc

-- Ejercicio Y
-- Obtener la información de los médicos más jóvenes y el número de pacientes que han atendido
select m.idmedico, count(c.idpersona) "Cantidad de Pacientes", floor((current_date - p.nacimiento)/365.25) edadreal
from general.consultar c join general.medico m on c.idmedico = m.idmedico 
	join general.persona p on m.idpersona = p.idpersona, 
	floor((current_date - p.nacimiento)/365.25) edadreal
group by m.idmedico, edadreal.edadreal, p.nacimiento
having edadreal < any (select round(avg(edad),0) 
						from general.medico m natural left join general.persona p,
						floor((current_date - p.nacimiento)/365.25) edad
					  )
order by 1 asc
 
-- Ejercicio Z
-- Para obtener la especialidad de menor ingreso
select sum(c.precioconsulta) "Total de Ingresos", e.nombreespecialidad 
from general.consultar c join general.tener t on
		t.idmedico = c.idmedico
	join general.especialidad e on
		e.idespecialidad = t.idespecialidad
group by t.idespecialidad, e.nombreespecialidad
order by 1 asc limit 1;

-- Resolucion completa 
select m.idmedico, e.nombreespecialidad
	-- no aclara qué información de los médicos hallar, solo se obtiene el
	-- id a criterio propio
from general.tener t join general.especialidad e
	on t.idespecialidad = e.idespecialidad join general.medico m
	on m.idmedico = t.idmedico,
	(select sum(c.precioconsulta) "Total de Ingresos", e.nombreespecialidad 
	from general.consultar c join general.tener t on
			t.idmedico = c.idmedico
		join general.especialidad e on
			e.idespecialidad = t.idespecialidad
	group by t.idespecialidad, e.nombreespecialidad
	order by 1 asc limit 1) mn
where mn.nombreespecialidad = e.nombreespecialidad



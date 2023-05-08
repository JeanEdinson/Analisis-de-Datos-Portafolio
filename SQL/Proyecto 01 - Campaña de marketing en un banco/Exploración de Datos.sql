/*Que preguntas necesitamos responder:
1. ¿Que rango de edad ha respondido mejor y peor a la campaña realizada?
2. ¿Que medio de contacto a tenido mayor respuesta en la campaña?
3. ¿Que día de la semana se ha tenido mayor respuesta en la campaña?
4. Contactos concretados segun el nivel de educación
5. Número total de contactos concretados y no concretados
6. ¿Cuantos clientes accedieron al deposito a plazo teniendo un resultado negativo en anteriores campañas?*/

/*Primeros pasos con los datos*/

/*Exploramos la estructura de y los tipos de datos de todas las columnas*/
exec sp_columns 'campaña_marketing'

--Consultamos una muestra de los datos para verificar si estan acorde a sus tipos de datos
select top 20 * from campaña_marketing;

--Cambiamos el tipo de dato de la columna nr_employed a float
alter table campaña_marketing alter column nr_employed float;
select distinct nr_employed from campaña_marketing;

--Agregamos la columna 'rango_edad' para clasificar los registros por grupo etario
alter table campaña_marketing add rango_edad varchar(50);

update campaña_marketing set rango_edad =
	case 
		when age between 0 and 20 then 'Jovenes (0 a 20 Años)'
		when age between 21 and 40 then 'Adulto Joven (21 a 40 Años)'
		when age between 41 and 60 then 'Adulto (41 a 60 Años)'
		else 'Adulto Mayor (60 años a mas)'
	end;

-- Exploración de datos y respuesta a preguntas iniciales

--Conocer el total de personas por rango de edad que han adquirido el deposito a plazo y las que no
select rango_edad, y, count(rango_edad) as cantidad from campaña_marketing group by rango_edad,y with rollup

--Rango de edad con mayor aceptación en la campaña de marketing
select rango_edad, y, count(rango_edad) as cantidad from campaña_marketing group by rango_edad,y having y = 'yes' order by cantidad desc;

/*Inferencias:
- Hubo mas clientes entre los 21 y 40 años que accedieron al deposito a plazo.
- De los 23628 clientes entre los 21 y 40 años, solo 2664 accedieron al deposito a plazo.
- Solo 57 contactos de los 140 realizados a clientes entre los 0 a 20 años fueron exitosos.
*/

--Eficacia en los contactos con los usuarios segun el tipo de medio que se utilizo.
select m1.contact, y, count(m1.contact) as cantidad, (cast(count(m1.contact) as float)/(select count(*) 
from campaña_marketing as m2 where m2.contact = m1.contact))*100 as eficacia from campaña_marketing as m1 
group by m1.contact, m1.y order by m1.contact, m1.y

/*Inferencias:
- Del 100% de contactos realizados por celular, solo el 85% tuvo resultados favorables, mientras que del 100% de 
contactos realizados por telefono, 94% fueron exitosos.
- Los contactos por telefono poseen mayor eficiencia que los realziados por celular.*/

--Cantidad de contactos con resultados favorables por día
select day_of_week,
case 
when day_of_week = 'mon' then 'lunes'
when day_of_week = 'tue' then 'martes'
when day_of_week = 'wed' then 'miercoles'
when day_of_week = 'thu' then 'jueves'
else 'viernes'
end as dia_español,
y, count(day_of_week) as cantidad from campaña_marketing group by day_of_week, y having y = 'yes' 
order by count(day_of_week) desc

/*Inferencias:
- El día jueves, fue el mas fructifero de la semana al concretarse 1045 contactos durante toda la campaña y el viernes, 
el día con com menos contactos concretados, con 846.*/

--Cantidad de contactos concretados y no concretados por nivel de educación y su proporcion acorde al total de clientes pertenecientes a cada nivel
select m1.education, m1.y, count(m1.education) as cantidad, (cast(count(m1.education) as float)/(select count(*) 
from campaña_marketing as m2 where m1.education = m2.education))*100 as proporcion_porcentaje 
from campaña_marketing as m1 group by m1.education, m1.y order by m1.education 

--Cantidad contactos concretados por nivel de educación y su proporción acorde al total de contactos realizados en la compaña
select m1.education, m1.y, count(m1.education) as cantidad, (cast(count(m1.education) as float)/(select count(*) 
from campaña_marketing as m2))*100 as proporcion_porcentaje from campaña_marketing as m1 group by m1.education, m1.y 
having m1.y='yes' order by proporcion_porcentaje

/*Inferencias:
- El nivel de educación 'basic.9y' fue el que obtuve el mayor porcentaje de no aceptación durante la campaña, ya que 
del 100% de contactos realizados a clientes que poseen este nivel de educación, 92% no aceptaron el deposito a plazo.
- El nivel de educación 'university degree' fue el de mayor aceptación en la campaña, ya que comprende el 4% de los 
contactos concretados exitosamente con la adquisición del deposito a plazo.*/

--Número total de clientes que se suscribieron al deposito a plazo
select y as resultado, count(y) as cantidad, (cast(count(y) as float)/(select count(*) 
from campaña_marketing))*100 as proporcion_porcentaje from campaña_marketing group by y 

/*Inferenciia
- Solo el 11% de los contactos realizados acabo con la adquisición del deposito a plazo, mientras que el 89% no se 
concreto exitosamente*/

--Clientes que accedieron al deposito a plazo teniendo un resultado negativo en la anterior campaña y clientes que 
--no accedieron al deposito en la campaña actual pero que si lo hicieron en la campaña pasada, se agrego tambien la 
--proporcion de las cantidades en base a la cantidad de clientes de la campaña actual que fueron contactados en la 
--anterior campaña
select y as resultado_campaña_actual, poutcome as resultado_campaña_anterior, count(y) as cantidad, (cast(count(y) 
as float))/(select count(y) from campaña_marketing where poutcome in ('success','failure'))*100 as proporcion 
from campaña_marketing group by y, poutcome having poutcome in ('success','failure') order by proporcion desc

/*Inferencias:
- Del 100% de los clientes que fueron contactados en la campaña actual y la anterior, el 11% acepto la oferta de la 
presente campaña habiendola rechazado anteriormente, por otro lado, el 9% declino la oferta de la campaña actual 
habiendola aceptado en la campaña anterior.
- De igual forma el 64% de los clientes se reafirmaron en su desición de no aceptar la oferta de la campaña realizada 
y 16% en aceptarla.
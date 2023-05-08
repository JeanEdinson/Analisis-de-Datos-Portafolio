/*Que preguntas necesitamos responder:
1. �Que rango de edad ha respondido mejor y peor a la campa�a realizada?
2. �Que medio de contacto a tenido mayor respuesta en la campa�a?
3. �Que d�a de la semana se ha tenido mayor respuesta en la campa�a?
4. Contactos concretados segun el nivel de educaci�n
5. N�mero total de contactos concretados y no concretados
6. �Cuantos clientes accedieron al deposito a plazo teniendo un resultado negativo en anteriores campa�as?*/

/*Primeros pasos con los datos*/

/*Exploramos la estructura de y los tipos de datos de todas las columnas*/
exec sp_columns 'campa�a_marketing'

--Consultamos una muestra de los datos para verificar si estan acorde a sus tipos de datos
select top 20 * from campa�a_marketing;

--Cambiamos el tipo de dato de la columna nr_employed a float
alter table campa�a_marketing alter column nr_employed float;
select distinct nr_employed from campa�a_marketing;

--Agregamos la columna 'rango_edad' para clasificar los registros por grupo etario
alter table campa�a_marketing add rango_edad varchar(50);

update campa�a_marketing set rango_edad =
	case 
		when age between 0 and 20 then 'Jovenes (0 a 20 A�os)'
		when age between 21 and 40 then 'Adulto Joven (21 a 40 A�os)'
		when age between 41 and 60 then 'Adulto (41 a 60 A�os)'
		else 'Adulto Mayor (60 a�os a mas)'
	end;

-- Exploraci�n de datos y respuesta a preguntas iniciales

--Conocer el total de personas por rango de edad que han adquirido el deposito a plazo y las que no
select rango_edad, y, count(rango_edad) as cantidad from campa�a_marketing group by rango_edad,y with rollup

--Rango de edad con mayor aceptaci�n en la campa�a de marketing
select rango_edad, y, count(rango_edad) as cantidad from campa�a_marketing group by rango_edad,y having y = 'yes' order by cantidad desc;

/*Inferencias:
- Hubo mas clientes entre los 21 y 40 a�os que accedieron al deposito a plazo.
- De los 23628 clientes entre los 21 y 40 a�os, solo 2664 accedieron al deposito a plazo.
- Solo 57 contactos de los 140 realizados a clientes entre los 0 a 20 a�os fueron exitosos.
*/

--Eficacia en los contactos con los usuarios segun el tipo de medio que se utilizo.
select m1.contact, y, count(m1.contact) as cantidad, (cast(count(m1.contact) as float)/(select count(*) 
from campa�a_marketing as m2 where m2.contact = m1.contact))*100 as eficacia from campa�a_marketing as m1 
group by m1.contact, m1.y order by m1.contact, m1.y

/*Inferencias:
- Del 100% de contactos realizados por celular, solo el 85% tuvo resultados favorables, mientras que del 100% de 
contactos realizados por telefono, 94% fueron exitosos.
- Los contactos por telefono poseen mayor eficiencia que los realziados por celular.*/

--Cantidad de contactos con resultados favorables por d�a
select day_of_week,
case 
when day_of_week = 'mon' then 'lunes'
when day_of_week = 'tue' then 'martes'
when day_of_week = 'wed' then 'miercoles'
when day_of_week = 'thu' then 'jueves'
else 'viernes'
end as dia_espa�ol,
y, count(day_of_week) as cantidad from campa�a_marketing group by day_of_week, y having y = 'yes' 
order by count(day_of_week) desc

/*Inferencias:
- El d�a jueves, fue el mas fructifero de la semana al concretarse 1045 contactos durante toda la campa�a y el viernes, 
el d�a con com menos contactos concretados, con 846.*/

--Cantidad de contactos concretados y no concretados por nivel de educaci�n y su proporcion acorde al total de clientes pertenecientes a cada nivel
select m1.education, m1.y, count(m1.education) as cantidad, (cast(count(m1.education) as float)/(select count(*) 
from campa�a_marketing as m2 where m1.education = m2.education))*100 as proporcion_porcentaje 
from campa�a_marketing as m1 group by m1.education, m1.y order by m1.education 

--Cantidad contactos concretados por nivel de educaci�n y su proporci�n acorde al total de contactos realizados en la compa�a
select m1.education, m1.y, count(m1.education) as cantidad, (cast(count(m1.education) as float)/(select count(*) 
from campa�a_marketing as m2))*100 as proporcion_porcentaje from campa�a_marketing as m1 group by m1.education, m1.y 
having m1.y='yes' order by proporcion_porcentaje

/*Inferencias:
- El nivel de educaci�n 'basic.9y' fue el que obtuve el mayor porcentaje de no aceptaci�n durante la campa�a, ya que 
del 100% de contactos realizados a clientes que poseen este nivel de educaci�n, 92% no aceptaron el deposito a plazo.
- El nivel de educaci�n 'university degree' fue el de mayor aceptaci�n en la campa�a, ya que comprende el 4% de los 
contactos concretados exitosamente con la adquisici�n del deposito a plazo.*/

--N�mero total de clientes que se suscribieron al deposito a plazo
select y as resultado, count(y) as cantidad, (cast(count(y) as float)/(select count(*) 
from campa�a_marketing))*100 as proporcion_porcentaje from campa�a_marketing group by y 

/*Inferenciia
- Solo el 11% de los contactos realizados acabo con la adquisici�n del deposito a plazo, mientras que el 89% no se 
concreto exitosamente*/

--Clientes que accedieron al deposito a plazo teniendo un resultado negativo en la anterior campa�a y clientes que 
--no accedieron al deposito en la campa�a actual pero que si lo hicieron en la campa�a pasada, se agrego tambien la 
--proporcion de las cantidades en base a la cantidad de clientes de la campa�a actual que fueron contactados en la 
--anterior campa�a
select y as resultado_campa�a_actual, poutcome as resultado_campa�a_anterior, count(y) as cantidad, (cast(count(y) 
as float))/(select count(y) from campa�a_marketing where poutcome in ('success','failure'))*100 as proporcion 
from campa�a_marketing group by y, poutcome having poutcome in ('success','failure') order by proporcion desc

/*Inferencias:
- Del 100% de los clientes que fueron contactados en la campa�a actual y la anterior, el 11% acepto la oferta de la 
presente campa�a habiendola rechazado anteriormente, por otro lado, el 9% declino la oferta de la campa�a actual 
habiendola aceptado en la campa�a anterior.
- De igual forma el 64% de los clientes se reafirmaron en su desici�n de no aceptar la oferta de la campa�a realizada 
y 16% en aceptarla.
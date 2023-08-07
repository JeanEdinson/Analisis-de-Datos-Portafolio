# Desempeño de Agentes TI

En este proyecto se utilizó un banco de datos libre sobre tickets de atención de Tecnologías de la Información, el cual se dividió en seis archivos Excel:
- Agentes.xlsx: Contiene datos personales de los agentes que atendieron los tickets.
- 2016.xlsx, 2017.xlsx, 2018.xlsx, 2019.xlsx, 2020.xlsx: Contiene datos de cada ticket atendido desde el año 2016 al 2020 como, por ejemplo, categoría, severidad, prioridad, días de resolución, etc.

Utilizando este banco de datos y la herramienta de visualización de datos Power BI se realizó lo siguiente:

## 1. Exploración y limpieza de datos
Haciendo uso del editor de power query pude realizar las siguientes tareas:
   - Verificar la cantidad de registros y columnas de las tablas
   - Eliminar columnas innecesarias
   - Tratar valores erróneos o nulos
   - Eliminar registros duplicados
   - Tratar valores atípicos
   - Agregar nuevas columnas de interés
   - Dar formato a los valores como, por ejemplo, eliminar o remplazar símbolos no entendibles, capitalizar textos, eliminar espacios, etc.

```
let
    Origen = Folder.Files("Dirección del folder con los datos"),
    #"Archivos ocultos filtrados1" = Table.SelectRows(Origen, each [Attributes]?[Hidden]? <> true),
    #"Invocar función personalizada1" = Table.AddColumn(#"Archivos ocultos filtrados1", "Transformar archivo", each #"Transformar archivo"([Content])),
    #"Columnas con nombre cambiado1" = Table.RenameColumns(#"Invocar función personalizada1", {"Name", "Source.Name"}),
    #"Otras columnas quitadas1" = Table.SelectColumns(#"Columnas con nombre cambiado1", {"Source.Name", "Transformar archivo"}),
    #"Columna de tabla expandida1" = Table.ExpandTableColumn(#"Otras columnas quitadas1", "Transformar archivo", Table.ColumnNames(#"Transformar archivo"(#"Archivo de ejemplo"))),
    #"Tipo cambiado" = Table.TransformColumnTypes(#"Columna de tabla expandida1",{{"Source.Name", type text}, {"ID Ticket", type text}, {"Fecha", type date}, {"ID Empleado", Int64.Type}, {"ID Agente", Int64.Type}, {"Categoría", type text}, {"Tipo", type text}, {"Severidad", type text}, {"Prioridad", type text}, {"Días Resolución", Int64.Type}, {"Satisfacción", Int64.Type}}),
    #"Columnas quitadas" = Table.RemoveColumns(#"Tipo cambiado",{"Source.Name"}),
    #"Semana del año insertada" = Table.AddColumn(#"Columnas quitadas", "Semana del año", each Date.WeekOfYear([Fecha]), Int64.Type),
    #"Semana del mes insertada" = Table.AddColumn(#"Semana del año insertada", "Semana del mes", each Date.WeekOfMonth([Fecha]), Int64.Type),
    #"Nombre del día insertado" = Table.AddColumn(#"Semana del mes insertada", "Nombre del día", each Date.DayOfWeekName([Fecha]), type text),
    #"Columnas quitadas1" = Table.RemoveColumns(#"Nombre del día insertado",{"Semana del año", "Semana del mes", "Nombre del día"})
in
    #"Columnas quitadas1"

```
     
## 2. Modelado de los datos
En esta etapa se siguió utilizando el editor de power query para crear la tabla hechos y dimensiones, propios del modelo de datos estrella, obteniendo como resultado el siguiente modelo:

- HechoTickets

```
let
    Origen = Folder.Files("Dirección del folder con los datos"),
    #"Archivos ocultos filtrados1" = Table.SelectRows(Origen, each [Attributes]?[Hidden]? <> true),
    #"Invocar función personalizada1" = Table.AddColumn(#"Archivos ocultos filtrados1", "Transformar archivo", each #"Transformar archivo"([Content])),
    #"Columnas con nombre cambiado1" = Table.RenameColumns(#"Invocar función personalizada1", {"Name", "Source.Name"}),
    #"Otras columnas quitadas1" = Table.SelectColumns(#"Columnas con nombre cambiado1", {"Source.Name", "Transformar archivo"}),
    #"Columna de tabla expandida1" = Table.ExpandTableColumn(#"Otras columnas quitadas1", "Transformar archivo", Table.ColumnNames(#"Transformar archivo"(#"Archivo de ejemplo"))),
    #"Tipo cambiado" = Table.TransformColumnTypes(#"Columna de tabla expandida1",{{"Source.Name", type text}, {"ID Ticket", type text}, {"Fecha", type date}, {"ID Empleado", Int64.Type}, {"ID Agente", Int64.Type}, {"Categoría", type text}, {"Tipo", type text}, {"Severidad", type text}, {"Prioridad", type text}, {"Días Resolución", Int64.Type}, {"Satisfacción", Int64.Type}}),
    #"Columnas quitadas" = Table.RemoveColumns(#"Tipo cambiado",{"Source.Name"}),
    #"Semana del año insertada" = Table.AddColumn(#"Columnas quitadas", "Semana del año", each Date.WeekOfYear([Fecha]), Int64.Type),
    #"Semana del mes insertada" = Table.AddColumn(#"Semana del año insertada", "Semana del mes", each Date.WeekOfMonth([Fecha]), Int64.Type),
    #"Nombre del día insertado" = Table.AddColumn(#"Semana del mes insertada", "Nombre del día", each Date.DayOfWeekName([Fecha]), type text),
    #"Columnas quitadas1" = Table.RemoveColumns(#"Nombre del día insertado",{"Semana del año", "Semana del mes", "Nombre del día"})
in
    #"Columnas quitadas1"

```
  
- DimAgentes_de_TI
```
  let
    Origen = Excel.Workbook(File.Contents("Direccion del archivo con los datos"), null, true),
    #"Agentes de TI_Sheet" = Origen{[Item="Agentes de TI",Kind="Sheet"]}[Data],
    #"Filas superiores quitadas" = Table.Skip(#"Agentes de TI_Sheet",1),
    #"Encabezados promovidos" = Table.PromoteHeaders(#"Filas superiores quitadas", [PromoteAllScalars=true]),
    #"Tipo cambiado" = Table.TransformColumnTypes(#"Encabezados promovidos",{{"ID Agente", Int64.Type}, {"Nombre", type text}, {"email", type text}, {"Año", Int64.Type}, {"Mes", Int64.Type}, {"Día", Int64.Type}}),
    #"Columna combinada insertada" = Table.AddColumn(#"Tipo cambiado", "Fecha Nacimiento", each Text.Combine({Text.From([Día], "es-PE"), Text.From([Mes], "es-PE"), Text.From([Año], "es-PE")}, "/"), type text),
    #"Tipo cambiado1" = Table.TransformColumnTypes(#"Columna combinada insertada",{{"Fecha Nacimiento", type date}}),
    #"Texto insertado antes del delimitador" = Table.AddColumn(#"Tipo cambiado1", "Texto antes del delimitador", each Text.BeforeDelimiter([email], "@"), type text),
    #"Columnas reordenadas" = Table.ReorderColumns(#"Texto insertado antes del delimitador",{"ID Agente", "Nombre", "Texto antes del delimitador", "email", "Año", "Mes", "Día", "Fecha Nacimiento"}),
    #"Valor reemplazado" = Table.ReplaceValue(#"Columnas reordenadas","."," ",Replacer.ReplaceText,{"Texto antes del delimitador"}),
    #"Poner En Mayúsculas Cada Palabra" = Table.TransformColumns(#"Valor reemplazado",{{"Texto antes del delimitador", Text.Proper, type text}}),
    #"Columnas quitadas" = Table.RemoveColumns(#"Poner En Mayúsculas Cada Palabra",{"Nombre"}),
    #"Columnas con nombre cambiado" = Table.RenameColumns(#"Columnas quitadas",{{"Texto antes del delimitador", "Nombre"}}),
    #"Antigüedad insertada" = Table.AddColumn(#"Columnas con nombre cambiado", "Antigüedad", each Date.From(DateTime.LocalNow()) - [Fecha Nacimiento], type duration),
    #"Total de años calculados" = Table.TransformColumns(#"Antigüedad insertada",{{"Antigüedad", each Duration.TotalDays(_) / 365, type number}}),
    #"Redondeado a la baja" = Table.TransformColumns(#"Total de años calculados",{{"Antigüedad", Number.RoundDown, Int64.Type}}),
    #"Columna condicional agregada" = Table.AddColumn(#"Redondeado a la baja", "Edad Grupo", each if [Antigüedad] < 30 then "20-29" else if [Antigüedad] < 40 then "30-39" else "40+"),
    #"Tipo cambiado2" = Table.TransformColumnTypes(#"Columna condicional agregada",{{"Edad Grupo", type text}}),
    #"Columnas con nombre cambiado1" = Table.RenameColumns(#"Tipo cambiado2",{{"Antigüedad", "Edad"}}),
    #"Consultas combinadas" = Table.NestedJoin(#"Columnas con nombre cambiado1", {"ID Agente"}, FotosAgentes, {"ID Agente"}, "FotosAgentes", JoinKind.LeftOuter),
    #"Se expandió FotosAgentes" = Table.ExpandTableColumn(#"Consultas combinadas", "FotosAgentes", {"Genero", "URL Foto"}, {"Genero", "URL Foto"})

in
    #"Se expandió FotosAgentes"
```
- DimSatisfacción
```
  let
    Origen = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("i45WMlTSUXJJTU4tSM7Mz0vMK0kF8v1S0xNLMsvygcxHaycoxepEKxkB2b6JOfkYsjAFxkBuUGp6aU5iETY1MGUmQBGn0tQ8kExAfnEmuiKYOlOgoGtFcmpOKsRJONSClccCAA==", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [Satisfacción = _t, #"Satisfacción Grupo" = _t, Estatus = _t, Rating = _t]),
    #"Tipo cambiado" = Table.TransformColumnTypes(Origen,{{"Satisfacción", Int64.Type}, {"Satisfacción Grupo", type text}, {"Estatus", type text}, {"Rating", type text}})
in
    #"Tipo cambiado"
```  
- DimDias
```
let
    Origen = HechoTickets[Días Resolución],
    #"Duplicados quitados" = List.Distinct(Origen),
    #"Elementos ordenados" = List.Sort(#"Duplicados quitados",Order.Ascending),
    #"Convertida en tabla" = Table.FromList(#"Elementos ordenados", Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Tipo cambiado" = Table.TransformColumnTypes(#"Convertida en tabla",{{"Column1", Int64.Type}}),
    #"Columnas con nombre cambiado" = Table.RenameColumns(#"Tipo cambiado",{{"Column1", "Días Abierto"}})
in
    #"Columnas con nombre cambiado"
```
- DimCalendario
```
let
    Origen = HechoTickets[Fecha],
    FechaMinima = #date( Date.Year(List.Min(Origen)), 01, 01 ),
    FechaMaxima = #date( Date.Year(List.Max(Origen)), 12, 31 ),
    Personalizado1 = {Number.From(FechaMinima)..Number.From(FechaMaxima)},
    #"Convertida en tabla" = Table.FromList(Personalizado1, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Tipo cambiado" = Table.TransformColumnTypes(#"Convertida en tabla",{{"Column1", type date}}),
    #"Columnas con nombre cambiado" = Table.RenameColumns(#"Tipo cambiado",{{"Column1", "Fecha"}}),
    #"Año insertado" = Table.AddColumn(#"Columnas con nombre cambiado", "Año", each Date.Year([Fecha]), Int64.Type),
    #"Mes insertado" = Table.AddColumn(#"Año insertado", "Mes", each Date.Month([Fecha]), Int64.Type),
    #"Nombre del mes insertado" = Table.AddColumn(#"Mes insertado", "Nombre del mes", each Date.MonthName([Fecha]), type text),
    #"Trimestre insertado" = Table.AddColumn(#"Nombre del mes insertado", "Trimestre", each Date.QuarterOfYear([Fecha]), Int64.Type),
    #"Semana del año insertada" = Table.AddColumn(#"Trimestre insertado", "Semana del año", each Date.WeekOfYear([Fecha]), Int64.Type),
    #"Semana del mes insertada" = Table.AddColumn(#"Semana del año insertada", "Semana del mes", each Date.WeekOfMonth([Fecha]), Int64.Type),
    #"Día insertado" = Table.AddColumn(#"Semana del mes insertada", "Día", each Date.Day([Fecha]), Int64.Type),
    #"Día de la semana insertado" = Table.AddColumn(#"Día insertado", "Día de la semana", each Date.DayOfWeek([Fecha]), Int64.Type),
    #"Día del año insertado" = Table.AddColumn(#"Día de la semana insertado", "Día del año", each Date.DayOfYear([Fecha]), Int64.Type),
    #"Nombre del día insertado" = Table.AddColumn(#"Día del año insertado", "Nombre del día", each Date.DayOfWeekName([Fecha]), type text),
    #"Valor reemplazado" = Table.ReplaceValue(#"Nombre del día insertado",0,7,Replacer.ReplaceValue,{"Día de la semana"}),
    #"Primeros caracteres insertados" = Table.AddColumn(#"Valor reemplazado", "Primeros caracteres", each Text.Start([Nombre del mes], 3), type text),
    #"Primeros caracteres insertados1" = Table.AddColumn(#"Primeros caracteres insertados", "Primeros caracteres.1", each Text.Start([Nombre del día], 3), type text),
    #"Columna condicional agregada" = Table.AddColumn(#"Primeros caracteres insertados1", "Semestre", each if [Mes] <= 6 then 1 else if [Mes] <= 12 then 2 else null),
    #"Columna condicional agregada1" = Table.AddColumn(#"Columna condicional agregada", "Tipo de Día", each if [Día de la semana] <= 5 then "Día Laboral" else "Fin de Semana"),
    #"Columnas con nombre cambiado1" = Table.RenameColumns(#"Columna condicional agregada1",{{"Primeros caracteres", "Mes Corto"}, {"Primeros caracteres.1", "Dia Corto"}})
in
    #"Columnas con nombre cambiado1"

```
Obteniendo asi el siguiente modelo:

![image](https://github.com/JeanEdinson/Analisis-de-Datos-Portafolio/assets/51329337/31e41fe6-a1df-49f8-90bf-165825e4cafe)

Como último paso de esta etapa se crearon las medidas necesarias para el análisis mediante el lenguaje DAX.

![image](https://github.com/JeanEdinson/Analisis-de-Datos-Portafolio/assets/51329337/dac73a8f-97c7-41f3-81aa-6b1cef91134a)

## 3. Visualizaciones y formato de reporte
Se utilizaron visualizaciones de áreas, barras, pastel, tarjetas, tablas, además, se creó una página que se utilizó como tooltip para obtener más detalles de cada agente, se creó un modo oscuro para el reporte general, se establecieron rankings de desempeño, se utilizaron marcadores para mostrar más visualizaciones de interés, entre otras cosas más que podrán ver el reporte final. El cual consistió en dos páginas, la primera brinda conocimiento en base a una segmentación de tickets de atención y la segunda se centra en analizar el desempeño de los agentes de TI.

![image](https://github.com/JeanEdinson/Analisis-de-Datos-Portafolio/assets/51329337/722f798b-b4b6-4c78-b320-7bf6966d9381)

![image](https://github.com/JeanEdinson/Analisis-de-Datos-Portafolio/assets/51329337/2c6f90fb-c96f-467c-a211-28fcbe5a6572)

![image](https://github.com/JeanEdinson/Analisis-de-Datos-Portafolio/assets/51329337/c9fa6090-7306-4691-8985-d4b3f6843c75)

![image](https://github.com/JeanEdinson/Analisis-de-Datos-Portafolio/assets/51329337/e178b153-3814-4591-bd53-43ddd9e1b841)

![image](https://github.com/JeanEdinson/Analisis-de-Datos-Portafolio/assets/51329337/2e3a02c7-ffdd-4a97-ad07-1f90127229f7)

![image](https://github.com/JeanEdinson/Analisis-de-Datos-Portafolio/assets/51329337/f10409e0-5865-4842-ac5d-652b1f6ef860)

El reporte final se puede ver en el siguiente enlace:

[Reporte Final - Campeonato Mundial](https://app.powerbi.com/view?r=eyJrIjoiNTgwMmFkMDktZmRmYS00ZDlhLTg3NzItNjgzNjQ4MjY1Y2YxIiwidCI6ImM4MThkN2FlLTQzNmEtNGQ3MC1iODlhLWE1ZGRiYjljNWEyNSJ9)







# Datos FIFA - Campeonato Mundial

En este proyecto se utilizó un banco de datos libre sobre los campeonatos mundiales, el cual se dividió en dos archivos CSV:
- WorldCupMatches.csv: Este archivo contiene datos sobre todos los partidos realizados desde el mundial de 1930 hasta el del 2014.
- WorldCups.csv: Este archivo contiene los datos generales de cada mundial como la sede, el campeón, el subcampeón, el tercer y cuarto lugar, la cantidad de goles anotados, etc.

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
    Origen = Folder.Files("Direccion de carpeta"),
    #"Datos\_WorldCupMatches csv" = Origen{[#"Folder Path"="Direccion de carpeta",Name="WorldCupMatches.csv"]}[Content],
    #"CSV importado" = Csv.Document(#"Datos\_WorldCupMatches csv",[Delimiter=",", Columns=20, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Encabezados promovidos" = Table.PromoteHeaders(#"CSV importado", [PromoteAllScalars=true]),
    #"Tipo cambiado" = Table.TransformColumnTypes(#"Encabezados promovidos",{{"Year", Int64.Type}, {"Datetime", type text}, {"Stage", type text}, {"Stadium", type text}, {"City", type text}, {"Home Team Name", type text}, {"Home Team Goals", Int64.Type}, {"Away Team Goals", Int64.Type}, {"Away Team Name", type text}, {"Win conditions", type text}, {"Attendance", Int64.Type}, {"Half-time Home Goals", Int64.Type}, {"Half-time Away Goals", Int64.Type}, {"Referee", type text}, {"Assistant 1", type text}, {"Assistant 2", type text}, {"RoundID", Int64.Type}, {"MatchID", Int64.Type}, {"Home Team Initials", type text}, {"Away Team Initials", type text}}),
    #"Eliminar campos vacios en la columna años" = Table.SelectRows(#"Tipo cambiado", each ([Year] <> null and [Year] <> "")),
    #"Duplicados quitados en la id de partidos" = Table.Distinct(#"Eliminar campos vacios en la columna años", {"MatchID"}),
    #"Valores nulos en audiencia resplazados con cero" = Table.ReplaceValue(#"Duplicados quitados en la id de partidos",null,0,Replacer.ReplaceValue,{"Attendance"}),
    #"Valores vacios en columna ""Win Conditions"" remplazados" = Table.ReplaceValue(#"Valores nulos en audiencia resplazados con cero"," ","Sin condiciones extras",Replacer.ReplaceValue,{"Win conditions"}),
    #"Filas filtradas" = Table.SelectRows(#"Valores vacios en columna ""Win Conditions"" remplazados", each true),
    #"Columnas reordenadas" = Table.ReorderColumns(#"Filas filtradas",{"Year", "Datetime", "Stage", "Stadium", "City", "Home Team Name", "Home Team Goals", "Away Team Goals", "Away Team Name", "Win conditions", "Attendance", "Half-time Home Goals", "Half-time Away Goals", "Referee", "Assistant 1", "Assistant 2", "RoundID", "MatchID", "Home Team Initials", "Away Team Initials"}),
    #"Otras columnas quitadas" = Table.SelectColumns(#"Columnas reordenadas",{"Year", "Datetime", "Stage", "Stadium", "Home Team Name", "Home Team Goals", "Away Team Goals", "Away Team Name", "Win conditions", "Attendance", "Half-time Home Goals", "Half-time Away Goals", "Referee", "Assistant 1", "Assistant 2", "RoundID", "MatchID"}),
    #"Valor reemplazado" = Table.ReplaceValue(#"Otras columnas quitadas","-","",Replacer.ReplaceText,{"Datetime"}),
    #"Tipo cambiado1" = Table.TransformColumnTypes(#"Valor reemplazado",{{"Datetime", type datetime}}),
    #"Fecha insertada" = Table.AddColumn(#"Tipo cambiado1", "Fecha", each Date.From([Datetime]), type date),
    #"Hora insertada" = Table.AddColumn(#"Fecha insertada", "Hora", each Time.From([Datetime]), type time),
    #"Valor reemplazado1" = Table.ReplaceValue(#"Hora insertada","Stade V�lodrome","Stade Vélodrome",Replacer.ReplaceValue,{"Stadium"}),
    #"Valor reemplazado2" = Table.ReplaceValue(#"Valor reemplazado1","Maracan� - Est�dio Jornalista M�rio Filho","Maracaná - Estádio Jornalista Mário Filho",Replacer.ReplaceValue,{"Stadium"}),
    #"Valor reemplazado3" = Table.ReplaceValue(#"Valor reemplazado2","Nou Camp - Estadio Le�n","Nou Camp - Estadio León",Replacer.ReplaceValue,{"Stadium"}),
    #"Valor reemplazado4" = Table.ReplaceValue(#"Valor reemplazado3","Estadio Jos� Mar�a Minella","Estadio José María Minella",Replacer.ReplaceValue,{"Stadium"}),
    #"Valor reemplazado5" = Table.ReplaceValue(#"Valor reemplazado4","Estadio Ol�mpico Chateau Carreras","Estadio Olímpico Chateau Carreras",Replacer.ReplaceText,{"Stadium"}),
    #"Valor reemplazado6" = Table.ReplaceValue(#"Valor reemplazado5","Estadio Municipal de Bala�dos","Estadio Municipal de Balaídos",Replacer.ReplaceValue,{"Stadium"}),
    #"Valor reemplazado7" = Table.ReplaceValue(#"Valor reemplazado6","Estadio Ol�mpico Universitario","Estadio Olímpico Universitario",Replacer.ReplaceText,{"Stadium"}),
    #"Valor reemplazado8" = Table.ReplaceValue(#"Valor reemplazado7","IR Iran","Iran",Replacer.ReplaceValue,{"Home Team Name"}),
    #"Valor reemplazado9" = Table.ReplaceValue(#"Valor reemplazado8","IR Iran","Iran",Replacer.ReplaceValue,{"Away Team Name"}),
    #"Valor reemplazado10" = Table.ReplaceValue(#"Valor reemplazado9","rn"">","",Replacer.ReplaceText,{"Home Team Name"}),
    #"Valor reemplazado11" = Table.ReplaceValue(#"Valor reemplazado10","rn"">","",Replacer.ReplaceText,{"Away Team Name"}),
    #"Valor reemplazado12" = Table.ReplaceValue(#"Valor reemplazado11","C�te d'Ivoire","Côte d'Ivoire",Replacer.ReplaceValue,{"Home Team Name"}),
    #"Valor reemplazado13" = Table.ReplaceValue(#"Valor reemplazado12","C�te d'Ivoire","Côte d'Ivoire",Replacer.ReplaceValue,{"Away Team Name"}),
    #"Consultas combinadas" = Table.NestedJoin(#"Valor reemplazado13", {"Stage"}, Dim_Fase, {"Stage"}, "Dim_Fase", JoinKind.LeftOuter),
    #"Se expandió Dim_Fase" = Table.ExpandTableColumn(#"Consultas combinadas", "Dim_Fase", {"Indice"}, {"Dim_Fase.Indice"}),
    #"Columnas con nombre cambiado" = Table.RenameColumns(#"Se expandió Dim_Fase",{{"Dim_Fase.Indice", "ID Fase"}}),
    #"Columnas reordenadas1" = Table.ReorderColumns(#"Columnas con nombre cambiado",{"Year", "Datetime", "ID Fase", "Stage", "Stadium", "Home Team Name", "Home Team Goals", "Away Team Goals", "Away Team Name", "Win conditions", "Attendance", "Half-time Home Goals", "Half-time Away Goals", "Referee", "Assistant 1", "Assistant 2", "RoundID", "MatchID", "Fecha", "Hora"})
in
    #"Columnas reordenadas1"
```
     
## 2. Modelado de los datos
En esta etapa se siguió utilizando el editor de power query para crear la tabla hechos y dimensiones, propios del modelo de datos estrella, obteniendo como resultado el siguiente modelo:

![image](https://github.com/JeanEdinson/Analisis-de-Datos-Portafolio/assets/51329337/fbb3b31a-ce5f-4aff-bd98-b23dcc65cb3f)

Como último paso de esta etapa se crearon las medidas necesarias para el análisis mediante el lenguaje DAX.

![image](https://github.com/JeanEdinson/Analisis-de-Datos-Portafolio/assets/51329337/58ed3551-6371-4511-a527-ba87eada05f3)
 
## 3. Visualizaciones y formato de reporte
Se crearon visualizaciones de mapas, barras, tarjetas, tablas e incluso se utilizó la visualización externa de banderas para un mejor entendimiento del reporte. El cual consistió en dos páginas, la primera brinda conocimiento sobre cada mundial realizado y la segunda se centra en analizar el comportamiento de cada selección durante un mundial.

![image](https://github.com/JeanEdinson/Analisis-de-Datos-Portafolio/assets/51329337/42369c90-94f2-414e-a603-2411a77e53b2)

![image](https://github.com/JeanEdinson/Analisis-de-Datos-Portafolio/assets/51329337/caed9355-753d-4029-bb5a-8e72a23ed92b)

El reporte final se puede ver en el siguiente enlace:

[Reporte Final - Campeonato Mundial](https://app.powerbi.com/view?r=eyJrIjoiOWM5M2QyNDQtMDk5Mi00ZjBjLWExMmQtN2QwMzdkODc4ODZjIiwidCI6ImM4MThkN2FlLTQzNmEtNGQ3MC1iODlhLWE1ZGRiYjljNWEyNSJ9&pageName=ReportSection)






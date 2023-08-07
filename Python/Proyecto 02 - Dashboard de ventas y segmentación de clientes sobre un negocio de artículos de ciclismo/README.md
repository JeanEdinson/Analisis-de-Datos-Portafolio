# Dashboard de ventas y segmentación de clientes sobre un negocio de artículos de ciclismo

El presente proyecto se basa en realizar todas las etapas de un correcto análisis de datos, haciendo uso de Python, pandas, numpy, power bi, power query y DAX; sobre un dataset contenido en un archivo Excel llamado “Raw_data”, el cual se divide en cuatro hojas:
-	La primera hoja contiene las transacciones realizadas durante el año 2017 en un negocio de artículos de bicicletas.
-	La segunda hoja contiene datos demográficos y de ubicación sobre los nuevos clientes que se han registrado en el negocio.
-	La tercera y última hoja contienen datos demográficos y de ubicación de los antiguos clientes respectivamente.
Nota: Una vez inmerso en la explicación de las etapas del trabajo, se dará mas detalle de cada dato del archivo.
Existen diversas documentaciones que muestran diferentes procedimientos al momento de realizar un análisis de datos, sin embargo, todas ellas se centran en 5 grandes etapas:

## 1.	Obtener Datos.
Como ya se mencionó, los datos se obtuvieron del archivo “Raw_data” y sus cuatro hojas: Transactions, NewCustomerList, CustomerDemographic y CustomerAddress.

## 2.	Preparación de Datos.
Esta es la etapa mas importante de las cinco y aquí hice uso de Python y sus librerías Pandas y Numpy para poder entender los datos y más importante aún, limpiarlos.

Como primer paso, importe los datos al entorno de trabajo que me brinda jupyter notebook y crea un diccionario de datos en un archivo Excel con la descripción de cada columna de las cuatro tablas, dicho diccionario lo podrán encontrar en la presente carpeta del repositorio.

Ya habiendo entendido cada dato del dataset, procedí a realizar los siguientes pasos por cada hoja del archivo de origen.

-	Identificar la cantidad de registros y columnas
-	Eliminar las columnas innecesarias
-	Tratar o limpiar los valores nulos o erróneos
-	Eliminar registros duplicados
-	Tratar o limpiar valores atípicos
-	Agregar nuevas columnas necesarias 
-	Corregir tipos de datos de las columnas

Al final exporte tres archivos CSV con datos limpios:

-	transacciones_limpiado.csv: Contiene datos limpios de las transacciones del archivo de origen.
-	nuevos_clientes_limpiado.csv: Contiene datos limpios de los nuevos clientes registrados en el negocio del archivo de origen.
-	clientes_antiguos.csv: Contiene datos limpios de la combinación de las dos ultimas hojas del archivo de origen (CustomerDemographic y CustomerAddress).
Todo este proceso lo pueden observar en el archivo llamado “Exploración y Limpieza de Datos.ipynb”, que se encuentra ubicado en la presente carpeta del repositorio.

## 3.	Modelado de Datos.
Ya teniendo lo datos limpios, se procedió a utilizar la herramienta Power Query y el lenguaje DAX, propias de Power BI, para realizar un modelo estrella de los datos. Entre las tareas que se realizaron en esta etapa tenemos:

-	Aprovechar la interfaz grafica de power query para dar formato a los valores de determinadas columnas como por ejemplo capitalizar los textos, cambiar valores booleanos a valores entendibles por el usuario, etc.
-	Crear la tabla hecho “Hecho_Transacciones” y las dimensiones “Dim_Nuevos_Clientes”, “Dim_Antiguos_Clientes”, “Dim_Clase_Producto” y “Dim_Tamaño_Producto” con power query.
-	Crear la dimensión “Dim_Calendario” con el lenguaje DAX.
IMAGEN DEL CODIGO

Al final el modelo quedo de la siguiente manera:
IMAGEN DEL MODELO
Aquí cabe resaltar que la dimensión “Dim_Nuevos_Clientes” no esta relacionada con ninguna tabla ya que tiene la finalidad de brindar información de los nuevos clientes mas no existen transacciones ligados a ellos.

Ya en este punto, entra a tallar un tema importante, para poder segmentar a los clientes antiguos se utilizó el análisis RFM (recencia, frecuencia y valor monetario), utilizada en marketing y análisis de clientes para segmentar y comprender la base de clientes en función de su comportamiento de compra. Se centra en tres aspectos clave de la interacción del cliente con un negocio:
-	Recencia (Recency): Se refiere a la última vez que un cliente realizó una compra. Cuanto más reciente sea la compra, mayor será el valor asignado en términos de recencia. En este caso se utilizo la cantidad de días transcurridos desde la ultima compra del cliente hasta la fecha 01/01/2018.
-	Frecuencia (Frequency): Hace referencia a la cantidad de veces que un cliente ha realizado compras en un período de tiempo determinado. Los clientes que compran con frecuencia obtienen un valor más alto en esta dimensión. En este caso se utilizo la cantidad de compras realizadas durante todo el 2017.
-	Monetario (Monetary): Indica cuánto dinero ha gastado un cliente en total en el negocio. Los clientes que gastan más dinero reciben un valor más alto en términos monetarios. En este caso se utilizó las ganancias obtenidas por el negocio por las compras del cliente.
Para estas tres puntuaciones se utilizo una escala del 1 al 5, siendo 1 el que represente un comportamiento negativo del cliente con el negocio y 5 un comportamiento positivo. Al final, estos valores se utilizaron para crear segmentos o clusters que reflejan diferentes tipos de comportamiento de compra.

La finalidad de explicar el análisis RFM es porque se utilizo el lenguaje DAX para crear las medidas necesarias para poder realizar este tipo de análisis.
IMAGEN DE LAS MEDIDAS

## 4.	Visualización de Datos.
En esta etapa se crearon diversos gráficos, los cuales se formatearon de tal forma para garantizar armoniosidad en la visualización, por otro lado, se establecieron las interacciones entre gráficos y se determinaron los filtros necesarios para el análisis.

## 5.	Reporteo de Datos.

Los gráficos se dividieron en tres páginas:

-	Dashboard General: En esta página se crearon y ordenaron gráficos para analizar los datos referentes a las ventas generadas en el negocio.
IMAGEN

-	Clientes Antiguos: En esta página se crearon y ordenaron gráficos para analizar el comportamiento de los clientes con el negocio por segmentación.
IMAGEN

-	Clientes Nuevo: En esta pagina se crearon y ordenaron gráficos para segmentar a los nuevos clientes por datos demográficos y de ubicación.
IMAGEN
	El reporte final se puede visualizar en el siguiente enlace:

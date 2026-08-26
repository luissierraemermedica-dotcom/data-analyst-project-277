-- Seleccionamos los datos a mostrar en el reporte
SELECT
    e.first_name,	-- Nombre del vendedor
    e.last_name,	-- Apellido del vendedor

    -- Calculamos los ingresos totales:
    SUM(s.quantity * p.price) AS total_income	    -- Cant productos vendidos x por su precio y luego sumamos todos los ingresos de cada vendedor

FROM sales s	-- Indicamos que la información principal proviene de la tabla sales

JOIN employees e	-- Unimos la tabla employees para obtener los datos del vendedor
    ON s.sales_person_id = e.employee_id	-- Relacionamos el vendedor de la venta con su empleado correspondiente
JOIN products p	-- Unimos la tabla products para obtener el precio de cada producto
    ON s.product_id = p.product_id	-- Relacionamos el producto vendido con su información en products

GROUP BY	-- Agrupamos las ventas por cada vendedor
    e.employee_id,	-- Identificador único del vendedor
    e.first_name,	-- Nombre del vendedor
    e.last_name		-- Apellido del vendedor

ORDER BY total_income DESC	-- Ordenamos los vendedores desde el que tiene mayores ingresos hasta el que tiene menores ingresos

LIMIT 10;	-- Limitamos el resultado a los 10 vendedores con mayores ingresos


-- Creamos una expresión de tabla común (CTE) para calcular el ingreso promedio de cada vendedor
WITH employee_average_income AS (

    SELECT	-- Seleccionamos los datos necesarios de cada vendedor
        e.employee_id,	-- Identificador del vendedor
        e.first_name,	-- Nombre del vendedor
        e.last_name,	-- Apellido del vendedor

        AVG(s.quantity * p.price) AS average_income	-- Calculamos el ingreso promedio de las ventas de cada vendedor

    FROM sales s	-- La información de las ventas proviene de la tabla sales
	
    JOIN employees e	-- Unimos sales con employees para identificar al vendedor
        ON s.sales_person_id = e.employee_id	-- Relacionamos el vendedor de la venta con el empleado
    JOIN products p	-- Unimos sales con products para obtener el precio del producto
        ON s.product_id = p.product_id	-- Relacionamos cada producto vendido con su información

    GROUP BY	-- Agrupamos las ventas por cada vendedor
        e.employee_id,	-- Identificador del vendedor
        e.first_name,	-- Nombre del vendedor
        e.last_name	-- Apellido del vendedor
),

-- Creamos una segunda expresión de tabla común (CTE) para calcular el promedio de los ingresos promedio de todos los vendedores
general_average AS (
    SELECT AVG(average_income) AS average_income	-- Calculamos el promedio general
    FROM employee_average_income	-- Utilizamos los resultados obtenidos en la primera CTE
)

-- Seleccionamos los vendedores cuyo promedio está por debajo del promedio general
SELECT
    eai.first_name,	-- Nombre del vendedor
    eai.last_name,	-- Apellido del vendedor
    eai.average_income	-- Ingreso promedio del vendedor

FROM employee_average_income eai	-- Utilizamos la primera CTE como fuente de datos

CROSS JOIN general_average ga	-- Realizamos un CROSS JOIN con el promedio general para poder comparar cada vendedor con dicho promedio

WHERE eai.average_income < ga.average_income	-- Filtramos solamente los vendedores cuyo promedio es menor que el promedio general

ORDER BY eai.average_income ASC;	-- Ordenamos los resultados desde el menor ingreso promedio hasta el mayor


-- Seleccionamos la información que queremos mostrar
SELECT
    e.first_name,	-- Nombre del vendedor
    e.last_name,	-- Apellido del vendedor

    TO_CHAR(s.sale_date, 'FMDay') AS day_of_the_week,	-- Convertimos la fecha de venta en el nombre del día de la semana FM elimina los espacios adicionales que puede generar TO_CHAR

    FLOOR(SUM(s.quantity * p.price)) AS total_income	-- Calculamos los ingresos totales de las ventas y eliminamos la parte decimal utilizando FLOOR

FROM sales s	-- La información principal se obtiene de la tabla sales

JOIN employees e	-- Unimos sales con employees para identificar al vendedor
    ON s.sales_person_id = e.employee_id	-- Relacionamos el vendedor de la venta con el empleado
JOIN products p	-- Unimos sales con products para obtener el precio de cada producto vendido
    ON s.product_id = p.product_id	-- Relacionamos el producto vendido con su información

GROUP BY	-- Agrupamos los resultados por vendedor y día de la semana
    e.employee_id,	-- Identificador del vendedor
    e.first_name,	-- Nombre del vendedor
    e.last_name,	-- Apellido del vendedor

    EXTRACT(ISODOW FROM s.sale_date),	-- Obtenemos el número del día de la semana. ISODOW utiliza lunes = 1 y domingo = 7

    TO_CHAR(s.sale_date, 'FMDay')	-- También agrupamos por el nombre del día

ORDER BY	-- Ordenamos primero por el número del día de la semana para que aparezca en orden de lunes a domingo
    EXTRACT(ISODOW FROM s.sale_date),

    e.first_name,	-- Dentro de cada día ordenamos por nombre
    e.last_name;	-- Finalmente ordenamos por apellido
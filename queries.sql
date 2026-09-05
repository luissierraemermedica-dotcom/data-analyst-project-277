-- Cuenta el número total de registros (clientes) en la tabla customers
SELECT COUNT(*) AS customers_count
FROM customers;


-- Reporte 1 Los 10 vendedores con más ingresos
SELECT
    -- Concatena el nombre y apellido del empleado para mostrar el nombre completo del vendedor
    CONCAT(e.first_name, ' ', e.last_name) AS seller,

    -- Cuenta la cantidad de operaciones/ventas realizadas por cada vendedor
    COUNT(s.sales_id) AS operations,

    /*	Calcula el ingreso total generado por cada vendedor.
    	El ingreso se obtiene multiplicando el precio del producto por la cantidad vendida.
    	FLOOR() elimina los decimales del resultado.
	*/
	
    FLOOR(SUM(p.price * s.quantity)) AS income

-- La tabla principal contiene los registros de las ventas
FROM sales s

-- Relaciona cada venta con el empleado que realizó dicha venta
JOIN employees e
    ON s.sales_person_id = e.employee_id

-- Relaciona cada venta con el producto vendido para obtener su precio
JOIN products p
    ON s.product_id = p.product_id

/*	
	Agrupa los resultados por vendedor.
	Se incluyen el ID, nombre y apellido para identificar correctamente a cada empleado.
*/

GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name

-- Ordena los vendedores de mayor a menor según el ingreso generado
ORDER BY income DESC

-- Limita el resultado a los 10 vendedores con mayores ingresos
LIMIT 10;

-- Reporte 2 Vendedores con ingresos por debajo del promedio
SELECT
    -- Concatena el nombre y apellido del vendedor en un campo llamado seller
    CONCAT(e.first_name, ' ', e.last_name) AS seller,

    -- Calcula el ingreso promedio por venta del vendedor y lo redondea
    -- hacia abajo al número entero más cercano
    FLOOR(AVG(p.price * s.quantity)) AS average_income

FROM Employees e

-- Relaciona cada empleado con las ventas que realizó
JOIN Sales s
    ON e.employee_id = s.sales_person_id

-- Relaciona cada venta con el producto vendido para obtener su precio
JOIN Products p
    ON s.product_id = p.product_id

/*
	Agrupa las ventas por empleado para calcular el ingreso promedio
	de cada vendedor de manera independiente
*/

GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name

/*
	Filtra únicamente los vendedores cuyo ingreso promedio
	sea menor que el ingreso promedio general de todas las ventas
*/

HAVING AVG(p.price * s.quantity) < (

/*
    -- Calcula el ingreso promedio general considerando todas las ventas
    -- sin importar qué empleado realizó la venta
*/

    SELECT AVG(p2.price * s2.quantity)

    FROM Sales s2

/*
    -- Se une nuevamente Sales con Products para obtener
    -- el precio correspondiente a cada producto vendido
*/

    JOIN Products p2
        ON s2.product_id = p2.product_id
)

/*
-- Ordena los vendedores desde el menor hasta el mayor
-- ingreso promedio
*/

ORDER BY average_income ASC;


-- Reporte 3 ingresos por día de la semana

SELECT
    -- Nombre completo del vendedor
    CONCAT(e.first_name, ' ', e.last_name) AS seller,

    -- Nombre del día de la semana en inglés y en minúsculas
    LOWER(TO_CHAR(s.sale_date, 'Day')) AS day_of_week,

    -- Ingreso total: precio × cantidad, redondeado hacia abajo
    FLOOR(SUM(p.price * s.quantity)) AS income

FROM Sales AS s

-- Relacionamos cada venta con el vendedor
INNER JOIN Employees AS e
    ON s.sales_person_id = e.employee_id

-- Relacionamos cada venta con el producto para obtener su precio
INNER JOIN Products AS p
    ON s.product_id = p.product_id

-- Agrupamos por vendedor y día de la semana
GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name,
	day_of_week

-- Ordenamos primero por el día de la semana y después por el vendedor
ORDER BY
	day_of_week,
    seller;

	
-- Reporte 1 Clientes por grupo de edad
SELECT
    CASE
        -- Clientes entre 16 y 25 años
        WHEN age BETWEEN 16 AND 25 THEN '16–25 años'

        -- Clientes entre 26 y 40 años
        WHEN age BETWEEN 26 AND 40 THEN '26–40 años'

        -- Clientes mayores de 40 años
        WHEN age > 40 THEN '40+ años'
    END AS age_category,

    -- Cuenta la cantidad de clientes pertenecientes a cada categoría
    COUNT(*) AS age_count

FROM Customers

-- Agrupa los clientes según la categoría de edad creada anteriormente
GROUP BY age_category

-- Ordena el resultado de menor a mayor rango de edad
ORDER BY age_category;


-- Reporte 2 clientes e ingresos por mes
SELECT
    -- Convertimos la fecha de venta al formato AÑO-MES
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,

    -- Contamos los clientes únicos que realizaron compras durante el mes
    COUNT(DISTINCT s.customer_id) AS total_customers,

    -- Calculamos los ingresos: cantidad vendida × precio del producto
    SUM(s.quantity * p.price) AS income

FROM Sales AS s

    -- Relacionamos cada venta con su producto para obtener el precio
    INNER JOIN Products AS p
        ON s.product_id = p.product_id

    -- Relacionamos cada venta con el cliente
    INNER JOIN Customers AS c
        ON s.customer_id = c.customer_id

-- Agrupamos las ventas por año y mes
GROUP BY TO_CHAR(s.sale_date, 'YYYY-MM')

-- Ordenamos los resultados de menor a mayor
ORDER BY selling_month ASC;


-- Reporte 3: clientes cuya primera compra fue durante una promoción
WITH ranked_sales AS (
    SELECT
        s.*,

        -- ROW_NUMBER() asigna el número 1 a la primera compra
        -- de cada cliente.
        ROW_NUMBER() OVER (
            PARTITION BY s.customer_id
            ORDER BY s.sale_date, s.sales_id
        ) AS purchase_number

    FROM Sales AS s
)

SELECT DISTINCT
    -- Nombre completo del cliente
    CONCAT(c.first_name, ' ', c.last_name) AS customer,

    -- Fecha de la primera compra
    rs.sale_date,

    -- Nombre completo del vendedor
    CONCAT(e.first_name, ' ', e.last_name) AS seller

FROM ranked_sales AS rs

-- Relacionamos la venta con el cliente
INNER JOIN Customers AS c
    ON rs.customer_id = c.customer_id

-- Relacionamos la venta con el vendedor
INNER JOIN Employees AS e
    ON rs.sales_person_id = e.employee_id

-- Relacionamos la venta con el producto
INNER JOIN Products AS p
    ON rs.product_id = p.product_id

WHERE rs.purchase_number = 1

  -- La primera compra debe haber sido realizada
  -- durante una promoción.
  AND p.price = 0

ORDER BY rs.sale_date;

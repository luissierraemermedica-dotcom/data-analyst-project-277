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
	

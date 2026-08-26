/* ============================================================
Reporte 1: Clientes por grupo de edad
============================================================
Esta consulta cuenta cuántos clientes existen en cada grupo
de edad: 16-25, 26-40 y mayores de 40 años.
============================================================
*/

SELECT
    age_category,	-- Muestra la categoría de edad calculada para cada cliente.
    COUNT(*) AS age_count	-- Cuenta la cantidad de clientes que pertenecen a cada categoría.

FROM (
    SELECT	-- Consulta interna que permite clasificar a cada cliente según su edad.
        CASE
            WHEN age BETWEEN 16 AND 25 THEN '16-25'	-- Clientes con edades entre 16 y 25 años.
            WHEN age BETWEEN 26 AND 40 THEN '26-40'	-- Clientes con edades entre 26 y 40 años.
            WHEN age > 40 THEN '40+'	-- Clientes mayores de 40 años.
        END AS age_category

    FROM customers	-- Tabla que contiene la información de los clientes.

) AS categorized_customers

GROUP BY age_category	-- Agrupa los resultados según la categoría de edad.

ORDER BY	-- Ordena las categorías de edad en el orden deseado.
    CASE age_category
        WHEN '16-25' THEN 1	-- Primera categoría: clientes de 16 a 25 años.
        WHEN '26-40' THEN 2	-- Segunda categoría: clientes de 26 a 40 años.
        WHEN '40+' THEN 3	-- Tercera categoría: clientes mayores de 40 años.
    END;
	
/* ============================================================
 Reporte 2: Clientes e ingresos por mes
 ============================================================
 Esta consulta obtiene, para cada mes:
   1. La cantidad de clientes que realizaron compras.
   2. Los ingresos generados por las ventas.
 ============================================================*/

SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,	    -- Convierte la fecha de venta al formato Año-Mes (YYYY-MM). Ej: 2025-08.

    COUNT(DISTINCT s.customer_id) AS total_customers,	    -- Cuenta los clientes diferentes que realizaron compras durante cada mes.
    SUM(p.price * s.quantity) AS income	    -- Calcula los ingresos multiplicando el precio del producto por la cantidad vendida.

FROM sales AS s	-- Tabla que contiene las ventas.

JOIN products AS p	-- Se relaciona cada venta con el producto correspondiente para poder obtener su precio.

    ON s.product_id = p.product_id	-- La relación se realiza mediante el identificador del producto.

GROUP BY	-- Agrupa todas las ventas que pertenecen al mismo mes.
    TO_CHAR(s.sale_date, 'YYYY-MM')

ORDER BY	-- Ordena los resultados cronológicamente por mes.
    selling_month;
	
/* ============================================================
 Reporte 3: Clientes cuya primera compra fue durante
            una promoción
 ============================================================
 Esta consulta identifica a los clientes cuya primera compra 
 corresponde a un producto con precio igual a 0, lo cual se
 interpreta como una compra realizada durante una promoción.
 También muestra la fecha de compra y el vendedor responsable.
 ============================================================*/

-- CTE (Common Table Expression) utilizada para identificar la primera compra de cada cliente.
WITH first_purchase AS (

    SELECT
        s.customer_id,	-- Identificador del cliente que realizó la compra.
        s.sale_date,	-- Fecha en la que se realizó la compra.
        s.product_id,	-- Identificador del producto comprado.
        s.sales_person_id,	-- Identificador del empleado que realizó la venta.

        ROW_NUMBER() OVER (	-- Asigna un número consecutivo a las compras de cada cliente. La primera compra recibe el número 1.
            
            PARTITION BY s.customer_id	-- Reinicia la numeración para cada cliente.

            ORDER BY s.sale_date, s.sales_id	-- Ordena las compras desde la más antigua hasta la más reciente.

        ) AS purchase_number

    FROM sales AS s	-- Tabla que contiene las ventas.
)

/* ============================================================
	Consulta principal
   ============================================================*/

SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS customer,		-- Concatena el nombre y apellido del cliente.
    fp.sale_date,	-- Muestra la fecha de la primera compra.
    CONCAT(e.first_name, ' ', e.last_name) AS seller	-- Concatena el nombre y apellido del vendedor.

-- Utiliza los resultados de la CTE que contiene las compras numeradas de cada cliente.

FROM first_purchase AS fp

JOIN customers AS c	-- Relaciona la compra con la tabla de clientes.

    ON fp.customer_id = c.customer_id	-- La relación se realiza mediante el identificador del cliente.

JOIN employees AS e	-- Relaciona la compra con el empleado que realizó la venta.

    ON fp.sales_person_id = e.employee_id	-- La relación se realiza mediante el identificador del empleado.

JOIN products AS p	-- Relaciona la compra con el producto adquirido.

    ON fp.product_id = p.product_id	-- La relación se realiza mediante el identificador del producto.

WHERE fp.purchase_number = 1	-- Solo se consideran las primeras compras de cada cliente.

  AND p.price = 0	-- Se seleccionan únicamente los productos cuyo precio es 0, interpretándolos como productos entregados durante una promoción.

ORDER BY	-- Ordena los resultados por el identificador del cliente.
    fp.customer_id;
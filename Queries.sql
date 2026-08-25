-- Objetivo: Obtener el número total de clientes registrados.
-- Tabla utilizada: customers.
-- Alias: customers_count, nombre asignado a la columna del resultado.
-- Resultado: Retorna una única fila con el total de clientes.


SELECT COUNT(*) AS customers_count  -- Función utilizada: COUNT(*), que cuenta todas las filas de la tabla.
FROM customers; -- Tabla utilizada: customers.
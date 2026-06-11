-- ============================================================
-- EJERCICIO 5: EVENTO — evt_aggregate_daily_sales_data
-- Tabla destino: resumen_ventas_diario (ya existente)
-- Campos: id (PK AI), fecha (DATE UNIQUE),
--         total_ordenes (INT), ingresos_totales (DECIMAL)
-- ============================================================

-- ── Activar el planificador de eventos ──────────────────────
-- Por defecto MySQL tiene el event_scheduler apagado.
-- Sin este comando, los eventos existen pero nunca se ejecutan.
-- En servidores de producción se configura en my.cnf:
--   event_scheduler = ON
SET GLOBAL event_scheduler = ON;

-- ── Evento programado ───────────────────────────────────────

CREATE EVENT IF NOT EXISTS evt_aggregate_daily_sales_data

-- EVERY 1 DAY: el evento se repite cada 24 horas.
-- STARTS: fija el primer disparo. Al ponerlo en la medianoche
-- del día siguiente garantizamos que se ejecute al inicio de
-- cada nuevo día con los datos completos del día actual.
ON SCHEDULE EVERY 1 DAY
    STARTS (CURRENT_DATE + INTERVAL 1 DAY)

ON COMPLETION NOT PRESERVE   -- si fuera de un solo disparo, MySQL lo borra al terminar
ENABLE
COMMENT 'Agrega las ventas del día en resumen_ventas_diario'

DO
BEGIN

    -- INSERT ... ON DUPLICATE KEY UPDATE (patrón "upsert"):
    --
    -- MySQL intenta insertar una fila nueva para la fecha de hoy.
    -- Si ya existe una fila con ese valor en la columna 'fecha'
    -- (que tiene restricción UNIQUE), en lugar de lanzar error,
    -- MySQL ejecuta el bloque UPDATE y sobreescribe los valores.
    --
    -- Esto hace el evento IDEMPOTENTE: si se ejecuta dos veces
    -- el mismo día, el resultado es correcto (no hay filas duplicadas).
    INSERT INTO resumen_ventas_diario
        (fecha, total_ordenes, ingresos_totales)

    SELECT
        CURDATE()       AS fecha,

        -- COUNT(*) cuenta el total de filas de ventas del día.
        -- Cada fila es una orden/transacción distinta.
        COUNT(*)        AS total_ordenes,

        -- SUM(total) suma el campo 'total' de cada venta del día.
        -- IFNULL evita que el resultado sea NULL si no hay ventas.
        IFNULL(SUM(total), 0) AS ingresos_totales

    FROM ventas
    -- DATE(fecha_venta) extrae solo la parte de fecha de un DATETIME,
    -- permitiendo comparar con CURDATE() que devuelve DATE.
    WHERE DATE(fecha_venta) = CURDATE()

    ON DUPLICATE KEY UPDATE
        -- VALUES(col) hace referencia al valor que se intentó insertar
        -- (es decir, el valor recién calculado en el SELECT de arriba).
        total_ordenes    = VALUES(total_ordenes),
        ingresos_totales = VALUES(ingresos_totales);

END;

-- ── Verificar que el evento quedó registrado ─────────────────
-- SHOW EVENTS;
--
-- ── Probar la lógica manualmente en DBeaver ──────────────────
-- Los eventos no se pueden invocar como los procedimientos.
-- Para probar, ejecuta directamente el bloque INSERT...SELECT:
--
-- INSERT INTO resumen_ventas_diario (fecha, total_ordenes, ingresos_totales)
-- SELECT CURDATE(), COUNT(*), IFNULL(SUM(total), 0)
-- FROM ventas WHERE DATE(fecha_venta) = CURDATE()
-- ON DUPLICATE KEY UPDATE
--     total_ordenes    = VALUES(total_ordenes),
--     ingresos_totales = VALUES(ingresos_totales);
-- ============================================================
-- EJERCICIO 2: FUNCIÓN — fn_DeterminarEstadoLealtad
-- Tabla usada: ventas (columnas: id_clientes, total, estado)
-- ============================================================

CREATE FUNCTION fn_DeterminarEstadoLealtad(p_id_cliente INT)
RETURNS VARCHAR(10)
-- DETERMINISTIC: mismo input produce mismo output en el mismo momento.
-- Requerido por MySQL cuando el binary log está activo.
DETERMINISTIC
READS SQL DATA
BEGIN

    -- Variable local para acumular el gasto histórico del cliente.
    DECLARE v_gasto_total DECIMAL(10,2);

    -- Sumamos la columna 'total' de todas las ventas del cliente,
    -- excluyendo las que están en estado 'Cancelado' porque no
    -- representan ingresos reales.
    --
    -- IFNULL(..., 0): si el cliente no tiene ninguna venta activa,
    -- SUM() devuelve NULL. Lo convertimos a 0 para poder comparar.
    SELECT IFNULL(SUM(total), 0)
    INTO   v_gasto_total
    FROM   ventas
    WHERE  id_clientes = p_id_cliente
      AND  estado != 'Cancelado';

    -- Lógica de clasificación:
    -- Primero verificamos si el gasto resultó en 0 (sin compras válidas).
    -- Luego aplicamos los umbrales del programa de fidelización.
    IF v_gasto_total = 0 THEN
        RETURN 'Nuevo';

    ELSEIF v_gasto_total < 500 THEN
        RETURN 'Bronce';

    ELSEIF v_gasto_total <= 2000 THEN
        -- Entre 500 y 2000 inclusive en el límite superior.
        RETURN 'Plata';

    ELSE
        -- Más de 2000: cliente de mayor valor para el negocio.
        RETURN 'Oro';

    END IF;

END;

-- ── Ejemplo de uso ──────────────────────────────────────────
-- Consultar el nivel de todos los clientes activos:
-- SELECT id, nombre, apellido,
--        fn_DeterminarEstadoLealtad(id) AS nivel_lealtad
-- FROM clientes
-- WHERE activo = 1;
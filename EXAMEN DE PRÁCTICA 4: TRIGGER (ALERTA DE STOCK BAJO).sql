-- ============================================================
-- EJERCICIO 4: TRIGGER — trg_send_stock_alert_on_low_stock
-- Tabla destino: alertas_stock (ya existente en el esquema)
-- Campos disponibles: id, id_producto, stock_actual, fecha_alerta
-- ============================================================

CREATE TRIGGER trg_send_stock_alert_on_low_stock
-- AFTER UPDATE: el trigger se dispara DESPUÉS de que la fila
-- de 'productos' ya fue actualizada con el nuevo valor.
-- Usamos AFTER (no BEFORE) porque queremos leer el valor
-- definitivo guardado, no el valor que está a punto de guardarse.
AFTER UPDATE ON productos
FOR EACH ROW   -- se ejecuta una vez por cada fila modificada
BEGIN

    -- En los triggers de UPDATE, MySQL provee dos pseudoregistros:
    --
    --   OLD.columna  →  valor que tenía la fila ANTES del UPDATE
    --   NEW.columna  →  valor que tiene la fila DESPUÉS del UPDATE
    --
    -- Condición de alerta (doble verificación):
    --
    --   1. NEW.stock <= 10   → el stock actual está en zona de peligro.
    --   2. OLD.stock > 10    → el stock ANTERIOR estaba bien.
    --
    -- Juntas, estas dos condiciones significan: "el stock ACABA DE
    -- cruzar el umbral hacia abajo en esta actualización".
    --
    -- Esto evita alertas repetitivas: si el stock ya era 5 y sigue
    -- siendo 5, OLD.stock NO es > 10, por lo que no se genera alerta.
    IF NEW.stock <= 10 AND OLD.stock > 10 THEN

        INSERT INTO alertas_stock
            (id_producto, stock_actual)
        VALUES
            (NEW.id,      -- id del producto recién actualizado
             NEW.stock);  -- el nuevo valor de stock ya confirmado
                          -- fecha_alerta usa su DEFAULT (CURRENT_TIMESTAMP)

    END IF;

END;

-- ── Ejemplos de prueba en DBeaver ───────────────────────────
-- Caso 1: stock baja de 50 a 8 → DEBE generar alerta.
-- UPDATE productos SET stock = 8 WHERE id = 5;
--
-- Caso 2: stock ya era 8 y baja a 6 → NO genera alerta (OLD.stock no > 10).
-- UPDATE productos SET stock = 6 WHERE id = 5;
--
-- Caso 3: stock sube de 6 a 50 → NO genera alerta (NEW.stock no <= 10).
-- UPDATE productos SET stock = 50 WHERE id = 5;
--
-- Ver alertas registradas:
-- SELECT * FROM alertas_stock ORDER BY fecha_alerta DESC;
-- ============================================================
-- EJERCICIO 3: PROCEDIMIENTO — sp_AjustarNivelStock
-- Tablas usadas: productos, Auditoria_Stock (se crea aquí)
-- ============================================================

-- ── Tabla de auditoría ──────────────────────────────────────
-- Registra cada ajuste manual para trazabilidad futura.
-- IF NOT EXISTS evita error si el script se corre más de una vez.
CREATE TABLE IF NOT EXISTS Auditoria_Stock (
    id_auditoria    INT       NOT NULL AUTO_INCREMENT PRIMARY KEY,
    id_producto     INT       NOT NULL,
    cantidad_ajuste INT       NOT NULL,   -- positivo = entrada, negativo = salida
    stock_anterior  INT       NOT NULL,
    stock_nuevo     INT       NOT NULL,
    motivo          TEXT      NOT NULL,
    fecha           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ── Procedimiento ───────────────────────────────────────────

CREATE PROCEDURE sp_AjustarNivelStock(
    IN p_id_producto     INT,
    IN p_cantidad_ajuste INT,
    IN p_motivo          TEXT
)
BEGIN

    -- Variables locales para guardar el stock antes y después.
    DECLARE v_stock_anterior INT;
    DECLARE v_stock_nuevo    INT;

    -- EXIT HANDLER: si ocurre cualquier excepción SQL dentro
    -- de la transacción (incluyendo nuestro SIGNAL manual),
    -- este bloque se ejecuta automáticamente.
    -- ROLLBACK deshace todos los cambios de la transacción,
    -- y RESIGNAL vuelve a lanzar el error para que el llamador
    -- (tu app o DBeaver) pueda verlo.
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- ── Inicio de la transacción ────────────────────────────
    -- ATOMICIDAD: el UPDATE en 'productos' y el INSERT en
    -- 'Auditoria_Stock' son una unidad. O ambos ocurren,
    -- o ninguno ocurre.
    START TRANSACTION;

        -- 1. Leemos el stock actual.
        --    FOR UPDATE bloquea la fila durante la transacción
        --    para evitar que dos ajustes simultáneos lean el
        --    mismo valor y generen inconsistencias.
        SELECT stock
        INTO   v_stock_anterior
        FROM   productos
        WHERE  id = p_id_producto
        FOR UPDATE;

        -- 2. Calculamos el stock resultante.
        SET v_stock_nuevo = v_stock_anterior + p_cantidad_ajuste;

        -- 3. Validación: si el resultado es negativo, lanzamos
        --    un error con SIGNAL. Esto activa el EXIT HANDLER,
        --    que ejecuta el ROLLBACK y detiene el procedimiento.
        IF v_stock_nuevo < 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Error: el ajuste dejaría el stock en negativo.';
        END IF;

        -- 4. Actualizamos el stock en la tabla productos.
        UPDATE productos
        SET    stock = v_stock_nuevo
        WHERE  id = p_id_producto;

        -- 5. Insertamos el registro de auditoría.
        INSERT INTO Auditoria_Stock
            (id_producto, cantidad_ajuste, stock_anterior, stock_nuevo, motivo)
        VALUES
            (p_id_producto, p_cantidad_ajuste, v_stock_anterior, v_stock_nuevo, p_motivo);

    -- Si llegamos aquí sin errores, confirmamos ambos cambios.
    COMMIT;

END
-- ── Ejemplos de uso ─────────────────────────────────────────
-- Restar 5 unidades (daño):
-- CALL sp_AjustarNivelStock(3, -5, 'Producto dañado en bodega');
--
-- Agregar 20 unidades (reposición):
-- CALL sp_AjustarNivelStock(3, 20, 'Reposición proveedor XYZ');
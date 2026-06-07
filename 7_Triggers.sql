-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--	7. Triggers (Disparadores)
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- Tabla para guardar el historial de cambios de precios
CREATE TABLE IF NOT EXISTS log_cambios_precio (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    precio_anterior DECIMAL(10,2) NOT NULL,
    precio_nuevo DECIMAL(10,2) NOT NULL,
    fecha_cambio TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);




-- 1.trg_audit_precio_producto_after_update: Guarda un log de cambios de precios.
----------------------------------------------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_audit_precio_producto_after_update;

CREATE TRIGGER trg_audit_precio_producto_after_update
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
    -- Solo registro si el precio realmente cambió
    IF OLD.precio <> NEW.precio THEN
        INSERT INTO log_cambios_precio (id_producto, precio_anterior, precio_nuevo)
        VALUES (OLD.id, OLD.precio, NEW.precio);
    END IF;
END;

-- Prueba: cambio el precio del Smartphone
UPDATE productos SET precio = 850.00 WHERE id = 1;

-- Reviso que quedó guardado en el log
SELECT * FROM log_cambios_precio;

-- 2.trg_check_stock_before_insert_venta: Verifica el stock antes de registrar una venta.
----------------------------------------------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_check_stock_before_insert_venta;

CREATE TRIGGER trg_check_stock_before_insert_venta
BEFORE INSERT ON detalle_ventas
FOR EACH ROW
BEGIN
    DECLARE v_stock_disponible INT;

    -- Consulto el stock actual del producto
    SELECT stock INTO v_stock_disponible
    FROM productos
    WHERE id = NEW.id_producto;

    -- Si no alcanza, lanzo un error para bloquear el INSERT
    IF v_stock_disponible < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: No hay suficiente stock para completar la venta.';
    END IF;
END;

-- 3.trg_update_stock_after_insert_venta: Decrementa el stock después de una venta.
----------------------------------------------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_update_stock_after_insert_venta;

CREATE TRIGGER trg_update_stock_after_insert_venta
AFTER INSERT ON detalle_ventas
FOR EACH ROW
BEGIN
    -- Resto la cantidad vendida del stock
    UPDATE productos
    SET stock = stock - NEW.cantidad
    WHERE id = NEW.id_producto;
END;

-- 4.trg_prevent_delete_categoria_with_products: Impide eliminar una categoría si tiene productos asociados.
----------------------------------------------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_prevent_delete_categoria_with_products;

CREATE TRIGGER trg_prevent_delete_categoria_with_products
BEFORE DELETE ON categoria
FOR EACH ROW
BEGIN
    DECLARE v_total_productos INT;

    -- Cuento cuántos productos están en esta categoría
    SELECT COUNT(*) INTO v_total_productos
    FROM productos
    WHERE id_categoria = OLD.id;

    -- Si tiene productos, bloqueo el DELETE
    IF v_total_productos > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: No se puede eliminar una categoría que tiene productos.';
    END IF;
END;

-- 5.trg_log_new_customer_after_insert: Registra en una tabla de auditoría cada vez que se crea un nuevo cliente.
----------------------------------------------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_log_new_customer_after_insert;

CREATE TRIGGER trg_log_new_customer_after_insert
AFTER INSERT ON clientes
FOR EACH ROW
BEGIN
    -- Guardo el id y el nombre completo del nuevo cliente
    INSERT INTO log_nuevos_clientes (id_cliente, nombre_completo)
    VALUES (NEW.id, CONCAT(NEW.nombre, ' ', NEW.apellido));
END;

-- Prueba: inserto un cliente nuevo
INSERT INTO clientes (nombre, apellido, email, contraseña, direccion_envio)
VALUES ('Prueba', 'Trigger', 'prueba.trigger@test.com', 'hash_prueba', 'Bogotá, Colombia');

SELECT * FROM log_nuevos_clientes;

-- 6.trg_update_total_gastado_cliente: Actualiza un campo total_gastado en la tabla clientes después de cada compra.
----------------------------------------------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_update_total_gastado_cliente;

CREATE TRIGGER trg_update_total_gastado_cliente
AFTER INSERT ON ventas
FOR EACH ROW
BEGIN
    -- Acumulo el total de la venta al gasto histórico del cliente
    UPDATE clientes
    SET total_gastado = total_gastado + NEW.total
    WHERE id = NEW.id_clientes;
END;

-- 7.trg_set_fecha_modificacion_producto: Actualiza automáticamente la fecha de última modificación de un producto.
----------------------------------------------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_set_fecha_modificacion_producto;

CREATE TRIGGER trg_set_fecha_modificacion_producto
BEFORE UPDATE ON productos
FOR EACH ROW
BEGIN
    -- Guardo la fecha y hora exacta del cambio
    SET NEW.fecha_modificacion = NOW();
END;

-- Prueba: actualizo la descripción de un producto
UPDATE productos SET descripcion = 'Gama alta - Actualizado' WHERE id = 1;

SELECT id, nombre, descripcion, fecha_modificacion FROM productos WHERE id = 1;

-- 8.trg_prevent_negative_stock: Impide que el stock de un producto se actualice a un valor negativo.
----------------------------------------------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_prevent_negative_stock;

CREATE TRIGGER trg_prevent_negative_stock
BEFORE UPDATE ON productos
FOR EACH ROW
BEGIN
    -- Si el nuevo stock es negativo, bloqueo la operación
    IF NEW.stock < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: El stock no puede ser negativo.';
    END IF;
END;

-- 9.trg_capitalize_nombre_cliente: Convierte a mayúscula la primera letra del nombre y apellido de un cliente al insertarlo.
----------------------------------------------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_capitalize_nombre_cliente;

CREATE TRIGGER trg_capitalize_nombre_cliente
BEFORE INSERT ON clientes
FOR EACH ROW
BEGIN
    -- Pongo en mayúscula la primera letra y en minúscula el resto
    SET NEW.nombre   = CONCAT(UPPER(LEFT(TRIM(NEW.nombre), 1)),
                              LOWER(SUBSTRING(TRIM(NEW.nombre), 2)));
    SET NEW.apellido = CONCAT(UPPER(LEFT(TRIM(NEW.apellido), 1)),
                              LOWER(SUBSTRING(TRIM(NEW.apellido), 2)));
END;

-- Prueba: inserto con todo en mayúsculas
INSERT INTO clientes (nombre, apellido, email, contraseña, direccion_envio)
VALUES ('CARLOS', 'RAMIREZ', 'carlos.ram2@test.com', 'hash_x', 'Cali, Colombia');

-- Verifico que quedó capitalizado
SELECT nombre, apellido FROM clientes WHERE email = 'carlos.ram2@test.com';

-- 10.trg_recalculate_total_venta_on_detalle_change: Recalcula el total en la tabla ventas si se modifica un detalle_venta.
----------------------------------------------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_recalculate_total_venta_on_detalle_change;

CREATE TRIGGER trg_recalculate_total_venta_on_detalle_change
AFTER UPDATE ON detalle_ventas
FOR EACH ROW
BEGIN
    DECLARE v_nuevo_total DECIMAL(10,2);

    -- Sumo todos los subtotales del detalle de esa venta
    SELECT SUM(cantidad * precio_unitario)
    INTO v_nuevo_total
    FROM detalle_ventas
    WHERE id_venta = NEW.id_venta;

    -- Actualizo el total en la tabla ventas
    UPDATE ventas
    SET total = v_nuevo_total
    WHERE id = NEW.id_venta;
END;

-- 11.trg_log_order_status_change: Audita cada cambio de estado en un pedido (ej. de 'Procesando' a 'Enviado').
----------------------------------------------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_log_order_status_change;

CREATE TRIGGER trg_log_order_status_change
AFTER UPDATE ON ventas
FOR EACH ROW
BEGIN
    -- Solo registro si el estado realmente cambió
    IF OLD.estado <> NEW.estado THEN
        INSERT INTO log_estado_pedido (id_venta, estado_anterior, estado_nuevo)
        VALUES (OLD.id, OLD.estado, NEW.estado);
    END IF;
END;

-- Prueba: cambio el estado de una venta
UPDATE ventas SET estado = 'Procesando' WHERE id = 1;

SELECT * FROM log_estado_pedido;

-- 12.trg_prevent_price_zero_or_less: Impide que el precio de un producto se establezca en cero o un valor negativo.
----------------------------------------------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_prevent_price_zero_or_less;

CREATE TRIGGER trg_prevent_price_zero_or_less
BEFORE UPDATE ON productos
FOR EACH ROW
BEGIN
    -- Si intentan poner precio 0 o negativo, bloqueo
    IF NEW.precio <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: El precio debe ser mayor que cero.';
    END IF;
END;

-- 13.trg_send_stock_alert_on_low_stock: Inserta un registro en una tabla alertas si el stock baja de un umbral.
----------------------------------------------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_send_stock_alert_on_low_stock;

CREATE TRIGGER trg_send_stock_alert_on_low_stock
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
    -- Reviso si el stock bajó del umbral de 10 unidades
    IF NEW.stock < 10 AND OLD.stock >= 10 THEN
        INSERT INTO alertas_stock (id_producto, stock_actual)
        VALUES (NEW.id, NEW.stock);
    END IF;
END;

-- Prueba: bajo el stock de la Laptop (stock=2) para activar la alerta
UPDATE productos SET stock = 1 WHERE id = 3;

SELECT * FROM alertas_stock;

-- 14.trg_archive_deleted_venta: Mueve una venta eliminada a una tabla de archivo en lugar de borrarla permanentemente.
----------------------------------------------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_archive_deleted_venta;

CREATE TRIGGER trg_archive_deleted_venta
BEFORE DELETE ON ventas
FOR EACH ROW
BEGIN
    -- Guardo la venta en el archivo antes de borrarla
    INSERT INTO archivo_ventas (id, id_clientes, fecha_venta, estado, total)
    VALUES (OLD.id, OLD.id_clientes, OLD.fecha_venta, OLD.estado, OLD.total);
END;

-- 15.trg_validate_email_format_on_customer: Valida el formato del email antes de insertar o actualizar un cliente.
----------------------------------------------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_validate_email_format_on_customer;

CREATE TRIGGER trg_validate_email_format_on_customer
BEFORE INSERT ON clientes
FOR EACH ROW
BEGIN
    -- Verifico que el email tenga @ y punto después del @
    IF LOCATE('@', NEW.email) = 0
       OR LOCATE('.', NEW.email, LOCATE('@', NEW.email)) = 0
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: El formato del email no es válido.';
    END IF;
END;

-- 16.trg_update_last_order_date_customer: Actualiza la fecha del último pedido en la tabla clientes.
----------------------------------------------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_update_last_order_date_customer;

CREATE TRIGGER trg_update_last_order_date_customer
AFTER INSERT ON ventas
FOR EACH ROW
BEGIN
    -- Guardo la fecha de esta venta como la más reciente del cliente
    UPDATE clientes
    SET fecha_ultimo_pedido = NEW.fecha_venta
    WHERE id = NEW.id_clientes;
END;

-- 17.trg_prevent_self_referral: Impide que un cliente se referencie a sí mismo en un programa de referidos.
----------------------------------------------------------------------------------------------------

-- Primero agrego la columna referido_por si no existe
ALTER TABLE clientes ADD COLUMN referido_por INT NULL;

DROP TRIGGER IF EXISTS trg_prevent_self_referral;

CREATE TRIGGER trg_prevent_self_referral
BEFORE INSERT ON clientes
FOR EACH ROW
BEGIN
    -- Un cliente no puede referirse a sí mismo
    IF NEW.referido_por IS NOT NULL AND NEW.referido_por = NEW.id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: Un cliente no puede ser su propio referido.';
    END IF;
END;

-- 18.trg_log_permission_changes: Audita los cambios en los permisos de los usuarios.
----------------------------------------------------------------------------------------------------

-- Tabla de auditoría de cambios de permisos/estado
CREATE TABLE IF NOT EXISTS log_permisos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    estado_anterior BOOLEAN,
    estado_nuevo BOOLEAN,
    fecha_cambio TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

DROP TRIGGER IF EXISTS trg_log_permission_changes;

CREATE TRIGGER trg_log_permission_changes
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
    -- Registro cuando el campo activo (habilitado/deshabilitado) cambia
    IF OLD.activo <> NEW.activo THEN
        INSERT INTO log_permisos (id_producto, estado_anterior, estado_nuevo)
        VALUES (OLD.id, OLD.activo, NEW.activo);
    END IF;
END;

-- Prueba: desactivo un producto
UPDATE productos SET activo = FALSE WHERE id = 13;

SELECT * FROM log_permisos;


-- 19.trg_assign_default_category_on_null: Asigna una categoría "General" si se inserta un producto sin categoría.
----------------------------------------------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_assign_default_category_on_null;

CREATE TRIGGER trg_assign_default_category_on_null
BEFORE INSERT ON productos
FOR EACH ROW
BEGIN
    DECLARE v_existe INT;

    -- Verifico si la categoría enviada existe
    SELECT COUNT(*) INTO v_existe
    FROM categoria
    WHERE id = NEW.id_categoria;

    -- Si no existe, asigno la categoría 1 por defecto
    IF v_existe = 0 THEN
        SET NEW.id_categoria = 1;
    END IF;
END;

-- 20.trg_update_producto_count_in_categoria: Mantiene un contador de cuántos productos hay en cada categoría.
----------------------------------------------------------------------------------------------------

-- Trigger al insertar producto: suma 1 al contador de su categoría
DROP TRIGGER IF EXISTS trg_update_producto_count_insert;

CREATE TRIGGER trg_update_producto_count_insert
AFTER INSERT ON productos
FOR EACH ROW
BEGIN
    UPDATE categoria
    SET total_productos = total_productos + 1
    WHERE id = NEW.id_categoria;
END;

-- Trigger al eliminar producto: resta 1 al contador de su categoría
DROP TRIGGER IF EXISTS trg_update_producto_count_delete;

CREATE TRIGGER trg_update_producto_count_delete
AFTER DELETE ON productos
FOR EACH ROW
BEGIN
    UPDATE categoria
    SET total_productos = total_productos - 1
    WHERE id = OLD.id_categoria;
END;

-- Inicializo el contador con los datos que ya existen
UPDATE categoria c
SET total_productos = (
    SELECT COUNT(*) FROM productos p WHERE p.id_categoria = c.id
);

SELECT id, nombre, total_productos FROM categoria;

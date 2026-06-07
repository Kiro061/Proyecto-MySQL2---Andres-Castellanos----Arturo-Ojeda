-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--	9. Procedimientos Almacenados
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- 1.sp_RealizarNuevaVenta: Procesa una nueva venta de forma transaccional.
----------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_RealizarNuevaVenta;

CREATE PROCEDURE sp_RealizarNuevaVenta(
    IN v_id_cliente INT,
    IN v_id_producto INT,
    IN v_cantidad INT
)
BEGIN
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_id_nueva_venta INT;
    DECLARE v_total DECIMAL(10,2);

    -- Si algo sale mal, deshago todo
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'ERROR: La venta no pudo procesarse.' AS mensaje;
    END;

    START TRANSACTION;

    -- Obtengo el precio actual del producto
    SELECT precio INTO v_precio
    FROM productos WHERE id = v_id_producto;

    SET v_total = v_precio * v_cantidad;

    -- Creo el encabezado de la venta
    INSERT INTO ventas (id_clientes, estado, total)
    VALUES (v_id_cliente, 'Pendiente de Pago', v_total);

    SET v_id_nueva_venta = LAST_INSERT_ID();

    -- Agrego el detalle de la venta
    INSERT INTO detalle_ventas (id_venta, id_producto, cantidad, precio_unitario)
    VALUES (v_id_nueva_venta, v_id_producto, v_cantidad, v_precio);

    COMMIT;

    SELECT 'Venta registrada exitosamente' AS mensaje, v_id_nueva_venta AS id_venta;
END;

-- Prueba: el cliente 3 compra 2 unidades del producto 14 (Balón de Fútbol)
CALL sp_RealizarNuevaVenta(3, 14, 2);

-- 2.sp_AgregarNuevoProducto: Inserta un nuevo producto y sus atributos iniciales.
----------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_AgregarNuevoProducto;

CREATE PROCEDURE sp_AgregarNuevoProducto(
    IN p_id_categoria INT,
    IN p_id_proveedor INT,
    IN p_nombre VARCHAR(100),
    IN p_descripcion TEXT,
    IN p_precio DECIMAL(10,2),
    IN p_costo DECIMAL(10,2),
    IN p_stock INT,
    IN p_sku VARCHAR(100)
)
BEGIN
    -- Inserto el producto con los datos recibidos
    INSERT INTO productos
        (id_categoria, id_proveedor, nombre, descripcion, precio, costo, stock, sku)
    VALUES
        (p_id_categoria, p_id_proveedor, p_nombre, p_descripcion,
         p_precio, p_costo, p_stock, p_sku);

    SELECT 'Producto agregado correctamente' AS mensaje,
           LAST_INSERT_ID() AS id_producto;
END;

-- Prueba: agrego un teclado mecánico
CALL sp_AgregarNuevoProducto(
    1, 1, 'Teclado Mecánico', 'Switch Cherry MX Red',
    90.00, 45.00, 30, 'SKU-ELECT-21'
);

-- 3.sp_ActualizarDireccionCliente: Actualiza la dirección de un cliente en todas las tablas relevantes.
----------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_ActualizarDireccionCliente;

CREATE PROCEDURE sp_ActualizarDireccionCliente(
    IN c_id_cliente INT,
    IN c_nueva_direccion TEXT
)
BEGIN
    DECLARE v_existe INT;

    -- Verifico que el cliente exista
    SELECT COUNT(*) INTO v_existe
    FROM clientes WHERE id = c_id_cliente;

    IF v_existe = 0 THEN
        SELECT 'ERROR: El cliente no existe.' AS mensaje;
    ELSE
        UPDATE clientes
        SET direccion_envio = c_nueva_direccion
        WHERE id = c_id_cliente;

        SELECT 'Dirección actualizada correctamente.' AS mensaje;
    END IF;
END;

-- Prueba: actualizo la dirección del cliente 1
CALL sp_ActualizarDireccionCliente(1, 'CDMX, Coyoacán, Región Sur');

-- 4.sp_ProcesarDevolucion: Gestiona la devolución de un producto, ajustando el stock y generando un crédito.
----------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_ProcesarDevolucion;

CREATE PROCEDURE sp_ProcesarDevolucion(
    IN v_id_venta INT
)
BEGIN
    DECLARE v_estado_actual VARCHAR(50);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'ERROR: No se pudo procesar la devolución.' AS mensaje;
    END;

    -- Verifico el estado actual de la venta
    SELECT estado INTO v_estado_actual
    FROM ventas WHERE id = v_id_venta;

    IF v_estado_actual = 'Cancelado' THEN
        SELECT 'La venta ya está cancelada.' AS mensaje;
    ELSE
        START TRANSACTION;

        -- Cambio el estado de la venta a Cancelado
        UPDATE ventas SET estado = 'Cancelado' WHERE id = v_id_venta;

        -- Devuelvo el stock de cada producto del detalle
        UPDATE productos p
        INNER JOIN detalle_ventas dv ON p.id = dv.id_producto
        SET p.stock = p.stock + dv.cantidad
        WHERE dv.id_venta = v_id_venta;

        COMMIT;

        SELECT 'Devolución procesada correctamente.' AS mensaje;
    END IF;
END;

-- Prueba: proceso la devolución de la venta 7
CALL sp_ProcesarDevolucion(7);


-- 5.sp_ObtenerHistorialComprasCliente: Devuelve el historial completo de compras de un cliente.
----------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_ObtenerHistorialComprasCliente;

CREATE PROCEDURE sp_ObtenerHistorialComprasCliente(
    IN c_id_cliente INT
)
BEGIN
    -- Muestro todas las ventas con el detalle de productos
    SELECT
        v.id AS id_venta,
        v.fecha_venta,
        v.estado,
        p.nombre AS producto,
        dv.cantidad,
        dv.precio_unitario,
        (dv.cantidad * dv.precio_unitario) AS subtotal,
        v.total AS total_venta
    FROM ventas v
    INNER JOIN detalle_ventas dv ON v.id = dv.id_venta
    INNER JOIN productos p ON dv.id_producto = p.id
    WHERE v.id_clientes = c_id_cliente
    ORDER BY v.fecha_venta DESC;
END;

-- Prueba: historial del cliente 1 (Juan Pérez)
CALL sp_ObtenerHistorialComprasCliente(1);


-- 6.sp_AjustarNivelStock: Permite ajustar manualmente el stock de un producto, registrando el motivo.
----------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_AjustarNivelStock;

CREATE PROCEDURE sp_AjustarNivelStock(
    IN p_id_producto INT,
    IN p_nuevo_stock INT,
    IN p_motivo VARCHAR(255)
)
BEGIN
    DECLARE p_stock_anterior INT;

    IF p_nuevo_stock < 0 THEN
        SELECT 'ERROR: El stock no puede ser negativo.' AS mensaje;
    ELSE
        SELECT stock INTO p_stock_anterior
        FROM productos WHERE id = p_id_producto;

        -- Actualizo el stock con el valor nuevo
        UPDATE productos
        SET stock = p_nuevo_stock
        WHERE id = p_id_producto;

        SELECT
            'Stock ajustado.' AS mensaje,
            p_stock_anterior  AS stock_antes,
            p_nuevo_stock     AS stock_nuevo,
            p_motivo          AS motivo;
    END IF;
END;

-- Prueba: ajusto el stock del producto 3 (Laptop) a 10
CALL sp_AjustarNivelStock(3, 10, 'Reposición de inventario mensual');


-- 7.sp_EliminarClienteDeFormaSegura: Anonimiza los datos de un cliente en lugar de borrarlos, para mantener la integridad referencial.
----------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_EliminarClienteDeFormaSegura;

CREATE PROCEDURE sp_EliminarClienteDeFormaSegura(
    IN c_id_cliente INT
)
BEGIN
    -- Remplazo los datos personales con valores genéricos (anonimización)
    UPDATE clientes
    SET
        nombre         = 'ANONIMIZADO',
        apellido       = 'ANONIMIZADO',
        email          = CONCAT('anonimo_', c_id_cliente, '@eliminado.com'),
        contraseña     = 'ELIMINADO',
        direccion_envio = 'ELIMINADO'
    WHERE id = c_id_cliente;

    SELECT 'Cliente anonimizado correctamente. Sus ventas se conservan.' AS mensaje;
END;

-- Prueba: anonimizo al cliente 15
CALL sp_EliminarClienteDeFormaSegura(15);

SELECT id, nombre, apellido, email FROM clientes WHERE id = 15;

-- 8.sp_AplicarDescuentoPorCategoria: Aplica un descuento a todos los productos de una categoría específica.
----------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_AplicarDescuentoPorCategoria;

CREATE PROCEDURE sp_AplicarDescuentoPorCategoria(
    IN c_id_categoria INT,
    IN c_porcentaje_descuento DECIMAL(5,2)
)
BEGIN
    IF c_porcentaje_descuento <= 0 OR c_porcentaje_descuento >= 100 THEN
        SELECT 'ERROR: El porcentaje debe estar entre 0 y 100.' AS mensaje;
    ELSE
        -- Aplico el descuento a todos los productos activos de esa categoría
        UPDATE productos
        SET precio = precio * (1 - c_porcentaje_descuento / 100)
        WHERE id_categoria = c_id_categoria
          AND activo = TRUE;

        SELECT CONCAT('Descuento del ', c_porcentaje_descuento,
                      '% aplicado a la categoría ', c_id_categoria) AS mensaje;
    END IF;
END;

-- Prueba: descuento del 15% a todos los Libros (categoría 4)
CALL sp_AplicarDescuentoPorCategoria(4, 15.00);

-- 9.sp_GenerarReporteMensualVentas: Genera un reporte completo de ventas para un mes y año dados.
----------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_GenerarReporteMensualVentas;

CREATE PROCEDURE sp_GenerarReporteMensualVentas(
    IN r_anio INT,
    IN r_mes INT
)
BEGIN
    -- Muestro un resumen de ventas del mes indicado
    SELECT
        c.nombre,
        c.apellido,
        COUNT(v.id)      AS total_pedidos,
        SUM(v.total)     AS ingresos_generados
    FROM ventas v
    INNER JOIN clientes c ON v.id_clientes = c.id
    WHERE YEAR(v.fecha_venta)  = r_anio
      AND MONTH(v.fecha_venta) = r_mes
      AND v.estado = 'Entregado'
    GROUP BY c.id, c.nombre, c.apellido
    ORDER BY ingresos_generados DESC;
END;

-- Prueba: reporte de julio 2025
CALL sp_GenerarReporteMensualVentas(2025, 7);

-- 10.sp_CambiarEstadoPedido: Cambia el estado de un pedido (ej. 'Procesando' a 'Enviado') y notifica a otros sistemas.
----------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_CambiarEstadoPedido;

CREATE PROCEDURE sp_CambiarEstadoPedido(
    IN v_id_venta INT,
    IN v_nuevo_estado VARCHAR(50)
)
BEGIN
    DECLARE v_estado_actual VARCHAR(50);

    SELECT estado INTO v_estado_actual
    FROM ventas WHERE id = v_id_venta;

    -- No permito cambiar si ya está Entregado o Cancelado
    IF v_estado_actual IN ('Entregado', 'Cancelado') THEN
        SELECT CONCAT('ERROR: No se puede cambiar un pedido en estado: ',
                      v_estado_actual) AS mensaje;
    ELSE
        UPDATE ventas
        SET estado = v_nuevo_estado
        WHERE id = v_id_venta;

        SELECT 'Estado actualizado correctamente.' AS mensaje;
    END IF;
END;

-- Prueba: cambio la venta 28 a 'Procesando'
CALL sp_CambiarEstadoPedido(28, 'Procesando');

-- 11.sp_RegistrarNuevoCliente: Registra un nuevo cliente validando que el email no exista.
----------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_RegistrarNuevoCliente;

CREATE PROCEDURE sp_RegistrarNuevoCliente(
    IN c_nombre VARCHAR(100),
    IN c_apellido VARCHAR(100),
    IN c_email VARCHAR(50),
    IN c_contrasena VARCHAR(155),
    IN c_direccion TEXT
)
BEGIN
    DECLARE v_existe INT;

    -- Reviso si el email ya está registrado
    SELECT COUNT(*) INTO v_existe
    FROM clientes WHERE email = c_email;

    IF v_existe > 0 THEN
        SELECT 'ERROR: Ya existe un cliente con ese email.' AS mensaje;
    ELSE
        INSERT INTO clientes (nombre, apellido, email, contraseña, direccion_envio)
        VALUES (c_nombre, c_apellido, c_email, c_contrasena, c_direccion);

        SELECT 'Cliente registrado exitosamente.' AS mensaje,
               LAST_INSERT_ID() AS id_cliente;
    END IF;
END;

-- Prueba con un email nuevo
CALL sp_RegistrarNuevoCliente(
    'Valentina', 'Ospina', 'vale.ospina@correo.com',
    'hash_vale', 'Medellín, Laureles, Región Antióquia'
);

-- 12.sp_ObtenerDetallesProductoCompleto: Devuelve toda la información de un producto, incluyendo datos de su proveedor y categoría.
----------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_ObtenerDetallesProductoCompleto;

CREATE PROCEDURE sp_ObtenerDetallesProductoCompleto(
    IN p_id_producto INT
)
BEGIN
    -- Junto productos, categoría y proveedor en una sola consulta
    SELECT
        p.id,
        p.nombre AS producto,
        p.descripcion,
        p.precio,
        p.costo,
        p.stock,
        p.sku,
        p.activo,
        c.nombre AS categoria,
        pr.nombre AS proveedor,
        pr.email_contacto AS email_proveedor
    FROM productos p
    INNER JOIN categoria c  ON p.id_categoria = c.id
    INNER JOIN proveedores pr ON p.id_proveedor = pr.id
    WHERE p.id = p_id_producto;
END;

-- Prueba: detalle completo del producto 1 (Smartphone X)
CALL sp_ObtenerDetallesProductoCompleto(1);

-- 13.sp_FusionarCuentasCliente: Fusiona dos cuentas de cliente duplicadas en una sola.
----------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_FusionarCuentasCliente;

CREATE PROCEDURE sp_FusionarCuentasCliente(
    IN c_id_principal INT,
    IN c_id_secundario INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'ERROR: No se pudo fusionar las cuentas.' AS mensaje;
    END;

    START TRANSACTION;

    -- Muevo todas las ventas del cliente secundario al principal
    UPDATE ventas
    SET id_clientes = c_id_principal
    WHERE id_clientes = c_id_secundario;

    -- Anonimizo la cuenta secundaria
    UPDATE clientes
    SET
        nombre         = 'FUSIONADO',
        apellido       = 'FUSIONADO',
        email          = CONCAT('fusionado_', c_id_secundario, '@eliminado.com'),
        contraseña     = 'ELIMINADO'
    WHERE id = c_id_secundario;

    COMMIT;

    SELECT 'Cuentas fusionadas correctamente.' AS mensaje;
END;

-- 14.sp_AsignarProductoAProveedor: Asigna o cambia el proveedor de un producto.
----------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_AsignarProductoAProveedor;

CREATE PROCEDURE sp_AsignarProductoAProveedor(
    IN p_id_producto INT,
    IN p_id_proveedor_nuevo INT
)
BEGIN
    DECLARE v_existe_proveedor INT;

    -- Verifico que el proveedor exista
    SELECT COUNT(*) INTO v_existe_proveedor
    FROM proveedores WHERE id = p_id_proveedor_nuevo;

    IF v_existe_proveedor = 0 THEN
        SELECT 'ERROR: El proveedor no existe.' AS mensaje;
    ELSE
        UPDATE productos
        SET id_proveedor = p_id_proveedor_nuevo
        WHERE id = p_id_producto;

        SELECT 'Proveedor asignado correctamente.' AS mensaje;
    END IF;
END;

-- Prueba: cambio el proveedor del producto 5 al proveedor 3
CALL sp_AsignarProductoAProveedor(5, 3);

-- 15.sp_BuscarProductos: Realiza una búsqueda avanzada de productos con filtros por nombre, categoría, rango de precios, etc.
----------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_BuscarProductos;

CREATE PROCEDURE sp_BuscarProductos(
    IN p_nombre VARCHAR(100),
    IN p_id_categoria INT,
    IN p_precio_min DECIMAL(10,2),
    IN p_precio_max DECIMAL(10,2)
)
BEGIN
    -- Uso COALESCE para que cada filtro sea opcional:
    -- si viene NULL, el producto pasa el filtro de todas formas
    SELECT
        p.id,
        p.nombre,
        p.precio,
        p.stock,
        c.nombre AS categoria
    FROM productos p
    INNER JOIN categoria c ON p.id_categoria = c.id
    WHERE p.activo = TRUE
      AND (p_nombre IS NULL OR p.nombre LIKE CONCAT('%', p_nombre, '%'))
      AND (p_id_categoria IS NULL OR p.id_categoria = p_id_categoria)
      AND (p_precio_min IS NULL OR p.precio >= p_precio_min)
      AND (p_precio_max IS NULL OR p.precio <= p_precio_max)
    ORDER BY p.precio;
END;

-- Prueba: busco productos de Electrónica entre $100 y $500
CALL sp_BuscarProductos(NULL, 1, 100.00, 500.00);

-- 16.sp_ObtenerDashboardAdmin: Devuelve un conjunto de KPIs para un panel de administración (ventas de hoy, nuevos clientes, etc.).
----------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_ObtenerDashboardAdmin;

CREATE PROCEDURE sp_ObtenerDashboardAdmin()
BEGIN
    -- KPI 1: Ventas de hoy
    SELECT COUNT(*) AS ventas_hoy, COALESCE(SUM(total), 0) AS ingresos_hoy
    FROM ventas
    WHERE DATE(fecha_venta) = CURDATE()
      AND estado <> 'Cancelado';

    -- KPI 2: Nuevos clientes registrados en el último mes
    SELECT COUNT(*) AS nuevos_clientes_mes
    FROM clientes
    WHERE fecha_registro >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);

    -- KPI 3: Productos con stock crítico (menos de 5 unidades)
    SELECT id, nombre, stock
    FROM productos
    WHERE stock < 5 AND activo = TRUE
    ORDER BY stock ASC;
END;

-- Llamado al dashboard
CALL sp_ObtenerDashboardAdmin();

-- 17.sp_ProcesarPago: Simula el procesamiento de un pago para una venta, actualizando su estado a "Pagado".
----------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_ProcesarPago;

CREATE PROCEDURE sp_ProcesarPago(
    IN v_id_venta INT
)
BEGIN
    DECLARE v_estado_actual VARCHAR(50);

    SELECT estado INTO v_estado_actual
    FROM ventas WHERE id = v_id_venta;

    -- Solo proceso el pago si la venta está pendiente
    IF v_estado_actual = 'Pendiente de Pago' THEN
        UPDATE ventas
        SET estado = 'Procesando'
        WHERE id = v_id_venta;

        SELECT 'Pago procesado. Estado actualizado a Procesando.' AS mensaje;
    ELSE
        SELECT CONCAT('No se puede procesar. Estado actual: ',
                      v_estado_actual) AS mensaje;
    END IF;
END;

-- Prueba: proceso el pago de la última venta creada
CALL sp_ProcesarPago(29);

-- 18.sp_AñadirReseñaProducto: Permite a un cliente añadir una reseña y calificación a un producto que ha comprado.
----------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_AnadirResenaProducto;

CREATE PROCEDURE sp_AnadirResenaProducto(
    IN r_id_cliente INT,
    IN r_id_producto INT,
    IN r_calificacion TINYINT,
    IN r_comentario TEXT
)
BEGIN
    DECLARE v_compro INT;

    -- Verifico que el cliente haya comprado ese producto
    SELECT COUNT(*) INTO v_compro
    FROM ventas v
    INNER JOIN detalle_ventas dv ON v.id = dv.id_venta
    WHERE v.id_clientes = r_id_cliente
      AND dv.id_producto = r_id_producto
      AND v.estado = 'Entregado';

    IF v_compro = 0 THEN
        SELECT 'ERROR: Solo puedes reseñar productos que hayas comprado.' AS mensaje;
    ELSEIF r_calificacion < 1 OR r_calificacion > 5 THEN
        SELECT 'ERROR: La calificación debe estar entre 1 y 5.' AS mensaje;
    ELSE
        INSERT INTO resenas_producto (id_producto, id_cliente, calificacion, comentario)
        VALUES (r_id_producto, r_id_cliente, r_calificacion, r_comentario);

        SELECT 'Reseña registrada correctamente.' AS mensaje;
    END IF;
END;

-- Prueba: cliente 1 reseña el Smartphone X con 5 estrellas
CALL sp_AnadirResenaProducto(1, 1, 5, 'Excelente producto, muy rápido y buena batería.');

-- 19.sp_ObtenerProductosRelacionados: Devuelve una lista de productos relacionados a uno dado, basándose en compras de otros clientes.
----------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_ObtenerProductosRelacionados;

CREATE PROCEDURE sp_ObtenerProductosRelacionados(
    IN p_id_producto INT
)
BEGIN
    -- Busco productos que aparecen en las mismas ventas que el producto indicado
    SELECT
        p.id,
        p.nombre,
        p.precio,
        COUNT(*) AS veces_comprado_junto
    FROM detalle_ventas dv1
    INNER JOIN detalle_ventas dv2 ON dv1.id_venta = dv2.id_venta
    INNER JOIN productos p ON dv2.id_producto = p.id
    WHERE dv1.id_producto = p_id_producto
      AND dv2.id_producto <> p_id_producto
      AND p.activo = TRUE
    GROUP BY p.id, p.nombre, p.precio
    ORDER BY veces_comprado_junto DESC
    LIMIT 5;
END;

-- Prueba: productos relacionados con el Smartphone X (id=1)
CALL sp_ObtenerProductosRelacionados(1);

-- 20.sp_MoverProductosEntreCategorias: Mueve uno o más productos de una categoría a otra de forma segura.
----------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_MoverProductosEntreCategorias;

CREATE PROCEDURE sp_MoverProductosEntreCategorias(
    IN p_id_categoria_origen INT,
    IN p_id_categoria_destino INT
)
BEGIN
    DECLARE v_existe_destino INT;
    DECLARE v_total_movidos INT;

    -- Verifico que la categoría destino exista
    SELECT COUNT(*) INTO v_existe_destino
    FROM categoria WHERE id = p_id_categoria_destino;

    IF v_existe_destino = 0 THEN
        SELECT 'ERROR: La categoría destino no existe.' AS mensaje;
    ELSEIF p_id_categoria_origen = p_id_categoria_destino THEN
        SELECT 'ERROR: El origen y destino no pueden ser iguales.' AS mensaje;
    ELSE
        -- Cuento cuántos productos voy a mover
        SELECT COUNT(*) INTO v_total_movidos
        FROM productos WHERE id_categoria = p_id_categoria_origen;

        -- Muevo todos los productos al destino
        UPDATE productos
        SET id_categoria = p_id_categoria_destino
        WHERE id_categoria = p_id_categoria_origen;

        SELECT CONCAT(v_total_movidos, ' producto(s) movido(s) correctamente.') AS mensaje;
    END IF;
END;

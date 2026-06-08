-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--	5. Funciones Definidas por el Usuario (UDFs)
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

--  1.fn_CalcularTotalVenta: Calcula el monto total de una venta específica.
----------------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_CalcularTotalVenta;

-- Multiplica cantidad por precio y devuelve el subtotal
CREATE FUNCTION fn_CalcularTotalVenta (dv_cantidad INT, dv_precio_unitario DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE dv_total DECIMAL(10,2);

    SET dv_total = dv_cantidad * dv_precio_unitario;

    RETURN dv_total;
END;

-- Pruebo con todos los registros del detalle
SELECT
    id_venta,
    id_producto,
    cantidad,
    precio_unitario,
    fn_CalcularTotalVenta(cantidad, precio_unitario) AS subtotal_calculado
FROM detalle_ventas
LIMIT 60;

-- 2.fn_VerificarDisponibilidadStock: Valida si hay stock suficiente para un producto.
----------------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_VerificarDisponibilidadStock;

-- Revisa si hay suficiente stock de un producto para una cantidad pedida
CREATE FUNCTION fn_VerificarDisponibilidadStock (p_id_producto INT, p_cantidad_requerida INT)
RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE p_stock_actual INT;
    DECLARE p_disponible BOOLEAN DEFAULT FALSE;

    -- Traigo el stock actual del producto
    SELECT stock INTO p_stock_actual
    FROM productos
    WHERE id = p_id_producto;

    -- Comparo y decido si hay abasto
    IF p_stock_actual >= p_cantidad_requerida THEN
        SET p_disponible = TRUE;
    END IF;
    RETURN p_disponible;
END;

-- Pruebo si cada producto puede surtir 10 unidades
SELECT
    id,
    nombre,
    stock AS stock_actual,
    fn_VerificarDisponibilidadStock(id, 10) AS tiene_abasto_para_10_unidades
FROM productos;


-- 3.fn_ObtenerPrecioProducto: Devuelve el precio actual de un producto.
----------------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_ObtenerPrecioProducto;

-- Devuelve el precio de lista actual de un producto
CREATE FUNCTION fn_ObtenerPrecioProducto (p_id_producto INT)
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE p_precio DECIMAL(10,2);

    SELECT precio INTO p_precio
    FROM productos
    WHERE id = p_id_producto;

    RETURN p_precio;
END;

-- Comparo el precio de lista con el precio al que se vendió
SELECT
    id_venta,
    id_producto,
    cantidad,
    fn_ObtenerPrecioProducto(id_producto) AS precio_lista,
    precio_unitario AS precio_de_venta
FROM detalle_ventas
LIMIT 5;

-- 4.fn_CalcularEdadCliente: Calcula la edad de un cliente a partir de su fecha de nacimiento.
----------------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_CalcularEdadCliente;

-- Calcula la edad en años a partir de una fecha de nacimiento
CREATE FUNCTION fn_CalcularEdadCliente (c_fecha_nacimiento DATE)
RETURNS INT
NOT DETERMINISTIC
NO SQL
BEGIN
    DECLARE c_edad INT;

    -- TIMESTAMPDIFF me da la diferencia exacta en años
    SET c_edad = TIMESTAMPDIFF(YEAR, c_fecha_nacimiento, CURDATE());

    RETURN c_edad;
END;

-- Prueba con una fecha de ejemplo
SELECT fn_CalcularEdadCliente('2000-10-18') AS edad_cliente;

-- 5.fn_FormatearNombreCompleto: Devuelve el nombre y apellido de un cliente en un formato estandarizado
----------------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_FormatearNombreCompleto;

-- Devuelve "apellido  nombre" todo en minúsculas y sin espacios extra
CREATE FUNCTION fn_FormatearNombreCompleto (c_nombre VARCHAR(100), c_apellido VARCHAR(100))
RETURNS VARCHAR(205)
DETERMINISTIC
BEGIN
    DECLARE c_nombre_limpio VARCHAR(100);
    DECLARE c_apellido_limpio VARCHAR(100);
    DECLARE c_resultado VARCHAR(205);

    -- Quito espacios al principio y al final antes de formatear
    SET c_nombre_limpio   = TRIM(c_nombre);
    SET c_apellido_limpio = TRIM(c_apellido);

    SET c_resultado = CONCAT(LOWER(c_apellido_limpio), '  ', LOWER(c_nombre_limpio));

    RETURN c_resultado;
END;

-- Prueba con nombre desordenado en mayúsculas
SELECT fn_FormatearNombreCompleto('   ANDRES felipe   ', 'castellanos JIMENEZ') AS nombre_formateado;

-- 6.fn_EsClienteNuevo: Devuelve VERDADERO si un cliente realizó su primera compra en los últimos 30 días.
----------------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_EsClienteNuevo;

-- Devuelve TRUE si el cliente hizo su primera compra hace 30 días o menos
CREATE FUNCTION fn_EsClienteNuevo (c_id_cliente INT)
RETURNS BOOLEAN
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE c_fecha_primera_compra TIMESTAMP;
    DECLARE c_es_nuevo BOOLEAN DEFAULT FALSE;

    -- Busco la fecha de compra más antigua del cliente
    SELECT MIN(fecha_venta) INTO c_fecha_primera_compra
    FROM ventas
    WHERE id_clientes = c_id_cliente;

    -- Solo evalúo si realmente tiene compras
    IF c_fecha_primera_compra IS NOT NULL THEN
        IF TIMESTAMPDIFF(DAY, c_fecha_primera_compra, CURDATE()) <= 30 THEN
            SET c_es_nuevo = TRUE;
        END IF;
    END IF;

    RETURN c_es_nuevo;
END;

-- Reviso qué clientes son considerados nuevos
SELECT
    id,
    nombre,
    apellido,
    fn_EsClienteNuevo(id) AS es_perfil_nuevo
FROM clientes;

-- 7.fn_CalcularCostoEnvio: Calcula el costo de envío basado en el peso total de los productos de una venta.
----------------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_CalcularCostoEnvio;

CREATE FUNCTION fn_CalcularCostoEnvio (p_peso_kg DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    -- Declaro la variable que va a guardar el resultado
    DECLARE v_costo DECIMAL(10,2);

    -- Calculo: $2 por cada kg
    SET v_costo = p_peso_kg * 2.00;

    -- Si el costo es menor a $5, cobro el mínimo de $5
    IF v_costo < 5.00 THEN
        SET v_costo = 5.00;
    END IF;

    RETURN v_costo;
END;

-- Prueba: 3 kg -> debe dar $6, 1 kg -> debe dar $5 (mínimo)
SELECT
    fn_CalcularCostoEnvio(3.00) AS envio_3kg,
    fn_CalcularCostoEnvio(1.00) AS envio_1kg_minimo;


-- 8.fn_AplicarDescuento: Aplica un porcentaje de descuento a un monto dado.
----------------------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_AplicarDescuento;

CREATE FUNCTION fn_AplicarDescuento (p_monto DECIMAL(10,2), p_porcentaje DECIMAL(5,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_descuento DECIMAL(10,2);
    DECLARE v_precio_final DECIMAL(10,2);

    -- Calculo cuánto es el descuento en dinero
    SET v_descuento = p_monto * (p_porcentaje / 100);

    -- Resto el descuento al monto original
    SET v_precio_final = p_monto - v_descuento;

    RETURN v_precio_final;
END;

-- Prueba: $800 con 10% de descuento -> debe dar $720
SELECT
    id,
    nombre,
    precio AS precio_original,
    fn_AplicarDescuento(precio, 10) AS precio_con_10_pct_descuento
FROM productos
LIMIT 5;

-- 9.fn_ObtenerUltimaFechaCompra: Devuelve la fecha de la última compra de un cliente.
----------------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_ObtenerUltimaFechaCompra;

CREATE FUNCTION fn_ObtenerUltimaFechaCompra (c_id_cliente INT)
RETURNS TIMESTAMP
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE c_ultima_fecha TIMESTAMP;

    -- Busco la fecha más reciente de ventas de ese cliente
    SELECT MAX(fecha_venta)
    INTO c_ultima_fecha
    FROM ventas
    WHERE id_clientes = c_id_cliente;

    RETURN c_ultima_fecha;
END;

-- Muestro la última compra de cada cliente
SELECT
    id,
    nombre,
    apellido,
    fn_ObtenerUltimaFechaCompra(id) AS ultima_compra
FROM clientes;

-- 10.fn_ValidarFormatoEmail: Comprueba si una cadena de texto tiene un formato de correo electrónico válido.
----------------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_ValidarFormatoEmail;

CREATE FUNCTION fn_ValidarFormatoEmail (c_email VARCHAR(100))
RETURNS BOOLEAN
DETERMINISTIC
NO SQL
BEGIN
    DECLARE v_es_valido BOOLEAN DEFAULT FALSE;

    -- Verifico que tenga @ y que después del @ haya un punto
    IF LOCATE('@', c_email) > 0
       AND LOCATE('.', c_email, LOCATE('@', c_email)) > 0
    THEN
        SET v_es_valido = TRUE;
    END IF;

    RETURN v_es_valido;
END;

-- Pruebo con emails reales e inventados
SELECT
    fn_ValidarFormatoEmail('juan.perez@email.com') AS email_valido,
    fn_ValidarFormatoEmail('esto_no_es_un_email')  AS email_invalido;


-- 11.fn_ObtenerNombreCategoria: Devuelve el nombre de la categoría a partir del ID de un producto.
----------------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_ObtenerNombreCategoria;

CREATE FUNCTION fn_ObtenerNombreCategoria (p_id_producto INT)
RETURNS VARCHAR(100)
READS SQL DATA
BEGIN
    DECLARE p_nombre_categoria VARCHAR(100);

    -- Uno productos con categoría para traer el nombre
    SELECT c.nombre
    INTO p_nombre_categoria
    FROM productos p
    INNER JOIN categoria c ON p.id_categoria = c.id
    WHERE p.id = p_id_producto;

    RETURN p_nombre_categoria;
END;

-- Muestro el producto y su categoría usando la función
SELECT
    id,
    nombre AS producto,
    fn_ObtenerNombreCategoria(id) AS categoria
FROM productos
LIMIT 10;


-- 12.fn_ContarVentasCliente: Cuenta el número total de compras realizadas por un cliente.
----------------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_ContarVentasCliente;

CREATE FUNCTION fn_ContarVentasCliente (c_id_cliente INT)
RETURNS INT
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE c_total_ventas INT;

    -- Cuento todas las ventas de ese cliente
    SELECT COUNT(*)
    INTO c_total_ventas
    FROM ventas
    WHERE id_clientes = c_id_cliente;

    RETURN c_total_ventas;
END;

-- Listo a todos los clientes con su número de compras
SELECT
    id,
    nombre,
    apellido,
    fn_ContarVentasCliente(id) AS total_compras
FROM clientes
ORDER BY total_compras DESC;

-- 13.fn_CalcularDiasDesdeUltimaCompra: Devuelve el número de días transcurridos desde la última compra de un cliente.
----------------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_CalcularDiasDesdeUltimaCompra;

CREATE FUNCTION fn_CalcularDiasDesdeUltimaCompra (c_id_cliente INT)
RETURNS INT
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE c_ultima_compra TIMESTAMP;
    DECLARE c_dias INT;

    -- Obtengo la fecha de la última compra
    SELECT MAX(fecha_venta)
    INTO c_ultima_compra
    FROM ventas
    WHERE id_clientes = c_id_cliente;

    -- Si nunca compró, devuelvo -1 para indicar que no hay datos
    IF c_ultima_compra IS NULL THEN
        RETURN -1;
    END IF;

    SET c_dias = DATEDIFF(CURDATE(), c_ultima_compra);

    RETURN c_dias;
END;

-- Veo qué clientes tienen más tiempo sin comprar
SELECT
    id,
    nombre,
    apellido,
    fn_CalcularDiasDesdeUltimaCompra(id) AS dias_sin_comprar
FROM clientes
ORDER BY dias_sin_comprar DESC;


-- 14.fn_DeterminarEstadoLealtad: Asigna un estado de lealtad (Bronce, Plata, Oro) a un cliente según su gasto total.
----------------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_DeterminarEstadoLealtad;

CREATE FUNCTION fn_DeterminarEstadoLealtad (c_id_cliente INT)
RETURNS VARCHAR(20)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE c_gasto_total DECIMAL(10,2);
    DECLARE c_nivel VARCHAR(20);

    -- Sumo solo las ventas entregadas (compras reales)
    SELECT COALESCE(SUM(total), 0)
    INTO c_gasto_total
    FROM ventas
    WHERE id_clientes = c_id_cliente
      AND estado = 'Entregado';

    -- Asigno el nivel según el gasto
    IF c_gasto_total > 2000 THEN
        SET c_nivel = 'Oro';
    ELSEIF c_gasto_total >= 500 THEN
        SET c_nivel = 'Plata';
    ELSE
        SET c_nivel = 'Bronce';
    END IF;

    RETURN c_nivel;
END;

-- Muestro el nivel de lealtad de cada cliente
SELECT
    id,
    nombre,
    apellido,
    fn_DeterminarEstadoLealtad(id) AS nivel_lealtad
FROM clientes
ORDER BY id;


-- 15.fn_GenerarSKU: Genera un código de producto (SKU) único basado en su nombre y categoría.
----------------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_GenerarSKU;

CREATE FUNCTION fn_GenerarSKU (p_nombre VARCHAR(100), p_id_categoria INT)
RETURNS VARCHAR(50)
DETERMINISTIC
NO SQL
BEGIN
    DECLARE p_prefijo VARCHAR(10);
    DECLARE p_sku_generado VARCHAR(50);

    -- Tomo las primeras 4 letras del nombre y las paso a mayúscula
    SET p_prefijo = UPPER(LEFT(TRIM(p_nombre), 4));

    -- Armo el SKU con el formato acordado
    SET p_sku_generado = CONCAT(p_prefijo, '-CAT-', p_id_categoria);

    RETURN p_sku_generado;
END;

-- Genero el SKU sugerido para cada producto
SELECT
    id,
    nombre,
    id_categoria,
    fn_GenerarSKU(nombre, id_categoria) AS sku_sugerido
FROM productos
LIMIT 10;


-- 16.fn_CalcularIVA: Calcula el impuesto (IVA) sobre el total de una venta.
----------------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_CalcularIVA;

CREATE FUNCTION fn_CalcularIVA (p_total DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
NO SQL
BEGIN
    DECLARE p_iva DECIMAL(10,2);

    -- El IVA en Colombia es del 19%
    SET p_iva = p_total * 0.19;

    RETURN p_iva;
END;

-- Muestro el total de cada venta y cuánto sería el IVA
SELECT
    id AS id_venta,
    total AS total_sin_iva,
    fn_CalcularIVA(total) AS valor_iva,
    total + fn_CalcularIVA(total) AS total_con_iva
FROM ventas
WHERE estado = 'Entregado'
LIMIT 10;



-- 17.fn_ObtenerStockTotalPorCategoria: Suma el stock de todos los productos de una categoría.
----------------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_ObtenerStockTotalPorCategoria;

CREATE FUNCTION fn_ObtenerStockTotalPorCategoria (c_id_categoria INT)
RETURNS INT
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE c_stock_total INT;

    -- Sumo el stock de todos los productos de esa categoría
    SELECT COALESCE(SUM(stock), 0)
    INTO c_stock_total
    FROM productos
    WHERE id_categoria = c_id_categoria
      AND activo = TRUE;

    RETURN c_stock_total;
END;

-- Muestro el stock total por categoría
SELECT
    id AS id_categoria,
    nombre AS categoria,
    fn_ObtenerStockTotalPorCategoria(id) AS stock_total
FROM categoria
ORDER BY stock_total DESC;



-- 18.fn_EstimarFechaEntrega: Calcula la fecha estimada de entrega de un pedido según la ubicación del cliente.
----------------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_EstimarFechaEntrega;

CREATE FUNCTION fn_EstimarFechaEntrega (c_id_cliente INT, p_fecha_venta TIMESTAMP)
RETURNS DATE
READS SQL DATA
BEGIN
    DECLARE c_direccion TEXT;
    DECLARE v_dias_entrega INT DEFAULT 7;
    DECLARE v_fecha_entrega DATE;

    -- Busco la dirección del cliente para saber su región
    SELECT direccion_envio
    INTO c_direccion
    FROM clientes
    WHERE id = c_id_cliente;

    -- Asigno días según la región que aparece en la dirección
    IF LOCATE('Norte', c_direccion) > 0 THEN
        SET v_dias_entrega = 3;
    ELSEIF LOCATE('Andina', c_direccion) > 0 THEN
        SET v_dias_entrega = 5;
    ELSE
        SET v_dias_entrega = 7;
    END IF;

    SET v_fecha_entrega = DATE_ADD(DATE(p_fecha_venta), INTERVAL v_dias_entrega DAY);

    RETURN v_fecha_entrega;
END;

-- Estimo la fecha de entrega de cada venta
SELECT
    v.id AS id_venta,
    c.nombre,
    v.fecha_venta,
    fn_EstimarFechaEntrega(v.id_clientes, v.fecha_venta) AS entrega_estimada
FROM ventas v
INNER JOIN clientes c ON v.id_clientes = c.id
LIMIT 10;



-- 19.fn_ConvertirMoneda: Convierte un monto a otra moneda usando una tasa de cambio fija.
----------------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_ConvertirMoneda;

CREATE FUNCTION fn_ConvertirMoneda (p_monto_usd DECIMAL(10,2), p_tasa_cambio DECIMAL(10,4))
RETURNS DECIMAL(12,2)
DETERMINISTIC
NO SQL
BEGIN
    DECLARE p_monto_convertido DECIMAL(12,2);

    -- Multiplico el monto por la tasa de cambio
    SET p_monto_convertido = p_monto_usd * p_tasa_cambio;

    RETURN p_monto_convertido;
END;

-- Convierto los precios de productos a pesos colombianos (aprox 1 USD = 4100 COP)
SELECT
    id,
    nombre,
    precio AS precio_usd,
    fn_ConvertirMoneda(precio, 4100.00) AS precio_cop
FROM productos
LIMIT 5;

-- 20.fn_ValidarComplejidadContraseña: Verifica si una contraseña cumple con los criterios de seguridad (longitud, caracteres, etc.).
----------------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_ValidarComplejidadContrasena;

CREATE FUNCTION fn_ValidarComplejidadContrasena (c_contrasena VARCHAR(155))
RETURNS BOOLEAN
DETERMINISTIC
NO SQL
BEGIN
    DECLARE v_es_segura BOOLEAN DEFAULT FALSE;

    -- Reviso que la contraseña tenga mínimo 8 caracteres
    IF LENGTH(TRIM(c_contrasena)) >= 8 THEN
        SET v_es_segura = TRUE;
    END IF;

    RETURN v_es_segura;
END;

-- Pruebo con contraseñas de distinta longitud
SELECT
    fn_ValidarComplejidadContrasena('abc')            AS contrasena_corta,
    fn_ValidarComplejidadContrasena('MiClave123')     AS contrasena_segura;

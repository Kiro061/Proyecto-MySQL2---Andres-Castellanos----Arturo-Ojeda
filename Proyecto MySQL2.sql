CREATE DATABASE e_commerce;
USE e_commerce;

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--	TABLAS
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CREATE TABLE categoria(
	id INT AUTO_INCREMENT PRIMARY KEY,
	nombre VARCHAR(100) UNIQUE,
	descripcion TEXT NULL
);

CREATE TABLE proveedores(
	id INT AUTO_INCREMENT PRIMARY KEY,
	nombre VARCHAR(100) UNIQUE,
	email_contacto VARCHAR(50) NOT NULL UNIQUE,
	telefono_contacto INT NOT NULL
);

CREATE TABLE clientes (
	id INT AUTO_INCREMENT PRIMARY KEY,
	nombre VARCHAR(100) NOT NULL ,
	apellido VARCHAR(100) NOT NULL ,
	email VARCHAR(50) NOT NULL UNIQUE,
	contraseña VARCHAR(155) NOT NULL,
	direccion_envio TEXT NOT NULL,
	fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE productos(
	id INT AUTO_INCREMENT PRIMARY KEY,
	id_categoria INT NOT NULL,
	id_proveedor INT NOT NULL,
	nombre VARCHAR(100) UNIQUE,
	descripcion TEXT NULL,
    precio DECIMAL(10,2) NOT NULL,
    costo DECIMAL(10,2) NOT NULL,
    stock INT UNSIGNED NOT NULL DEFAULT 0,
    sku VARCHAR(100) NOT NULL UNIQUE,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_precio CHECK (precio > 0),
    CONSTRAINT chk_costo CHECK (costo >= 0),
    FOREIGN KEY (id_categoria) REFERENCES categoria(id),
    FOREIGN KEY (id_proveedor) REFERENCES proveedores(id)
);

CREATE TABLE ventas(
	id INT AUTO_INCREMENT PRIMARY KEY,
	id_clientes INT NOT NULL,
	fecha_venta TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	estado ENUM(
        'Pendiente de Pago',
        'Procesando',
        'Enviado',
        'Entregado',
        'Cancelado'
    ) NOT NULL DEFAULT 'Pendiente de Pago',
	total DECIMAL(10,2) NOT NULL DEFAULT 0.00,
	CONSTRAINT chk_total CHECK (total >= 0),
	FOREIGN KEY(id_clientes) REFERENCES  clientes(id)
);

CREATE TABLE detalle_ventas(
	id INT AUTO_INCREMENT PRIMARY KEY,
	id_venta INT NOT NULL,
	id_producto INT NOT NULL,
	cantidad INT NOT NULL,
	precio_unitario decimal(10,2) NOT NULL,
	CONSTRAINT chk_cantidad CHECK (cantidad > 0),
	CONSTRAINT chk_precio_unitario CHECK (precio_unitario >= 0),
	CONSTRAINT uk_venta_producto UNIQUE (id_venta, id_producto),
	FOREIGN KEY (id_venta) REFERENCES ventas(id),
	FOREIGN KEY (id_producto) REFERENCES productos(id)
);

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--	INSERCION DE DATOS
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

INSERT INTO categoria (id, nombre, descripcion) VALUES
(1, 'Electrónica', 'Dispositivos y gadgets tecnológicos'),
(2, 'Ropa', 'Prendas de vestir y accesorios'),
(3, 'Hogar', 'Artículos para el hogar y decoración'),
(4, 'Libros', 'Libros físicos y digitales'),
(5, 'Deportes', 'Equipamiento y ropa deportiva');

INSERT INTO proveedores (id, nombre, email_contacto, telefono_contacto) VALUES
(1, 'TechSupplier', 'contacto@techsupplier.com', 5551234),
(2, 'ModaDistribución', 'info@modadist.com', 5555678),
(3, 'HogarYEstilo', 'ventas@hogaryestilo.com', 5559012),
(4, 'EditorialAlfa', 'editor@editorialalfa.com', 5553456),
(5, 'SportGlobal', 'sports@sportglobal.com', 5557890);

INSERT INTO clientes (id, nombre, apellido, email, contraseña, direccion_envio, fecha_registro) VALUES
(1, 'Juan', 'Pérez', 'juan.perez@email.com', 'hash1', 'CDMX, Centro, Región Norte', '2025-06-15 10:00:00'),
(2, 'María', 'Gómez', 'maria.gomez@email.com', 'hash2', 'Bogotá, Chapinero, Región Andina', '2025-07-20 11:30:00'),
(3, 'Carlos', 'López', 'carlos.lopez@email.com', 'hash3', 'Lima, Miraflores, Región Costa', '2025-08-05 14:15:00'),
(4, 'Ana', 'Martínez', 'ana.martinez@email.com', 'hash4', 'Santiago, Providencia, Región Metropolitana', '2025-09-12 09:00:00'),
(5, 'Luis', 'Rodríguez', 'luis.rodriquez@email.com', 'hash5', 'Buenos Aires, Palermo, Región Pampeana', '2025-10-01 16:45:00'),
(6, 'Elena', 'Sánchez', 'elena.sanchez@email.com', 'hash6', 'CDMX, Polanco, Región Norte', '2025-11-18 08:20:00'),
(7, 'Jorge', 'Ramírez', 'jorge.ramirez@email.com', 'hash7', 'Bogotá, Usaquén, Región Andina', '2025-12-05 13:10:00'),
(8, 'Sofia', 'Torres', 'sofia.torres@email.com', 'hash8', 'Medellín, Poblado, Región Antióquia', '2026-01-10 17:00:00'),
(9, 'Pedro', 'Fernández', 'pedro.fernandez@email.com', 'hash9', 'Lima, San Isidro, Región Costa', '2026-02-14 11:00:00'),
(10, 'Lucia', 'Díaz', 'lucia.diaz@email.com', 'hash10', 'Viña del Mar, Región Valparaíso', '2026-03-03 15:30:00'),
(11, 'Diego', 'Castro', 'diego.castro@email.com', 'hash11', 'Quito, Cumbayá, Región Sierra', '2026-03-20 12:00:00'),
(12, 'Laura', 'Morales', 'laura.morales@email.com', 'hash12', 'Guayaquil, Samborondón, Región Costa', '2026-04-05 10:45:00'),
(13, 'Miguel', 'Herrera', 'miguel.herrera@email.com', 'hash13', 'Montevideo, Pocitos, Región Sur', '2026-04-22 14:25:00'),
(14, 'Andrés', 'Clavijo', 'andres.clavijo@email.com', 'hash14', 'Cali, Valle, Región Pacífica', '2026-05-01 09:15:00'),
(15, 'Patricia', 'Ruiz', 'patricia.ruiz@email.com', 'hash15', 'Asunción, Villamorra, Región Central', '2026-05-15 16:00:00');

INSERT INTO productos (id, id_categoria, id_proveedor, nombre, descripcion, precio, costo, stock, sku, fecha_creacion, activo) VALUES
(1, 1, 1, 'Smartphone X', 'Gama alta', 800.00, 400.00, 50, 'SKU-ELECT-01', '2025-06-01 09:00:00', 1),
(2, 1, 1, 'Audífonos Pro', 'Cancelación ruido', 150.00, 50.00, 120, 'SKU-ELECT-02', '2025-06-02 09:00:00', 1),
(3, 1, 1, 'Laptop Alpha', 'Trabajo pesado', 1200.00, 900.00, 2, 'SKU-ELECT-03', '2025-06-03 09:00:00', 1),
(4, 1, 1, 'Cargador Rápido', '20W Tipo C', 25.00, 5.00, 300, 'SKU-ELECT-04', '2025-06-04 09:00:00', 1),
(5, 2, 2, 'Camiseta Básica', '100% Algodón', 20.00, 8.00, 150, 'SKU-ROPA-01', '2025-06-05 09:00:00', 1),
(6, 2, 2, 'Jeans Slim Fit', 'Mezclilla premium', 50.00, 22.00, 80, 'SKU-ROPA-02', '2025-06-06 09:00:00', 1),
(7, 2, 2, 'Chaqueta Invierno', 'Térmica impermeable', 120.00, 70.00, 4, 'SKU-ROPA-03', '2025-06-07 09:00:00', 1),
(8, 3, 3, 'Lámpara LED', 'Escritorio regulable', 35.00, 15.00, 5, 'SKU-HOGAR-01', '2025-06-08 09:00:00', 1),
(9, 3, 3, 'Juego Sábanas', 'King size 400 hilos', 80.00, 40.00, 45, 'SKU-HOGAR-02', '2025-06-09 09:00:00', 1),
(10, 3, 3, 'Cafetera Goteo', 'Programable 12 tazas', 60.00, 35.00, 25, 'SKU-HOGAR-03', '2025-06-10 09:00:00', 1),
(11, 4, 4, 'Novela de Ficción', 'Best seller', 15.00, 5.00, 200, 'SKU-LIBR-01', '2025-06-11 09:00:00', 1),
(12, 4, 4, 'Guía Programación', 'Aprende MySQL', 45.00, 20.00, 90, 'SKU-LIBR-02', '2025-06-12 09:00:00', 1),
(13, 4, 4, 'Enciclopedia Visual', 'Tapa dura', 95.00, 60.00, 3, 'SKU-LIBR-03', '2025-06-13 09:00:00', 1),
(14, 5, 5, 'Balón de Fútbol', 'Reglamentario', 30.00, 10.00, 110, 'SKU-DEPO-01', '2025-06-14 09:00:00', 1),
(15, 5, 5, 'Manga Elástica', 'Compresión muscular', 12.00, 3.00, 500, 'SKU-DEPO-02', '2025-06-15 09:00:00', 1),
(16, 5, 5, 'Mancuernas 5kg', 'Par de hierro', 40.00, 20.00, 15, 'SKU-DEPO-03', '2025-06-16 09:00:00', 1),
(17, 1, 1, 'Smartwatch Fit', 'Ritmo cardíaco', 180.00, 90.00, 60, 'SKU-ELECT-05', '2025-06-17 09:00:00', 1),
(18, 2, 2, 'Zapatillas Urbanas', 'Estilo casual', 75.00, 35.00, 40, 'SKU-ROPA-04', '2025-06-18 09:00:00', 1),
(19, 3, 3, 'Espejo Pared', 'Marco de madera', 110.00, 55.00, 8, 'SKU-HOGAR-04', '2025-06-19 09:00:00', 1),
(20, 5, 5, 'Termo Deportivo', 'Inoxidable 1L', 22.00, 7.00, 140, 'SKU-DEPO-04', '2025-06-20 09:00:00', 1);

INSERT INTO ventas (id, id_clientes, fecha_venta, estado, total) VALUES
(1, 1, '2025-07-05 08:30:00', 'Entregado', 1010.00),
(2, 1, '2025-08-12 14:20:00', 'Entregado', 40.00),
(3, 1, '2025-09-22 19:45:00', 'Entregado', 200.00),
(4, 1, '2025-10-05 11:15:00', 'Entregado', 1200.00),
(5, 1, '2025-11-12 07:10:00', 'Entregado', 70.00),
(6, 1, '2025-12-20 15:40:00', 'Entregado', 205.00),
(7, 1, '2026-01-05 10:05:00', 'Entregado', 90.00),
(8, 1, '2026-02-14 21:00:00', 'Entregado', 22.00),
(9, 2, '2025-07-10 09:15:00', 'Entregado', 925.00),
(10, 2, '2025-09-15 13:00:00', 'Entregado', 75.00),
(11, 2, '2025-11-03 16:22:00', 'Entregado', 75.00),
(12, 2, '2026-01-18 10:30:00', 'Entregado', 15.00),
(13, 2, '2026-03-05 23:15:00', 'Entregado', 30.00),
(14, 3, '2025-08-20 11:00:00', 'Entregado', 1045.00),
(15, 3, '2025-10-10 14:50:00', 'Entregado', 65.00),
(16, 3, '2025-12-01 08:12:00', 'Entregado', 80.00),
(17, 3, '2026-02-25 18:35:00', 'Entregado', 12.00),
(18, 4, '2025-09-18 10:40:00', 'Entregado', 230.00),
(19, 4, '2025-12-15 15:25:00', 'Entregado', 60.00),
(20, 4, '2026-04-10 12:10:00', 'Entregado', 110.00),
(21, 5, '2025-10-05 16:50:00', 'Entregado', 155.00),
(22, 5, '2026-02-10 09:30:00', 'Entregado', 25.00),
(23, 6, '2025-11-20 11:15:00', 'Entregado', 145.00),
(24, 6, '2026-03-12 14:20:00', 'Entregado', 105.00),
(25, 7, '2025-12-10 10:00:00', 'Cancelado', 800.00),
(26, 8, '2026-01-15 13:45:00', 'Entregado', 145.00),
(27, 9, '2026-02-20 16:10:00', 'Cancelado', 1200.00),
(28, 10, '2026-03-10 11:30:00', 'Entregado', 25.00),
(29, 11, '2026-03-25 08:45:00', 'Entregado', 40.00),
(30, 12, '2026-04-12 15:20:00', 'Entregado', 30.00);

INSERT INTO detalle_ventas (id, id_venta, id_producto, cantidad, precio_unitario) VALUES
(1, 1, 1, 1, 800.00),
(2, 1, 2, 1, 150.00),
(3, 1, 4, 1, 25.00),
(4, 2, 4, 1, 25.00),
(5, 3, 2, 1, 150.00),
(6, 4, 3, 1, 1200.00),
(7, 5, 16, 1, 40.00),
(8, 6, 17, 1, 180.00),
(9, 7, 18, 1, 75.00),
(10, 8, 20, 1, 22.00),
(11, 9, 1, 1, 800.00),
(12, 9, 5, 1, 20.00),
(13, 10, 10, 1, 60.00),
(14, 11, 6, 1, 50.00),
(15, 12, 11, 1, 15.00),
(16, 13, 14, 1, 30.00),
(17, 14, 1, 1, 800.00),
(18, 14, 2, 1, 150.00),
(19, 15, 8, 1, 35.00),
(20, 16, 9, 1, 80.00),
(21, 17, 15, 1, 12.00),
(22, 18, 2, 1, 150.00),
(23, 18, 11, 1, 15.00),
(24, 19, 12, 1, 45.00),
(25, 20, 19, 1, 110.00),
(26, 21, 13, 1, 95.00),
(27, 21, 16, 1, 40.00),
(28, 22, 4, 1, 25.00),
(29, 23, 13, 1, 95.00),
(30, 24, 10, 1, 60.00),
(31, 25, 1, 1, 800.00),
(32, 26, 7, 1, 120.00),
(33, 27, 3, 1, 1200.00),
(34, 28, 4, 1, 25.00),
(35, 29, 16, 1, 40.00),
(36, 30, 14, 1, 30.00),
(37, 1, 5, 2, 20.00),
(38, 9, 4, 3, 25.00),
(39, 14, 4, 2, 25.00),
(40, 18, 4, 1, 25.00),
(41, 3, 4, 2, 25.00),
(42, 6, 4, 1, 25.00),
(43, 11, 4, 1, 25.00),
(44, 23, 4, 2, 25.00),
(45, 26, 4, 1, 25.00),
(46, 1, 11, 1, 15.00),
(47, 9, 11, 2, 15.00),
(48, 14, 11, 1, 15.00),
(49, 18, 5, 2, 20.00),
(50, 21, 5, 1, 20.00),
(51, 1, 14, 1, 30.00),
(52, 9, 14, 1, 30.00),
(53, 14, 14, 1, 30.00),
(54, 2, 11, 1, 15.00),
(55, 5, 11, 2, 15.00),
(56, 7, 11, 1, 15.00),
(57, 10, 11, 1, 15.00),
(58, 15, 11, 2, 15.00),
(59, 19, 11, 1, 15.00),
(60, 24, 11, 3, 15.00);


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

-- Tabla para registrar nuevos clientes
CREATE TABLE IF NOT EXISTS log_nuevos_clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    nombre_completo VARCHAR(205),
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Tabla para alertas de stock bajo
CREATE TABLE IF NOT EXISTS alertas_stock (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    stock_actual INT NOT NULL,
    fecha_alerta TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Tabla para historial de cambios de estado de pedidos
CREATE TABLE IF NOT EXISTS log_estado_pedido (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT NOT NULL,
    estado_anterior VARCHAR(50),
    estado_nuevo VARCHAR(50),
    fecha_cambio TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Tabla archivo para ventas eliminadas
CREATE TABLE IF NOT EXISTS archivo_ventas (
    id INT PRIMARY KEY,
    id_clientes INT,
    fecha_venta TIMESTAMP,
    estado VARCHAR(50),
    total DECIMAL(10,2),
    fecha_archivado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Columna para la fecha de última modificación en productos
ALTER TABLE productos ADD COLUMN fecha_modificacion TIMESTAMP NULL;

-- Columna para la fecha del último pedido en clientes
ALTER TABLE clientes ADD COLUMN fecha_ultimo_pedido TIMESTAMP NULL;

-- Columna para el total gastado acumulado en clientes
ALTER TABLE clientes ADD COLUMN total_gastado DECIMAL(10,2) NOT NULL DEFAULT 0.00;

-- Columna contador de productos en categoría
ALTER TABLE categoria ADD COLUMN total_productos INT NOT NULL DEFAULT 0;


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

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--	9. Procedimientos Almacenados
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- 1.sp_RealizarNuevaVenta: Procesa una nueva venta de forma transaccional.
----------------------------------------------------------------------------------------------------
-- 2.sp_AgregarNuevoProducto: Inserta un nuevo producto y sus atributos iniciales.
-- 3.sp_ActualizarDireccionCliente: Actualiza la dirección de un cliente en todas las tablas relevantes.
-- 4.sp_ProcesarDevolucion: Gestiona la devolución de un producto, ajustando el stock y generando un crédito.
-- 5.sp_ObtenerHistorialComprasCliente: Devuelve el historial completo de compras de un cliente.
-- 6.sp_AjustarNivelStock: Permite ajustar manualmente el stock de un producto, registrando el motivo.
-- 7.sp_EliminarClienteDeFormaSegura: Anonimiza los datos de un cliente en lugar de borrarlos, para mantener la integridad referencial.
-- 8.sp_AplicarDescuentoPorCategoria: Aplica un descuento a todos los productos de una categoría específica.
-- 9.sp_GenerarReporteMensualVentas: Genera un reporte completo de ventas para un mes y año dados.
-- 10.sp_CambiarEstadoPedido: Cambia el estado de un pedido (ej. 'Procesando' a 'Enviado') y notifica a otros sistemas.
-- 11.sp_RegistrarNuevoCliente: Registra un nuevo cliente validando que el email no exista.
-- 12.sp_ObtenerDetallesProductoCompleto: Devuelve toda la información de un producto, incluyendo datos de su proveedor y categoría.
-- 13.sp_FusionarCuentasCliente: Fusiona dos cuentas de cliente duplicadas en una sola.
-- 14.sp_AsignarProductoAProveedor: Asigna o cambia el proveedor de un producto.
-- 15.sp_BuscarProductos: Realiza una búsqueda avanzada de productos con filtros por nombre, categoría, rango de precios, etc.
-- 16.sp_ObtenerDashboardAdmin: Devuelve un conjunto de KPIs para un panel de administración (ventas de hoy, nuevos clientes, etc.).
-- 17.sp_ProcesarPago: Simula el procesamiento de un pago para una venta, actualizando su estado a "Pagado".
-- 18.sp_AñadirReseñaProducto: Permite a un cliente añadir una reseña y calificación a un producto que ha comprado.
-- 19.sp_ObtenerProductosRelacionados: Devuelve una lista de productos relacionados a uno dado, basándose en compras de otros clientes.
-- 20.sp_MoverProductosEntreCategorias: Mueve uno o más productos de una categoría a otra de forma segura.

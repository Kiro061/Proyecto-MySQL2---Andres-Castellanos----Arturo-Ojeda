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

CREATE TABLE IF NOT EXISTS log_nuevos_clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    nombre_completo VARCHAR(205),
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS alertas_stock (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    stock_actual INT NOT NULL,
    fecha_alerta TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS log_estado_pedido (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT NOT NULL,
    estado_anterior VARCHAR(50),
    estado_nuevo VARCHAR(50),
    fecha_cambio TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS archivo_ventas (
    id INT PRIMARY KEY,
    id_clientes INT,
    fecha_venta TIMESTAMP,
    estado VARCHAR(50),
    total DECIMAL(10,2),
    fecha_archivado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS resenas_producto (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    id_cliente INT NOT NULL,
    calificacion TINYINT NOT NULL,
    comentario TEXT,
    fecha_resena TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_calificacion CHECK (calificacion BETWEEN 1 AND 5),
    CONSTRAINT uk_resena UNIQUE (id_producto, id_cliente),
    FOREIGN KEY (id_producto) REFERENCES productos(id),
    FOREIGN KEY (id_cliente) REFERENCES clientes(id)
);

ALTER TABLE productos ADD COLUMN fecha_modificacion TIMESTAMP NULL;


ALTER TABLE clientes ADD COLUMN fecha_ultimo_pedido TIMESTAMP NULL;


ALTER TABLE clientes ADD COLUMN total_gastado DECIMAL(10,2) NOT NULL DEFAULT 0.00;


ALTER TABLE categoria ADD COLUMN total_productos INT NOT NULL DEFAULT 0;


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
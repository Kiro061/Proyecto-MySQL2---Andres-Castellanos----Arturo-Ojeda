-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- Seguridad y permisos
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- 1.Crear el rol Administrador_Sistema con todos los privilegios.

CREATE ROLE IF NOT EXISTS Administrador_Sistema;

GRANT ALL PRIVILEGES ON e_commerce.* TO Administrador_Sistema WITH GRANT OPTION;

-- =====================================================================================================================
-- 2.Crear el rol Gerente_Marketing con acceso de solo lectura a ventas y clientes.

CREATE ROLE IF NOT EXISTS Gerente_Marketing;

GRANT SELECT ON e_commerce.clientes  TO Gerente_marketing;
GRANT SELECT ON e_commerce.ventas  TO Gerente_marketing;

-- =====================================================================================================================
-- 3Crear el rol Analista_Datos con acceso de solo lectura a todas las tablas, excepto a las de auditoría.

CREATE ROLE IF NOT EXISTS Analista_Datos;

GRANT SELECT ON e_commerce.* TO Analista_Datos;

-- =====================================================================================================================
-- 4.Crear el rol Empleado_Inventario que solo pueda modificar la tabla productos (stock y ubicación).

CREATE ROLE IF NOT EXISTS Empleado_Inventario;

GRANT UPDATE (stock) ON e_commerce.productos TO Empleado_Inventario;

-- =====================================================================================================================
-- 5.Crear el rol Atencion_Cliente que pueda ver clientes y ventas, pero no modificar precios.

CREATE ROLE IF NOT EXISTS Atencion_Cliente;

GRANT SELECT ON e_commerce.ventas  TO Atencion_Cliente;
GRANT SELECT ON e_commerce.clientes  TO Atencion_Cliente;

-- =====================================================================================================================
-- 6.Crear el rol Auditor_Financiero con acceso de solo lectura a ventas, productos y logs de precios.

CREATE ROLE IF NOT EXISTS Auditor_Financiero;

GRANT SELECT ON e_commerce.ventas  TO Auditor_Financiero;
GRANT SELECT ON e_commerce.productos  TO Auditor_Financiero;

-- =====================================================================================================================
-- 7.Crear un usuario admin_user y asignarle el rol de administrador.

CREATE USER IF NOT EXISTS 'admin_user'@'localhost'
IDENTIFIED adminUser#2026';

GRANT Administrador_Sistema TO 'admin_user'@'localhost';
-- =====================================================================================================================
-- 8.Crear un usuario marketing_user y asignarle el rol de marketing.

CREATE USER IF NOT EXISTS 'marketing_user'@'localhost'
IDENTIFIED marketingU#2026';

GRANT Gerente_Marketing TO 'marketing_user'@'localhost';

-- =====================================================================================================================
-- 9.Crear un usuario inventory_user y asignarle el rol de inventario.


CREATE USER IF NOT EXISTS 'inventory_user'@'localhost'
IDENTIFIED inventoryU#2026';

GRANT Empleado_Inventario TO 'inventory_user'@'localhost';

-- =====================================================================================================================
-- 10.Crear un usuario support_user y asignarle el rol de atención al cliente.

CREATE USER IF NOT EXISTS 'support_user'@'localhost'
IDENTIFIED supportU#2026';

GRANT Atencion_Cliente TO 'support_user'@'localhost';
-- =====================================================================================================================
-- 11.Impedir que el rol Analista_Datos pueda ejecutar comandos DELETE o TRUNCATE.

REVOKE DELETE ON e_commerce.* FROM Analista_Datos;

REVOKE DROP ON e_commerce.* FROM Analista_Datos;

-- =====================================================================================================================
-- 12.Otorgar al rol Gerente_Marketing permiso para ejecutar procedimientos almacenados de reportes de marketing.

GRANT EXECUTE ON PROCEDURE e_commerce.reporte_marketing TO Gerente_Marketing;

-- =====================================================================================================================
-- 13.Crear una vista v_info_clientes_basica que oculte información sensible y dar acceso a ella al rol Atencion_Cliente.

CREATE VIEW v_info_clientes_basica AS
SELECT
    id,
    nombre,
    apellido,
    email,
    fecha_registro
FROM clientes;

GRANT SELECT ON e_commerce.v_info_clientes_basica TO Atencion_Cliente;

-- =====================================================================================================================
-- 14.Revocar el permiso de UPDATE sobre la columna precio de la tabla productos al rol Empleado_Inventario.

REVOKE UPDATE(precio) ON e_commerce.productos FROM Empleado_Inventario;

-- =====================================================================================================================
-- 15.Implementar una política de contraseñas seguras para todos los usuarios.

SET GLOBAL validate_password.length = 10;

SET GLOBAL validate_password.policy = STRONG;
-- =====================================================================================================================
-- 16.Asegurar que el usuario root no pueda ser usado desde conexiones remotas.

SELECT USER, host FROM mysql.user WHERE USER='root';

DROP USER 'root'@'%';

-- =====================================================================================================================
-- 17.Crear un rol Visitante que solo pueda ver la tabla productos.

CREATE ROLE Visitante;

GRANT SELECT ON e_commerce.productos TO Visitante;

-- =====================================================================================================================
-- 18.Limitar el número de consultas por hora para el rol Analista_Datos para evitar sobrecarga.

ALTER USER 'analista_user'@'localhost' WITH MAX_QUERIES_PER_HOUR 1000;
-- =====================================================================================================================
-- 19.Asegurar que los usuarios solo puedan ver las ventas de la sucursal a la que pertenecen (requiere añadir id_sucursal).

ALTER TABLE ventas ADD COLUMN id_sucursal INT;

CREATE VIEW ventas_sucursal AS
SELECT *
FROM ventas;
-- =====================================================================================================================
-- 20.Auditar todos los intentos de inicio de sesión fallidos en la base de datos.

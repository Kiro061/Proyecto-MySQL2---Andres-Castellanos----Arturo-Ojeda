-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- Eventos Programados
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
SET GLOBAL event_scheduler = ON;

SHOW VARIABLES LIKE 'event_scheduler';
-- =====================================================================================================================
-- 1.evt_generate_weekly_sales_report: Genera un reporte de ventas semanal.

CREATE EVENT evt_generate_weekly_sales_report
ON SCHEDULE EVERY 1 WEEK
STARTS '2025-01-06 06:00:00'   -- lunes
DO
    INSERT INTO reporte_ventas_semanal (semana_inicio, semana_fin, total_ventas, ingresos_totales)
    SELECT
        DATE_SUB(CURDATE(), INTERVAL 7 DAY),
        CURDATE(),
        COUNT(*),
        COALESCE(SUM(total), 0)
    FROM ventas
    WHERE fecha_venta >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
      AND estado = 'Entregado';

-- =====================================================================================================================
-- 2.evt_cleanup_temp_tables_daily: Borra tablas temporales diariamente.

CREATE EVENT evt_cleanup_temp_tables_daily
ON SCHEDULE EVERY 1 DAY
STARTS (DATE(NOW()) + INTERVAL 1 DAY + INTERVAL 2 HOUR)
DO
    DELETE FROM temp_sesiones
    WHERE creado_en < DATE_SUB(NOW(), INTERVAL 24 HOUR);


-- =====================================================================================================================
-- 3.evt_archive_old_logs_monthly: Archiva logs de más de 6 meses en tablas históricas.

CREATE EVENT evt_archive_old_logs_monthly
ON SCHEDULE EVERY 1 MONTH
STARTS '2025-02-01 03:00:00'
DO BEGIN
    -- Copiar a historicos
    INSERT INTO logs_historicos (id_log_original, descripcion, tipo, fecha_original)
    SELECT id, descripcion, tipo, fecha
    FROM logs_actividad
    WHERE fecha < DATE_SUB(NOW(), INTERVAL 6 MONTH);

    -- Borrar los originales ya archivados
    DELETE FROM logs_actividad
    WHERE fecha < DATE_SUB(NOW(), INTERVAL 6 MONTH);
END;

-- =====================================================================================================================
-- 4.evt_deactivate_expired_promotions_hourly: Desactiva códigos de descuento que han expirado.

CREATE EVENT evt_deactivate_expired_promotions_hourly
ON SCHEDULE EVERY 1 HOUR
DO
    UPDATE codigos_descuento
    SET activo = FALSE
    WHERE fecha_expiracion < CURDATE()
      AND activo = TRUE;
-- =====================================================================================================================
-- 5.evt_recalculate_customer_loyalty_tiers_nightly: Recalcula el nivel de lealtad de los clientes cada noche.

CREATE EVENT evt_recalculate_customer_loyalty_tiers_nightly
ON SCHEDULE EVERY 1 DAY
STARTS (DATE(NOW()) + INTERVAL 1 DAY + INTERVAL 1 HOUR)
DO
    INSERT INTO lealtad_clientes (id_cliente, total_compras, nivel)
    SELECT
        v.id_clientes,
        SUM(v.total),
        CASE
            WHEN SUM(v.total) >= 5000 THEN 'Platino'
            WHEN SUM(v.total) >= 2000 THEN 'Oro'
            WHEN SUM(v.total) >= 500  THEN 'Plata'
            ELSE 'Bronce'
        END
    FROM ventas v
    WHERE v.estado = 'Entregado'
    GROUP BY v.id_clientes
    ON DUPLICATE KEY UPDATE
        total_compras = VALUES(total_compras),
        nivel = VALUES(nivel);

-- =====================================================================================================================
-- 6.evt_generate_reorder_list_daily: Crea una lista de productos que necesitan ser reabastecidos.

CREATE EVENT evt_generate_reorder_list_daily
ON SCHEDULE EVERY 1 DAY
STARTS (DATE(NOW()) + INTERVAL 1 DAY + INTERVAL 7 HOUR)
DO BEGIN
    -- Limpiar lista anterior
    DELETE FROM lista_reabastecimiento;

    -- Insertar productos con stock bajo (menos de 10 unidades)
    INSERT INTO lista_reabastecimiento (id_producto, stock_actual)
    SELECT id, stock
    FROM productos
    WHERE stock < 10
      AND activo = TRUE;
END;


-- =====================================================================================================================
-- 7.evt_rebuild_indexes_weekly: Reconstruye los índices de las tablas más usadas para optimizar el rendimiento.

CREATE EVENT evt_rebuild_indexes_weekly
ON SCHEDULE EVERY 1 WEEK
STARTS '2025-01-05 04:00:00'   -- domingo
DO BEGIN
    OPTIMIZE TABLE ventas;
    OPTIMIZE TABLE detalle_ventas;
    OPTIMIZE TABLE productos;
    OPTIMIZE TABLE clientes;
END;

-- =====================================================================================================================
-- 8.evt_suspend_inactive_accounts_quarterly: Desactiva cuentas de clientes sin actividad en más de un año.

CREATE EVENT evt_suspend_inactive_accounts_quarterly
ON SCHEDULE EVERY 3 MONTH
STARTS '2025-04-01 02:00:00'
DO
    UPDATE clientes
    SET activo = FALSE
    WHERE activo = TRUE
      AND (
          ultima_compra < DATE_SUB(NOW(), INTERVAL 1 YEAR)
          OR (ultima_compra IS NULL AND fecha_registro < DATE_SUB(NOW(), INTERVAL 1 YEAR))
      );

-- =====================================================================================================================
-- 9.evt_aggregate_daily_sales_data: Agrega los datos de ventas del día en una tabla de resumen para acelerar reportes.

CREATE EVENT evt_aggregate_daily_sales_data
ON SCHEDULE EVERY 1 DAY
STARTS (DATE(NOW()) + INTERVAL 1 DAY + INTERVAL 23 HOUR + INTERVAL 59 MINUTE)
DO
    INSERT INTO resumen_ventas_diario (fecha, total_ordenes, ingresos_totales)
    SELECT
        CURDATE(),
        COUNT(*),
        COALESCE(SUM(total), 0)
    FROM ventas
    WHERE DATE(fecha_venta) = CURDATE()
    ON DUPLICATE KEY UPDATE
        total_ordenes    = VALUES(total_ordenes),
        ingresos_totales = VALUES(ingresos_totales);

-- =====================================================================================================================
-- 10.evt_check_data_consistency_nightly: Busca inconsistencias en los datos (ej. ventas sin detalles).

CREATE EVENT evt_check_data_consistency_nightly
ON SCHEDULE EVERY 1 DAY
STARTS (DATE(NOW()) + INTERVAL 1 DAY + INTERVAL 1 HOUR + INTERVAL 30 MINUTE)
DO
    INSERT INTO logs_actividad (descripcion, tipo)
    SELECT
        CONCAT('Venta ID ', v.id, ' no tiene detalle de productos'),
        'INCONSISTENCIA'
    FROM ventas v
    LEFT JOIN detalle_ventas dv ON v.id = dv.id_venta
    WHERE dv.id IS NULL;

-- =====================================================================================================================
-- 11.evt_send_birthday_greetings_daily: Genera una lista de clientes que cumplen años para enviarles un cupón.

CREATE EVENT evt_send_birthday_greetings_daily
ON SCHEDULE EVERY 1 DAY
STARTS (DATE(NOW()) + INTERVAL 1 DAY + INTERVAL 8 HOUR)
DO
    INSERT INTO cupones_cumpleanos (id_cliente, cupon)
    SELECT
        id,
        CONCAT('CUMPLE-', id, '-', YEAR(CURDATE()))
    FROM clientes
    WHERE DAY(fecha_nacimiento)  = DAY(CURDATE())
      AND MONTH(fecha_nacimiento) = MONTH(CURDATE())
      AND activo = TRUE

-- =====================================================================================================================
-- 12.evt_update_product_rankings_hourly: Actualiza una tabla con el ranking de los productos más populares.

CREATE EVENT evt_update_product_rankings_hourly
ON SCHEDULE EVERY 1 HOUR
DO
    INSERT INTO ranking_productos (id_producto, unidades_vendidas, posicion)
    SELECT
        dv.id_producto,
        SUM(dv.cantidad),
        RANK() OVER (ORDER BY SUM(dv.cantidad) DESC)
    FROM detalle_ventas dv
    INNER JOIN ventas v ON dv.id_venta = v.id
    WHERE v.estado = 'Entregado'
    GROUP BY dv.id_producto
    ON DUPLICATE KEY UPDATE
        unidades_vendidas = VALUES(unidades_vendidas),
        posicion          = VALUES(posicion);

-- =====================================================================================================================
-- 13.evt_backup_critical_tables_daily: Realiza un backup lógico de las tablas más importantes cada noche.

CREATE EVENT evt_backup_critical_tables_daily
ON SCHEDULE EVERY 1 DAY
STARTS (DATE(NOW()) + INTERVAL 1 DAY + INTERVAL 3 HOUR)
DO BEGIN
    INSERT INTO backup_clientes (id, nombre, apellido, email, direccion_envio, fecha_registro)
    SELECT id, nombre, apellido, email, direccion_envio, fecha_registro
    FROM clientes;

    INSERT INTO backup_ventas (id, id_clientes, fecha_venta, estado, total)
    SELECT id, id_clientes, fecha_venta, estado, total
    FROM ventas;
END;

-- =====================================================================================================================
-- 14.evt_clear_abandoned_carts_daily: Vacía los carritos de compra abandonados hace más de 72 horas.

CREATE EVENT evt_clear_abandoned_carts_daily
ON SCHEDULE EVERY 1 DAY
STARTS (DATE(NOW()) + INTERVAL 1 DAY + INTERVAL 5 HOUR)
DO
    DELETE FROM carritos
    WHERE agregado_en < DATE_SUB(NOW(), INTERVAL 72 HOUR);

-- =====================================================================================================================
-- 15.evt_calculate_monthly_kpis: Calcula los KPIs (Key Performance Indicators) del mes y los guarda en una tabla.

CREATE EVENT evt_calculate_monthly_kpis
ON SCHEDULE EVERY 1 MONTH
STARTS '2025-02-01 06:00:00'
DO
    INSERT INTO kpis_mensuales (mes, total_ventas, ingresos, ticket_promedio, clientes_nuevos)
    SELECT
        DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 MONTH), '%Y-%m-01'),
        COUNT(*),
        COALESCE(SUM(total), 0),
        COALESCE(AVG(total), 0),
        (SELECT COUNT(*) FROM clientes
         WHERE YEAR(fecha_registro)  = YEAR(DATE_SUB(CURDATE(), INTERVAL 1 MONTH))
           AND MONTH(fecha_registro) = MONTH(DATE_SUB(CURDATE(), INTERVAL 1 MONTH)))
    FROM ventas
    WHERE estado = 'Entregado'
      AND YEAR(fecha_venta)  = YEAR(DATE_SUB(CURDATE(), INTERVAL 1 MONTH))
      AND MONTH(fecha_venta) = MONTH(DATE_SUB(CURDATE(), INTERVAL 1 MONTH))
    ON DUPLICATE KEY UPDATE
        total_ventas   = VALUES(total_ventas),
        ingresos       = VALUES(ingresos),
        ticket_promedio = VALUES(ticket_promedio),
        clientes_nuevos = VALUES(clientes_nuevos);

-- =====================================================================================================================
-- 16.evt_refresh_materialized_views_nightly: Actualiza las vistas materializadas (si se usan).

CREATE EVENT evt_refresh_materialized_views_nightly
ON SCHEDULE EVERY 1 DAY
STARTS (DATE(NOW()) + INTERVAL 1 DAY)
DO
    INSERT INTO resumen_ventas_diario (fecha, total_ordenes, ingresos_totales)
    SELECT
        DATE(fecha_venta),
        COUNT(*),
        SUM(total)
    FROM ventas
    WHERE DATE(fecha_venta) = DATE_SUB(CURDATE(), INTERVAL 1 DAY)
    ON DUPLICATE KEY UPDATE
        total_ordenes    = VALUES(total_ordenes),
        ingresos_totales = VALUES(ingresos_totales);

-- =====================================================================================================================
-- 17.evt_log_database_size_weekly: Registra el tamaño de la base de datos para monitorear su crecimiento.

CREATE EVENT evt_log_database_size_weekly
ON SCHEDULE EVERY 1 WEEK
DO
    INSERT INTO log_tamanio_bd (tamanio_mb)
    SELECT ROUND(SUM(data_length + index_length) / 1024 / 1024, 2)
    FROM information_schema.tables
    WHERE table_schema = DATABASE();


-- =====================================================================================================================
-- 18.evt_detect_fraudulent_activity_hourly: Busca patrones de actividad sospechosa (ej. múltiples pedidos fallidos).

CREATE EVENT evt_detect_fraudulent_activity_hourly
ON SCHEDULE EVERY 1 HOUR
DO
    INSERT INTO actividad_sospechosa (id_cliente, pedidos_fallidos)
    SELECT
        id_clientes,
        COUNT(*) AS pedidos_fallidos
    FROM ventas
    WHERE estado = 'Cancelado'
    AND fecha_venta >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
    GROUP BY id_clientes
    HAVING COUNT(*) > 3;

-- =====================================================================================================================
-- 19.evt_generate_supplier_performance_report_monthly: Crea un reporte mensual sobre el rendimiento de los proveedores.

CREATE EVENT evt_generate_supplier_performance_report_monthly
ON SCHEDULE EVERY 1 MONTH
STARTS '2025-02-01 07:00:00'
DO
    INSERT INTO reporte_proveedores (id_proveedor, mes, total_productos_activos, ingresos_generados)
    SELECT
        p.id_proveedor,
        DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 MONTH), '%Y-%m-01'),
        COUNT(DISTINCT p.id),
        COALESCE(SUM(dv.cantidad * dv.precio_unitario), 0)
    FROM productos p
    LEFT JOIN detalle_ventas dv ON p.id = dv.id_producto
    LEFT JOIN ventas v ON dv.id_venta = v.id
        AND v.estado = 'Entregado'
        AND YEAR(v.fecha_venta)  = YEAR(DATE_SUB(CURDATE(), INTERVAL 1 MONTH))
        AND MONTH(v.fecha_venta) = MONTH(DATE_SUB(CURDATE(), INTERVAL 1 MONTH))
    WHERE p.activo = TRUE
    GROUP BY p.id_proveedor;

-- =====================================================================================================================
-- 20.evt_purge_soft_deleted_records_weekly: Elimina permanentemente los registros marcados para borrado hace más de 30 días.

CREATE EVENT evt_purge_soft_deleted_records_weekly
ON SCHEDULE EVERY 1 WEEK
STARTS '2025-01-05 05:00:00'
DO BEGIN
    DELETE FROM productos
    WHERE eliminado_en IS NOT NULL
      AND eliminado_en < DATE_SUB(NOW(), INTERVAL 30 DAY);

    DELETE FROM clientes
    WHERE eliminado_en IS NOT NULL
      AND eliminado_en < DATE_SUB(NOW(), INTERVAL 30 DAY);
END;


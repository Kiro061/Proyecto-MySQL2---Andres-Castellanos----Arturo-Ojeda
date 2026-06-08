-- /////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- Consultas Avanzadas 
-- /////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- 1.Top 10 Productos Más Vendidos: Generar un ranking con los 10 productos que han generado más ingresos.

SELECT
    p.nombre AS producto,
    SUM(dv.cantidad * dv.precio_unitario) AS ingresos_totales,
    SUM(dv.cantidad) AS unidades_vendidas
FROM detalle_ventas dv
JOIN ventas v ON dv.id_venta = v.id
JOIN productos p ON dv.id_producto = p.id
WHERE v.estado = 'Entregado' 
GROUP BY p.id, p.nombre
ORDER BY ingresos_totales DESC
LIMIT 10;

-- 2.Productos con Bajas Ventas: Identificar los productos en el 10% inferior de ventas para considerar su descontinuación.

WITH ventas_por_producto AS (
    SELECT
        p.id, p.nombre,
        COALESCE(SUM(dv.cantidad * dv.precio_unitario), 0) AS ingresos
    FROM productos p
    LEFT JOIN detalle_ventas dv ON p.id = dv.id_producto
    LEFT JOIN ventas v ON dv.id_venta = v.id AND v.estado = 'Entregado'
    GROUP BY p.id, p.nombre
)
SELECT nombre, ingresos
FROM ventas_por_producto
WHERE ingresos <= (
    SELECT PERCENTILE_CONT(0.10) WITHIN GROUP (ORDER BY ingresos)
    FROM ventas_por_producto
)
ORDER BY ingresos ASC;

-- 3.Clientes VIP: Listar los 5 clientes con el mayor valor de vida (LTV), basado en su gasto total histórico.

SELECT
    CONCAT(c.nombre, ' ', c.apellido) AS cliente,
    c.email,
    COUNT(v.id) AS total_compras,
    SUM(v.total) AS ltv
FROM clientes c
JOIN ventas v ON c.id = v.id_clientes
WHERE v.estado = 'Entregado'
GROUP BY c.id, c.nombre, c.apellido, c.email
ORDER BY ltv DESC
LIMIT 5;

-- 4.Análisis de Ventas Mensuales: Mostrar las ventas totales agrupadas por mes y año.

SELECT
    YEAR(fecha_venta)  AS ano,
    MONTH(fecha_venta) AS mes,
    DATE_FORMAT(fecha_venta, '%M %Y') AS periodo,
    COUNT(id)        AS num_ventas,
    SUM(total)       AS ingresos_totales
FROM ventas
WHERE estado = 'Entregado'
GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)
ORDER BY año, mes;

-- 5.Crecimiento de Clientes: Calcular el número de nuevos clientes registrados por trimestre.

SELECT
    YEAR(fecha_registro)    AS ano,
    QUARTER(fecha_registro) AS trimestre,
    COUNT(id)              AS nuevos_clientes
FROM clientes
GROUP BY YEAR(fecha_registro), QUARTER(fecha_registro)
ORDER BY año, trimestre;

-- 6.Tasa de Compra Repetida: Determinar qué porcentaje de clientes ha realizado más de una compra.

SELECT
    COUNT(DISTINCT id_clientes)                          AS total_clientes,
    SUM(CASE WHEN compras > 1 THEN 1 ELSE 0 END)     AS clientes_repetidos,
    ROUND(
        SUM(CASE WHEN compras > 1 THEN 1 ELSE 0 END) * 100.0
        / COUNT(DISTINCT id_clientes), 2
    )                                                     AS tasa_repeticion_pct
FROM (
    -- Subconsulta: cuántas compras tiene cada cliente
    SELECT id_clientes, COUNT(id) AS compras
    FROM ventas
    WHERE estado = 'Entregado'
    GROUP BY id_clientes
) AS resumen;

-- 7.Productos Comprados Juntos Frecuentemente: Identificar pares de productos que a menudo se compran en la misma transacción.

SELECT
    p1.nombre  AS producto_a,
    p2.nombre  AS producto_b,
    COUNT(*) AS veces_juntos
FROM detalle_ventas dv1
JOIN detalle_ventas dv2
    ON dv1.id_venta = dv2.id_venta
    AND dv1.id_producto < dv2.id_producto  -- evita pares duplicados
JOIN productos p1 ON dv1.id_producto = p1.id
JOIN productos p2 ON dv2.id_producto = p2.id
GROUP BY p1.nombre, p2.nombre
HAVING veces_juntos >= 2  -- al menos 2 veces juntos
ORDER BY veces_juntos DESC
LIMIT 20;

-- 8.Rotación de Inventario: Calcular la tasa de rotación de stock para cada categoría de producto.

SELECT
    cat.nombre                          AS categoria,
    SUM(p.stock)                        AS stock_actual,
    COALESCE(SUM(dv.cantidad), 0)       AS unidades_vendidas,
    CASE
        WHEN SUM(p.stock) = 0 THEN NULL
        ELSE ROUND(SUM(dv.cantidad) / SUM(p.stock), 2)
    END                                 AS tasa_rotacion
FROM categoria cat
JOIN productos p   ON cat.id = p.id_categoria
LEFT JOIN detalle_ventas dv ON p.id = dv.id_producto
GROUP BY cat.id, cat.nombre
ORDER BY tasa_rotacion DESC;

-- 9. Productos que Necesitan Reabastecimiento: Listar productos cuyo stock actual está por debajo de su umbral mínimo.


ALTER TABLE productos ADD COLUMN stock_minimo INT DEFAULT 10;

SELECT
    p.sku,
    p.nombre,
    cat.nombre  AS categoria,
    p.stock     AS stock_actual,
    p.stock_minimo,
    (p.stock_minimo - p.stock) AS unidades_faltantes
FROM productos p
JOIN categoria cat ON p.id_categoria = cat.id
WHERE p.stock < p.stock_minimo
  AND p.activo = TRUE
ORDER BY unidades_faltantes DESC;

-- 10.Análisis de Carrito Abandonado (Simulado): Identificar clientes que agregaron productos pero no completaron una venta en un período determinado.



SELECT
    CONCAT(c.nombre, ' ', c.apellido) AS cliente,
    c.email,
    v.id        AS id_venta,
    v.fecha_venta,
    v.total     AS valor_pendiente,
    DATEDIFF(NOW(), v.fecha_venta) AS dias_abandonado
FROM ventas v
JOIN clientes c ON v.id_clientes = c.id
WHERE v.estado = 'Pendiente de Pago'
  AND DATEDIFF(NOW(), v.fecha_venta) > 3  -- más de 3 días
ORDER BY dias_abandonado DESC;

-- 11.Rendimiento de Proveedores: Clasificar a los proveedores según el volumen de ventas de sus productos.


SELECT
    pr.nombre                              AS proveedor,
    COUNT(DISTINCT p.id)                  AS num_productos,
    SUM(dv.cantidad)                       AS unidades_vendidas,
    SUM(dv.cantidad * dv.precio_unitario)  AS ingresos_totales
FROM proveedores pr
JOIN productos p    ON pr.id = p.id_proveedor
LEFT JOIN detalle_ventas dv ON p.id = dv.id_producto
LEFT JOIN ventas v          ON dv.id_venta = v.id AND v.estado = 'Entregado'
GROUP BY pr.id, pr.nombre
ORDER BY ingresos_totales DESC;

-- 12.Análisis Geográfico de Ventas: Agrupar las ventas por ciudad o región del cliente.

SELECT
    TRIM(SUBSTRING_INDEX(
        SUBSTRING_INDEX(c.direccion_envio, ',', 2), ',', -1
    ))                      AS ciudad,
    COUNT(v.id)             AS num_ventas,
    SUM(v.total)            AS ingresos_totales
FROM ventas v
JOIN clientes c ON v.id_clientes = c.id
WHERE v.estado = 'Entregado'
GROUP BY ciudad
ORDER BY ingresos_totales DESC;

-- 13.Ventas por Hora del Día: Determinar las horas pico de compras para optimizar campañas de marketing.


SELECT
    HOUR(fecha_venta)  AS hora,
    COUNT(id)          AS num_ventas,
    SUM(total)         AS ingresos
FROM ventas
WHERE estado = 'Entregado'
GROUP BY HOUR(fecha_venta)
ORDER BY num_ventas DESC;
-- 14.Impacto de Promociones: Comparar las ventas de un producto antes, durante y después de una campaña de descuento.


SELECT
    p.nombre AS producto,
    CASE
        WHEN v.fecha_venta < '2025-11-01'  THEN 'Antes'
        WHEN v.fecha_venta <= '2025-11-30' THEN 'Durante'
        ELSE 'Después'
    END      AS periodo,
    COUNT(dv.id)                          AS transacciones,
    SUM(dv.cantidad)                      AS unidades,
    SUM(dv.cantidad * dv.precio_unitario) AS ingresos
FROM detalle_ventas dv
JOIN ventas v    ON dv.id_venta    = v.id
JOIN productos p ON dv.id_producto = p.id
WHERE v.estado = 'Entregado'
  AND p.id = 1  
GROUP BY p.nombre, periodo
ORDER BY FIELD(periodo, 'Antes', 'Durante', 'Después');


-- 15.Análisis de Cohort: Analizar la retención de clientes mes a mes desde su primera compra.

WITH primera_compra AS (
    SELECT
        id_clientes,
        DATE_FORMAT(MIN(fecha_venta), '%Y-%m') AS cohorte
    FROM ventas WHERE estado = 'Entregado'
    GROUP BY id_clientes

actividad AS (
    SELECT
        pc.cohorte,
        TIMESTAMPDIFF(MONTH,
            STR_TO_DATE(CONCAT(pc.cohorte, '-01'), '%Y-%m-%d'),
            v.fecha_venta
        ) AS mes_relativo,
        v.id_clientes
    FROM ventas v
    JOIN primera_compra pc ON v.id_clientes = pc.id_clientes
    WHERE v.estado = 'Entregado'
)
SELECT
    cohorte,
    mes_relativo,
    COUNT(DISTINCT id_clientes) AS clientes_activos
FROM actividad
GROUP BY cohorte, mes_relativo
ORDER BY cohorte, mes_relativo;

-- 16.Margen de Beneficio por Producto: Calcular el margen de beneficio para cada producto (requiere añadir un campo costo a la tabla productos).

SELECT
    p.nombre,
    p.precio,
    p.costo,
    (p.precio - p.costo)                       AS ganancia_unitaria,
    ROUND((p.precio - p.costo) / p.precio * 100, 2) AS margen_pct,
    COALESCE(SUM(dv.cantidad), 0)              AS unidades_vendidas,
    COALESCE(SUM(dv.cantidad) * (p.precio - p.costo), 0) AS ganancia_total
FROM productos p
LEFT JOIN detalle_ventas dv ON p.id = dv.id_producto
LEFT JOIN ventas v          ON dv.id_venta = v.id AND v.estado = 'Entregado'
GROUP BY p.id, p.nombre, p.precio, p.costo
ORDER BY margen_pct DESC;

-- 17.Tiempo Promedio Entre Compras: Calcular el tiempo medio que tarda un cliente en volver a comprar.


WITH compras_ordenadas AS (
    SELECT
        id_clientes,
        fecha_venta,
        LAG(fecha_venta) OVER (
            PARTITION BY id_clientes  -- reinicia por cliente
            ORDER BY fecha_venta
        ) AS compra_anterior
    FROM ventas
    WHERE estado = 'Entregado'
),
diferencias AS (
    SELECT
        id_clientes,
        DATEDIFF(fecha_venta, compra_anterior) AS dias_entre_compras
    FROM compras_ordenadas
    WHERE compra_anterior IS NOT NULL  -- excluye la primera compra
)
SELECT
    CONCAT(c.nombre, ' ', c.apellido) AS cliente,
    ROUND(AVG(d.dias_entre_compras), 1) AS dias_promedio_entre_compras
FROM diferencias d
JOIN clientes c ON d.id_clientes = c.id
GROUP BY c.id, c.nombre, c.apellido
ORDER BY dias_promedio_entre_compras ASC;

-- 18.Productos Más Vistos vs. Comprados: Comparar los productos más visitados con los más comprados.
SELECT
    p.nombre,
    COUNT(DISTINCT vp.id)  AS total_visitas,
    COALESCE(SUM(dv.cantidad), 0) AS unidades_vendidas,
    CASE
        WHEN COUNT(DISTINCT vp.id) = 0 THEN 0
        ELSE ROUND(SUM(dv.cantidad) / COUNT(DISTINCT vp.id) * 100, 2)
    END                      AS tasa_conversion_pct
FROM productos p
LEFT JOIN visitas_producto vp ON p.id = vp.id_producto
LEFT JOIN detalle_ventas dv   ON p.id = dv.id_producto
LEFT JOIN ventas v            ON dv.id_venta = v.id AND v.estado = 'Entregado'
GROUP BY p.id, p.nombre
ORDER BY total_visitas DESC;

-- 19.Segmentación de Clientes (RFM): Clasificar a los clientes en segmentos (Recencia, Frecuencia, Monetario).

WITH rfm_base AS (
    SELECT
        c.id,
        CONCAT(c.nombre, ' ', c.apellido) AS cliente,
        DATEDIFF(NOW(), MAX(v.fecha_venta)) AS recencia_dias,
        COUNT(v.id)                         AS frecuencia,
        SUM(v.total)                        AS monetario
    FROM clientes c
    JOIN ventas v ON c.id = v.id_clientes
    WHERE v.estado = 'Entregado'
    GROUP BY c.id, c.nombre, c.apellido
),
-- Puntuamos 1-3 cada dimensión con NTILE(3)
rfm_scores AS (
    SELECT *,
        -- Recencia: menos días = mejor = score 3
        4 - NTILE(3) OVER (ORDER BY recencia_dias ASC)  AS r_score,
        NTILE(3) OVER (ORDER BY frecuencia  ASC)         AS f_score,
        NTILE(3) OVER (ORDER BY monetario   ASC)         AS m_score
    FROM rfm_base
)
SELECT
    cliente, recencia_dias, frecuencia, monetario,
    r_score, f_score, m_score,
    (r_score + f_score + m_score) AS rfm_total,
    CASE
        WHEN (r_score + f_score + m_score) >= 8 THEN 'Campeones'
        WHEN (r_score + f_score + m_score) >= 6 THEN 'Clientes leales'
        WHEN (r_score + f_score + m_score) >= 4 THEN 'En riesgo'
        ELSE 'Perdidos'
    END AS segmento
FROM rfm_scores
ORDER BY rfm_total DESC;

-- 20.Predicción de Demanda Simple: Utilizar datos de ventas pasadas para proyectar las ventas del próximo mes para una categoría específica.

-- Proyectamos el próximo mes como promedio de los últimos 3 meses por categoría
-- Cambia 'Electrónica' por la categoría que te interese
WITH ventas_recientes AS (
    SELECT
        cat.nombre AS categoria,
        DATE_FORMAT(v.fecha_venta, '%Y-%m') AS mes,
        SUM(dv.cantidad * dv.precio_unitario) AS ingresos_mes
    FROM detalle_ventas dv
    JOIN ventas v    ON dv.id_venta    = v.id
    JOIN productos p ON dv.id_producto = p.id
    JOIN categoria cat ON p.id_categoria = cat.id
    WHERE v.estado = 'Entregado'
      AND v.fecha_venta >= DATE_SUB(NOW(), INTERVAL 3 MONTH)
    GROUP BY cat.nombre, mes
)
SELECT
    categoria,
    ROUND(AVG(ingresos_mes), 2)  AS promedio_3_meses,
    ROUND(AVG(ingresos_mes), 2)  AS proyeccion_proximo_mes,
    ROUND(AVG(ingresos_mes) * 0.05, 2) AS margen_error_5pct
FROM ventas_recientes
GROUP BY categoria
ORDER BY proyeccion_proximo_mes DESC;
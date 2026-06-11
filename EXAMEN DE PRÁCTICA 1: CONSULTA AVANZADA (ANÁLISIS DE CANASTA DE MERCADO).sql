-- ============================================================
-- EJERCICIO 1: ANÁLISIS DE CANASTA DE MERCADO
-- Tablas usadas: detalle_ventas, productos
-- ============================================================

SELECT
    p1.nombre   AS producto_a,
    p2.nombre   AS producto_b,
    COUNT(*)    AS veces_comprados_juntos

FROM detalle_ventas dv1

    -- JOIN de detalle_ventas consigo misma usando el alias dv2.
    -- La condición dv1.id_venta = dv2.id_venta une las filas
    -- que pertenecen a la misma venta (misma "bolsa de compras").
    --
    -- La segunda condición dv1.id_producto < dv2.id_producto
    -- es el truco clave para evitar duplicados:
    --   · Descarta el par (A, A) — un producto consigo mismo.
    --   · Garantiza que el par (A,B) y el par (B,A) se traten
    --     como uno solo, generando solo la versión donde el id
    --     del primer producto es estrictamente MENOR.
    JOIN detalle_ventas dv2
        ON  dv1.id_venta    = dv2.id_venta
        AND dv1.id_producto < dv2.id_producto

    -- Obtenemos el nombre del PRIMER producto del par.
    JOIN productos p1
        ON dv1.id_producto = p1.id

    -- Obtenemos el nombre del SEGUNDO producto del par.
    JOIN productos p2
        ON dv2.id_producto = p2.id

-- Agrupamos por cada combinación única de productos para
-- poder contar cuántas ventas distintas contienen ese par.
GROUP BY
    p1.id,
    p2.id,
    p1.nombre,
    p2.nombre

-- El par más frecuentemente comprado juntos aparece primero.
ORDER BY
    veces_comprados_juntos DESC;
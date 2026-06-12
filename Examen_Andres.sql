-- Consulta Avanzada - Segmentación de Clientes RFM
-- Esta consulta segmenta a los clientes en función de su Recencia, Frecuencia y Monetario (RFM) para identificar grupos como "Campeones", "Clientes leales", "En riesgo" y "Perdidos".
WITH rfm_base AS (
    SELECT
        c.id,
        CONCAT(c.nombre, ' ', c.apellido) AS cliente,
        DATEDIFF(NOW(), MAX(v.fecha_venta)) AS recencia_dias,
        COUNT(v.id)                         AS frecuencia,
        SUM(v.total)                        AS monetario
    -- Solo consideramos ventas entregadas para el análisis RFM
    FROM clientes c
    JOIN ventas v ON c.id = v.id_clientes
    WHERE v.estado = 'Entregado'
      AND v.fecha_venta IS NOT NULL
      AND v.total > 0
    GROUP BY c.id, c.nombre, c.apellido
),
-- Puntuamos 1-4 cada dimensión con NTILE(4)
rfm_scores AS (
    SELECT *,
        -- Recencia: menos días = mejor = score 4
        5 - NTILE(4) OVER (ORDER BY recencia_dias ASC)  AS r_score,
        NTILE(4) OVER (ORDER BY frecuencia  ASC)         AS f_score,
        NTILE(4) OVER (ORDER BY monetario   ASC)         AS m_score
    FROM rfm_base
)
-- Segmentamos según la suma de los scores RFM
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
-- Ordenamos por el total de RFM para ver primero los mejores clientes
FROM rfm_scores
ORDER BY rfm_total DESC;

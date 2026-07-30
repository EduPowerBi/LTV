WITH Estatisticas AS
(
    SELECT
        ltv_historico,

        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY ltv_historico) OVER() AS Q1,
        PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY ltv_historico) OVER() AS Mediana,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY ltv_historico) OVER() AS Q3

    FROM dm_marketing.indicadores_clientes
)

SELECT
    MIN(ltv_historico) AS Menor_LTV,
    MAX(ltv_historico) AS Maior_LTV,
    AVG(ltv_historico) AS Media_LTV,
    MIN(Q1) AS Q1,
    MIN(Mediana) AS Mediana,
    MIN(Q3) AS Q3
FROM Estatisticas;
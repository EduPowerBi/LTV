

CREATE TABLE dm_clientes.resumo_clientes
(
    cliente_id                 INT             NOT NULL PRIMARY KEY,
    pais                       VARCHAR(100),
    primeira_compra            DATE,
    ultima_compra              DATE,
    quantidade_pedidos         INT,
    quantidade_produtos        INT,
    valor_total_gasto          DECIMAL(18,2),
    ticket_medio               DECIMAL(18,2),
    tempo_relacionamento_dias  INT
);
GO

--

INSERT INTO dm_clientes.resumo_clientes
(
    cliente_id,
    pais,
    primeira_compra,
    ultima_compra,
    quantidade_pedidos,
    quantidade_produtos,
    valor_total_gasto,
    ticket_medio,
    tempo_relacionamento_dias
)

SELECT
    dc.cliente_id,
    dc.pais,

    MIN(dt.data) AS primeira_compra,
    MAX(dt.data) AS ultima_compra,

    COUNT(DISTINCT fv.numero_fatura) AS quantidade_pedidos,

    SUM(fv.quantidade) AS quantidade_produtos,
    SUM(fv.valor_total) AS valor_total_gasto,
    SUM(fv.valor_total) / COUNT(DISTINCT fv.numero_fatura) AS ticket_medio,

    DATEDIFF(DAY,
             MIN(dt.data),
             MAX(dt.data)) AS tempo_relacionamento_dias

FROM gold.fact_vendas fv

    INNER JOIN gold.dim_cliente dc
        ON fv.cliente_key = dc.cliente_key

    INNER JOIN gold.dim_tempo dt
        ON fv.tempo_key = dt.tempo_key

GROUP BY
    dc.cliente_id,
    dc.pais;
GO


CREATE TABLE dm_marketing.indicadores_clientes
(
    ----------------------------------------------------------------
    -- Identificação do Cliente
    ----------------------------------------------------------------
    cliente_id                  INT             NOT NULL PRIMARY KEY,
    cliente_key                 INT             NOT NULL,

    ----------------------------------------------------------------
    -- Dados do Cliente
    ----------------------------------------------------------------
    pais                        VARCHAR(100)    NOT NULL,

    ----------------------------------------------------------------
    -- Relacionamento
    ----------------------------------------------------------------
    primeira_compra             DATE            NOT NULL,
    ultima_compra               DATE            NOT NULL,
    tempo_relacionamento_dias   INT             NOT NULL,
    dias_desde_ultima_compra    INT             NOT NULL,

    ----------------------------------------------------------------
    -- Indicadores de Compras
    ----------------------------------------------------------------
    quantidade_pedidos          INT             NOT NULL,
    quantidade_produtos         INT             NOT NULL,

    ----------------------------------------------------------------
    -- Indicadores Financeiros
    ----------------------------------------------------------------
    valor_total_gasto           DECIMAL(18,2)   NOT NULL,
    ticket_medio                DECIMAL(18,2)   NOT NULL,
    valor_medio_por_produto     DECIMAL(18,2)   NOT NULL,

    ----------------------------------------------------------------
    -- Indicadores de Marketing
    ----------------------------------------------------------------
    frequencia_compra           DECIMAL(18,2)   NULL,
    ltv_historico               DECIMAL(18,2)   NULL,
    ltv_estimado                DECIMAL(18,2)   NULL,
    categoria_ltv               VARCHAR(100)    NOT NULL
);
GO


WITH cte_indicadores AS
(
    SELECT

        dc.cliente_key,

        rc.cliente_id,
        rc.pais,
        rc.primeira_compra,
        rc.ultima_compra,
        rc.tempo_relacionamento_dias,

        ------------------------------------------------------------
        -- Dias desde a última compra
        ------------------------------------------------------------
        DATEDIFF
        (
            DAY,
            rc.ultima_compra,
            (
                SELECT MAX(ultima_compra)
                FROM dm_clientes.resumo_clientes
            )
        ) AS dias_desde_ultima_compra,

        rc.quantidade_pedidos,
        rc.quantidade_produtos,
        rc.valor_total_gasto,
        rc.ticket_medio,

        ------------------------------------------------------------
        -- Valor médio gasto por produto
        ------------------------------------------------------------
        CAST
        (
            rc.valor_total_gasto /
            NULLIF(rc.quantidade_produtos,0)
        AS DECIMAL(18,2))
        AS valor_medio_por_produto,

        ------------------------------------------------------------
        -- Tempo de relacionamento em anos
        ------------------------------------------------------------
        CAST
        (
            rc.tempo_relacionamento_dias / 365.25
        AS DECIMAL(18,4))
        AS tempo_relacionamento_anos,

        ------------------------------------------------------------
        -- Frequência anual de compra
        ------------------------------------------------------------
        CASE

            WHEN rc.tempo_relacionamento_dias < 30
                THEN NULL

            ELSE
                CAST
                (
                    rc.quantidade_pedidos * 365.25 /
                    rc.tempo_relacionamento_dias
                AS DECIMAL(18,2))

        END AS frequencia_compra

    FROM dm_clientes.resumo_clientes rc

        INNER JOIN gold.dim_cliente dc
            ON rc.cliente_id = dc.cliente_id
),

cte_ltv AS
(
    SELECT
        *,

        ------------------------------------------------------------
        -- LTV Histórico
        ------------------------------------------------------------
        CAST
        (
            ticket_medio *
            frequencia_compra *
            tempo_relacionamento_anos
        AS DECIMAL(18,2))
        AS ltv_historico

    FROM cte_indicadores
)

INSERT INTO dm_marketing.indicadores_clientes
(
    cliente_key,
    cliente_id,
    pais,
    primeira_compra,
    ultima_compra,
    tempo_relacionamento_dias,
    dias_desde_ultima_compra,
    quantidade_pedidos,
    quantidade_produtos,
    valor_total_gasto,
    ticket_medio,
    valor_medio_por_produto,
    frequencia_compra,
    ltv_historico,
    categoria_ltv,
    ltv_estimado
)

SELECT

    cliente_key,
    cliente_id,
    pais,
    primeira_compra,
    ultima_compra,
    tempo_relacionamento_dias,
    dias_desde_ultima_compra,
    quantidade_pedidos,
    quantidade_produtos,
    valor_total_gasto,
    ticket_medio,
    valor_medio_por_produto,
    frequencia_compra,

    ltv_historico,

    ------------------------------------------------------------
    -- Classificação do LTV
    ------------------------------------------------------------
    CASE
        WHEN ltv_historico <= 689.43 THEN '1 - Bronze'
        WHEN ltv_historico <= 1340.16 THEN '2 - Prata'
        WHEN ltv_historico <= 2608.80 THEN '3 - Ouro'
        ELSE '4 - Platinum'
    END,

    NULL

FROM cte_ltv;
GO
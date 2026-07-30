-- Data Mart de Vendas
CREATE SCHEMA dm_vendas;
GO

-- Data Mart de Clientes
CREATE SCHEMA dm_clientes;
GO

-- Data Mart de Marketing
CREATE SCHEMA dm_marketing;
GO

-- Data Mart de Produtos
CREATE SCHEMA dm_produtos;
GO

-- Data Mart Financeiro
CREATE SCHEMA dm_financeiro;
GO

----------------------------------

CREATE TABLE dm_vendas.fato_vendas
(
    id_venda            INT             NOT NULL PRIMARY KEY,

    -- Tempo
    data_venda          DATE            NOT NULL,
    ano                 INT             NOT NULL,
    mes                 INT             NOT NULL,
    nome_mes            VARCHAR(20)     NOT NULL,

    -- Cliente
    id_cliente          INT             NOT NULL,
    pais                VARCHAR(100)    NULL,

    -- Produto
    produto_id      VARCHAR(30)     NOT NULL,
    nome_produto   VARCHAR(255)    NOT NULL,

    -- Venda
    quantidade          INT             NOT NULL,
    preco_unitario      DECIMAL(18,2)   NOT NULL,
    valor_total         DECIMAL(18,2)   NOT NULL
);
GO

---

INSERT INTO dm_vendas.fato_vendas
(
    -- Identificação da Venda
    id_venda,

    -- Tempo
    data_venda,
    ano,
    mes,
    nome_mes,

    -- Cliente
    id_cliente,
    pais,

    -- Produto
    produto_id,
    nome_produto,

    -- Venda
    quantidade,
    preco_unitario,
    valor_total
)

SELECT

    -- Identificação da Venda
    fv.venda_key,

    -- Tempo
    dt.data,
    dt.ano,
    dt.mes,
    dt.nome_mes,

    -- Cliente
    dc.cliente_id,
    dc.pais,

    -- Produto
    dp.produto_id,
    dp.nome_produto,

    -- Venda
    fv.quantidade,
    fv.preco_unitario,
    fv.valor_total

FROM gold.fact_vendas AS fv

INNER JOIN gold.dim_cliente AS dc
    ON fv.cliente_key = dc.cliente_key

INNER JOIN gold.dim_produto AS dp
    ON fv.produto_key = dp.produto_key

INNER JOIN gold.dim_tempo AS dt
    ON fv.tempo_key = dt.tempo_key;
GO





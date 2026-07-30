CREATE SCHEMA gold;
GO


CREATE TABLE gold.dim_cliente
(
    customer_key INT IDENTITY(1,1) NOT NULL,
    customer_id  INT NOT NULL,
    country      VARCHAR(100) NOT NULL,

    CONSTRAINT pk_gold_dim_cliente
        PRIMARY KEY (customer_key),

    CONSTRAINT uq_gold_dim_cliente
        UNIQUE (customer_id)
);
GO


INSERT INTO gold.dim_cliente
(
    customer_id,
    country
)
SELECT
    customer_id,
    country
FROM silver.clientes;
GO


--------------------------------------------------------

CREATE TABLE gold.dim_produto
(
    product_key  INT IDENTITY(1,1) NOT NULL,
    product_id   VARCHAR(20) NOT NULL,
    product_name VARCHAR(255) NOT NULL,

    CONSTRAINT pk_dim_produto
        PRIMARY KEY (product_key),

    CONSTRAINT uq_dim_produto
        UNIQUE (product_id)
);
GO


INSERT INTO gold.dim_produto
(
    product_id,
    product_name
)
SELECT
    product_id,
    product_name
FROM silver.produtos;
GO




---------------------------------------------------------------

CREATE TABLE gold.fact_vendas
(
    venda_key          INT IDENTITY(1,1) NOT NULL,
    numero_fatura       VARCHAR(20) NOT NULL,
    cliente_key        INT NOT NULL,
    produto_key        INT NOT NULL,
    data_key           INT NOT NULL,
    quantidade         INT NOT NULL,
    preco_unitario     DECIMAL(10,2) NOT NULL,
    valor_total        DECIMAL(12,2) NOT NULL,

    CONSTRAINT pk_fact_vendas
        PRIMARY KEY (venda_key),

    CONSTRAINT fk_fact_cliente
        FOREIGN KEY (cliente_key)
        REFERENCES gold.dim_cliente(customer_key),

    CONSTRAINT fk_fact_produto
        FOREIGN KEY (produto_key)
        REFERENCES gold.dim_produto(product_key),

    CONSTRAINT fk_fact_tempo
        FOREIGN KEY (data_key)
        REFERENCES gold.dim_tempo(date_key)
);
GO


INSERT INTO gold.fact_vendas
(
    numero_fatura,
    cliente_key,
    produto_key,
    data_key,
    quantidade,
    preco_unitario,
    valor_total
)
SELECT
    v.Numero_Fatura,
    dc.customer_key,
    dp.product_key,
    CONVERT(INT, CONVERT(VARCHAR(8), v.Data_Compra, 112)) AS data_key,
    v.quantidade,
    v.preco_unitario,
    v.Valor_Venda
FROM silver.vendas AS v

INNER JOIN gold.dim_cliente AS dc
    ON v.ID_Cliente = dc.customer_id

INNER JOIN gold.dim_produto AS dp
    ON v.Codigo_Produto = dp.product_id

WHERE v.quantidade > 0
  AND v.preco_unitario > 0
  AND v.Numero_Fatura NOT LIKE 'C%'
  AND v.ID_Cliente IS NOT NULL
  AND v.Codigo_Produto IS NOT NULL;
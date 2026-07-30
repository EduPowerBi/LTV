/*
====================================================
Projeto........: Customer Analytics
Camada.........: Silver
Tabela.........: silver.vendas

Objetivo:
Armazenar os dados tratados
Remover duplicidades
Corrigir tipos de dados
Remover registros inválidos
Tratar valores nulos
Criar colunas derivadas (ex.: Receita = Quantity × UnitPrice)
Padronizar nomes de colunas
Separar entidades (clientes, produtos, vendas), se fizer sentido


Origem:
https://archive.ics.uci.edu/dataset/502/online+retail+ii


Data:
Julho/2026
====================================================
*/
CREATE SCHEMA silver;


CREATE TABLE silver.vendas
(
    Numero_Fatura      VARCHAR(20)     NOT NULL,
    Codigo_Produto     VARCHAR(20)     NOT NULL,
    Descricao_Produto  VARCHAR(255)    NOT NULL,
    Quantidade         INT             NOT NULL,
    Data_Compra        DATETIME        NOT NULL,
    Preco_Unitario     DECIMAL(10,2)   NOT NULL,
    Valor_Venda        DECIMAL(18,2)   NOT NULL,
    ID_Cliente         INT             NOT NULL,
    Pais               VARCHAR(100)    NOT NULL,
    Ano                SMALLINT        NOT NULL,
    Mes                TINYINT         NOT NULL,
    Dia                TINYINT         NOT NULL,
    Trimestre          TINYINT         NOT NULL,
    AnoMes             CHAR(6)         NOT NULL
);

-------


INSERT INTO silver.vendas
(
    Numero_Fatura,
    Codigo_Produto,
    Descricao_Produto,
    Quantidade,
    Data_Compra,
    Preco_Unitario,
    Valor_Venda,
    ID_Cliente,
    Pais,
    Ano,
    Mes,
    Dia,
    Trimestre,
    AnoMes
)
SELECT
    Invoice,
    StockCode,
    LTRIM(RTRIM(Description)),
    Quantity,
    InvoiceDate,
    Price,
    Quantity * Price,--tratando a informacao p gerar o valor da compra
    [Customer ID],
    Country,
    YEAR(InvoiceDate),
    MONTH(InvoiceDate),
    DAY(InvoiceDate),
    DATEPART(QUARTER, InvoiceDate),
    FORMAT(InvoiceDate,'yyyyMM')
       
FROM bronze.online_retail

WHERE [Customer ID] IS NOT NULL
  AND Quantity > 0
  AND Price > 0
  AND Description IS NOT NULL
  AND Invoice NOT LIKE 'C%';



/*---------------------------------------------
Projeto........: Customer Analytics
Camada.........: Silver
Tabela.........: silver.produtos
---------------------------------------------*/

CREATE TABLE silver.produtos (
    product_id VARCHAR(20),
    product_name VARCHAR(255)

    CONSTRAINT pk_silver_produtos PRIMARY KEY (product_id)

)


WITH produtos AS
(
    SELECT
        TRIM(StockCode) AS product_id,
        UPPER(TRIM([Description])) AS product_name,
        ROW_NUMBER() OVER
        (
            PARTITION BY StockCode
            ORDER BY InvoiceDate
        ) AS rn
    FROM OnlineRetail
    WHERE StockCode IS NOT NULL
      AND Description IS NOT NULL
)
INSERT INTO silver.produtos
(
    product_id,
    product_name
)
SELECT
    product_id,
    product_name
FROM produtos
WHERE rn = 1;




/*---------------------------------------------
Projeto........: Customer Analytics
Camada.........: Silver
Tabela.........: silver.clientes
---------------------------------------------*/

CREATE TABLE silver.clientes
(
    customer_id INT NOT NULL,
    country     VARCHAR(100) NOT NULL,

    CONSTRAINT pk_silver_clientes
        PRIMARY KEY (customer_id)
);
GO

WITH clientes AS
(
    SELECT
        [Customer ID] AS customer_id,
        TRIM(Country) AS country,
        ROW_NUMBER() OVER
        (
            PARTITION BY [Customer ID]
            ORDER BY InvoiceDate
        ) AS rn
    FROM bronze.online_retail
    WHERE Country IS NOT NULL
      AND [Customer ID] IS NOT NULL
)
INSERT INTO silver.clientes
(
    customer_id,
    country
)
SELECT
    customer_id,
    country
FROM clientes
WHERE rn = 1;
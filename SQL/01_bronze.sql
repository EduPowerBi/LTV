/*
====================================================
Projeto........: Customer Analytics
Camada.........: Bronze
Tabela.........: bronze.online_retail

Objetivo:
Armazenar os dados originais do dataset
Online Retail II sem qualquer transformação.

Origem:
https://archive.ics.uci.edu/dataset/502/online+retail+ii



Data:
Julho/2026
====================================================
*/

CREATE SCHEMA bronze;
GO

CREATE TABLE bronze.online_retail
(
    Invoice         VARCHAR(20)     NOT NULL,
    StockCode       VARCHAR(20)     NOT NULL,
    Description     VARCHAR(255)    NULL,
    Quantity        INT             NOT NULL,
    InvoiceDate     DATETIME        NOT NULL,
    Price           DECIMAL(10,2)   NOT NULL,
    [Customer ID]      INT             NULL,
    Country         VARCHAR(100)    NOT NULL
);
GO

---

INSERT INTO bronze.online_retail
(
    Invoice,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    Price,
    [Customer ID],
    Country
)
SELECT
    Invoice,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    Price,
    [Customer ID],
    Country
FROM OnlineRetail;
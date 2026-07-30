/*==============================================================
  DIMENSÃO TEMPO
==============================================================*/

CREATE TABLE gold.dim_tempo
(
   
    date_key            INT             NOT NULL PRIMARY KEY,
    data                DATE            NOT NULL,
    ano                 SMALLINT        NOT NULL,
    semestre            TINYINT         NOT NULL,
    semestre_desc       VARCHAR(20)     NOT NULL,
    trimestre           TINYINT         NOT NULL,
    trimestre_desc      VARCHAR(20)     NOT NULL,
    numero_semana       TINYINT         NOT NULL,
    mes                 TINYINT         NOT NULL,
    nome_mes            VARCHAR(20)     NOT NULL,
    nome_mes_abrev      VARCHAR(3)      NOT NULL,
    ano_mes             CHAR(7)         NOT NULL,   -- Ex.: 2010-01
    ano_mes_num         INT             NOT NULL,   -- Ex.: 201001
    nome_mes_ano        VARCHAR(8)      NOT NULL,   -- Ex.: Jan/2010
    dia                 TINYINT         NOT NULL,
    dia_semana          TINYINT         NOT NULL,
    nome_dia            VARCHAR(20)     NOT NULL,
    nome_dia_abrev      VARCHAR(3)      NOT NULL,
    fim_de_semana       CHAR(1)         NOT NULL
);
GO






/*==============================================================
  DIMENSÃO TEMPO
==============================================================*/

DECLARE @DataInicial DATE;
DECLARE @DataFinal DATE;

SELECT
    @DataInicial = MIN(CAST(Data_Compra AS DATE)),
    @DataFinal   = MAX(CAST(Data_Compra AS DATE))
FROM silver.vendas;

WITH calendario AS
(
    SELECT @DataInicial AS data

    UNION ALL

    SELECT DATEADD(DAY,1,data)
    FROM calendario
    WHERE data < @DataFinal
)

INSERT INTO gold.dim_tempo
(
    ----------------------------------------------------------------
    -- Chave
    ----------------------------------------------------------------
    date_key,

    ----------------------------------------------------------------
    -- Data
    ----------------------------------------------------------------
    data,

    ----------------------------------------------------------------
    -- Ano
    ----------------------------------------------------------------
    ano,

    ----------------------------------------------------------------
    -- Semestre
    ----------------------------------------------------------------
    semestre,
    semestre_desc,

    ----------------------------------------------------------------
    -- Trimestre
    ----------------------------------------------------------------
    trimestre,
    trimestre_desc,

    ----------------------------------------------------------------
    -- Semana
    ----------------------------------------------------------------
    numero_semana,

    ----------------------------------------------------------------
    -- Mês
    ----------------------------------------------------------------
    mes,
    nome_mes,
    nome_mes_abrev,

    ----------------------------------------------------------------
    -- Ano-Mês
    ----------------------------------------------------------------
    ano_mes,
    ano_mes_num,
    nome_mes_ano,

    ----------------------------------------------------------------
    -- Dia
    ----------------------------------------------------------------
    dia,
    dia_semana,
    nome_dia,
    nome_dia_abrev,

    ----------------------------------------------------------------
    -- Indicadores
    ----------------------------------------------------------------
    fim_de_semana
)

SELECT

    ----------------------------------------------------------------
    -- Chave da Data
    ----------------------------------------------------------------
    CONVERT(INT, CONVERT(VARCHAR(8), data, 112)) AS date_key,

    ----------------------------------------------------------------
    -- Data
    ----------------------------------------------------------------
    data,

    ----------------------------------------------------------------
    -- Ano
    ----------------------------------------------------------------
    YEAR(data) AS ano,

    ----------------------------------------------------------------
    -- Semestre
    ----------------------------------------------------------------
    CASE
        WHEN MONTH(data) <= 6 THEN 1
        ELSE 2
    END AS semestre,

    CASE
        WHEN MONTH(data) <= 6
            THEN '1º Semestre'
        ELSE '2º Semestre'
    END AS semestre_desc,

    ----------------------------------------------------------------
    -- Trimestre
    ----------------------------------------------------------------
    DATEPART(QUARTER,data) AS trimestre,

    CONCAT(
        DATEPART(QUARTER,data),
        'º Trimestre'
    ) AS trimestre_desc,

    ----------------------------------------------------------------
    -- Semana
    ----------------------------------------------------------------
    DATEPART(ISO_WEEK,data) AS numero_semana,

    ----------------------------------------------------------------
    -- Mês
    ----------------------------------------------------------------
    MONTH(data) AS mes,

    DATENAME(MONTH,data) AS nome_mes,

    LEFT(DATENAME(MONTH,data),3) AS nome_mes_abrev,

    ----------------------------------------------------------------
    -- Ano-Mês
    ----------------------------------------------------------------
    CONCAT
    (
        YEAR(data),
        '-',
        RIGHT('00' + CAST(MONTH(data) AS VARCHAR(2)),2)
    ) AS ano_mes,

    YEAR(data) * 100 + MONTH(data) AS ano_mes_num,

    CONCAT
    (
        LEFT(DATENAME(MONTH,data),3),
        '/',
        YEAR(data)
    ) AS nome_mes_ano,

    ----------------------------------------------------------------
    -- Dia
    ----------------------------------------------------------------
    DAY(data) AS dia,

    DATEPART(WEEKDAY,data) AS dia_semana,

    DATENAME(WEEKDAY,data) AS nome_dia,

    LEFT(DATENAME(WEEKDAY,data),3) AS nome_dia_abrev,

    ----------------------------------------------------------------
    -- Fim de Semana
    ----------------------------------------------------------------
    CASE
        WHEN DATEPART(WEEKDAY,data) IN (1,7)
            THEN 'S'
        ELSE 'N'
    END AS fim_de_semana

FROM calendario

OPTION (MAXRECURSION 1000);
GO
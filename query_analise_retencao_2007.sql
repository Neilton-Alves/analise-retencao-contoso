-- ====================================================================
-- PROJETO: Análise de Retenção Cronológica (Cohort) - Contoso 2007
-- OBJETIVO: Identificar o comportamento de recompra mensal por calendário
-- ====================================================================

-- --------------------------------------------------------------------
-- PASSO 1: Descobrir o Nascimento Real de Cada Cliente (1ª Compra)
-- --------------------------------------------------------------------
SELECT 
    CustomerKey,
    MIN(CAST(DateKey AS DATE)) AS DataPrimeiraCompra
FROM FactOnlineSales
GROUP BY CustomerKey
HAVING MIN(CAST(DateKey AS DATE)) >= '2007-01-01' 
   AND MIN(CAST(DateKey AS DATE)) <= '2007-12-31';


-- --------------------------------------------------------------------
-- PASSO 2: Calcular a Jornada (Garante que não há dados retroativos)
-- --------------------------------------------------------------------
WITH NascimentoClientes AS (
    SELECT 
        CustomerKey,
        MIN(CAST(DateKey AS DATE)) AS DataPrimeiraCompra
    FROM FactOnlineSales
    GROUP BY CustomerKey
    HAVING MIN(CAST(DateKey AS DATE)) >= '2007-01-01' 
       AND MIN(CAST(DateKey AS DATE)) <= '2007-12-31'
)
SELECT 
    f.CustomerKey,
    FORMAT(DATEADD(month, DATEDIFF(month, 0, p.DataPrimeiraCompra), 0), 'yyyy-MM') AS Mes_Nascimento,
    FORMAT(CAST(f.DateKey AS DATE), 'yyyy-MM') AS Mes_Calendario_Compra
FROM FactOnlineSales f
JOIN NascimentoClientes p ON f.CustomerKey = p.CustomerKey
WHERE CAST(f.DateKey AS DATE) >= p.DataPrimeiraCompra 
  AND CAST(f.DateKey AS DATE) <= '2007-12-31';


-- --------------------------------------------------------------------
-- PASSO 3: Agrupamento Final (Gera a Matriz de Calendário Cronológica)
-- --------------------------------------------------------------------
WITH NascimentoClientes AS (
    SELECT 
        CustomerKey,
        MIN(CAST(DateKey AS DATE)) AS DataPrimeiraCompra
    FROM FactOnlineSales
    GROUP BY CustomerKey
    HAVING MIN(CAST(DateKey AS DATE)) >= '2007-01-01' 
       AND MIN(CAST(DateKey AS DATE)) <= '2007-12-31'
),
JornadaClientes AS (
    SELECT 
        f.CustomerKey,
        FORMAT(DATEADD(month, DATEDIFF(month, 0, p.DataPrimeiraCompra), 0), 'yyyy-MM') AS Mes_Nascimento,
        FORMAT(CAST(f.DateKey AS DATE), 'yyyy-MM') AS Mes_Calendario_Compra
    FROM FactOnlineSales f
    JOIN NascimentoClientes p ON f.CustomerKey = p.CustomerKey
    WHERE CAST(f.DateKey AS DATE) >= p.DataPrimeiraCompra 
      AND CAST(f.DateKey AS DATE) <= '2007-12-31'
)
SELECT 
    Mes_Nascimento,
    Mes_Calendario_Compra,
    COUNT(DISTINCT CustomerKey) AS Qtd_Clientes_Ativos
FROM JornadaClientes
GROUP BY Mes_Nascimento, Mes_Calendario_Compra
ORDER BY Mes_Nascimento, Mes_Calendario_Compra;
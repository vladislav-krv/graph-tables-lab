-- Вариант 30: Цепочка поставок (Retail): Заводы, дистрибьюторы, магазины.

CREATE DATABASE SupplyChainGraph;
GO
USE SupplyChainGraph;
GO

-- не менее трёх таблиц узлов
-- 1.заводы
CREATE TABLE [Factory] (
    [ID_Завода] INT IDENTITY(1,1) PRIMARY KEY,
    [Название] NVARCHAR(100) NOT NULL,
    [Город] NVARCHAR(50) NOT NULL,
    [Специализация] NVARCHAR(100)
) AS NODE;

-- 2.дистрибьюторы
CREATE TABLE [Distributor] (
    [ID_Дистрибьютора] INT IDENTITY(1,1) PRIMARY KEY,
    [Название] NVARCHAR(100) NOT NULL,
    [Вместимость_Тонн] INT
) AS NODE;

-- 3.магазины
CREATE TABLE [Store] (
    [ID_Магазина] INT IDENTITY(1,1) PRIMARY KEY,
    [Название] NVARCHAR(100) NOT NULL,
    [Формат] NVARCHAR(50)
) AS NODE;
GO

-- не менее трёх таблиц рёбер.
-- 1.поставка (завод -> дистрибьютор, дистрибьютор -> магазин)
CREATE TABLE [Supplies] (
    [Объем_Поставки_Тонн] INT NOT NULL
) AS EDGE;

-- 2.транзит (перемещение между дистрибьюторами)
CREATE TABLE [Transfers] (
    [Дистанция_КМ] INT NOT NULL
) AS EDGE;

--3. владеет (завод -> магазин)
CREATE TABLE [Owns_Franchise] (
    [Процент_Владения] INT
) AS EDGE;
GO

-- не менее 10 строк для каждой таблицы

INSERT INTO [Factory] ([Название], [Город], [Специализация]) VALUES
(N'Савушкин продукт', N'Брест', N'Молочная продукция'),
(N'Санта Бремор', N'Брест', N'Рыба и морепродукты'),
(N'Коммунарка', N'Минск', N'Кондитерские изделия'),
(N'Спартак', N'Гомель', N'Кондитерские изделия'),
(N'Минскхлебпром', N'Минск', N'Хлебобулочные изделия'),
(N'Слодыч', N'Минск', N'Печенье и выпечка'),
(N'Кристалл', N'Минск', N'Напитки'),
(N'Аливария', N'Минск', N'Напитки'),
(N'Беллакт', N'Волковыск', N'Детское питание'),
(N'Бабушкина крынка', N'Могилев', N'Молочная продукция');

INSERT INTO [Distributor] ([Название], [Вместимость_Тонн]) VALUES
(N'Минск-Хаб Центральный', 50000),
(N'Брест-Логистик', 20000),
(N'Гомель-Торг', 15000),
(N'Витебск-База', 12000),
(N'Гродно-Опт', 14000),
(N'Могилев-Снаб', 13000),
(N'Северный Терминал', 30000),
(N'Южный Транзит', 25000),
(N'Западный Распределитель', 40000),
(N'Восточный Склад', 10000);

INSERT INTO [Store] ([Название], [Формат]) VALUES
(N'Евроопт Независимости', N'Гипермаркет'),
(N'Корона Замок', N'Гипермаркет'),
(N'Соседи Победителей', N'Супермаркет'),
(N'Гиппо Рокоссовского', N'Супермаркет'),
(N'Санта Дзержинского', N'Магазин у дома'),
(N'Алми Притыцкого', N'Супермаркет'),
(N'Виталюр Юго-Запад', N'Супермаркет'),
(N'Грин Дана Молл', N'Гипермаркет'),
(N'Белмаркет Сухарево', N'Магазин у дома'),
(N'Хит Экспресс', N'Дискаунтер');
GO

-- связи

-- связь поставок (завод -> дистрибьютор)
INSERT INTO [Supplies] ($from_id, $to_id, [Объем_Поставки_Тонн])
SELECT F.$node_id, D.$node_id, 500 FROM [Factory] F, [Distributor] D WHERE F.[Название] = N'Савушкин продукт' AND D.[Название] = N'Минск-Хаб Центральный'
UNION ALL SELECT F.$node_id, D.$node_id, 300 FROM [Factory] F, [Distributor] D WHERE F.[Название] = N'Коммунарка' AND D.[Название] = N'Минск-Хаб Центральный'
UNION ALL SELECT F.$node_id, D.$node_id, 200 FROM [Factory] F, [Distributor] D WHERE F.[Название] = N'Спартак' AND D.[Название] = N'Гомель-Торг'
UNION ALL SELECT F.$node_id, D.$node_id, 400 FROM [Factory] F, [Distributor] D WHERE F.[Название] = N'Санта Бремор' AND D.[Название] = N'Западный Распределитель'
UNION ALL SELECT F.$node_id, D.$node_id, 150 FROM [Factory] F, [Distributor] D WHERE F.[Название] = N'Бабушкина крынка' AND D.[Название] = N'Могилев-Снаб';

-- связь поставок (дистрибьютор -> магазин)
INSERT INTO [Supplies] ($from_id, $to_id, [Объем_Поставки_Тонн])
SELECT D.$node_id, S.$node_id, 50 FROM [Distributor] D, [Store] S WHERE D.[Название] = N'Минск-Хаб Центральный' AND S.[Название] = N'Евроопт Независимости'
UNION ALL SELECT D.$node_id, S.$node_id, 30 FROM [Distributor] D, [Store] S WHERE D.[Название] = N'Минск-Хаб Центральный' AND S.[Название] = N'Корона Замок'
UNION ALL SELECT D.$node_id, S.$node_id, 20 FROM [Distributor] D, [Store] S WHERE D.[Название] = N'Гомель-Торг' AND S.[Название] = N'Алми Притыцкого'
UNION ALL SELECT D.$node_id, S.$node_id, 45 FROM [Distributor] D, [Store] S WHERE D.[Название] = N'Западный Распределитель' AND S.[Название] = N'Санта Дзержинского';

-- связь транзит (дистрибьютор -> дистрибьютор)
INSERT INTO [Transfers] ($from_id, $to_id, [Дистанция_КМ])
SELECT D1.$node_id, D2.$node_id, 350 FROM [Distributor] D1, [Distributor] D2 WHERE D1.[Название] = N'Брест-Логистик' AND D2.[Название] = N'Западный Распределитель'
UNION ALL SELECT D1.$node_id, D2.$node_id, 120 FROM [Distributor] D1, [Distributor] D2 WHERE D1.[Название] = N'Западный Распределитель' AND D2.[Название] = N'Минск-Хаб Центральный'
UNION ALL SELECT D1.$node_id, D2.$node_id, 200 FROM [Distributor] D1, [Distributor] D2 WHERE D1.[Название] = N'Минск-Хаб Центральный' AND D2.[Название] = N'Северный Терминал'
UNION ALL SELECT D1.$node_id, D2.$node_id, 90 FROM [Distributor] D1, [Distributor] D2 WHERE D1.[Название] = N'Северный Терминал' AND D2.[Название] = N'Витебск-База';

-- связь владения (завод -> магазин)
INSERT INTO [Owns_Franchise] ($from_id, $to_id, [Процент_Владения])
SELECT F.$node_id, S.$node_id, 100 FROM [Factory] F, [Store] S WHERE F.[Название] = N'Санта Бремор' AND S.[Название] = N'Санта Дзержинского'
UNION ALL SELECT F.$node_id, S.$node_id, 50 FROM [Factory] F, [Store] S WHERE F.[Название] = N'Коммунарка' AND S.[Название] = N'Корона Замок';
GO

-- match 5+

-- 1.какие заводы поставляют на Минск-Хаб Центральный
SELECT F.[Название] AS [Завод], Sup.[Объем_Поставки_Тонн]
FROM [Factory] F, [Supplies] Sup, [Distributor] D
WHERE MATCH(F-(Sup)->D)
  AND D.[Название] = N'Минск-Хаб Центральный';

-- 2.полный путь товара: завод -> дистрибьютор -> магазин
SELECT F.[Название] AS [Завод], D.[Название] AS [Дистрибьютор], S.[Название] AS [Магазин]
FROM [Factory] F, [Supplies] Sup1, [Distributor] D, [Supplies] Sup2, [Store] S
WHERE MATCH(F-(Sup1)->D-(Sup2)->S);

--3.какие магазины напрямую принадлежат заводам
SELECT F.[Название] AS [Владелец], S.[Название] AS [Фирменный_Магазин]
FROM [Factory] F, [Owns_Franchise] Oxf, [Store] S
WHERE MATCH(F-(Oxf)->S);

-- 4.суммарный объем поставок в каждый магазин от всех дистрибьюторов
SELECT S.[Название] AS [Магазин], SUM(Sup.[Объем_Поставки_Тонн]) AS [Всего_Тонн_Получено]
FROM [Distributor] D, [Supplies] Sup, [Store] S
WHERE MATCH(D-(Sup)->S)
GROUP BY S.[Название];

-- 5.какой завод на какой распределительный центр делает поставки
SELECT F.[Название] AS [Завод], D.[Название] AS [Дистрибьютор]
FROM [Factory] F, [Supplies] Sup, [Distributor] D
WHERE MATCH(F-(Sup)->D);
GO

-- SHORTEST_PATH
-- 1. "+", кратчайший путь логистики от Брест-Логистик до Витебск-База
SELECT 
    [Старт],
    [Путь],
    [Финиш]
FROM (
    SELECT 
        D1.[Название] AS [Старт],
        STRING_AGG(D2.[Название], ' -> ') WITHIN GROUP (GRAPH PATH) AS [Путь],
        LAST_VALUE(D2.[Название]) WITHIN GROUP (GRAPH PATH) AS [Финиш]
    FROM 
        [Distributor] AS D1,
        [Transfers] FOR PATH AS T,
        [Distributor] FOR PATH AS D2
    WHERE 
        MATCH(SHORTEST_PATH(D1(-(T)->D2)+))
        AND D1.[Название] = N'Брест-Логистик'
) AS PathResult
WHERE PathResult.[Финиш] = N'Витебск-База';
 
-- 2."{1,n}", все пути от Брест-Логистик длиной от 1 до 2 шагов.
SELECT 
    D1.[Название] AS [Откуда],
    LAST_VALUE(D2.[Название]) WITHIN GROUP (GRAPH PATH) AS [Конечный_Пункт],
    COUNT(D2.[ID_Дистрибьютора]) WITHIN GROUP (GRAPH PATH) AS [Количество_Шагов],
    STRING_AGG(D2.[Название], ' -> ') WITHIN GROUP (GRAPH PATH) AS [Маршрут],
    SUM(T.[Дистанция_КМ]) WITHIN GROUP (GRAPH PATH) AS [Общий_Пробег_КМ]
FROM 
    [Distributor] AS D1,
    [Transfers] FOR PATH AS T,
    [Distributor] FOR PATH AS D2
WHERE 
    MATCH(SHORTEST_PATH(D1(-(T)->D2){1,2}))
    AND D1.[Название] = N'Брест-Логистик';

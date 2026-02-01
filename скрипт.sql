-- =========================
-- SQL Server: простой CREATE TABLE + FK + DATA
-- Без dbo. и без CONSTRAINT-имен (только FOREIGN KEY)
-- Таблица пользователей: Users (т.к. USER зарезервировано)
-- =========================

-- ---------- USERS / ROLES ----------
CREATE TABLE Role (
    RoleId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name   NVARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Users (
    UserId       INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Username     NVARCHAR(60) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(200) NOT NULL,
    IsActive     BIT NOT NULL DEFAULT(1)
);

CREATE TABLE UserRole (
    UserRoleId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    UserId     INT NOT NULL,
    RoleId     INT NOT NULL,
    UNIQUE (UserId, RoleId),

    FOREIGN KEY (UserId) REFERENCES Users(UserId),
    FOREIGN KEY (RoleId) REFERENCES Role(RoleId)
);

-- ---------- DIRECTORIES ----------
CREATE TABLE Product (
    ProductId    INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Article      NVARCHAR(64)  NOT NULL UNIQUE,
    Name         NVARCHAR(200) NOT NULL,
    Category     NVARCHAR(100) NOT NULL,
    Description  NVARCHAR(MAX) NULL,
    Unit         NVARCHAR(50)  NOT NULL,
    Status       NVARCHAR(20)  NOT NULL DEFAULT('active'),
    CHECK (Status IN ('active','discontinued'))
);

CREATE TABLE Material (
    MaterialId   INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Code         NVARCHAR(64)  NOT NULL UNIQUE,
    Name         NVARCHAR(200) NOT NULL,
    Type         NVARCHAR(20)  NOT NULL,
    Unit         NVARCHAR(50)  NOT NULL,
    MinQty       DECIMAL(14,3) NOT NULL DEFAULT(0),
    MarketPrice  DECIMAL(14,2) NOT NULL DEFAULT(0),
    CHECK (Type IN ('raw','component')),
    CHECK (MinQty >= 0),
    CHECK (MarketPrice >= 0)
);

CREATE TABLE Supplier (
    SupplierId  INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Inn         NVARCHAR(12)  NOT NULL UNIQUE,
    Name        NVARCHAR(200) NOT NULL,
    Contacts    NVARCHAR(300) NULL,
    Rating      TINYINT NULL,
    PayTerms    NVARCHAR(200) NULL,
    CHECK (Rating IS NULL OR Rating BETWEEN 1 AND 5)
);

CREATE TABLE Employee (
    EmployeeId   INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    PersonnelNo  NVARCHAR(30)  NOT NULL UNIQUE,
    LastName     NVARCHAR(80)  NOT NULL,
    FirstName    NVARCHAR(80)  NOT NULL,
    MiddleName   NVARCHAR(80)  NULL,
    Position     NVARCHAR(100) NOT NULL,
    Department   NVARCHAR(100) NOT NULL,
    Qualifications NVARCHAR(300) NULL,
    RateType     NVARCHAR(10)  NOT NULL DEFAULT('salary'),
    RateValue    DECIMAL(14,2) NOT NULL DEFAULT(0),
    Status       NVARCHAR(20)  NOT NULL DEFAULT('working'),
    CHECK (RateType IN ('hour','salary')),
    CHECK (RateValue >= 0),
    CHECK (Status IN ('working','fired'))
);

CREATE TABLE Equipment (
    EquipmentId   INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    InventoryNo   NVARCHAR(64) NOT NULL UNIQUE,
    Model         NVARCHAR(120) NOT NULL,
    Type          NVARCHAR(80)  NOT NULL,
    Commissioned  DATE NOT NULL,
    Status        NVARCHAR(20) NOT NULL DEFAULT('in_work'),
    MaintenancePlan NVARCHAR(200) NULL,
    CHECK (Status IN ('in_work','repair','to','written_off'))
);

-- ---------- BOM ----------
CREATE TABLE BillOfMaterials (
    BillOfMaterialsId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ProductId   INT NOT NULL,
    MaterialId  INT NOT NULL,
    QtyPerUnit  DECIMAL(14,3) NOT NULL,
    UNIQUE (ProductId, MaterialId),
    CHECK (QtyPerUnit > 0),

    FOREIGN KEY (ProductId) REFERENCES Product(ProductId),
    FOREIGN KEY (MaterialId) REFERENCES Material(MaterialId)
);

-- ---------- TECH ROUTE / OPERATIONS ----------
CREATE TABLE TechRoute (
    TechRouteId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ProductId   INT NOT NULL UNIQUE,     -- упрощение: 1 маршрут на продукт
    Name        NVARCHAR(200) NOT NULL,
    IsActive    BIT NOT NULL DEFAULT(1),

    FOREIGN KEY (ProductId) REFERENCES Product(ProductId)
);

CREATE TABLE TechOperation (
    TechOperationId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TechRouteId     INT NOT NULL,
    SeqNo           INT NOT NULL,
    Name            NVARCHAR(200) NOT NULL,
    StageType       NVARCHAR(20) NOT NULL,
    NormMinutes     INT NOT NULL DEFAULT(0),

    UNIQUE (TechRouteId, SeqNo),
    CHECK (SeqNo > 0),
    CHECK (StageType IN ('prep','assembly','test','pack')),
    CHECK (NormMinutes >= 0),

    FOREIGN KEY (TechRouteId) REFERENCES TechRoute(TechRouteId)
);

-- ---------- WAREHOUSE / STOCK ----------
CREATE TABLE Warehouse (
    WarehouseId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name        NVARCHAR(200) NOT NULL UNIQUE,
    Type        NVARCHAR(20)  NOT NULL,
    CHECK (Type IN ('main','temp','defect'))
);

CREATE TABLE StockBalance (
    StockBalanceId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    WarehouseId INT NOT NULL,
    MaterialId  INT NOT NULL,
    Qty         DECIMAL(14,3) NOT NULL DEFAULT(0),

    UNIQUE (WarehouseId, MaterialId),
    CHECK (Qty >= 0),

    FOREIGN KEY (WarehouseId) REFERENCES Warehouse(WarehouseId),
    FOREIGN KEY (MaterialId) REFERENCES Material(MaterialId)
);

-- ---------- PURCHASE ORDER / RECEIPT ----------
CREATE TABLE PurchaseOrder (
    PurchaseOrderId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    SupplierId  INT NOT NULL,
    OrderDate   DATE NOT NULL DEFAULT(CONVERT(date, GETDATE())),
    Status      NVARCHAR(20) NOT NULL DEFAULT('created'),
    CreatedByUserId INT NULL,
    CHECK (Status IN ('created','sent','closed','canceled')),

    FOREIGN KEY (SupplierId) REFERENCES Supplier(SupplierId),
    FOREIGN KEY (CreatedByUserId) REFERENCES Users(UserId)
);

CREATE TABLE PurchaseOrderItem (
    PurchaseOrderItemId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    PurchaseOrderId INT NOT NULL,
    MaterialId      INT NOT NULL,
    QtyOrdered      DECIMAL(14,3) NOT NULL,
    Price           DECIMAL(14,2) NOT NULL DEFAULT(0),

    CHECK (QtyOrdered > 0),
    CHECK (Price >= 0),

    FOREIGN KEY (PurchaseOrderId) REFERENCES PurchaseOrder(PurchaseOrderId),
    FOREIGN KEY (MaterialId) REFERENCES Material(MaterialId)
);

CREATE TABLE PurchaseReceipt (
    PurchaseReceiptId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    PurchaseOrderId INT NOT NULL,
    WarehouseId     INT NOT NULL,
    ReceiptDate     DATE NOT NULL DEFAULT(CONVERT(date, GETDATE())),
    Status          NVARCHAR(20) NOT NULL DEFAULT('received'),
    CHECK (Status IN ('received','partial','closed')),

    FOREIGN KEY (PurchaseOrderId) REFERENCES PurchaseOrder(PurchaseOrderId),
    FOREIGN KEY (WarehouseId) REFERENCES Warehouse(WarehouseId)
);

CREATE TABLE PurchaseReceiptItem (
    PurchaseReceiptItemId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    PurchaseReceiptId INT NOT NULL,
    MaterialId        INT NOT NULL,
    QtyAccepted       DECIMAL(14,3) NOT NULL DEFAULT(0),
    QtyRejected       DECIMAL(14,3) NOT NULL DEFAULT(0),
    RejectReason      NVARCHAR(200) NULL,

    CHECK (QtyAccepted >= 0 AND QtyRejected >= 0 AND (QtyAccepted + QtyRejected) > 0),

    FOREIGN KEY (PurchaseReceiptId) REFERENCES PurchaseReceipt(PurchaseReceiptId),
    FOREIGN KEY (MaterialId) REFERENCES Material(MaterialId)
);

-- ---------- PRODUCTION ORDER / STAGES ----------
CREATE TABLE Client (
    ClientId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name     NVARCHAR(200) NOT NULL
);

CREATE TABLE ProductionOrder (
    ProductionOrderId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ClientId   INT NOT NULL,
    ProductId  INT NOT NULL,
    Qty        DECIMAL(14,3) NOT NULL,
    Priority   NVARCHAR(10)  NOT NULL DEFAULT('normal'),
    Deadline   DATE NULL,
    Status     NVARCHAR(30)  NOT NULL DEFAULT('planned'),

    CHECK (Qty > 0),
    CHECK (Priority IN ('low','normal','high')),
    CHECK (Status IN (
        'planned','in_work','quality_control','ready_to_ship','shipped',
        'paused','canceled','rework'
    )),

    FOREIGN KEY (ClientId) REFERENCES Client(ClientId),
    FOREIGN KEY (ProductId) REFERENCES Product(ProductId)
);

CREATE TABLE ProductionStage (
    ProductionStageId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ProductionOrderId INT NOT NULL,
    SeqNo     INT NOT NULL,
    StageType NVARCHAR(20) NOT NULL,
    Status    NVARCHAR(20) NOT NULL DEFAULT('planned'),
    DateStart DATE NULL,
    DateEnd   DATE NULL,

    UNIQUE (ProductionOrderId, SeqNo),
    CHECK (SeqNo > 0),
    CHECK (StageType IN ('prep','assembly','test','pack')),
    CHECK (Status IN ('planned','in_work','done','paused','rework')),
    CHECK (DateEnd IS NULL OR DateStart IS NULL OR DateEnd >= DateStart),

    FOREIGN KEY (ProductionOrderId) REFERENCES ProductionOrder(ProductionOrderId)
);

-- ---------- QUALITY DEFECT ----------
CREATE TABLE QualityDefect (
    QualityDefectId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ProductionStageId INT NOT NULL,
    Description NVARCHAR(400) NOT NULL,
    Severity    NVARCHAR(10) NOT NULL DEFAULT('medium'),
    Decision    NVARCHAR(30) NULL,
    QtyAffected DECIMAL(14,3) NULL,
    CreatedAt   DATETIME NOT NULL DEFAULT(GETDATE()),

    CHECK (Severity IN ('low','medium','high')),
    CHECK (Decision IS NULL OR Decision IN ('repair','scrap','accept')),
    CHECK (QtyAffected IS NULL OR QtyAffected >= 0),

    FOREIGN KEY (ProductionStageId) REFERENCES ProductionStage(ProductionStageId)
);

-- ---------- WORK LOG / EQUIPMENT USAGE ----------
CREATE TABLE WorkLog (
    WorkLogId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ProductionStageId INT NOT NULL,
    EmployeeId INT NOT NULL,
    WorkDate   DATE NOT NULL DEFAULT(CONVERT(date, GETDATE())),
    Hours      DECIMAL(10,2) NOT NULL,

    CHECK (Hours > 0 AND Hours <= 24),

    FOREIGN KEY (ProductionStageId) REFERENCES ProductionStage(ProductionStageId),
    FOREIGN KEY (EmployeeId) REFERENCES Employee(EmployeeId)
);

CREATE TABLE EquipmentUsageLog (
    EquipmentUsageLogId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ProductionStageId INT NOT NULL,
    EquipmentId INT NOT NULL,
    StartTime  DATETIME NOT NULL DEFAULT(GETDATE()),
    EndTime    DATETIME NULL,

    CHECK (EndTime IS NULL OR EndTime >= StartTime),

    FOREIGN KEY (ProductionStageId) REFERENCES ProductionStage(ProductionStageId),
    FOREIGN KEY (EquipmentId) REFERENCES Equipment(EquipmentId)
);

-- =========================
-- DATA: заполнение (5-10 строк на таблицу)
-- =========================

-- Role (3)
INSERT INTO Role (Name) VALUES
(N'Администратор'),
(N'Менеджер'),
(N'Оператор');

-- Users (5)
INSERT INTO Users (Username, PasswordHash, IsActive) VALUES
(N'admin',   N'hash_admin', 1),
(N'ivan',    N'hash_ivan',  1),
(N'olga',    N'hash_olga',  1),
(N'petya',   N'hash_petya', 1),
(N'guest',   N'hash_guest', 0);

-- UserRole
INSERT INTO UserRole (UserId, RoleId) VALUES
(1,1), -- admin -> Администратор
(2,2), -- ivan  -> Менеджер
(3,2), -- olga  -> Менеджер
(4,3), -- petya -> Оператор
(5,3); -- guest -> Оператор (неактивен)

-- Product (6)
INSERT INTO Product (Article, Name, Category, Description, Unit, Status) VALUES
(N'PR-001', N'Стиральная машина Compact',  N'Бытовая техника', N'Компактная модель для малых помещений', N'шт', N'active'),
(N'PR-002', N'Пылесос TurboMax',          N'Бытовая техника', N'Пылесос с турбощёткой',               N'шт', N'active'),
(N'PR-003', N'Кофемашина Barista Pro',    N'Бытовая техника', N'Полуавтомат для эспрессо',            N'шт', N'active'),
(N'PR-004', N'Миксер KitchenMix',         N'Кухонная техника',N'Настольный миксер',                   N'шт', N'active'),
(N'PR-005', N'Электрочайник HeatUp',      N'Кухонная техника',N'Чайник 1.7л',                         N'шт', N'active'),
(N'PR-006', N'Посудомоечная машина Slim', N'Бытовая техника', N'Узкая посудомойка',                   N'шт', N'discontinued');

-- Material (10)
INSERT INTO Material (Code, Name, Type, Unit, MinQty, MarketPrice) VALUES
(N'M-001', N'Листовая сталь 1мм',      N'raw',      N'кг',  50,  95.00),
(N'M-002', N'Алюминий профиль',        N'raw',      N'кг',  30,  160.00),
(N'M-003', N'Пластик ABS гранулы',     N'raw',      N'кг',  20,  110.00),
(N'M-004', N'Винты M4',                N'component',N'шт',  500, 0.20),
(N'M-005', N'Кабель силовой',          N'component',N'м',   200, 18.00),
(N'M-006', N'Клей термостойкий',       N'component',N'л',   10,  12.50),
(N'M-007', N'Электродвигатель 220V',   N'component',N'шт',  5,   1200.00),
(N'M-008', N'Коробка картонная',       N'component',N'шт',  100, 15.00),
(N'M-009', N'Плёнка упаковочная',      N'component',N'м2',  50,  8.00),
(N'M-010', N'Краска порошковая',       N'raw',      N'кг',  25,  45.00);

-- Supplier (5)
INSERT INTO Supplier (Inn, Name, Contacts, Rating, PayTerms) VALUES
(N'5401000001', N'ООО МеталлСнаб',     N'8-800-111-11-11, metal@snab.ru', 5, N'Постоплата 10 дней'),
(N'5401000002', N'ООО ПластКомплект',  N'plast@comp.ru',                 4, N'Предоплата 50%'),
(N'5401000003', N'ООО ЭлектроПартс',   N'elec@parts.ru',                 4, N'Постоплата 5 дней'),
(N'5401000004', N'ООО Упаковка+',      N'pack@plus.ru',                  5, N'Предоплата 100%'),
(N'5401000005', N'ООО ХимСырьё',       N'chem@raw.ru',                   3, N'Постоплата 15 дней');

-- Employee (6)
INSERT INTO Employee (PersonnelNo, LastName, FirstName, MiddleName, Position, Department, Qualifications, RateType, RateValue, Status) VALUES
(N'T-001', N'Иванов',    N'Иван',     N'Иванович',   N'Мастер',          N'Производство', N'Сборка;Контроль', N'salary', 55000, N'working'),
(N'T-002', N'Петров',    N'Пётр',     N'Петрович',   N'Сборщик',         N'Производство', N'Сборка',          N'salary', 48000, N'working'),
(N'T-003', N'Сидорова',  N'Ольга',    N'Сергеевна',  N'Тестировщик',     N'ОТК',          N'Тестирование',    N'salary', 52000, N'working'),
(N'T-004', N'Кузнецов',  N'Алексей',  N'Николаевич', N'Упаковщик',       N'Склад',        N'Упаковка',        N'salary', 45000, N'working'),
(N'T-005', N'Орлова',    N'Мария',    N'Игоревна',   N'Закупщик',        N'Снабжение',    N'Закупки;Логистика',N'salary', 60000, N'working'),
(N'T-006', N'Морозов',   N'Дмитрий',  N'Олегович',   N'Оператор станка', N'Производство', N'Заготовка',       N'hour',   350,   N'working');

-- Equipment (5)
INSERT INTO Equipment (InventoryNo, Model, Type, Commissioned, Status, MaintenancePlan) VALUES
(N'EQ-0001', N'Press-100',   N'Пресс',       '2024-03-10', N'in_work',   N'ТО каждые 90 дней'),
(N'EQ-0002', N'Line-Assembly',N'Сборочная линия','2023-11-05', N'in_work',N'ТО каждые 180 дней'),
(N'EQ-0003', N'Tester-X',    N'Тестер',      '2024-06-15', N'to',        N'ТО каждые 60 дней'),
(N'EQ-0004', N'PackPro',     N'Упаковщик',   '2022-09-01', N'in_work',   N'ТО каждые 120 дней'),
(N'EQ-0005', N'PaintBox',    N'Покраска',    '2021-05-20', N'repair',    N'ТО каждые 365 дней');

-- Warehouse (3)
INSERT INTO Warehouse (Name, Type) VALUES
(N'Основной склад',   N'main'),
(N'Временный склад',  N'temp'),
(N'Склад брака',      N'defect');

-- StockBalance (10) (warehouse 1 = основной)
INSERT INTO StockBalance (WarehouseId, MaterialId, Qty) VALUES
(1,1, 180.000),
(1,2, 140.000),
(1,3, 70.000),
(1,4, 5000.000),
(1,5, 420.000),
(1,6, 60.000),
(1,7, 12.000),
(1,8, 300.000),
(1,9, 150.000),
(1,10, 40.000);

-- TechRoute (3) (на продукты 1,2,4)
INSERT INTO TechRoute (ProductId, Name, IsActive) VALUES
(1, N'Маршрут PR-001', 1),
(2, N'Маршрут PR-002', 1),
(4, N'Маршрут PR-004', 1);

-- TechOperation (по 4 операции на маршрут)
-- Route 1 (PR-001)
INSERT INTO TechOperation (TechRouteId, SeqNo, Name, StageType, NormMinutes) VALUES
(1,1, N'Заготовка деталей корпуса', N'prep',     30),
(1,2, N'Сборка узлов',             N'assembly',  45),
(1,3, N'Тестирование',             N'test',      20),
(1,4, N'Упаковка',                 N'pack',      10);

-- Route 2 (PR-002)
INSERT INTO TechOperation (TechRouteId, SeqNo, Name, StageType, NormMinutes) VALUES
(2,1, N'Подготовка корпуса',       N'prep',     20),
(2,2, N'Сборка двигателя',         N'assembly', 35),
(2,3, N'Проверка тяги',            N'test',     15),
(2,4, N'Упаковка',                 N'pack',     10);

-- Route 3 (PR-004)
INSERT INTO TechOperation (TechRouteId, SeqNo, Name, StageType, NormMinutes) VALUES
(3,1, N'Подготовка деталей',       N'prep',     15),
(3,2, N'Сборка миксера',           N'assembly', 25),
(3,3, N'Функциональный тест',      N'test',     10),
(3,4, N'Упаковка',                 N'pack',      8);

-- BillOfMaterials (10)
-- PR-001: сталь, винты, кабель, клей, двигатель, коробка, плёнка
INSERT INTO BillOfMaterials (ProductId, MaterialId, QtyPerUnit) VALUES
(1,1, 5.000),
(1,4, 40.000),
(1,5, 2.000),
(1,6, 0.200),
(1,7, 1.000);

-- PR-002: пластик, винты, кабель, двигатель, коробка
INSERT INTO BillOfMaterials (ProductId, MaterialId, QtyPerUnit) VALUES
(2,3, 2.500),
(2,4, 25.000),
(2,5, 1.500),
(2,7, 1.000),
(2,8, 1.000);

-- PurchaseOrder (6)
INSERT INTO PurchaseOrder (SupplierId, OrderDate, Status, CreatedByUserId) VALUES
(1, '2026-01-05', N'created', 2),
(2, '2026-01-06', N'sent',    2),
(3, '2026-01-08', N'closed',  3),
(4, '2026-01-10', N'sent',    5),
(5, '2026-01-12', N'created', 3),
(1, '2026-01-15', N'canceled',2);

-- PurchaseOrderItem (10)
INSERT INTO PurchaseOrderItem (PurchaseOrderId, MaterialId, QtyOrdered, Price) VALUES
(1, 1, 200.000, 95.00),
(1, 4, 3000.000, 0.20),
(2, 3, 120.000, 110.00),
(2,10, 50.000, 45.00),
(3, 7, 10.000, 1200.00),
(3, 5, 200.000, 18.00),
(4, 8, 400.000, 15.00),
(4, 9, 300.000, 8.00),
(5, 6, 30.000, 12.50),
(6, 2, 100.000, 160.00);

-- PurchaseReceipt (4) (warehouse 1 = основной)
INSERT INTO PurchaseReceipt (PurchaseOrderId, WarehouseId, ReceiptDate, Status) VALUES
(1, 1, '2026-01-07', N'received'),
(2, 1, '2026-01-09', N'partial'),
(3, 1, '2026-01-11', N'received'),
(4, 1, '2026-01-13', N'partial');

-- PurchaseReceiptItem (10)
INSERT INTO PurchaseReceiptItem (PurchaseReceiptId, MaterialId, QtyAccepted, QtyRejected, RejectReason) VALUES
(1, 1, 190.000, 10.000, N'Повреждение листов'),
(1, 4, 3000.000, 0.000, NULL),
(2, 3, 110.000, 10.000, N'Несоответствие партии'),
(2,10, 48.000,  2.000,  N'Комки/влажность'),
(3, 7, 10.000,  0.000,  NULL),
(3, 5, 198.000, 2.000,  N'Повреждение изоляции'),
(4, 8, 390.000, 10.000, N'Деформация коробок'),
(4, 9, 300.000, 0.000,  NULL),
(2, 3, 5.000,   0.000,  NULL),
(1, 1, 5.000,   0.000,  NULL);

-- Client (5)
INSERT INTO Client (Name) VALUES
(N'ООО Север'),
(N'ООО Восток'),
(N'ИП Петров'),
(N'ООО ТехСервис'),
(N'ООО МегаБыт');

-- ProductionOrder (5)
INSERT INTO ProductionOrder (ClientId, ProductId, Qty, Priority, Deadline, Status) VALUES
(1, 1, 10.000, N'high',   '2026-02-10', N'planned'),
(2, 2, 20.000, N'normal', '2026-02-15', N'in_work'),
(3, 4, 15.000, N'normal', '2026-02-18', N'in_work'),
(4, 1, 5.000,  N'low',    '2026-02-05', N'shipped'),
(5, 2, 8.000,  N'normal', NULL,         N'canceled');

-- ProductionStage (20) (по 4 этапа на заказ)
-- Order 1 -> stages 1..4
INSERT INTO ProductionStage (ProductionOrderId, SeqNo, StageType, Status, DateStart, DateEnd) VALUES
(1,1,N'prep',    N'done',   '2026-01-20','2026-01-21'),
(1,2,N'assembly',N'in_work','2026-01-22',NULL),
(1,3,N'test',    N'planned',NULL,NULL),
(1,4,N'pack',    N'planned',NULL,NULL);

-- Order 2 -> stages 5..8
INSERT INTO ProductionStage (ProductionOrderId, SeqNo, StageType, Status, DateStart, DateEnd) VALUES
(2,1,N'prep',    N'done',   '2026-01-18','2026-01-18'),
(2,2,N'assembly',N'done',   '2026-01-19','2026-01-21'),
(2,3,N'test',    N'in_work','2026-01-22',NULL),
(2,4,N'pack',    N'planned',NULL,NULL);

-- Order 3 -> stages 9..12
INSERT INTO ProductionStage (ProductionOrderId, SeqNo, StageType, Status, DateStart, DateEnd) VALUES
(3,1,N'prep',    N'in_work','2026-01-23',NULL),
(3,2,N'assembly',N'planned',NULL,NULL),
(3,3,N'test',    N'planned',NULL,NULL),
(3,4,N'pack',    N'planned',NULL,NULL);

-- Order 4 -> stages 13..16
INSERT INTO ProductionStage (ProductionOrderId, SeqNo, StageType, Status, DateStart, DateEnd) VALUES
(4,1,N'prep',    N'done', '2026-01-10','2026-01-10'),
(4,2,N'assembly',N'done', '2026-01-11','2026-01-12'),
(4,3,N'test',    N'done', '2026-01-13','2026-01-13'),
(4,4,N'pack',    N'done', '2026-01-14','2026-01-14');

-- Order 5 -> stages 17..20
INSERT INTO ProductionStage (ProductionOrderId, SeqNo, StageType, Status, DateStart, DateEnd) VALUES
(5,1,N'prep',    N'paused','2026-01-16',NULL),
(5,2,N'assembly',N'planned',NULL,NULL),
(5,3,N'test',    N'planned',NULL,NULL),
(5,4,N'pack',    N'planned',NULL,NULL);

-- QualityDefect (5) (ссылаемся на ProductionStageId 2,7,9,15,18)
INSERT INTO QualityDefect (ProductionStageId, Description, Severity, Decision, QtyAffected) VALUES
(2,  N'Неправильная затяжка крепежа', N'medium', N'repair', 1.000),
(7,  N'Шум двигателя выше нормы',     N'high',   N'repair', 2.000),
(9,  N'Смещение деталей корпуса',     N'medium', N'repair', 1.000),
(15, N'Не проходит тест безопасности',N'high',   N'scrap',  1.000),
(18, N'Царапины на поверхности',      N'low',    N'accept', 0.000);

-- WorkLog (10)
INSERT INTO WorkLog (ProductionStageId, EmployeeId, WorkDate, Hours) VALUES
(1, 6, '2026-01-20', 6.0),
(2, 2, '2026-01-22', 7.5),
(2, 1, '2026-01-22', 2.0),
(5, 6, '2026-01-18', 4.0),
(6, 2, '2026-01-19', 8.0),
(7, 3, '2026-01-22', 6.0),
(9, 6, '2026-01-23', 5.0),
(13,2, '2026-01-10', 3.0),
(15,3, '2026-01-13', 4.0),
(16,4, '2026-01-14', 2.0);

-- EquipmentUsageLog (8)
INSERT INTO EquipmentUsageLog (ProductionStageId, EquipmentId, StartTime, EndTime) VALUES
(1, 1, '2026-01-20 09:00', '2026-01-20 12:00'),
(2, 2, '2026-01-22 10:00', NULL),
(5, 1, '2026-01-18 09:30', '2026-01-18 11:00'),
(6, 2, '2026-01-19 10:00', '2026-01-19 16:30'),
(7, 3, '2026-01-22 11:00', NULL),
(13,1, '2026-01-10 08:00', '2026-01-10 10:00'),
(15,3, '2026-01-13 09:00', '2026-01-13 12:00'),
(16,4, '2026-01-14 13:00', '2026-01-14 15:00');


CREATE TABLE SupplierMaterialTerms (
    SupplierMaterialTermsId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    SupplierId INT NOT NULL,
    MaterialId INT NOT NULL,
    LeadTimeDays INT NOT NULL DEFAULT(0),
    MinBatchQty DECIMAL(14,3) NOT NULL DEFAULT(0),
    DiscountPct DECIMAL(5,2) NOT NULL DEFAULT(0),

    UNIQUE (SupplierId, MaterialId),
    CHECK (LeadTimeDays >= 0),
    CHECK (MinBatchQty >= 0),
    CHECK (DiscountPct >= 0 AND DiscountPct <= 100),

    FOREIGN KEY (SupplierId) REFERENCES Supplier(SupplierId),
    FOREIGN KEY (MaterialId) REFERENCES Material(MaterialId)
);

INSERT INTO SupplierMaterialTerms (SupplierId, MaterialId, LeadTimeDays, MinBatchQty, DiscountPct) VALUES
(1, 1, 7,  100.000, 5.00),
(1, 2, 10, 50.000,  3.00),
(2, 3, 5,  80.000,  2.50),
(3, 7, 14, 5.000,   0.00),
(4, 8, 3,  200.000, 4.00),
(4, 9, 3,  150.000, 4.00),
(5,10, 6,  30.000,  1.50),
(3, 5, 7,  100.000, 2.00);


CREATE TABLE StageAssignment (
    StageAssignmentId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ProductionStageId INT NOT NULL,
    EmployeeId INT NULL,
    EquipmentId INT NULL,
    AssignedAt DATETIME NOT NULL DEFAULT(GETDATE()),

    CHECK (
        (CASE WHEN EmployeeId IS NULL THEN 0 ELSE 1 END) +
        (CASE WHEN EquipmentId IS NULL THEN 0 ELSE 1 END) = 1
    ),

    FOREIGN KEY (ProductionStageId) REFERENCES ProductionStage(ProductionStageId),
    FOREIGN KEY (EmployeeId) REFERENCES Employee(EmployeeId),
    FOREIGN KEY (EquipmentId) REFERENCES Equipment(EquipmentId)
);

INSERT INTO StageAssignment (ProductionStageId, EmployeeId, EquipmentId) VALUES
(2,  2, NULL),  -- сборщик на этап сборки
(2,  NULL, 2),  -- сборочная линия на тот же этап
(7,  3, NULL),  -- тестировщик на этап тестирования
(7,  NULL, 3),  -- тестер
(9,  6, NULL),  -- оператор станка на заготовку
(9,  NULL, 1),  -- пресс
(16, 4, NULL),  -- упаковщик
(16, NULL, 4);  -- упаковочное оборудование

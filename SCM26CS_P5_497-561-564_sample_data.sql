-- ============================================================
--  P5 Centralized Monitoring — SupplyNex Pvt Ltd
--  Sample Dataset | UE23CS342BA1 SCME Project
--  Generated: Apr 17, 2026
-- ============================================================

-- ─── DROP & CREATE TABLES ────────────────────────────────────

DROP TABLE IF EXISTS DEMAND_FORECAST;
DROP TABLE IF EXISTS DELIVERY;
DROP TABLE IF EXISTS ORDER_ITEMS;
DROP TABLE IF EXISTS ORDERS;
DROP TABLE IF EXISTS PROCUREMENT_ORDER;
DROP TABLE IF EXISTS INVENTORY;
DROP TABLE IF EXISTS PRODUCT;
DROP TABLE IF EXISTS WAREHOUSE;
DROP TABLE IF EXISTS SUPPLIER;
DROP TABLE IF EXISTS COMPANY;

-- ─── COMPANY ─────────────────────────────────────────────────
CREATE TABLE COMPANY (
  company_id    INT PRIMARY KEY,
  company_name  VARCHAR(100),
  region        VARCHAR(50),
  contact_email VARCHAR(100)
);

INSERT INTO COMPANY VALUES
(1, 'SupplyNex Pvt Ltd – North', 'North', 'north@supplynex.in'),
(2, 'SupplyNex Pvt Ltd – South', 'South', 'south@supplynex.in'),
(3, 'SupplyNex Pvt Ltd – West',  'West',  'west@supplynex.in'),
(4, 'SupplyNex Pvt Ltd – East',  'East',  'east@supplynex.in');

-- ─── WAREHOUSE ───────────────────────────────────────────────
CREATE TABLE WAREHOUSE (
  warehouse_id   INT PRIMARY KEY,
  company_id     INT REFERENCES COMPANY(company_id),
  location       VARCHAR(100),
  region         VARCHAR(50),
  capacity_units INT
);

INSERT INTO WAREHOUSE VALUES
(1, 1, 'Delhi Logistics Hub',     'North', 50000),
(2, 1, 'Gurugram Storage Center', 'North', 30000),
(3, 2, 'Chennai Port Warehouse',  'South', 45000),
(4, 2, 'Bangalore Cold Store',    'South', 20000),
(5, 3, 'Mumbai Central WH',       'West',  60000),
(6, 3, 'Pune Industrial Park',    'West',  25000),
(7, 4, 'Kolkata Freight Depot',   'East',  35000),
(8, 4, 'Bhubaneswar Storage',     'East',  18000);

-- ─── PRODUCT ─────────────────────────────────────────────────
CREATE TABLE PRODUCT (
  product_id   INT PRIMARY KEY,
  product_name VARCHAR(100),
  category     VARCHAR(50),
  unit         VARCHAR(20),
  unit_price   DECIMAL(10,2)
);

INSERT INTO PRODUCT VALUES
(1,  'Microcontroller MCU-32',   'Electronics',   'Units',  450.00),
(2,  'LCD Display Panel 7"',     'Electronics',   'Units',  820.00),
(3,  'HDMI Cable 2m',            'Electronics',   'Units',   95.00),
(4,  'Steel Sheet 2mm',          'Raw Materials', 'Kg',      62.50),
(5,  'Aluminium Rod 10mm',       'Raw Materials', 'Kg',      88.00),
(6,  'Copper Wire 1.5mm',        'Raw Materials', 'Kg',     310.00),
(7,  'Instant Noodles Pack',     'FMCG',          'Units',   18.00),
(8,  'Soap Bar 100g',            'FMCG',          'Units',   22.00),
(9,  'Shampoo Bottle 200ml',     'FMCG',          'Units',   85.00),
(10, 'Corrugated Box 30x20x15', 'Packaging',     'Units',   12.00),
(11, 'Bubble Wrap Roll 50m',     'Packaging',     'Units',  220.00),
(12, 'Bearing 6205-2RS',         'Spare Parts',   'Units',  145.00),
(13, 'O-Ring Set (100pcs)',      'Spare Parts',   'Units',  380.00),
(14, 'Transformer 5KVA',         'Electronics',   'Units', 4200.00),
(15, 'PVC Granules',             'Raw Materials', 'Kg',      55.00);

-- ─── INVENTORY ───────────────────────────────────────────────
CREATE TABLE INVENTORY (
  inventory_id  INT PRIMARY KEY,
  warehouse_id  INT REFERENCES WAREHOUSE(warehouse_id),
  product_id    INT REFERENCES PRODUCT(product_id),
  current_stock INT,
  reorder_point INT,
  last_updated  DATE
);

INSERT INTO INVENTORY VALUES
(1,  1, 1,  1200, 500,  '2026-04-15'),
(2,  1, 4,   420, 600,  '2026-04-15'),
(3,  1, 10, 1800, 500,  '2026-04-15'),
(4,  3, 7,   650, 400,  '2026-04-14'),
(5,  3, 8,   980, 400,  '2026-04-14'),
(6,  3, 9,   310, 300,  '2026-04-14'),
(7,  5, 2,   800, 400,  '2026-04-16'),
(8,  5, 5,   110, 300,  '2026-04-16'),
(9,  5, 11,  420, 200,  '2026-04-16'),
(10, 7, 12,  180, 150,  '2026-04-13'),
(11, 7, 13,   85, 120,  '2026-04-13'),
(12, 7, 6,   230, 400,  '2026-04-13'),
(13, 2, 3,   560, 200,  '2026-04-15'),
(14, 4, 14,   45,  30,  '2026-04-14'),
(15, 6, 15,  700, 500,  '2026-04-16'),
(16, 8, 1,   300, 200,  '2026-04-12'),
(17, 1, 5,   900, 300,  '2026-04-15'),
(18, 3, 4,   150, 350,  '2026-04-14'),
(19, 5, 7,   480, 300,  '2026-04-16'),
(20, 7, 10,  620, 400,  '2026-04-13');

-- ─── SUPPLIER ────────────────────────────────────────────────
CREATE TABLE SUPPLIER (
  supplier_id       INT PRIMARY KEY,
  supplier_name     VARCHAR(100),
  contact           VARCHAR(100),
  region            VARCHAR(50),
  performance_score DECIMAL(5,2)
);

INSERT INTO SUPPLIER VALUES
(1, 'VendorA – TechParts Co.',    'vendora@techparts.in',   'North', 92.0),
(2, 'VendorB – MetalWorks Ltd.',  'vendorb@metalworks.in',  'West',  85.0),
(3, 'VendorC – PackPro Supplies', 'vendorc@packpro.in',     'South', 78.0),
(4, 'VendorD – RawMat Traders',   'vendord@rawmat.in',      'East',  65.0),
(5, 'VendorE – SpareHub India',   'vendore@sparehub.in',    'West',  55.0),
(6, 'VendorF – ElecSource',       'vendorf@elecsource.in',  'North', 80.0),
(7, 'VendorG – FMCG Direct',      'vendorg@fmcgdirect.in',  'South', 73.0);

-- ─── PROCUREMENT_ORDER ───────────────────────────────────────
CREATE TABLE PROCUREMENT_ORDER (
  proc_order_id INT PRIMARY KEY,
  supplier_id   INT REFERENCES SUPPLIER(supplier_id),
  product_id    INT REFERENCES PRODUCT(product_id),
  quantity      INT,
  total_cost    DECIMAL(12,2),
  order_date    DATE,
  expected_date DATE,
  status        VARCHAR(30)
);

INSERT INTO PROCUREMENT_ORDER VALUES
(1,  1, 1,  500,  225000.00, '2026-03-01', '2026-03-15', 'Delivered'),
(2,  2, 4,  2000, 125000.00, '2026-03-05', '2026-03-20', 'Delivered'),
(3,  3, 10, 3000,  36000.00, '2026-03-10', '2026-03-22', 'Delivered'),
(4,  4, 5,  1000,  88000.00, '2026-03-12', '2026-03-28', 'Delayed'),
(5,  5, 12,  300,  43500.00, '2026-03-15', '2026-03-30', 'Delivered'),
(6,  6, 2,  400,  328000.00, '2026-03-18', '2026-04-05', 'Delivered'),
(7,  7, 7,  2000,  36000.00, '2026-03-20', '2026-04-01', 'Delivered'),
(8,  4, 6,   500, 155000.00, '2026-03-22', '2026-04-08', 'Delayed'),
(9,  2, 15, 3000, 165000.00, '2026-04-01', '2026-04-14', 'In Transit'),
(10, 1, 14,   20,  84000.00, '2026-04-02', '2026-04-18', 'In Transit'),
(11, 3, 11,  200,  44000.00, '2026-04-05', '2026-04-19', 'Pending'),
(12, 5, 13,  150,  57000.00, '2026-04-07', '2026-04-22', 'Pending'),
(13, 6, 3,  1000,  95000.00, '2026-04-10', '2026-04-25', 'Pending'),
(14, 7, 8,  2000,  44000.00, '2026-04-12', '2026-04-28', 'Pending'),
(15, 2, 4,  1500,  93750.00, '2026-04-14', '2026-04-30', 'Pending');

-- ─── ORDERS ──────────────────────────────────────────────────
CREATE TABLE ORDERS (
  order_id     INT PRIMARY KEY,
  company_id   INT REFERENCES COMPANY(company_id),
  warehouse_id INT REFERENCES WAREHOUSE(warehouse_id),
  order_date   DATE,
  status       VARCHAR(30),
  total_value  DECIMAL(12,2)
);

INSERT INTO ORDERS VALUES
(1001, 1, 1, '2026-01-05', 'Fulfilled',  128500.00),
(1002, 2, 3, '2026-01-08', 'Fulfilled',   54200.00),
(1003, 3, 5, '2026-01-12', 'Fulfilled',  310800.00),
(1004, 4, 7, '2026-01-15', 'Fulfilled',   22400.00),
(1005, 1, 2, '2026-01-20', 'Fulfilled',   87600.00),
(1006, 2, 4, '2026-02-02', 'Fulfilled',   43100.00),
(1007, 3, 6, '2026-02-08', 'Fulfilled',  195000.00),
(1008, 4, 8, '2026-02-14', 'Delayed',     31500.00),
(1009, 1, 1, '2026-02-18', 'Fulfilled',  220000.00),
(1010, 2, 3, '2026-02-22', 'Fulfilled',   68900.00),
(1011, 3, 5, '2026-03-01', 'Fulfilled',  410000.00),
(1012, 1, 2, '2026-03-05', 'Fulfilled',   55000.00),
(1013, 4, 7, '2026-03-10', 'Delayed',     18200.00),
(1014, 2, 4, '2026-03-15', 'Fulfilled',   92000.00),
(1015, 3, 6, '2026-03-20', 'Fulfilled',  178500.00),
(1016, 1, 1, '2026-04-01', 'In Transit', 340000.00),
(1017, 2, 3, '2026-04-03', 'In Transit',  76800.00),
(1018, 3, 5, '2026-04-06', 'Pending',    215000.00),
(1019, 4, 7, '2026-04-09', 'Pending',     42300.00),
(1020, 1, 2, '2026-04-12', 'Pending',     98500.00),
(1021, 2, 4, '2026-04-14', 'Pending',     61000.00),
(1022, 3, 6, '2026-04-16', 'Pending',    182000.00),
(1023, 4, 8, '2026-04-17', 'Pending',     29000.00);

-- ─── ORDER_ITEMS ─────────────────────────────────────────────
CREATE TABLE ORDER_ITEMS (
  item_id    INT PRIMARY KEY,
  order_id   INT REFERENCES ORDERS(order_id),
  product_id INT REFERENCES PRODUCT(product_id),
  quantity   INT,
  unit_price DECIMAL(10,2)
);

INSERT INTO ORDER_ITEMS VALUES
(1,  1001, 1,  50,  450.00),
(2,  1001, 3, 200,   95.00),
(3,  1001, 10, 500,  12.00),
(4,  1002, 7,  800,  18.00),
(5,  1002, 8,  500,  22.00),
(6,  1002, 9,  200,  85.00),
(7,  1003, 2,  100, 820.00),
(8,  1003, 14,  50, 4200.00),
(9,  1004, 12, 100, 145.00),
(10, 1004, 13,  50, 380.00),
(11, 1005, 1,  80,  450.00),
(12, 1005, 3, 300,   95.00),
(13, 1006, 7, 600,   18.00),
(14, 1006, 9, 250,   85.00),
(15, 1007, 2, 120,  820.00),
(16, 1007, 11, 80,  220.00),
(17, 1008, 12, 80,  145.00),
(18, 1009, 1, 200,  450.00),
(19, 1009, 2, 100,  820.00),
(20, 1010, 7, 900,   18.00),
(21, 1010, 8, 700,   22.00),
(22, 1011, 2, 200,  820.00),
(23, 1011, 14, 40, 4200.00),
(24, 1012, 3, 500,   95.00),
(25, 1013, 12, 60,  145.00),
(26, 1014, 7, 800,   18.00),
(27, 1014, 9, 400,   85.00),
(28, 1015, 2, 150,  820.00),
(29, 1016, 1, 300,  450.00),
(30, 1016, 14, 30, 4200.00);

-- ─── DELIVERY ────────────────────────────────────────────────
CREATE TABLE DELIVERY (
  delivery_id    INT PRIMARY KEY,
  order_id       INT REFERENCES ORDERS(order_id),
  scheduled_date DATE,
  actual_date    DATE,
  carrier        VARCHAR(100),
  status         VARCHAR(30)
);

INSERT INTO DELIVERY VALUES
(1,  1001, '2026-01-10', '2026-01-10', 'BlueDart Express',    'On Time'),
(2,  1002, '2026-01-13', '2026-01-14', 'DTDC Courier',        'On Time'),
(3,  1003, '2026-01-17', '2026-01-17', 'Delhivery Ltd',       'On Time'),
(4,  1004, '2026-01-20', '2026-01-22', 'Ecom Express',        'Delayed'),
(5,  1005, '2026-01-25', '2026-01-25', 'BlueDart Express',    'On Time'),
(6,  1006, '2026-02-07', '2026-02-07', 'DTDC Courier',        'On Time'),
(7,  1007, '2026-02-13', '2026-02-15', 'Delhivery Ltd',       'Delayed'),
(8,  1008, '2026-02-19', '2026-02-24', 'Ecom Express',        'Delayed'),
(9,  1009, '2026-02-23', '2026-02-23', 'BlueDart Express',    'On Time'),
(10, 1010, '2026-02-27', '2026-02-27', 'DTDC Courier',        'On Time'),
(11, 1011, '2026-03-06', '2026-03-06', 'Delhivery Ltd',       'On Time'),
(12, 1012, '2026-03-10', '2026-03-10', 'BlueDart Express',    'On Time'),
(13, 1013, '2026-03-15', '2026-03-19', 'Ecom Express',        'Delayed'),
(14, 1014, '2026-03-20', '2026-03-20', 'DTDC Courier',        'On Time'),
(15, 1015, '2026-03-25', '2026-03-25', 'Delhivery Ltd',       'On Time'),
(16, 1016, '2026-04-08', NULL,          'BlueDart Express',   'In Transit'),
(17, 1017, '2026-04-10', NULL,          'DTDC Courier',       'In Transit'),
(18, 1018, '2026-04-15', NULL,          'Delhivery Ltd',      'Pending'),
(19, 1019, '2026-04-16', NULL,          'Ecom Express',       'Pending'),
(20, 1020, '2026-04-20', NULL,          'BlueDart Express',   'Pending'),
(21, 1021, '2026-04-22', NULL,          'DTDC Courier',       'Pending'),
(22, 1022, '2026-04-25', NULL,          'Delhivery Ltd',      'Pending'),
(23, 1023, '2026-04-28', NULL,          'Ecom Express',       'Pending');

-- ─── DEMAND_FORECAST ─────────────────────────────────────────
CREATE TABLE DEMAND_FORECAST (
  forecast_id      INT PRIMARY KEY,
  product_id       INT REFERENCES PRODUCT(product_id),
  warehouse_id     INT REFERENCES WAREHOUSE(warehouse_id),
  forecast_month   DATE,
  forecasted_units INT,
  actual_units     INT,
  model_used       VARCHAR(50)
);

INSERT INTO DEMAND_FORECAST VALUES
-- Historical actuals (Jan–Apr 2026)
(1,  1, 1, '2026-01-01', 4700, 4800, 'ARIMA(1,1,1)'),
(2,  1, 1, '2026-02-01', 5100, 5200, 'ARIMA(1,1,1)'),
(3,  1, 1, '2026-03-01', 5400, 5500, 'ARIMA(1,1,1)'),
(4,  1, 1, '2026-04-01', 5600, 5700, 'ARIMA(1,1,1)'),
-- Forecasts (May–Oct 2026)
(5,  1, 1, '2026-05-01', 5900, NULL, 'ARIMA(1,1,1)'),
(6,  1, 1, '2026-06-01', 6300, NULL, 'ARIMA(1,1,1)'),
(7,  1, 1, '2026-07-01', 6600, NULL, 'ARIMA(1,1,1)'),
(8,  1, 1, '2026-08-01', 7000, NULL, 'ARIMA(1,1,1)'),
(9,  1, 1, '2026-09-01', 6800, NULL, 'ARIMA(1,1,1)'),
(10, 1, 1, '2026-10-01', 7200, NULL, 'ARIMA(1,1,1)'),
-- Product 7 (FMCG) at Chennai
(11, 7, 3, '2026-01-01', 7800, 8000, 'ARIMA(2,1,1)'),
(12, 7, 3, '2026-02-01', 8200, 8400, 'ARIMA(2,1,1)'),
(13, 7, 3, '2026-03-01', 8600, 8500, 'ARIMA(2,1,1)'),
(14, 7, 3, '2026-04-01', 8900, 9100, 'ARIMA(2,1,1)'),
(15, 7, 3, '2026-05-01', 9400, NULL, 'ARIMA(2,1,1)'),
(16, 7, 3, '2026-06-01', 9800, NULL, 'ARIMA(2,1,1)'),
-- Product 4 (Raw Mat Steel) at Delhi — stockout risk trend
(17, 4, 1, '2026-01-01', 1800, 1900, 'ARIMA(1,1,0)'),
(18, 4, 1, '2026-02-01', 2000, 2100, 'ARIMA(1,1,0)'),
(19, 4, 1, '2026-03-01', 2200, 2400, 'ARIMA(1,1,0)'),
(20, 4, 1, '2026-04-01', 2500, 2600, 'ARIMA(1,1,0)'),
(21, 4, 1, '2026-05-01', 2800, NULL, 'ARIMA(1,1,0)'),
(22, 4, 1, '2026-06-01', 3100, NULL, 'ARIMA(1,1,0)');

-- ─── USEFUL ANALYTICAL QUERIES ───────────────────────────────

-- 1. KPI: On-Time Delivery Rate
-- SELECT 
--   ROUND(100.0 * SUM(CASE WHEN status = 'On Time' THEN 1 ELSE 0 END) / COUNT(*), 1) AS otd_percent
-- FROM DELIVERY WHERE actual_date IS NOT NULL;

-- 2. Stockout Risk Items
-- SELECT p.product_name, p.category, i.current_stock, i.reorder_point,
--   w.location,
--   CASE WHEN i.current_stock < i.reorder_point THEN 'Stockout Risk' ELSE 'OK' END AS status
-- FROM INVENTORY i
-- JOIN PRODUCT p ON i.product_id = p.product_id
-- JOIN WAREHOUSE w ON i.warehouse_id = w.warehouse_id
-- ORDER BY (i.current_stock - i.reorder_point) ASC;

-- 3. Procurement Cost by Month
-- SELECT DATE_FORMAT(order_date,'%Y-%m') AS month,
--   SUM(total_cost)/100000 AS total_cost_lakhs
-- FROM PROCUREMENT_ORDER
-- GROUP BY month ORDER BY month;

-- 4. Supplier Performance Ranking
-- SELECT supplier_name, performance_score,
--   RANK() OVER (ORDER BY performance_score DESC) AS rank
-- FROM SUPPLIER;

-- 5. Demand Forecast Accuracy
-- SELECT p.product_name, f.forecast_month,
--   f.forecasted_units, f.actual_units,
--   ROUND(100.0 * ABS(f.actual_units - f.forecasted_units) / f.actual_units, 1) AS mape_pct
-- FROM DEMAND_FORECAST f
-- JOIN PRODUCT p ON f.product_id = p.product_id
-- WHERE f.actual_units IS NOT NULL;

-- ─── END OF SCRIPT ───────────────────────────────────────────

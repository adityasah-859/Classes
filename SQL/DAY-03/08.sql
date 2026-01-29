CREATE DATABASE IF NOT EXISTS nyse;
USE nyse;
CREATE TABLE nyse_daily_prices (
    exchange        VARCHAR(10),
    symbol          VARCHAR(10),
    trade_date      DATE,
    open_price      DECIMAL(10,2),
    high_price      DECIMAL(10,2),
    low_price       DECIMAL(10,2),
    close_price     DECIMAL(10,2),
    volume          BIGINT,
    adj_close_price DECIMAL(10,2)
);
   
LOAD DATA LOCAL INFILE '/Users/as-mac-1346/Desktop/Classes/SQL/DAY-03/nyse_sample_data.csv'
INTO TABLE nyse_daily_prices
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
(exchange, symbol, trade_date, open_price, high_price, low_price, close_price, volume, adj_close_price);
SELECT *
FROM nyse_daily_prices
LIMIT 10;

SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;

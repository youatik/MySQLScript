CREATE SCHEMA IF NOT EXISTS hibernate;

SET FOREIGN_KEY_CHECKS = 0;

-- Drop tables
DROP TABLE IF EXISTS hibernate.shoppingCart;
DROP TABLE IF EXISTS hibernate.orderItem;
DROP TABLE IF EXISTS hibernate.clientOrder;
DROP TABLE IF EXISTS hibernate.payment;
DROP TABLE IF EXISTS hibernate.userAuthentication;
DROP TABLE IF EXISTS hibernate.library;
DROP TABLE IF EXISTS hibernate.client;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE IF NOT EXISTS hibernate.client (
  clientId INT PRIMARY KEY AUTO_INCREMENT,
  firstName VARCHAR(50) NOT NULL,
  lastName VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL,
  address VARCHAR(200) NOT NULL
);

CREATE TABLE IF NOT EXISTS hibernate.library (
  ean_isbn13 BIGINT NOT NULL,
  title VARCHAR(145) NOT NULL,
  creators VARCHAR(123) NOT NULL,
  firstName VARCHAR(13) NOT NULL,
  lastName VARCHAR(14) NOT NULL,
  description VARCHAR(4769) NOT NULL,
  publisher VARCHAR(37),
  publishDate DATE,
  price NUMERIC(7,3) NOT NULL,
  length INTEGER NOT NULL,
  PRIMARY KEY(ean_isbn13)
);

CREATE TABLE IF NOT EXISTS hibernate.userAuthentication (
  clientId INT PRIMARY KEY,
  username VARCHAR(100) NOT NULL,
  password VARCHAR(100) NOT NULL,
  CONSTRAINT fk_auth_client
    FOREIGN KEY (clientId)
    REFERENCES hibernate.client (clientId)
);



CREATE TABLE IF NOT EXISTS hibernate.clientOrder (
  orderId INT PRIMARY KEY AUTO_INCREMENT,
  clientId INT,
  orderDate DATE,
  totalAmount DECIMAL(10,2),
  FOREIGN KEY (clientId) REFERENCES hibernate.client(clientId)
);

CREATE TABLE IF NOT EXISTS hibernate.payment (
  paymentId INT PRIMARY KEY AUTO_INCREMENT,
  orderId INT NOT NULL,
  cardNumber VARCHAR(16) NOT NULL,
  expiration DATE NOT NULL,
  CONSTRAINT fk_payment_order
    FOREIGN KEY (orderId)
    REFERENCES hibernate.clientOrder (orderId)
);

CREATE TABLE IF NOT EXISTS hibernate.orderItem (
  id INT PRIMARY KEY AUTO_INCREMENT,
  orderId INT,
  ean_isbn13 BIGINT,
  quantity INT,
  price DECIMAL(10,2), 
  clientId INT,
  FOREIGN KEY (orderId) REFERENCES hibernate.clientOrder(orderId),
  FOREIGN KEY (ean_isbn13) REFERENCES hibernate.library(ean_isbn13)
);

DELIMITER //

CREATE TRIGGER hibernate.calculate_price
BEFORE INSERT ON hibernate.orderItem
FOR EACH ROW
BEGIN
    SET NEW.price = (SELECT price FROM hibernate.library WHERE ean_isbn13 = NEW.ean_isbn13);
END //

DELIMITER ;


CREATE TABLE IF NOT EXISTS hibernate.shoppingCart (
  id INT PRIMARY KEY AUTO_INCREMENT,
  clientId INT,
  ean_isbn13 BIGINT,
  quantity INT,
  FOREIGN KEY (clientId) REFERENCES hibernate.client(clientId),
  FOREIGN KEY (ean_isbn13) REFERENCES hibernate.library(ean_isbn13)
);

DELIMITER //

CREATE TRIGGER hibernate.calculate_total_amount
AFTER INSERT ON hibernate.orderItem
FOR EACH ROW
BEGIN
  UPDATE hibernate.clientOrder
  SET totalAmount = (SELECT SUM(price * quantity) FROM hibernate.orderItem WHERE orderId = NEW.orderId)
  WHERE orderId = NEW.orderId;
END;

DELIMITER ;

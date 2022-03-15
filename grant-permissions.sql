CREATE USER 'manager'@'localhost' IDENTIFIED BY 'strongpass';
CREATE USER 'user'@'localhost' IDENTIFIED BY 'weakpass';
-- Can add more users or refine permissions
GRANT ALL PRIVILEGES ON tennis.* TO 'manager'@'localhost';
GRANT SELECT ON tennis.* TO 'user'@'localhost';
GRANT EXECUTE ON FUNCTION authenticate TO 'user'@'localhost';
FLUSH PRIVILEGES;

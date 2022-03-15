
DELIMITER !
CREATE FUNCTION make_salt(num_chars INT)
RETURNS VARCHAR(20) NOT DETERMINISTIC NO SQL
BEGIN
    DECLARE salt VARCHAR(20) DEFAULT '';
    SET num_chars = LEAST(20, num_chars);
    WHILE num_chars > 0 DO 
        SET salt = CONCAT(salt, CHAR(32 + FLOOR(RAND() * (5))));
        SET num_chars = num_chars - 1;
    END WHILE;
    RETURN salt;
END !
DELIMITER ;


CREATE TABLE user_info (
    -- Usernames are up to 20 characters.
    username VARCHAR(20) PRIMARY KEY,
    -- Salt will be 8 characters all the time, so we can make this 8.
    salt CHAR(8) NOT NULL,
    -- We use SHA-2 with 256-bit hashes.
    password_hash BINARY(64) NOT NULL
);

-- [Problem 1a]
-- Adds a new user to the user_info table, using the specified password (max
-- of 20 characters). Salts the password with a newly-generated salt value,
-- and then the salt and hash values are both stored in the table.
DELIMITER !
CREATE PROCEDURE sp_add_user(new_username VARCHAR(20), password VARCHAR(20))
BEGIN
    DECLARE salt CHAR(8);
    DECLARE password_hash BINARY(64);

    SELECT make_salt(8) INTO salt;
    SELECT SHA2(CONCAT(password, salt), 256) INTO password_hash;
    INSERT INTO user_info
        VALUES (new_username, salt, password_hash);
END !
DELIMITER ;

-- [Problem 1b]
-- Authenticates the specified username and password against the data
-- in the user_info table.  Returns 1 if the user appears in the table, and the
-- specified password hashes to the value for the user. Otherwise returns 0.
DELIMITER !
CREATE FUNCTION authenticate(entered_username VARCHAR(20), 
entered_password VARCHAR(20))
RETURNS TINYINT DETERMINISTIC
BEGIN
    DECLARE if_username TINYINT DEFAULT 0;
    DECLARE if_password TINYINT DEFAULT 0;
    DECLARE temp_password_hash BINARY(64);
    DECLARE temp_salt CHAR(8);

    SELECT COUNT(*) INTO if_username FROM user_info
    WHERE username = entered_username;

    IF if_username = 1
        THEN
            SELECT salt INTO temp_salt FROM
            user_info WHERE username = entered_username;
            SELECT password_hash INTO temp_password_hash FROM
            user_info WHERE username = entered_username;
            IF SHA2(CONCAT(entered_password, temp_salt), 256) 
            = temp_password_hash
                THEN SET if_password = 1;
            END IF;
    END IF;
    RETURN if_password;
END !
DELIMITER ;


-- [Problem 1c]
-- Add at least two users into your user_info table so that when we run this file,
-- we will have examples users in the database.
CALL sp_add_user('ryan', 'securepassword');
CALL sp_add_user('raffey', 'strongpass');


-- [Problem 1d]
-- Optional: Create a procedure sp_change_password to generate a new salt and 
-- change the given
-- user's password to the given password (after salting and hashing)
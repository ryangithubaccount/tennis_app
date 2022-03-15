/*
 * Calculating the number of upsets in a specific tournament. These
 * are instances where a lower or unseeded player defeats a player with
 * a higher seed.
 */
DELIMITER !
CREATE FUNCTION upsets(entered_id VARCHAR(10))
RETURNS INT DETERMINISTIC
BEGIN
    DECLARE num_upsets INT DEFAULT 0;
    DECLARE temp_winner INT DEFAULT NULL;
    DECLARE temp_loser INT DEFAULT NULL;
    DECLARE done INT DEFAULT 0;
    DECLARE cur CURSOR FOR
        SELECT winner_seed, loser_seed
        FROM matches WHERE entered_id = tournament_id;
    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000'
        SET done = 1;
    OPEN cur;
    WHILE NOT done DO
        FETCH cur INTO temp_winner, temp_loser;
        IF NOT done THEN
            -- For the first instance, we don't have a previous submission
            IF temp_loser <> ' ' AND (temp_winner = ' ' OR temp_winner > temp_loser)
                THEN SET num_upsets = num_upsets + 1;
            END IF;
        END IF;
    END WHILE;
    CLOSE cur;
    RETURN num_upsets;
END !
DELIMITER ;


/*
*   add_new_player, 
*   the goal of this procedure is to add the information about a new player who just joined the ATP rankings, 
*   or just played their first ATP tournament. 
*   So, if the player exists, then this procedure will essentially do nothing, 
*   however if they do not exist, adds the player info to
*   player table.
*/
DELIMITER !
CREATE PROCEDURE add_new_player(new_player_id CHAR(6), new_firstname VARCHAR(20), new_lastname VARCHAR(20))
BEGIN
    DECLARE if_player_id TINYINT DEFAULT 0;

    SELECT COUNT(*) INTO if_player_id FROM player
    WHERE player_id = new_player_id;

    IF if_player_id = 0 THEN
        INSERT INTO player
            VALUES (new_player_id, new_firstname, new_lastname);
    END IF;
END !
DELIMITER ;


DELIMITER !
CREATE PROCEDURE update_win_loss(
new_winner CHAR(6),
new_loser CHAR(6)
)
BEGIN
    DECLARE wins INT;
    DECLARE losses INT;

    SELECT current_wins INTO wins FROM player_records WHERE player_id = new_winner;
    SELECT current_losses INTO losses FROM player_records WHERE player_id = new_loser;
    
    UPDATE player_records
    SET player_records.current_wins = wins + 1
    WHERE player_id = new_winner;

    UPDATE player_records
    SET player_records.current_losses = losses + 1
    WHERE player_id = new_loser;
END !

-- This trigger handles new rows added to the account table, and performs the
-- necessary updates to the branch-account statistics table.
CREATE TRIGGER trg_match_insert AFTER INSERT
    ON matches FOR EACH ROW
BEGIN
    CALL update_win_loss(NEW.winner_id, NEW.loser_id);
END !
DELIMITER ;

DELIMITER !
CREATE PROCEDURE add_player(
new_player CHAR(6)
)
BEGIN
    INSERT INTO player_records
    VALUE (new_player, 0, 0);
END !

-- This trigger handles new rows added to the player table, and performs the
-- necessary updates to the branch-account statistics table.
CREATE TRIGGER trg_player_insert AFTER INSERT
    ON player FOR EACH ROW
BEGIN
    CALL add_player(NEW.player_id);
END !
DELIMITER ;
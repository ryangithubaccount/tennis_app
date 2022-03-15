DROP TABLE IF EXISTS ranking;
DROP TABLE IF EXISTS matches;
DROP TABLE IF EXISTS tournament;
DROP TABLE IF EXISTS player_records;
DROP TABLE IF EXISTS player;

/*
 * This table stored information about each tennis player.
 */
CREATE TABLE player (
    -- Unique player id
    player_id            CHAR(6),
    -- The player name, first and last.
    firstname            VARCHAR(20) NOT NULL,
    lastname             VARCHAR(20) NOT NULL,
    PRIMARY KEY (player_id)
);

CREATE TABLE player_records (
    -- Unique player_id
    player_id           CHAR(6),
    -- Number of total wins for player past 2000
    current_wins         INT DEFAULT 0,
    -- Number of total losses for player past 2000
    current_losses       INT DEFAULT 0,
    PRIMARY KEY (player_id),
    FOREIGN KEY (player_id) REFERENCES player (player_id)
    ON DELETE CASCADE ON UPDATE CASCADE
);


/*
 * This table stores information about all the tournaments
 * in ATP circuit
 */
CREATE TABLE tournament (
    -- The unique id of the tournament being played.
    tournament_id           VARCHAR(50),
    -- The name of the tournament.
    tournament_name         VARCHAR(50) NOT NULL,
    -- The surface type on which games are played.
    surface                 VARCHAR(10) NOT NULL,
    -- The the level of competition.
    tournament_level                   CHAR(2) NOT NULL,
    -- The when the tournament was held.
    tournament_date         DATE NOT NULL,
    PRIMARY KEY (tournament_id)
);

/*
 * This table stores information about the players who played in
 * each lol match
 */
CREATE TABLE matches (
    -- The tournament id of the tournament in which match played
    tournament_id      VARCHAR(10),
    -- The match number of each match being played in tournament
    match_num         INT,
    -- Player_id of the winning player
    winner_id           CHAR(6) NOT NULL,
    -- Player_id of the losing player
    loser_id                CHAR(6) NOT NULL,
    -- The final score at the end of the match
    final_score            VARCHAR(30) NOT NULL,
    -- The duration of the match
    length_of_matches                INT DEFAULT NULL,
    -- The seeding of the winning player
    winner_seed             INT DEFAULT NULL,
    -- The seeding
    loser_seed                INT DEFAULT NULL,

    -- ensures unique player per match
    PRIMARY KEY (match_num, tournament_id),
    -- make sure when tournament deleted from tournament table
    -- any referetournament_idayers for that match deleted from played table
    FOREIGN KEY (tournament_id) REFERENCES tournament(tournament_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (winner_id) REFERENCES player(player_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (loser_id) REFERENCES player(player_id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

/*
 * A table storing ATP ranking information. It includes the date, ranking,
 * player, and number of points each player has.
 */
CREATE TABLE ranking (
    -- Date of the ranking
    ranking_date        VARCHAR(10),
    -- The rank of the player
    ranking             INT NOT NULL,
    -- The id of the player who holds this ranking
    player_id           CHAR(6),
    -- The number of ATP points the selected player had on this date
    points              INT,
    -- The date and ranking uniquely determine the player and points
    PRIMARY KEY         (ranking_date, player_id),
    -- All players must be players within the player table
    FOREIGN KEY (player_id) REFERENCES player(player_id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX better_rank ON ranking(ranking);
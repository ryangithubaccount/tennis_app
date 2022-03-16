LOAD DATA LOCAL INFILE './data/atp_players_temp_gone.csv' INTO TABLE player
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS
(player_id, firstname, lastname);

LOAD DATA LOCAL INFILE './data/tournament.csv' INTO TABLE tournament
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE './data/match_filled.csv' INTO TABLE matches
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS
SET winner_seed = NULLIF(winner_seed,''), loser_seed = NULLIF(loser_seed,'');

LOAD DATA  LOCAL INFILE './data/atp_rankings_00s_tmp.csv' INTO TABLE ranking
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS
SET points = NULLIF(points,'');

LOAD DATA LOCAL INFILE './data/atp_rankings_10s_tmp.csv' INTO TABLE ranking
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS
SET points = NULLIF(points,'');

LOAD DATA LOCAL INFILE './data/atp_rankings_20s_tmp.csv' INTO TABLE ranking
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS
SET points = NULLIF(points,'');





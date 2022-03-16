/*
 * Find all the matches that "Rafael Nadal" played in through his career.
 * Includes the tournament, final score, and whether he won or lost
 */
SELECT w_player.firstname, w_player.lastname, l_player.firstname, l_player.lastname,
tournament_name, final_score, tournament_date
FROM player AS w_player INNER JOIN matches ON
w_player.player_id = matches.winner_id
INNER JOIN player AS l_player ON
l_player.player_id = matches.loser_id
INNER JOIN tournament ON tournament.tournament_id = matches.tournament_id
WHERE (w_player.firstname like '%Rafael%' AND w_player.lastname like '%Nadal%') OR
(l_player.firstname like '%Rafael%' AND l_player.lastname like '%Nadal%')
ORDER BY tournament.tournament_date;


/*
 * The head to head history of Rafael Nadal and Novak Djokovic throughout
 * their careers.
 */
SELECT w_player.lastname AS winner, l_player.lastname AS loser, final_score, tournament_date
FROM player AS w_player JOIN matches
ON w_player.player_id = matches.winner_id
JOIN player AS l_player
ON l_player.player_id = matches.loser_id
JOIN tournament
ON tournament.tournament_id = matches.tournament_id
WHERE (w_player.firstname = 'Novak' AND l_player.lastname = 'Nadal') OR
(w_player.lastname = 'Nadal' AND l_player.firstname = 'Novak')
ORDER BY tournament_date;

/*
 * Number of weeks they stayed at the top for each player who was ranked #1
 * from 2000-2022.
 */
WITH
    player_weeks AS
        (SELECT COUNT(*) AS weeks, player_id
        FROM ranking
        WHERE ranking = 1 GROUP BY player_id)
SELECT firstname, lastname, weeks
FROM player JOIN player_weeks USING (player_id)
ORDER BY weeks DESC;

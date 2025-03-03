WITH tournament_winners AS (
    SELECT
        year_match,
        CASE
            WHEN home_goals > away_goals THEN home_team
            WHEN home_goals < away_goals THEN away_team
            WHEN win_conditions LIKE CONCAT('%', home_team, '%') THEN home_team
            WHEN win_conditions LIKE CONCAT('%', away_team, '%') THEN away_team
        END AS winner
    FROM (
        SELECT * FROM world_cup_matches
        UNION ALL
        SELECT * FROM world_cup_matches_2022
    ) wcm
    WHERE stage = 'Final'
),
winner_matches AS (
    SELECT
        wcm.year_match,
        wcm.home_team,
        wcm.away_team,
        wcm.home_goals,
        wcm.away_goals,
        tw.winner,
        CASE
            WHEN wcm.home_team = tw.winner THEN wcm.home_goals
            WHEN wcm.away_team = tw.winner THEN wcm.away_goals
        END AS winner_goals,
        CASE
            WHEN wcm.home_team = tw.winner THEN wcm.away_goals
            WHEN wcm.away_team = tw.winner THEN wcm.home_goals
        END AS opponent_goals
    FROM (
        SELECT * FROM world_cup_matches
        UNION ALL
        SELECT * FROM world_cup_matches_2022
    ) wcm
    JOIN tournament_winners tw ON wcm.year_match = tw.year_match
    WHERE wcm.home_team = tw.winner OR wcm.away_team = tw.winner
),
match_results AS (
    SELECT
        CONCAT(winner_goals, ':', opponent_goals) AS result,
        COUNT(*) AS result_count
    FROM winner_matches
    GROUP BY winner_goals, opponent_goals
),
total_matches AS (
    SELECT
        SUM(result_count) AS total_count
    FROM match_results
)
SELECT
    mr.result,
    ROUND((mr.result_count / tm.total_count) * 100, 2) AS percentage
FROM match_results mr
CROSS JOIN total_matches tm
ORDER BY percentage DESC;


/* The data used in the analysis was downloaded from KajoDataSpace and was updated with results from the recent World Cup. */ 

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
        tw.winner
    FROM (
        SELECT * FROM world_cup_matches
        UNION ALL
        SELECT * FROM world_cup_matches_2022
    ) wcm
    JOIN tournament_winners tw ON wcm.year_match = tw.year_match
    WHERE wcm.home_team = tw.winner OR wcm.away_team = tw.winner
)
SELECT
    wm.year_match,
    wm.winner,
    ROUND(
        AVG(
            CASE 
                WHEN wm.home_team = wm.winner AND wm.home_goals > wm.away_goals THEN 3
                WHEN wm.away_team = wm.winner AND wm.away_goals > wm.home_goals THEN 3
                WHEN wm.home_team = wm.winner AND wm.home_goals = wm.away_goals THEN 1
                WHEN wm.away_team = wm.winner AND wm.away_goals = wm.home_goals THEN 1
                ELSE 0
            END
        ), 2
    ) AS avg_points_per_match,
    ROUND(
        AVG(
            CASE 
                WHEN wm.home_team = wm.winner THEN wm.home_goals
                WHEN wm.away_team = wm.winner THEN wm.away_goals
            END
        ), 2
    ) AS avg_goals_scored_per_match,
    ROUND(
        AVG(
            CASE 
                WHEN wm.home_team = wm.winner THEN wm.away_goals
                WHEN wm.away_team = wm.winner THEN wm.home_goals
            END
        ), 2
    ) AS avg_goals_lost_per_match,
    COUNT(*) AS matches
FROM winner_matches wm
GROUP BY wm.year_match, wm.winner;

/* The data used in the analysis was downloaded from KajoDataSpace and was updated with results from the recent World Cup. */ 


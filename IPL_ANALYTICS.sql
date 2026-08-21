CREATE TABLE matches (
    id NUMBER,
    season NUMBER,
    city VARCHAR2(50),
    date_of_the_match DATE,
    team1 VARCHAR2(100),
    team2 VARCHAR2(100),
    toss_winner VARCHAR2(100),
    toss_decision VARCHAR2(20),
    winner VARCHAR2(100),
    player_of_match VARCHAR2(100),
    venue VARCHAR2(200)
);


CREATE TABLE deliveries (
  match_id NUMBER,
  inning NUMBER,
  batting_team VARCHAR(30),
  bowling_team VARCHAR(30),
  batsman VARCHAR(30),
  bowler VARCHAR(30),
  batsman_runs VARCHAR(30),
  extras_runs VARCHAR(30),
  total_runs VARCHAR(30),
  dismissal_kind VARCHAR(30),
  IS_WICKET NUMBER
);

-- Q1: Most successful teams by wins
SELECT winner AS team,
       COUNT(*) AS total_wins
FROM matches
WHERE winner IS NOT NULL
GROUP BY winner
ORDER BY total_wins DESC;


-- Q2: Does winning toss help win the match?
SELECT
  COUNT(*) AS total_matches,
  SUM(CASE WHEN toss_winner = winner THEN 1 ELSE 0 END) AS toss_winner_won,
  ROUND(100.0 * SUM(CASE WHEN toss_winner = winner THEN 1 ELSE 0 END) / COUNT(*), 2) AS win_pct
FROM matches
WHERE winner IS NOT NULL;


-- Q3: Field first or bat first — which wins more?
SELECT toss_decision,
       COUNT(*) AS times_chosen,
       SUM(CASE WHEN toss_winner = winner THEN 1 ELSE 0 END) AS times_won,
       ROUND(100.0 * SUM(CASE WHEN toss_winner = winner THEN 1 ELSE 0 END) / COUNT(*), 2) AS win_pct
FROM matches
WHERE winner IS NOT NULL
GROUP BY toss_decision;


-- Q4: Top 10 run scorers of all time
SELECT *
FROM (
    SELECT batsman,
           SUM(batsman_runs) AS total_runs,
           COUNT(DISTINCT match_id) AS matches_played,
           ROUND(AVG(batsman_runs), 2) AS avg_runs_per_ball
    FROM deliveries
    GROUP BY batsman
    ORDER BY total_runs DESC
)
WHERE ROWNUM <= 10;



-- Q5: Top 10 wicket takers of all time
SELECT * FROM (
    SELECT bowler,
           COUNT(*) AS total_wickets,
           COUNT(DISTINCT match_id) AS matches_bowled
    FROM deliveries
    WHERE is_wicket = 1
      AND dismissal_kind NOT IN ('run out', 'retired hurt', 'obstructing the field')
    GROUP BY bowler
    ORDER BY total_wickets DESC
)
WHERE ROWNUM<=10;


-- Q6: Most Player of the Match awards
SELECT *
FROM (
    SELECT player_of_match,
           COUNT(*) AS awards
    FROM matches
    WHERE player_of_match IS NOT NULL
    GROUP BY player_of_match
    ORDER BY awards DESC
)
WHERE ROWNUM <= 10;




-- Q7: Most matches hosted by venue
select * from (

    SELECT venue, city, COUNT(*) AS matches_hosted
    FROM matches
    GROUP BY venue, city
    ORDER BY matches_hosted DESC
)
WHERE ROWNUM<=10;


-- Q8: Season-wise total runs scored (batting trends over years)
SELECT m.season,
       SUM(d.total_RUNS) AS total_runs,
       COUNT(DISTINCT m.id) AS total_matches,
       ROUND(AVG(d.total_RUNS), 2) AS avg_runs_per_ball
FROM matches m
JOIN deliveries d ON m.id = d.match_id
GROUP BY m.season
ORDER BY m.season;

-- Q9: Best bowling economy (min 100 overs bowled)
SELECT * FROM (
    SELECT bowler,
           SUM(TOTAL_RUNS) AS runs_given,
           COUNT(*) / 6 AS overs_bowled,
           ROUND(SUM(TOTAL_RUNS) * 6.0 / COUNT(*), 2) AS economy
    FROM deliveries
    GROUP BY bowler
    HAVING COUNT(*) >= 600  -- 100 overs = 600 balls
    ORDER BY economy ASC
)
WHERE ROWNUM<=10;



-- Q10: Highest team totals in a single innings
SELECT * FROM (
    SELECT match_id, batting_team, inning,
           SUM(total_RUNS) AS team_total
    FROM deliveries
    GROUP BY match_id, batting_team, inning
    ORDER BY team_total DESC
)
WHERE ROWNUM<=10;

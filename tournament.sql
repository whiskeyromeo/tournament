-- W. Russell
-- 12.1.2015
DROP TABLE players CASCADE;
DROP TABLE tournament CASCADE;
DROP TABLE matches CASCADE;
DROP FUNCTION get_wins();
DROP FUNCTION get_total_matches();
DROP VIEW playerStandings;
DROP VIEW swissTournament;
DROP FUNCTION opponent_match_wins();
DROP VIEW playerStandingsOMW;
DROP VIEW swissTournamentOMW;


-- Create the players table
CREATE TABLE IF NOT EXISTS players(
    id      serial               primary key,
    name    varchar(255)         not null
); 

-- Create the tournament table
CREATE TABLE IF NOT EXISTS tournament(
    id      serial          primary key,
    title   varchar(44)     not null
);

-- Create the matches table
CREATE TABLE IF NOT EXISTS matches(
    id              serial      primary key,
    tournament_id   int         references tournament(id),
    winner          int         references players(id),
    loser           int         references players(id),
    draw            bool        default false,
    bye             bool        default false
);

-- Create function to get wins
CREATE OR REPLACE FUNCTION get_wins(players_id int)
RETURNS bigint
AS $BODY$
DECLARE 
    result bigint;
BEGIN
    select count(*) from matches where winner = players_id and draw = false INTO result;
    RETURN result;
END;
$BODY$ LANGUAGE plpgsql;

-- Create function to get the total number of matches
CREATE OR REPLACE FUNCTION get_total_matches(players_id int)
RETURNS bigint
AS $BODY$
DECLARE 
    result bigint;
BEGIN
    select count(*) 
     from matches      
     where (winner = players_id  or loser = players_id) 
            and (bye = false)
    INTO result;
    RETURN result;
END;
$BODY$ LANGUAGE plpgsql;

-- Create a view for the playerStandings
CREATE VIEW playerStandings AS
    SELECT 
        players.id as "id",
        players.name as"name",
        (select get_wins(players.id)) as wins,
        (select get_total_matches(players.id))
    FROM players
    ORDER BY wins DESC;

-- Create a view for the pairings of opponents based on playerStandings
CREATE VIEW swissTournament AS
    SELECT results.id1, results.player1, results2.id2, results2.player2
      FROM 
         (SELECT 
          row_number() over() AS "rank",
          players.id as "id1",
          players.name as "player1"
          FROM (select * from playerStandings) as players)
      AS results
      JOIN
          (SELECT 
           row_number() over() as "rank",
           players.id AS "id2",
           players.name AS "player2"
           FROM (select * from playerStandings) as players)
     AS results2
     ON results.rank = results2.rank-1
     WHERE results.rank % 2 != 0;


-- Create function for Opponent Match Wins results
CREATE OR REPLACE FUNCTION opponent_match_wins(players_id int)
RETURNS float(8)
AS $BODY$
DECLARE 
    result           float;
    summ             float     DEFAULT 0;
    wins             int;
    draws            int;
    total_matches    float;
    opponents        matches%rowtype;
BEGIN
    -- Select the ids of all of the previous opponents of the player
    FOR opponents IN  
        SELECT winner AS id FROM matches WHERE loser = players_id
            UNION
        SELECT loser AS id FROM matches WHERE winner = players_id AND loser > 0  
    -- Loop through the values
    LOOP  
        -- Get the opponent's win count (byes not included)
        SELECT count(*) FROM matches
             WHERE (winner = opponents.id)
                AND (draw = false)
                AND (bye = false)
        INTO wins;
        
        -- Get the opponent's draw count
        SELECT count(*) FROM matches
            WHERE (winner = opponents.id OR loser = opponents.id)
                AND (draw = true)
        INTO draws;
        
        -- Get the total number of matches for the opponents(byes not included)
        SELECT get_total_matches(opponents.id)
        INTO total_matches;
        
        -- Formulate the opponents match win ratio
        SELECT (wins*3 + draws)/(total_matches*3) 
        INTO result;
        
        -- Sum the result with those of the other opponents
        summ := summ + result;
    END LOOP;
        -- Divide the result by the total number of matches for the player.    
    result = summ/get_total_matches(players_id);
    -- Return the result as a float.
    RETURN result;
END;
$BODY$ LANGUAGE plpgsql;


-- Create a view to get for player standings based on Opponent Match Wins
CREATE OR REPLACE VIEW playerStandingsOMW AS
    SELECT
        players.id AS "id",
        players.name AS "name",
        (SELECT get_wins(players.id)),
        (SELECT get_total_matches(players.id))
    FROM players
    ORDER BY (SELECT opponent_match_wins(players.id)) ASC;


-- Create a view for the swissTournament based on Opponent Match Wins
CREATE OR REPLACE VIEW swissTournamentOMW AS
    SELECT results.id1, results.player1, results2.id2, results2.player2
      FROM 
         (SELECT 
          row_number() over() AS "rank",
          players.id as "id1",
          players.name as "player1"
          FROM (select * from playerStandingsOMW) as players)
      AS results
      JOIN
          (SELECT 
           row_number() over() as "rank",
           players.id AS "id2",
           players.name AS "player2"
           FROM  (select * from playerStandingsOMW) as players)
     AS results2
     ON results.rank = results2.rank-1
     WHERE results.rank % 2 != 0;



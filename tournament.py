#!/usr/bin/env python
# 
# tournament.py -- implementation of a Swiss-system tournament
#

import psycopg2


def connect():
    """Connect to the PostgreSQL database.  Returns a database connection."""
    return psycopg2.connect("dbname=tournament")

def make_commit(query, params='null'):
    """
    Commit a query to the database, passing optional parameters  
    """
    db = connect()
    c = db.cursor()
    c.execute(query, params)
    db.commit()
    db.close()

def get_query(query):
    """
    Perform a query on the database, returning the result
    """
    db = connect()
    c = db.cursor()
    c.execute(query)
    result = c.fetchall()
    db.close()
    return result
    

def deleteMatches():
    """Remove all the match records from the database."""
    make_commit("DELETE FROM matches")
    

def deletePlayers():
    """Remove all the player records from the database."""
    make_commit("DELETE FROM players")

def countPlayers():
    """Returns the number of players currently registered."""
    result = get_query("SELECT COUNT(*) FROM players")
    return result[0][0]

def registerPlayer(name):
    """Adds a player to the tournament database.
  
    The database assigns a unique serial id number for the player.  (This
    should be handled by your SQL database schema, not in your Python code.)
  
    Args:
      name: the player's full name (need not be unique).
    """
    args = [name]
    make_commit("INSERT INTO players (name) VALUES (%s)", args)


def playerStandings():
    """Returns a list of the players and their win records, sorted by wins.

    The first entry in the list should be the player in first place, or a player
    tied for first place if there is currently a tie.

    Returns:
      A list of tuples, each of which contains (id, name, wins, matches):
        id: the player's unique id (assigned by the database)
        name: the player's full name (as registered)
        wins: the number of matches the player has won
        matches: the number of matches the player has played
    """
    
    result = get_query("SELECT * FROM playerStandings")
    return result


def reportMatch(winner, loser = 'NULL', bye = 'false', draw = 'false'):
    """Records the outcome of a single match between two players.

    Args:
      winner:  the id number of the player who won
      loser:  the id number of the player who lost, default is null
      bye = boolean for a bye round, default is false
      draw = boolean for a draw, default is false
    """
    
    if bye == 'false':
        if not loser:
            raise ValueError("""If not a bye, the match must
            have two players""")
        else:
            if draw != 'false':
                make_commit("""INSERT INTO matches(winner, loser,
                draw) values (%s, %s, true)""", (winner, loser))
            else:
                make_commit("""INSERT INTO matches(winner, loser)
                values (%s, %s)""",(winner, loser)) 
    else:
        if countPlayers() % 2 != 0:
            result = get_query("""Select * from matches where 
                                id = %s and bye = true""", (winner))
            if result:
                raise ValueError("""The player selected already
                has had a bye""")
            else :
                make_commit("""INSERT INTO matches(winner, bye)
                VALUES(%s, true)""",(winner))
        else:
            raise ValueError("""There must be an odd number of
            players in order to have a bye round.""")
 
def swissPairings():
    """Returns a list of pairs of players for the next round of a match.
  
    Assuming that there are an even number of players registered, each player
    appears exactly once in the pairings.  Each player is paired with another
    player with an equal or nearly-equal win record, that is, a player adjacent
    to him or her in the standings.
  
    Returns:
      A list of tuples, each of which contains (id1, name1, id2, name2)
        id1: the first player's unique id
        name1: the first player's name
        id2: the second player's unique id
        name2: the second player's name
    """
    result = get_query("SELECT * FROM swissTournament")
    return result
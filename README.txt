=+=+=+=+=+=+=+=+=+=
Swiss Tournament
=+=+=+=+=+=+=+=+=+=

What is this anyway?
-------------------
This is the basic version of the swiss tournament project
with a few more complex features on the way, though not fully implemented
as of 12.10.2015

How to use this
-------------------
You may interact with the project by using the vagrant virtual 
machine built into the Udacity course, or you may set up your
own database to work with the files.

#Setup the database by following the instructions at
https://docs.google.com/document/d/16IgOm4XprTaKxAa8w02y028oBECOoB1EI1ReddADEeY/pub?embedded=true

or if you have postgres and python(2.7) setup already and just want to play
around with some queries :

$ >> createdb tournament
$ >> psql
$ >> \c tournament
$ >> \i tournament.sql

#Run the tests via python from the folder that you clone into
$ python tournament_test.py


-------------------
That does it for now. Enjoy!

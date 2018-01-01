
# Swiss Tournament

## What is this anyway?

This is the basic version of the swiss tournament project
as of 12.10.2015

## How to use this

You may interact with the project by using the vagrant virtual 
machine built into the Udacity course, or you may set up your
own database to work with the files.

## Seting up the DB

[Instructions can be found here](https://docs.google.com/document/d/16IgOm4XprTaKxAa8w02y028oBECOoB1EI1ReddADEeY/pub?embedded=true)
or if you have postgres and python(2.7) setup already and just want to play
around with some queries :

`sh
$ >> createdb tournament
$ >> psql
$ >> \c tournament
$ >> \i tournament.sql
`

- Run the tests via python from the folder that you clone into
` $ python tournament_test.py `


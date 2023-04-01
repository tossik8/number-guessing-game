#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
RANDOM_NUMBER=$(($RANDOM%1000 + 1))
echo "Enter your username:"
read USERNAME
USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USERNAME'")
if [[ -z $USER_ID ]]
then
  INSERT_USER=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USERNAME'")
else
  GAMES_COUNT=$($PSQL "SELECT count(1) FROM games WHERE user_id = $USER_ID")
  BEST_RESULT=$($PSQL "SELECT min(guesses) FROM games WHERE user_id = $USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_COUNT games, and your best game took $BEST_RESULT guesses."
fi
echo "Guess the secret number between 1 and 1000:"
ASK_INPUT(){
  
  read GUESS
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -gt $RANDOM_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  elif [[ $GUESS -lt $RANDOM_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  fi
}
COUNT=0
while [[ $GUESS -ne $RANDOM_NUMBER ]]
do
  ASK_INPUT
  ((++COUNT))
done
echo "You guessed it in $COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"
INSERT_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $COUNT)")
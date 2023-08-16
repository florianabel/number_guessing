#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SECRET_NUMBER=$((RANDOM % 1000))
GUESSES=1

GUESS_NUMBER() {
  read GUESS
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    if [[ $GUESS > $SECRET_NUMBER ]]
    then
      ((GUESSES ++))
      echo "It's lower than that, guess again:"
      GUESS_NUMBER
    elif [[ $GUESS < $SECRET_NUMBER ]]
    then
      ((GUESSES ++))
      echo "It's higher than that, guess again:"
      GUESS_NUMBER
    elif [[ $GUESS == $SECRET_NUMBER ]]
    then
      GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $GUESSES)")
      echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    fi
  else
    ((GUESSES ++))
    echo "That is not an integer, guess again:"
    GUESS_NUMBER
  fi
}

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")
if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  USER_CREATED=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")
else
  RESULTS=$($PSQL "SELECT COUNT(*), MIN(guesses) FROM games WHERE user_id=$USER_ID")
  echo $RESULTS | while IFS='|' read GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

echo "Guess the secret number between 1 and 1000:"
GUESS_NUMBER 

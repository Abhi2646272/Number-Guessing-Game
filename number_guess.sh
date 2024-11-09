#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Welcome and username prompt
echo "Enter your username:"
read USERNAME

USER_DATA=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_DATA ]]; 
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
  # Extract user data
  USER_ID=$(echo $USER_DATA | cut -d '|' -f 1)
  GAMES_PLAYED=$(echo $USER_DATA | cut -d '|' -f 2)
  BEST_GAME=$(echo $USER_DATA | cut -d '|' -f 3)

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi



# Generate random secret number
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
echo "Guess the secret number between 1 and 1000:"
GUESS_COUNT=0


while true; do
  read GUESS
  
  # Check if input is an integer
  if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  GUESS_COUNT=$(( GUESS_COUNT + 1 ))
   if (( GUESS > SECRET_NUMBER )); then
    echo "It's lower than that, guess again:"
  elif (( GUESS < SECRET_NUMBER )); then
    echo "It's higher than that, guess again:"
  else
    echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
if [[ -z $USER_DATA ]]; then
      UPDATE_RESULT=$($PSQL "UPDATE users SET games_played = 1, best_game = $GUESS_COUNT WHERE username = '$USERNAME'")
    else
      GAMES_PLAYED=$(( GAMES_PLAYED + 1 ))
      if [[ -z $BEST_GAME || $GUESS_COUNT -lt $BEST_GAME ]]; then
        BEST_GAME=$GUESS_COUNT
      fi
      UPDATE_RESULT=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED, best_game = $BEST_GAME WHERE username = '$USERNAME'")
    fi
    break
  fi
done
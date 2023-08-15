#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

RANDOM_NUMBER=$((1 + $RANDOM % 1000))
echo $RANDOM_NUMBER
GUESS=1
ASK_USERNAME(){
  echo -e "\nEnter your username:"
  read USER_NAME
  if [[ $(echo $USER_NAME | wc -c) -gt 22 ]]
  then
    ASK_USERNAME
  fi
}

ASK_USERNAME
USER=$($PSQL "SELECT name FROM users WHERE name='$USER_NAME'")

if [[ -z $USER ]]
then
  echo -e "\nWelcome, $USER_NAME! It looks like this is your first time here."
  INSERTED_USER=$($PSQL "INSERT INTO users(name) VALUES('$USER_NAME')")
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games INNER JOIN users USING(user_id) WHERE name='$USER'")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games INNER JOIN users USING(user_id) WHERE name='$USER'")
  echo -e "\Welcome back, $USER! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USER_NAME'")

echo -e "\nGuess the secret number between 1 and 1000:"
read INPUT

while [[ ! $INPUT -eq $RANDOM_NUMBER ]]
do
  GUESS=$(( $GUESS + 1 ))
  # if not a number
  if [[ ! $INPUT =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
  elif [[ $INPUT -lt $RANDOM_NUMBER ]]
  then
    echo -e "\nIt's higher than that, guess again:"
  else
    echo -e "\nIt's lower than that, guess again:"
  fi
  read INPUT
done

echo $($PSQL "INSERT INTO games(user_id,guesses) VALUES($USER_ID,$GUESS)")
echo -e "\nYou guessed it in $GUESS tries. The secret number was $RANDOM_NUMBER. Nice job!"

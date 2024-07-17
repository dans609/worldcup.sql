#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE TABLE games, teams;")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    # get the winner team id
    WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER';")

    # if not found
    if [[ -z $WINNER_TEAM_ID ]]
    then
      # insert team
      INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")
      if [[ $INSERT_TEAM == "INSERT 0 1" ]]
      then
        echo "[$WINNER] Inserted into teams."
      fi

      # get the new id of the winner team
      WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER';")
    fi


    # get the opponent team id
    OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT';")

    # if not found
    if [[ -z $OPPONENT_TEAM_ID ]]
    then
      # insert team
      INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")
      if [[ $INSERT_TEAM == "INSERT 0 1" ]]
      then
        echo "[$OPPONENT] Inserted into teams."
      fi

      # get the new id of the opponent team
      OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT';")
    fi

    # Insert data into games,
    # but make sure the '$WINNER_TEAM_ID' and '$OPPONENT_TEAM_ID' IS NOT NULL/EMPTY.
    if [[ -n $WINNER_TEAM_ID && -n $OPPONENT_TEAM_ID ]]
    then
      INSERT_GAMES=$($PSQL "INSERT INTO games(year, winner_id, opponent_id, winner_goals, opponent_goals, round) VALUES($YEAR, $WINNER_TEAM_ID, $OPPONENT_TEAM_ID, $WINNER_GOALS, $OPPONENT_GOALS, '$ROUND');")
      if [[ $INSERT_GAMES == "INSERT 0 1" ]]
      then
        echo "[$ROUND: $WINNER-$OPPONENT, $YEAR] Match is inserted into games."
      fi
    fi
  fi
done 
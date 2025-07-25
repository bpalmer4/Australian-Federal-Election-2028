#!/bin/zsh
#crontab: 57 6 * * * /Users/bryanpalmer/Australian-Federal-Election-2028/automated/election-winner.sh

# set-up parameters
home=/Users/bryanpalmer
project=Australian-Federal-Election-2028
working=automated
runrun=robust_scraper.py

# move to the home directory
cd $home

# activate the uv environment
source $home/$project/.venv/bin/activate

# move to the working directory
cd $project/$working

# Load environment variables from .env file if it exists
if [ -f ".env" ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

#initiate the data capture with robust scraper
python ./$runrun >>winner-log.log 2>>winner-err.log

# Only commit and push if scraper succeeded (exit code 0)
if [ $? -eq 0 ]; then
    cd $home/$project
    git add "betting-data/sportsbet-2028-election-winner.csv"
    git commit -m "betting market update"
    git push
    echo "$(date): Scraper succeeded, data committed" >>automated/winner-log.log
else
    echo "$(date): Scraper failed, no commit made" >>automated/winner-err.log
fi

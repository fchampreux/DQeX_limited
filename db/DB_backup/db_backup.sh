#!/bin/bash
### Generate cyclic backup file name and processes to the backup of the Postgres database
### Place the sis-portal.sh script in /etc/cron.daily to run this daily backup
# Initialise variables
BACKUP_DATE=$(date +%Y-%m-%d)
#echo $BACKUP_DATE
BACKUP_WEEK=$(date +%W)
#echo $BACKUP_WEEK
DAY_OF_WEEK=$(date +%u)
#echo $DAY_OF_WEEK
BACKUP_DAY=$(date +%A)
#echo $BACKUP_DAY
# Print variables
echo "Backup date: $BACKUP_DATE"
echo "Today is number $DAY_OF_WEEK day of the week"
echo "Backup daily tag $BACKUP_DAY"
echo "Backup weekly tag $BACKUP_WEEK"
if [ $DAY_OF_WEEK == 7 ]
then
  echo "Week $BACKUP_WEEK backup will be executed"
  BACKUP_FILE="weekly/SIS_portal_$BACKUP_WEEK.prod.tar"
  echo "$BACKUP_FILE"
  pg_dump -U postgres -w -F c dqm_prod > $BACKUP_FILE
else
  echo "$BACKUP_DAY backup will be executed"
  BACKUP_FILE="daily/SIS_portal_$DAY_OF_WEEK-$BACKUP_DAY.prod.tar"
  echo "$BACKUP_FILE"
  pg_dump -U postgres -w -F c dqm_prod > $BACKUP_FILE
fi
if [ $? == 0 ]
then
  echo "done."
  cp $BACKUP_FILE "SIS_portal_backup"
else
  echo "backup failed, check the log." > "SIS_portal_backup"
fi

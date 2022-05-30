cd /home/a80838986/sis-portal/db/DB_backup
sh ./db_backup.sh
echo "SIS-Portal Production data have been backed up" |  mail -s "SIS-Portal backup" -r SIS-Portal -a SIS_portal_backup frederic.champreux@bfs.admin.ch
rm -f SIS_portal_backup


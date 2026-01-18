#!/bin/bash

PATH=/usr/bin:/bin:/usr/sbin:/sbin
DATE=$(date +%F)
DEST="younes@192.168.11.122:backup/$DATE"
LOG="/home/younes/logs/backups.log"
PIDFILE=/tmp/backup.pid
MAX_BACKUPS=4
echo $$ > $PIDFILE

echo "======================================" >> "$LOG"
echo "Starting backup at $(date)" >> $LOG

/usr/bin/rsync -arAXvh /etc \
        /var/lib/plexmediaserver \
        /home/younes/monitoring \
        $DEST >> $LOG 2>&1

echo "Backup finished at $(date)" >> $LOG

ssh younes@192.168.11.122 bash << EOF
cd /home/younes/backup || exit
BACKUPS=(\$(ls -1d 20* | sort))
COUNT=\${#BACKUPS[@]}
if [ "\$COUNT" -gt "$MAX_BACKUPS" ]; then
    NUM_DELETE=\$((COUNT - $MAX_BACKUPS))
    for ((i=0; i<NUM_DELETE; i++)); do
        rm -rf "\${BACKUPS[i]}"
        echo "Deleted old backup: \${BACKUPS[i]}"
    done
fi
EOF

echo "Remote retention policy applied at $(date)" >> $LOG

rm -f /tmp/backup.pid

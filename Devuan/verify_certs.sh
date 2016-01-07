#!/bin/bash
# Title      : verify_certs.sh
# Description: Mail about expiring certificates
# Author     : linuxitux
# Date       : 08-07-2015
# Usage      : ./verify_certs.sh
# Notes      : Add this to your crontab on a weekly basis
#10 1 * * 1 root /root/scripts/verify_certs.sh >> /var/log/verify_certs.log 2>&1

SERVIDOR=$(hostname)
ASUNTO="Advertencia: Certificados por expirar en el servidor $SERVIDOR"
REMITENTE="xxxx@xxxx.com"
CERTS="/usr/local/nginx/conf/*.crt /usr/local/apache/conf/ssl.crt/*.crt"
DAYS=20
MAIL=""

echo "[$(date)]"

for FILE in $CERTS
do

        EXP=$(/usr/bin/openssl x509 -enddate -noout -in $FILE)
        EXP=${EXP:9}
        EXPD=$(date --date="$EXP" +%d-%m-%Y)
        echo $FILE expira el $EXPD
        EXP=$(date --date="$EXP" +%Y%m%d)

        for (( i=0; i<=$DAYS; i++ ))
        do

                DATE=$(date --date="+$i days" +%Y%m%d)

                if [ "$EXP" = "$DATE" ]; then

                        if [ "$i" = "0" ]; then MAIL=$(echo -e "El certificado $FILE expira hoy!\n$MAIL")
                        else MAIL=$(echo -e "El certificado $FILE expira en $i dia(s)\n$MAIL")
                        fi

                fi

        done

done

if [ "${#MAIL}" -gt 0 ]; then

        # enviar notificación
        MAIL=$(echo -e "Estado de los certificados SSL:\n$MAIL\n")
        echo -e "$MAIL"  | /usr/bin/mail -s "$ASUNTO" $REMITENTE
        echo -e "$MAIL"

else

        echo "Estado de los certificados SSL: Ok"

fi


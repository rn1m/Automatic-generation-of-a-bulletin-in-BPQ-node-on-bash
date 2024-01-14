#!/bin/bash
#Пример автоматического создания пакетного бюллетеня-прогноза погоды
#Прогноз погоды (https://meteoinfo.ru/hazardsbull) выходит ежедневно
#соответствующая запись оставлена в crontab
#===================================================================
#Сделано специально для BPQ Packet Node
#
#Обратная связь:
#Packet email: RN1M@RN1M.SPB.RUS.EU
#Winlink email: RN1M<at>winlink.org
#
#RN1M, Sergey 73!
#===================================================================
function sendingMessage2 {
cat wxbull.txt | while IFS= read -r line; do
	echo -en "$line\r"
	sleep 0.5
done
}

#загружаем страницу в тексте
links -dump https://meteoinfo.ru/hazardsbull > wxbull.txt

#удаляем сверху 82 строки меню
sed -i '1,82d' wxbull.txt

#удаляем строку, если в ней есть...
sed -i '/* /d' wxbull.txt
sed -i '/Mail.ru/d' wxbull.txt
sed -i '/Старый сайт/d' wxbull.txt
sed -i '/ссылка на/d' wxbull.txt
sed -i '/этой страницы в/d' wxbull.txt
sed -i '/Прогноз по Москве/d' wxbull.txt
sed -i '/источниках/d' wxbull.txt
sed -i '/территории России/d' wxbull.txt

#заменяем словосочетание пустотой
sed -i 's/Опасные явления погоды//' wxbull.txt

#удалим все пустые строки
sed -i '/^$/d' wxbull.txt

#cat wxbull.txt
#sleep 20

login=XXXXXXXXX
password=XXXXXXXXX

(sleep 1;
echo -en "$login\r";
sleep 1;
echo -en "$password\r";
sleep 1;
echo -en "BBS\r";
sleep 1;
echo -en "SB WX@RUS\r";
sleep 1;
echo -en "Опасные явления погоды-$(date '+%d %b')\r";
sleep 1;
sendingMessage2;
sleep 1;
echo -en "    ___________________________________________________\r";
sleep 1;
echo -en "    Пакетный бюллетень создан автоматически на RN1M BBS\r";
sleep 1;
echo -en "    на основе данных https://meteoinfo.ru/hazardsbull\r";
sleep 1;
echo -en "    $(date '+%d/%m/%Y %T %Z')\r";
sleep 1;
echo -en "    ___________________________________________________\r";
sleep 1;
echo -en "/ex\r";
sleep 1;
echo -en "bye\r";
sleep 1;
echo -en "bye\r";
) | ncat -C 127.0.0.1 8010



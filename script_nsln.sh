#!/bin/bash
#Пример автоматического создания пакетного бюллетеня
#из текстовой расшифровки классного подкаста
#Amateur Radio Newsline Report (http://arnewsline.org)
#Подкаст выходит раз в неделю по четвергам\пятницам,
#соответствующая запись оставлена в crontab
#=====================================================
#Сделано специально для BPQ Packet Node
#
#Обратная связь:
#Packet email: RN1M@RN1M.SPB.RUS.EU
#Winlink email: RN1M<at>winlink.org
#
#RN1M, Sergey 73!
#=====================================================
login=XXXXXXXXX
password=XXXXXXXXX

function sendingMessage2 {
cat $lastReport | while IFS= read -r line; do
        echo -en "$line\r"
        sleep 0.5
done
}

#скачиваем главную страницу с сайта, где содержится информация о прошлых выпусках
links -dump  http://arnewsline.org > index.txt
#копируем все найденные и нужные нам строки в новый файл
grep "Amateur Radio Newsline Report" index.txt > temp.txt

#удаляем все пробелы\табы до и после строки
sed -i 's/^[ \t]*//' temp.txt
sed -i 's/[ \t]*$//' temp.txt

#выводим только пятый столбец с номерами выпусков в отдельный файл
cut -d ' ' -f 5 temp.txt > temp2.txt
#удаляем ненужные файлы
rm temp.txt
rm index.txt

echo "Номера последних выпусков с главной страницы сайта:"
cat temp2.txt

#формируем название файла последнего выпуска - первая строка из файла temp2.txt
lastReportNumber=$(sed -n 1p temp2.txt)
lastReport="nsln"$lastReportNumber".txt"
# и предпоследнего
pastReportNumber=$(sed -n 2p temp2.txt)
pastReportFile="nsln"$pastReportNumber".txt"
#
echo "Название файла последнего выпуска: $lastReport"
echo "Название файла предпоследнего выпуска: $pastReportFile"
#ищем последний бюллетень в текущей папке, был ли он скачен или нет
#если был - то не отправляем
#если не был - скачиваем и отправляем
rm temp2.txt
find . $lastReport
 if [ $? -eq 0 ]
	then
	echo "Файл последнего выпуска найден, уже был отправлен в качестве бюллетеня."
	exit
	else
	echo "Файл последнего выпуска не найден. Скачиваем и отправляем в качестве бюллетеня."
        wget "arnewsline.org/s/"$lastReport
#удаляем предпоследний файл выпуска
	rm $pastReportFile
#ВАЖНО для форматирования - убираем все ^M в скаченном файле
	sed -i 's/\r$//' $lastReport
	(sleep 1;
	echo -en "$login\r";
	sleep 1;
	echo -en "$password\r";
	sleep 1;
	echo -en "BBS\r";
	sleep 1;
	echo -en "SB NSLN@WW\r";
	sleep 1;
	echo -en "Amateur Radio Newsline Report №$lastReportNumber\r";
sleep 1;
sendingMessage2;
sleep 1;
echo -en "    __________________________________________\r";
sleep 1;
echo -en "    Bulletin created automatically on RN1M BBS\r";
sleep 1;
echo -en "    based on https://arnewsline.org\r";
sleep 1;
echo -en "    $(date '+%d/%m/%Y %T %Z')\r";
sleep 1;
echo -en "    __________________________________________\r";
sleep 1;
echo -en "/ex\r";
sleep 1;
echo -en "bye\r";
sleep 1;
echo -en "bye\r";
) | ncat -C 127.0.0.1 8010

 fi

#!/bin/bash
# Format the downloaded ined webpages to valid csv tables.
mkdir backup
for FILE in *.csv; do
  # backup
  cp $FILE ./backup/$FILE.bak
  # delete first 23 and last 10 lines
  tail -n +23 $FILE | head -n -10 > $FILE.tmp && mv $FILE.tmp $FILE
  # replace comma decimal separator with dot
  sed -i -E -e 's/,/./g' $FILE
  # replace whitespace with comma
  sed -i -E -e 's/[[:space:]]+/,/g' $FILE
  # remove comma at eol
  sed -i -E -e 's/,$//g' $FILE
  # insert header
  awk '1' <(echo '"Year","Total","<1","1-4","5-9","10-14","15-19","20-24","25-29","30-34","35-39","40-44","45-49","50-54","55-59","60-64","65-69","70-74","75-79","80-84","85-89","90-94","95-99","100+"') $FILE > $FILE.tmp && mv $FILE.tmp $FILE
done
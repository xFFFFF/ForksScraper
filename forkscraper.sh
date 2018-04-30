#!/bin/bash
epoch=`date +%s`
dbser=search-results-$epoch.json
dbfl=all-repo-files-$epoch.json
dbfin=unique-repo-files-$epoch.json
auth='--user user:pass'

function lurc () {
	curl -L $auth $1 $2 
	sleep 1.4
}

# forks list 
for i in {1..10}
do
se="https://api.github.com/search/repositories?q=flutter+fork%3Atrue+created%3A2017-09-20..2018-01-01&per_page=100&page=$i&sort=updated&order=desc"
lurc $se >> $dbser
done

# files list
readarray a < <(grep "contents_url" $dbser | sed -e 's/\"contents_url\": \"\(.*\){+path}\",/\1/g; s/ //g')
for i in "${a[@]}"
do
lurc $i >> $dbfl
done

# matching urls with unique file hashes
[ -f tmp ] && rm tmp
readarray b < <(grep sha $dbfl | sed 's/\"sha\": \(.*\),$/\1/g; s/ //g' | grep -v : | sort | uniq -u)
for i in "${b[@]}"
do
echo ".[] | first(select(.sha==$i)" >> tmp
done
sed -i "/^)$/d; s/$/\))' $dbfl/g; s/^\.\[\]/jq -r '\.\[\]/g" tmp
. tmp 1> $dbfin 2>  /dev/null

# file scraping
grep download $dbfin | sed 's/download_url//g' | sed 's/[\", ]//g; s/^://g' | grep http > urls.txt
readarray c < urls.txt
for i in "${c[@]}"
do
u=`date +%N`
k=`echo $i | rev | cut -d"/" -f1 | rev`
n=`echo $k | rev | cut -d"." -f1 | rev`
r=`echo $k |  cut -d"," -f1`
if [ -f $k ]; then k=$n\-$u\.$r; fi
lurc "-o $k" $i 
sed -i "1 i# Source: $i" $k
done
# rm $dbser $dbfl $dbfin tmp

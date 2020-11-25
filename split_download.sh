#! /bin/sh
URL="$1"
size=`curl -s -I -L "$URL" | awk -v IGNORECASE=1 '/^Content-Length/ { print $2 }'`
size=${size//[ $'\001'-$'\037']} # drop any control character
echo 'size ' $size
if [ -z $size ]; then # if file size is not available through header
	echo 'file size unavailable, check if file is found'
	exit
fi
if [ -z "$2" ] # second argument for number of split files
then
	split=5
else
	split=$2
fi
# split download with curl --range
read -p 'filename(include extension): ' filename
for (( i=0; i<$split; i++ ))
do
	k=$((size / $split))
	s=$((k * $i))
	if [[ $i -eq $((split - 1)) ]]; then
		e=''
	else
		e=$((k * $((i + 1)) -1))
	fi
	echo 'downloading part '$i $s $e
	`curl --range $s-$e -o "$filename".part$i $URL` &
done
wait
# merge part files
`cat "$filename".part? > "$filename"; rm "$filename".part*`

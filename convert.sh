#!/bin/bash

###REQUIREMENTS:
#install id3v2 ffmpeg or I won't run
if ! hash id3v2 2>/dev/null; then echo "id3v2 command not found!"; exit 1; fi
if ! hash ffmpeg 2>/dev/null; then echo "ffmpeg command not found!"; exit 1; fi

#Declare vars
sourceFolder=$1
cleanFolder="$1"/cleanup
trackNum=$(ls -l "$1"/*wav | wc -l)
read -p 'Album Name: ' albumName
read -p 'Artist Name: ' artistName
read -p 'Year: ' releaseYear

#ffmpeg conversion
ffmpeg_convert () {
for i in "$sourceFolder"/*wav
do
	printf "\nProcessing track: \n$i"
	ffmpeg -hide_banner -loglevel error -i "$i" -vn -ar 44100 -ac 2 -b:a 320k "${i%.*}".mp3
done
}

#id3tag
id3tag_convert () {
for i in "$sourceFolder"/*mp3
do
	((trackCount=trackCount+1))
	read -p "Song title for track $i: " trackName
	id3v2 -A "$albumName" -a "$artistName" -t "$trackName" -y "$releaseYear" -T "$trackCount"\/"$trackNum" "$i"
done
}

#Move wavs to cleanFolder
clean_folder () {
mkdir -p "$cleanFolder"
mv "$sourceFolder"/*wav "$cleanFolder"
#Remove cleanFolder?
read -p "Do you want to delete the original wavs (type y for yes)?" toBeOrNot
if [ "toBeOrNot" = "y" ]
	then 
		echo "Deleteing wavs..."
		rm -rf "$cleanFolder"
	else echo "Then we're done"
fi
}

#Run functions run!
ffmpeg_convert
id3tag_convert
clean_folder

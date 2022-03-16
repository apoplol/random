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
	read -rep $'\nSong title for track '"$i: "$' \n'  trackName
	id3v2 -A "$albumName" -a "$artistName" -t "$trackName" -y "$releaseYear" -T "$trackCount"\/"$trackNum" "$i"
done
}

#Move wavs to cleanFolder
clean_folder () {
while true; do
	mkdir -p "$cleanFolder"
	mv "$sourceFolder"/*wav "$cleanFolder"
	#Remove cleanFolder?
	read -rep $'\nDo you want to delete the original wavs (y/n)? \n' toBeOrNot
	case $toBeOrNot in
		[yY] | [yY][Ee][Ss] )
				echo "Deleting original wav files."
				rm -rf "$cleanFolder"
				break
	    	;;
		[nN] | [n|N][O|o] )
				echo "Original wav files are in $cleanFolder";
				exit 1
	    	;;
		*) echo "Invalid input" 2>/dev/null
	      ;;
	esac
done
}

#Run functions run!
ffmpeg_convert
id3tag_convert
clean_folder

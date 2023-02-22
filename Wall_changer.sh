#!/bin/bash

#sleep some time
sleep 1s

# Check required programs are installed 
if which wget > /dev/null;
 then echo "wget Installed"
 else echo "wget Not Installed"
 exit
fi

#-------------Set some variables
#directory=/home/stefano/Apps/Scripts/Wallpapers_Bing/
directory=$PWD/Wallpapers_Bing/
#Base Bing URL
bing="www.bing.com"
#What day to start from. 0 is the current day,1 the previous day, etc...
day="&idx=0"

#Number of images to get
#May change this script later to get more images and rotate between them
number="&n=1"

#Set market, other options are:
#"&mkt=zh-CN"
#"&mkt=ja-JP"
#"&mkt=en-AU"
#"&mkt=en-UK"
#"&mkt=de-DE"
#"&mkt=en-NZ"
#"&mkt=en-CA"
market="&mkt=es"

xmlURL=$bing"/HPImageArchive.aspx?format=xml"$day$number$market

#Form the URL for the default pic resolution
pic_default=$bing$(echo $(wget -q -O - $xmlURL) | grep -oP "<url>(.*)</url>" | cut -d ">" -f 2 | cut -d "<" -f 1)

#Set desired resolution:
resolution="_1920x1080"
#The file extension for the Bing pic
extension=".jpg"

#The URL for the desired pic resolution from the XML file
pic_desired=$bing$(echo $(wget -q -O - $xmlURL) | grep -oP "<urlBase>(.*)</urlBase>" | cut -d ">" -f 2 | cut -d "<" -f 1)$resolution$extension


# Download the desired image resolution
# If it doesn't exist then download the default image resolution
if wget -q --spider "$pic_desired"
then
    pic_name=${pic_desired##*/}
    wget -q -O $directory$pic_name $pic_desired
else
    pic_name=${pic_default##*/}
    wget -q -O $directory$pic_name $pic_default
fi

# Set wallpaper
gsettings set org.gnome.desktop.background picture-uri file://$directory$pic_name

# Set matched lock-screen
gsettings set org.gnome.desktop.screensaver picture-uri file://$directory$pic_name


#-------------------Do you like the Wallpaper?
while ! GDK_BACKEND=x11 yad --image "dialog-question" --center --text-align=center --width=300 --height=100	--title "Alert" --text "Do you like the Wallpaper?"	--button=gtk-yes:0  --button=gtk-no:1
do
	cd $directory
	#random pic
	pic_name_loc=`ls | shuf -n 1`	
	# Set wallpaper
	gsettings set org.gnome.desktop.background picture-uri file://$directory$pic_name_loc	
	rm ./$pic_name
	pic_name=$pic_name_loc		
done

exit









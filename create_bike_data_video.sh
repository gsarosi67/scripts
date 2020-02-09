#!/bin/bash


####################################
#  Process bike ride video and gpx file
#
#   ToDo:
#   1.  Accept filename, video and gpx file must match.  Assume .mov and .gpx for now.
#   2.  Create image stills, have command line parameter for interval
#   3.  Create timelapse of video
#       - can't remember the best way to do this.  it is either frencode or frstepencode
#   4.  Add music.  Will need to include the music files as a command line parameter.
#       - first use aCat to create one audio file
#         - what if I need to trim??
#       - use addAudiocopy or addAudioencode (I think we want to encode)
#   5.  Create map and data images using parsegpx
#       - need to get the video length in seconds ffprobe??
#       - ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 file.mp4
#   6.  Create map and date videos using img2vid
#   7.  Create final video using vidover_vb_ro (change name)
#       important options:  -a 0.9, -bm screen
#
#   Notes:
#     - should consider combining step 4 and 7.  Should be able to add the audio when creating
#       the final video.
#     - what should we keep, what should be deleted.  Don't need to keep all of the images once the video is made
#     - Need to add a music credit screen
#


bTest=1
inputFile=input-filename
stillImageinterval=60
musicFilename=music*.mp3
timelapseFramerate=30
timelapseFrameskip=10
timelapseExtra=-timelapse
combinedmusicOutput=combined-music
musicExtra=-music
mapdatadir=-mapdataimg/
mapoutput=map
dataoutput=data
finalExtra=-final
genre=timelapse
bCreatethumbs=1
bCreatetimelapse=1
bCombinemusic=1
bAddmusic=1
bCreatefinalvideo=1
bCreatemapdata=1
bCreatemapdatavideo=1
bCreatefinalvideo=1
inputVideoExt=mov
outputVideoExt=mp4


PARAMS=""
while (( "$#" )); do
  case "$1" in
    -i|--input)
        inputFile=$2
        shift 2
      ;;
    -si|--image_interval)
        stillImageinterval=$2
        shift 2
      ;;
    -m|--music)
        musicFilename=$2
        shift 2
      ;;
    -tlfr|--time_lapse_frame_rate)
        timelapseFramerate=$2
        shift 2
      ;;
    -tlfs|--time_lapse_frame_skip)
        timelapseFrameskip=$2
        shift 2
      ;;
    -tle|--time_lapse_extra)
        timelapseExtra=$2
        shift 2
      ;;
    -cmo|--combined_music_output)
        combinedmusicOutput=$2
        shift 2
      ;;
    -me|--music_extra)
        musicExtra=$2
        shift 2
      ;;
    -mdd|--map_data_dir)
        mapdatadir=$2
        shift 2
      ;;
    -mo|--map_output)
        mapoutput=$2
        shift 2
      ;;
    -do|--data_output)
        dataoutput=$2
        shift 2
      ;;
    -ct|--create_thumb)
        bCreatethumbs=$2
        shift 2
      ;;
    -ctl|--create_time_lapse)
        bCreatetimelapse=$2
        shift 2
      ;;
    -cm|--combine_music)
        bCombinemusic=$2
        shift 2
      ;;
    -am|--add_music)
        bAddmusic=$2
        shift 2
      ;;
    -cmd|--create_map_data)
        bCreatemapdata=$2
        shift 2
      ;;
    -cmdv|--create_maps_data_video)
        bCreatemapdatavideo=$2
        shift 2
      ;;
    -cfv|--create_final_video)
        bCreatefinalvideo=$2
        shift 2
      ;;
    -g|--genre)
        genre=$2
        shift 2
      ;;
    -t|--test)
        bTest=$2
        shift 2
      ;;
    -ivext|--input_video_extension)
        inputVideoExt=$2
        shift 2
      ;;
    -ovext|--output_video_extension)
        outputVideoExt=$2
        shift 2
      ;;
    --) # end argument parsing
        shift
        break
      ;;
    -*|--*=) # unsupported flags
        echo "Error: Unsupported flag $1" >&2
        exit 1
      ;;
    *) # preserve positional arguments
        PARAMS="$PARAMS $1"
        shift
      ;;
  esac
done


echo "[`date "+%Y-%m-%dT%H:%M:%S"`] Creating timelapse video ($timelapseFramerate,$timelapseFrameskip)"
if [ $bTest = 0 -a $bCreatetimelapse = 1 ];
then
  frstepencode $inputFile.$inputVideoExt $timelapseFramerate $timelapseFrameskip $genre $timelapseExtra
else
  echo frstepencode $inputFile.$inputVideoExt $timelapseFramerate $timelapseFrameskip $genre $timelapseExtra
fi
echo

#Create still images
echo [`date "+%Y-%m-%dT%H:%M:%S"`] Creating still images
if [ $bTest = 0 -a $bCreatethumbs = 1 ];
then
  ffgenthumbs $inputFile$timelapseExtra.$outputVideoExt $stillImageinterval
else
  echo ffgenthumbs $inputFile$timelapseExtra.$outputVideoExt $stillImageinterval
fi
echo

if [ $bCombinemusic = 1 ];
then
  echo [`date "+%Y-%m-%dT%H:%M:%S"`] Combine music files $musicFilename
  if [ $bTest = 0 ];
  then
    aCat $inputFile-$combinedmusicOutput $musicFilename
  else
    echo aCat $inputFile-$combinedmusicOutput $musicFilename
  fi
  echo
fi

echo [`date "+%Y-%m-%dT%H:%M:%S"`] Add music
if [ $bTest = 0 -a $bAddmusic = 1 ];
then
  if [ $bCombinemusic = 1 ];
  then
    addAudioEncode $inputFile$timelapseExtra.$outputVideoExt $inputFile-$combinedmusicOutput.mp3 $inputFile$timelapseExtra$musicExtra
  else
    addAudioEncode $inputFile$timelapseExtra.$outputVideoExt $musicFilename $inputFile$timelapseExtra$musicExtra
  fi
else
  if [ $bCombinemusic = 1 ];
  then
    echo addAudioEncode $inputFile$timelapseExtra.$outputVideoExt $inputFile-$combinedmusicOutput.mp3 $inputFile$timelapseExtra$musicExtra
  else
    echo addAudioEncode $inputFile$timelapseExtra.$outputVideoExt $musicFilename $inputFile$timelapseExtra$musicExtra
  fi
fi
echo


echo [`date "+%Y-%m-%dT%H:%M:%S"`] Creating map and data images
if [ $bTest = 0 -a $bCreatemapdata = 1 ];
then
  mkdir $inputFile$mapdatadir
  parsegpx -i $inputFile.gpx -d `vidur $inputFile$timelapseExtra$musicExtra.$outputVideoExt` -op $inputFile$mapdatadir -dop $inputFile$mapdatadir -mo $mapoutput -do $dataoutput
else
  echo mkdir $inputFile$mapdatadir
  echo parsegpx -i $inputFile.gpx -d `vidur $inputFile$timelapseExtra$musicExtra.$outputVideoExt` -op $inputFile$mapdatadir -dop $inputFile$mapdatadir -mo $mapoutput -do $dataoutput
fi
echo

echo [`date "+%Y-%m-%dT%H:%M:%S"`] Creating map and data video files
if [ $bTest = 0 -a $bCreatemapdatavideo = 1 ];
then
  img2vid $inputFile$mapdatadir$mapoutput%04d.png 0 1 $inputFile-$mapoutput
  img2vid $inputFile$mapdatadir$dataoutput%04d.png 0 1 $inputFile-$dataoutput
else
  echo img2vid $inputFile$mapdatadir$mapoutput%04d.png 0 1 $inputFile-$mapoutput
  echo img2vid $inputFile$mapdatadir$dataoutput%04d.png 0 1 $inputFile-$dataoutput
fi
echo


echo [`date "+%Y-%m-%dT%H:%M:%S"`] Creating final video file
if [ $bTest = 0 -a $bCreatefinalvideo = 1 ];
then
  vidover_vb_ro -i $inputFile$timelapseExtra$musicExtra.$outputVideoExt -o1 $inputFile-$mapoutput.$outputVideoExt -o2 $inputFile-$dataoutput.$outputVideoExt -bm screen -e $finalExtra -g $genre
else
  echo vidover_vb_ro -i $inputFile$timelapseExtra$musicExtra.$outputVideoExt -o1 $inputFile-$mapoutput.$outputVideoExt -o2 $inputFile-$dataoutput.$outputVideoExt -bm screen -e $finalExtra -g $genre
fi
echo

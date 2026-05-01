
SOURCE_VIDEO=$1
FINAL_VIDEO=$SOURCE_VIDEO-loop.mp4

echo "Creating looped video from $SOURCE_VIDEO..."
echo "Output will be saved as $FINAL_VIDEO"

ffmpeg -i $SOURCE_VIDEO -i $SOURCE_VIDEO -filter_complex "[0:v][1:v]concat=n=2:v=1:a=0[out]" -map "[out]" $FINAL_VIDEO 

echo "Looped video created successfully: $FINAL_VIDEO"

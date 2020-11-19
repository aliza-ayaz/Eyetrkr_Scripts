#!/usr/bin/env zsh 
set -x
set -k 

ffmpeg -f rawvideo -framerate 250 -video_size 640x480 -pixel_format gray -r 250 -i $1.vid $1.mp4 
sed "s/$(printf '\r')\$//" $1.trk > $1_modified.trk

a=`grep 'start timecounter:' $1_modified.trk`
echo $a
ffmpeg -i $1.mp4 -movflags use_metadata_tags -metadata creation_time=$a $1_fixed.mp4

ffprobe $1_fixed.mp4 1>&$1.txt
sed "s/$(printf '\r')\$//" $1.txt > $1_modified.txt


trig_1=`cat $1.trk | grep Trigger | awk -F'T' '{print $(1)}' | awk 'NR==1'` 
echo $trig_1
start=`cat $1.trk | grep 'start timecounter' | awk -F'time' '{print $(NF-1) }'| awk -F':' '{print $NF}'`
echo $start
trig_last=`cat $1.trk | grep Trigger | awk -F'T' '{print $(1)}' | awk 'END{print}'|awk -F'.' '{print $1}'`
echo $trig_last


tru_start=`echo "$(($trig_1-$start))" |awk -F'.' '{print $(1)}'`
echo $tru_start
tru_start_sec=`echo "$((tru_start/1000))"`
echo $tru_start_sec
start_stamp=`printf '%d:%d:%d\n' $(($tru_start_sec/3600)) $(($tru_start_sec%3600/60)) $(($tru_start_sec%60))`
echo $start_stamp


cat $1_modified.trk | grep Trigger | awk -F'T' '{print $1 }' > tr.txt #saves the times which have triggers 
num_trigg=`wc -l tr.txt | awk '{print $(1)}'` #gets the length of the txt file which is the number of triggers 
echo $num_trigg
trig_time=`echo "$(($trig_last-$trig_1))"`
echo $trig_time
TR_avg=`echo "$(($trig_time/($num_trigg-1)))"`
echo $TR_avg



trigger_2=`cat $1_modified.trk | grep Trigger | awk -F'T' '{print $1 }' | awk 'NR==2'`
echo $trigger_2
TR=`echo $(($trigger_2-$trigger_1))| awk -F'.' '{print $1}'`
echo $TR

end_time=`echo "$(($trig_last+$TR))" |awk -F'.' '{print $(1)}'`
echo $end_time
end_time_sec=`echo "$((end_time/1000))"`
echo $end_time_sec
end_stamp=`printf '%d:%d:%d\n' $(($end_time_sec/3600)) $(($end_time_sec%3600/60)) $(($end_time_sec%60))`
echo $end_stamp
duration=`echo "$(($end_time-$trig_1))"`
echo $duration

ffmpeg -i $1_fixed.mp4 -ss ${start_stamp} -t ${duration} -c:a copy $1_timestamped.mp4



date=`cat $1_modified.txt | grep creation | awk -F'T' '{print $ (NF-1) }' | awk -F'time:' '{print $NF}'`
echo $date
time=`cat $1_modified.txt | grep creation | awk -F'T' '{print $NF }'| awk -F'.' '{print $ (NF-1) }'`
echo $time

all_secs=`echo ${time} | awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }'`
echo $all_secs
scan_start_secs=`echo "$(($all_secs+$tru_start_sec))"`
echo $scan_start_secs
scan_start=`printf '%d:%d:%d\n' $(($scan_start_secs/3600)) $(($scan_start_secs%3600/60)) $(($scan_start_secs%60))`
echo $scan_start



b=`echo -e "${date} \n\n ${scan_start} \n\n%{pts\:hms}"`
echo $b



ffmpeg -i $1_timestamped.mp4 -filter_complex drawtext="fontfile=/usr/share/fonts/truetype/freefont/FreeSerif.ttf: text=\'${b}\' :
     x=25: y=25: fontsize=12: fontcolor=white@0.9: box=0: boxcolor=black@0.8" -c:a copy $1_final.mp4





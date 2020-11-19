#!/usr/bin/env zsh 
set -x
set -k 

#converts the .vid file to .mp4, making it smaller and more manageable
#$1 refers to the first file in the working directory that we specify in the terminal. eg "eyetrking.sh runs_001"
ffmpeg -f rawvideo -framerate 250 -video_size 640x480 -pixel_format gray -r 250 -i $1.vid $1.mp4 
#removes the carriage return at the end of the line
sed "s/$(printf '\r')\$//" $1.trk > $1_modified.trk

#grabs the line that has the start timecounter (creation time) from trk and save it as creation time which is put into the metadata of the $1_fixed mp4
a=`grep 'start timecounter:' $1_modified.trk`
echo $a
ffmpeg -i $1.mp4 -movflags use_metadata_tags -metadata creation_time=$a $1_fixed.mp4

#put all the metadata in the mp4 into a text file
ffprobe $1_fixed.mp4 1>&$1.txt
#remove the carriage return which is at the end of the lines (not visible unless you try to see hidden chars on terminal)
sed "s/$(printf '\r')\$//" $1.txt > $1_modified.txt


#trig_1 is the time in ms of the first instance of a trigger
trig_1=`cat $1.trk | grep Trigger | awk -F'T' '{print $(1)}' | awk 'NR==1'` 
echo $trig_1
#start is the start time at the beginning of the trk file, i,e when eyetracker starts. but this is not the time we want, we want the time when mri starts 
start=`cat $1.trk | grep 'start timecounter' | awk -F'time' '{print $(NF-1) }'| awk -F':' '{print $NF}'`
echo $start
#trig_1 is the time in ms of the last instance of a trigger
trig_last=`cat $1.trk | grep Trigger | awk -F'T' '{print $(1)}' | awk 'END{print}'` 
echo $trig_last

#tru_start is the time in ms between the start of eyetracker and first trigger, which is the time we need to add onto the start time of the scan to give us the time when mri starts
tru_start=`echo "$(($trig_1-$start))" |awk -F'.' '{print $(1)}'`
echo $tru_start
#convert to secs
tru_start_sec=`echo "$((tru_start/1000))"`
echo $tru_start_sec
start_stamp=`printf '%d:%d:%d\n' $(($tru_start_sec/3600)) $(($tru_start_sec%3600/60)) $(($tru_start_sec%60))`
echo $start_stamp

#end_time is the time of the last trigger PLUS the TR which in this case is 1355. the TR is the difference in ms between two subsequent triggers 
end_time=`echo "$(($trig_last+1355))" |awk -F'.' '{print $(1)}'`
echo $end_time

#date of the scan
date=`cat $1_modified.txt | grep creation | awk -F'T' '{print $ (NF-1) }' | awk -F'time:' '{print $NF}'`
echo $date
#starting time of the scan in the format HH:MM:SS 
time=`cat $1_modified.txt | grep creation | awk -F'T' '{print $NF }'| awk -F'.' '{print $ (NF-1) }'`
echo $time

#convert it to seconds and add up hours mins and sec 
all_secs=`echo ${time} | awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }'`
echo $all_secs
#add the time bw start eyetracker and first trigger in seconds to the time in seconds at the start of the eyetrack - this gives the time in seconds when the mri scan starts
scan_start_secs=`echo "$(($all_secs+$tru_start_sec))"`
echo $scan_start_secs
#convert it back to HH:mm:ss
scan_start=`printf '%d:%d:%d\n' $(($scan_start_secs/3600)) $(($scan_start_secs%3600/60)) $(($scan_start_secs%60))`
echo $scan_start

#pts\:hms is a stopwatch/ counter
b=`echo -e "${date} \n\n ${time} \n\n%{pts\:hms}"`
echo $b


#draws b onto the top left corner of the video 
ffmpeg -i $1_fixed.mp4 -filter_complex drawtext="fontfile=/usr/share/fonts/truetype/freefont/FreeSerif.ttf: text=\'${b}\' :
     x=25: y=25: fontsize=12: fontcolor=white@0.9: box=0: boxcolor=black@0.8" -c:a copy $1_timestamped.mp4


trig_1=`cat runs_001.trk | grep Trigger | awk -F'T' '{print $(1)}' | awk 'NR==1'` 
echo $trig_1
start=`cat runs_001.trk | grep 'start timecounter' | awk -F'time' '{print $(NF-1) }'| awk -F':' '{print $NF}'`
echo $start
trig_last=`cat runs_001.trk | grep Trigger | awk -F'T' '{print $(1)}' | awk 'END{print}'|awk -F'.' '{print $1}'`
echo $trig_last


tru_start=`echo "$(($trig_1-$start))" |awk -F'.' '{print $(1)}'`
echo $tru_start
tru_start_sec=`echo "$((tru_start/1000))"`
echo $tru_start_sec
start_stamp=`printf '%d:%d:%d\n' $(($tru_start_sec/3600)) $(($tru_start_sec%3600/60)) $(($tru_start_sec%60))`
echo $start_stamp


end_time=`echo "$(($trig_last+1355))" |awk -F'.' '{print $(1)}'`
echo $end_time
end_time_sec=`echo "$((end_time/1000))"`
echo $end_time_sec
end_stamp=`printf '%d:%d:%d\n' $(($end_time_sec/3600)) $(($end_time_sec%3600/60)) $(($end_time_sec%60))`
echo $end_stamp
duration=`echo "$(($end_time-$trig_1))"`
echo $duration

_______________________________
#to run in terminal

#!/usr/bin/env zsh 
set -x

ffmpeg -f rawvideo -framerate 250 -video_size 640x480 -pixel_format gray -r 250 -i HV.vid HV.mp4 
sed "s/$(printf '\r')\$//" HV.trk > HV_modified.trk

a=`grep 'start timecounter:' HV_modified.trk`
echo $a
ffmpeg -i HV.mp4 -movflags use_metadata_tags -metadata creation_time=$a HV_fixed.mp4

ffprobe HV_fixed.mp4 1>&HV.txt
sed "s/$(printf '\r')\$//" HV.txt > HV_modified.txt


trig_1=`cat HV.trk | grep Trigger | awk -F'T' '{print $(1)}' | awk 'NR==1'` 
echo $trig_1
start=`cat HV.trk | grep 'start timecounter' | awk -F'time' '{print $(NF-1) }'| awk -F':' '{print $NF}'`
echo $start
trig_last=`cat HV.trk | grep Trigger | awk -F'T' '{print $(1)}' | awk 'END{print}'|awk -F'.' '{print $1}'`
echo $trig_last


tru_start=`echo "$(($trig_1-$start))" |awk -F'.' '{print $(1)}'`
echo $tru_start
tru_start_sec=`echo "$((tru_start/1000))"`
echo $tru_start_sec
start_stamp=`printf '%d:%d:%d\n' $(($tru_start_sec/3600)) $(($tru_start_sec%3600/60)) $(($tru_start_sec%60))`
echo $start_stamp

trigger_2=`cat HV_modified.trk | grep Trigger | awk -F'T' '{print $1 }' | awk 'NR==2'`
echo $trigger_2
TR=`echo $(($trigger_2-$trigger_1))| awk -F'.' '{print $1}'`
echo $TR

end_time=`echo "$(($trig_last+1355))" | awk -F'.' '{print $(1)}'`
echo $end_time
end_time_sec=`echo "$((end_time/1000))"`
echo $end_time_sec
end_stamp=`printf '%d:%d:%d\n' $(($end_time_sec/3600)) $(($end_time_sec%3600/60)) $(($end_time_sec%60))`
echo $end_stamp
duration=`echo "$(($end_time-$trig_1))"`
echo $duration

ffmpeg -i HV_fixed.mp4 -ss ${start_stamp} -t ${duration} -c:a copy HV_timestamped.mp4


date=`cat HV_modified.txt | grep creation | awk -F'T' '{print $ (NF-1) }' | awk -F'time:' '{print $NF}'`
echo $date
time=`cat HV_modified.txt | grep creation | awk -F'T' '{print $NF }'| awk -F'.' '{print $ (NF-1) }'`
echo $time

all_secs=`echo ${time} | awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }'`
echo $all_secs
scan_start_secs=`echo "$(($all_secs+$tru_start_sec))"`
echo $scan_start_secs
scan_start=`printf '%d:%d:%d\n' $(($scan_start_secs/3600)) $(($scan_start_secs%3600/60)) $(($scan_start_secs%60))`
echo $scan_start



b=`echo -e "${date} \n\n ${scan_start} \n\n%{pts\:hms}"`
echo $b



ffmpeg -i HV_timestamped.mp4 -filter_complex drawtext="fontfile=/usr/share/fonts/truetype/freefont/FreeSerif.ttf: text=\'${b}\' :
     x=25: y=25: fontsize=12: fontcolor=white@0.9: box=0: boxcolor=black@0.8" -c:a copy HV_final.mp4



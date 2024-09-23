%Checking for missing frames using a histogram approach. Check scatterplot approach below for better visual representation of individual outliers 
function [ave] = frame(filename)

str=['cat ' filename ' | sed ''1,5d;$d'' | grep -v Trigger | awk ''{print $1}'' '];
[jk a]=system(str);
ave.a=str2num(a);
ave.b=diff(ave.a);
ave.mean=mean(ave.b);
ave.max=max(ave.b);
histogram(ave.b);
set(gca,'yscale','log');
set(gca,'xscale','log');
xlabel('Time difference between subsequent frames');
ylabel('Frequency');
title(filename);
savefig('HistogramFile.fig');

ave.m =[ave.mean;ave.max];
writematrix(ave.m,'frame.xls');
writematrix(filename,'frame.xls','WriteMode','append');
readmatrix('frame.xls');
end



%Scatter Plot Approach
clear all
%add your directory here, e.g direct = '/Users/aliza/Desktop/trk_copy';
direc = dir(direct);
num_subdir = size(direc, 1);
how_many_unique = zeros(84,1);
j = 0; % counter - counts how many trk files you will work on
tiledlayout(3, 5)
for i = 4:19
  fs = dir([direct '/' direc(i).name]);
  for ii = 4: size(fs, 1)
    curr_file = [fs(ii).folder '/' fs(ii).name];
    if and(strcmp(curr_file(end - 2:end), 'trk'), (fs(ii).bytes > 0))
      j = j + 1;
      str=['cat ' curr_file ' | sed ''1,5d;$d'' | grep -v Trigger | awk ''{print $1}'' '] ;
      [jk, a]=system(str);
      ave.b=diff(str2num(a));
      nexttile
      scatter(1:numel(ave.b), ave.b, '.k')
      xlabel('timepoints'); ylabel('delay between adjacent frames, ms')
      title(curr_file)
    end
  end
end
 

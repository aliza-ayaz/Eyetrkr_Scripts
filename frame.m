function [ave] = frame(filename)

%run in command line 
%addpath '/Users/alizaayaz/Desktop/scrippies'
%addpath '/Users/alizaayaz/Desktop/dumbo'
%frame('runs_001.trk')

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
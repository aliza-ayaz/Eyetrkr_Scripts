%MATLAB script to QC your .trk files
clear all
direct = '/Users/[yourpath]';
direc = dir(direct);
num_subdir = size(direc, 1);
how_many_unique = zeros(84,1);
j = 0; % counter - counts how many .trk files you will work on
%tiledlayout(3, 5)
for i = 4:5
  fs = dir([direct '/' direc(i).name]);
  for ii = 4: size(fs, 1)
    curr_file = [fs(ii).folder '/' fs(ii).name];
  % check if .trk with 
    if and(strcmp(curr_file(end - 2:end), 'trk'), (fs(ii).bytes > 0))
      j = j + 1;
      str=['cat ' curr_file ' | sed ''1,5d;$d'' | grep -v Trigger | awk ''{print $1}'' '] ;
      [jk, a]=system(str);
      ave.b=diff(str2num(a));
      %nexttile
      scatter(1:numel(ave.b), ave.b, '.k')
      xlabel('Time'); ylabel('Delay Between Adjacent Frames (ms)')
      title(curr_file,'Interpreter','none')
      %       ave.b=diff(ave.a);
%       imcurious.which_values(j) = {unique(ave.b)};
%       imcurious.how_many_unique(j) = numel(imcurious.which_values);
%       imcurious.in_which_file(j) = {curr_file};
%       imcurious.max_val(j) = max(ave.b);
%       imcurious.min_val(j) = min(ave.b);
    end
  end
end

%get mean, max of time intervals for each eyetracking video
fid = fopen('frame.csv');
format longG;
MeanArray=csvread('frame.csv',1,11, [1 11 69 11]);
MaxArray=csvread('frame.csv',1,10, [1 10 69 10]);
figure(1)
subplot(2,1,1)
plot1=bar(MeanArray);
ylabel('Mean Time Between Two Frames');
xlabel('Eyetracking file #');


subplot(2,1,2)
plot2=bar(MaxArray);
set(gca,'yscale','log');
ylabel('Maximum Time Between Two Frames');
xlabel('Eyetracking file #');

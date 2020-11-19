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

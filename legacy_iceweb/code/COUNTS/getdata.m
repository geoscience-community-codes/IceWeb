function [dnum,counts]=getdata(fname,ndays);
% used for 'helicorder' file date formats, which are MMDDYY0000
%
% Based on getdata(fname,ndays), most likely written by Glenn Thompson
% documentation Updated by Celso Reyes July 24, 2003
%
% rewritten, Oct 31, 2005, Celso Reyes

[M,D,Y, counts,notes] = textread(fname,'%2u%2u%2u0000 %f%[^\n]');

%because of the two-digit year, I need to do the following formatting
Y(Y<80) = Y(Y<80) + 2000; %if the year is before 1980 it's probably 20XX
Y(Y<100) = Y(Y<100) + 1900; %otherwise it's likely in the 100's 

dnum = datenum([Y M D Y*0 Y*0 Y*0]);

firstDate = fix(now) - ndays; %find the datenum of our first day
indexMask = dnum >= firstDate; %which dates are we interested in?
dnum = dnum(indexMask); %chop dates down
counts = counts(indexMask); %chop counts down

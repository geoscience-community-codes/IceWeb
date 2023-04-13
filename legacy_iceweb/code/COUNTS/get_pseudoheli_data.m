function [dnum,counts]=get_pseudoheli_data(fname,ndays);
%  GET_PSEUDOHELI_DATA - reads pseudohelicorder information
%
%  rewritten by Celso, November 2005


%grab the data
[dnum, counts,n] = textread(fname,'%s %f%[^\n]');
%now, we have a cell array of dates and counts
dnum = datenum(dnum); % change text dates into datenumbers

firstDate = fix(now) - ndays; %find the datenum of our first day

indexMask = dnum >= firstDate; %which dates are we interested in?

dnum = dnum(indexMask); %chop dates down
counts = counts(indexMask); %chop counts down


% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%% BEGIN OLD CODE
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% global TEMP;
% 
% snum=floor(now)-ndays;
% 
% % look at last NDAYS rows of file
% tempfile=[TEMP,'/tempwebheli.dat'];
% eval(['!tail -',num2str(ndays),' ',fname,' > ',tempfile]);
% fid=fopen(tempfile,'r');
% 
% % read first date
% datestamp=fscanf(fid,'%c',8);
% 
% % initilise arrays
% y=[]; x=[];
% 
% % loop until end of 'shortened' file
% while(length(datestamp)==8),
% 	yy=round(fscanf(fid,'%f',1));
% 	trash=fgetl(fid);
% 	xx=datenum(datestamp);
% 	if xx>snum
% 		y=[y yy]; x=[x xx];
% 	end
% 	datestamp=fscanf(fid,'%c',8);
% end
% 
% % close file
% fclose(fid);
% 
% % make final array one entry per day - otherwise datetick.m screws up
% dnum=snum:floor(now);
% counts=zeros(length(dnum),1);
% for c=1:length(x)
% 	index=find(dnum==x(c));
% 	if ~isempty(index)
% 		counts(index)=y(c);
% 	end
% end

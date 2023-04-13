function pseudoheliplot(station,channel,nhrs,nlines);
% Glenn Thompson, October 1999
% Usage: [data,samprate,NOT_FOUND]=pseudoheliplot(station,channel,nhrs,nlines)
% station - 3 or 4 character station id
% channel - 3 character channel id, usually 'SHZ'
% nhrs - number of hours of data to plot
% nlines - number of lines to use for plotting data
%
% This is at an early stage of development !!


tic
global db aeicpf TRUE FALSE;
TRUE=1; FALSE=0;
path(path,'/home/iceweb/ICEWEB_UTILITIES');

start_time=str2epoch('now')-nhrs*3600;
end_time=str2epoch('now');

close all;

[data,DATA_FOUND,samprate]=get_iceworm_data_for_station(station,channel,start_time,end_time);
toc
if DATA_FOUND == TRUE
	[data,secs]=resamp(data,5*nhrs,samprate);
	toc
	m=rms(data);
	if m<1000
		panel_height_in_counts=100;
		while (m*nlines*5 > panel_height_in_counts)
			panel_height_in_counts=panel_height_in_counts*2;
		end
		l=length(data);
		dl=floor(l/nlines);
		lines_apart=panel_height_in_counts/(nlines+1);
		Yticks=[];Ylabels='';
		snum=epoch2dnum(start_time);
		axes('position',[0.1 0.1 0.8 0.8]);
		for line_num=1:nlines
			firstsample=(line_num-1)*dl+1;
			lastsample=line_num*dl;
			d=data(firstsample:lastsample);
			s=secs(firstsample:lastsample)-secs(firstsample);
			offset=lines_apart*(nlines-line_num);
			Yticks=[offset Yticks];
			stime=snum+(line_num-1)*nhrs/nlines/24;
			Ylabels=[datestr(stime,15); Ylabels];
			plot(s,d+offset,'k');
			set (gca,'LineWidth',[0.01]);
			hold on;
		end	
		set(gca,'YTick',Yticks,'YTickLabel',Ylabels);
		title(station);
		axes('position',[0.95 0.4 0.01 0.2]);
		image([1; 64; 1; 64]); colormap(pink);
		ylabel(sprintf('%d counts',panel_height_in_counts/4));
		set(gca,'XTick',[],'XTickLabel',[''],'YTick',[],'YTickLabel',['']);
		print -dps fred2.ps
	else
		disp('ERROR: data has values > 1000 counts');
	end
else
	disp('got no data');
end
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data,secs]=resamp(data,factor,samprate);
% for 1 hour, data resampled 100 - 20 Hz.
% decimation prefilters with high cut at 10 Hz
data=decimate(data,factor);
sample_num=1:length(data);
sample_rate=samprate(1)/factor;
secs=1/sample_rate.*sample_num;
% Now need to low cut at 0.8 Hz
[b a]=butter(1,1.6/sample_rate);
data=filtfilt(b,a,data);

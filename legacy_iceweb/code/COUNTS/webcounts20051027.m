function webcounts(volcano);
% Glenn Thompson, September 1998
% Modified: Celso Reyes, July 2003
% This function produces 4 graphs on 1 page for the volcano specified
% This is written to a gif file for display on the internal web page
% Top left - helicorder counts
% Top right - pseudo-helicorder counts
% Bottom left - detected VT events (a-types)
% Bottom right - detected LP events (b-types)

% globals
global COUNTS TEMP HELIWEB;
COUNTS=['/home/glenn/ICEWEB/COUNTS'];
TEMP=['/tmp'];
HELIWEB=['/usr/local/Mosaic/AVO/internal/heli'];

% set up main variables
volcano=deblank(volcano);
ndays=180; % was 3 months, changed to 6  CR
maxcounts=20;
mincounts=0;

% close all figures
close all;

% titles
tstr{1}=['Helicorder counts for ',volcano];
tstr{2}=['Pseudo-helicorder counts for ',volcano];
tstr{3}=['Detected a-type events for ',volcano];
tstr{4}=['Detected b-type events for ',volcano];

% filenames
fname{1}=['/home/guy/avo/counts/helicorder/',volcano,'.dat'];
fname{2}=[COUNTS,'/',volcano,'.ext'];
fname{3}=['/home/guy/avo/counts/detected/',volcano,'a.dat'];
fname{4}=['/home/guy/avo/counts/detected/',volcano,'b.dat'];

% Y-axis labels
ystr{1}='Counts per day';
ystr{2}=['Normalized ',ystr{1}];
ystr{3}=ystr{1};
ystr{4}=ystr{1};

% loop for detected events and helicorder counts

disp(volcano); %TESTING

for subfig=1:4
        disp(fname{subfig}) %TESTING

	fin=fopen(fname{subfig});
	if (fin==-1)
        % disp(['couldn''t open ' fname{subfig}]);
		show_no_data(subfig);
		title(tstr{subfig});
	else
		switch subfig
			case 1, [dnum,counts]=getdata(fname{subfig},ndays*2);
            case {3,4}, [dnum,counts]=get_detected_data(fname{subfig},ndays*2); %added to handle date formatting -CR
			case 2, [dnum,counts]=get_pseudoheli_data(fname{subfig},ndays*2);
		end
	    fclose(fin);
        
        % Following added for graph scaling - CR
        if max(counts) > 20, maxcounts = max(counts(end-ndays:end)) + 5;else  maxcounts = 20; end;
        
        
		plot_histogram(subfig,dnum,counts,ndays,mincounts,maxcounts,tstr{subfig},ystr{subfig});
		%subplot(2,2,subfig),plot(counts)
	end
end

add_last_update_time;
convert_to_gif(volcano);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function add_last_update_time();
rect = [0.15 0.01 0.7 0.05 ];
axes('position',rect); 
set(gca,'Xtick',[],'Ytick',[]);
text(0.35,0.5,['Data ends at ',datestr(now,1)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function convert_to_gif(volcano);
global TEMP HELIWEB;
psfile=[TEMP,'/',volcano,'.ps'];
% resize on screen
%set(gcf,'Position',[40 100 700 700]);
eval(['print -dpsc ',psfile]);
giffile=[HELIWEB,'/',volcano,'.gif'];
eval(['!/usr/local/bin/alchemy ',psfile,' -Zm2 -Zc1 -Zo 1000p -Z+ ',giffile,' -go -Q']); % my try
% eval(['!/usr/local/bin/alchemy ',psfile,' -Zm2 -Zc1 -Zo 600p -Z+ ',giffile,' -go -Q']);
%eval(['!rm ',psfile]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function show_no_data(subfig);
subplot(4,1,subfig), plot(10);
axis([0 1 0 20]);
text(0.1,10.0,'no data');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_histogram(subfig,dnum,counts,ndays,mincounts,maxcounts,tstr,ystr);
subplot(4,1,subfig), bar(dnum,counts);
enum=floor(now);
axis([enum-ndays enum mincounts maxcounts]);
DateTickLabel('x');
title(tstr);
ylabel(ystr);




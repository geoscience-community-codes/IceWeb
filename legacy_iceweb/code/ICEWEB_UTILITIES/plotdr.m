function plotdr(t,dr,volcano,stations,snum,enum);
% plots the supplied reduced displacement data
%
% modified 12/14/2005 by Celso
%   Fixed error where a wind value of zero causes entire wind vector to
%   collapse to the scalar [0]
%   Also, fixed (KLUDGE!) dates.  The date2dnum.pl program is off by one day
%   (as of today), and only returns NOW values, as opposed to values passed
%   to it.  I didn't change in case it would affect other parts of iceweb.
%   Ideally, fix date2dnum.pl, and remove the "+1" and teh "-1" below...
global FALSE;

windstation=read_windstation(volcano);
numstations=length(stations);

% number of days
days=enum-snum;

% open new figure window
figure

% symbols for plotting points
if days<3
	symbol='+';
else
	symbol='.';
end

% colours to plot each station
line_colour={'b','r','g','m','c','y','k'};

% plot dr data
for station_num=1:numstations
	hold on;

	if any(dr{station_num})
		dr0_ind = find(dr{station_num} <= 0);
	end

%	if dr{station_num} > 0
		logdr = log10(dr{station_num});  % use log plots
%	else
%		logdr = 0;
%	end

	if isempty(logdr)
		send_IceWeb_error(['No dr data to plot for ',stations{station_num}]);
	else
		plot(t{station_num},logdr,[line_colour{station_num},symbol]);
	end
end

% add wind data
ystr = 'Dr (cm^2)';
if windstation == 'nowind'
	disp('no windstation');
else
	[wt,wind,NO_WIND_DATA]=grabwinddata(snum-1,enum,windstation); %the -1 is part of the Kludge, see header
	if NO_WIND_DATA==FALSE
        troublewind = find(wind <= 0);
        wind(troublewind) = 1; % we'll get a log of zero    -cr
        logwind = log10(wind);

		switch windstation
            case 'auwind', wsstr='Augustine Is';
			case 'cbwind', wsstr='Cold Bay';
			case 'howind', wsstr='Homer';
			case 'ilwind', wsstr='Iliamna';
			case 'dhwind', wsstr='Dutch Harbour';
			case 'kswind', wsstr='King Salmon';
			case 'gkwind', wsstr='Glennallen';
            case 'rewind', wsstr='Drift River';
		end
		ystr = sprintf('Dr (cm^2) and surface winds @ %s (miles/h)',wsstr);
		plot(wt + 1,logwind,'k-x'); %the "+1" is a kludgey fix, see header
	end
end

% Print station legend
%for i = 1:numstations
%	disp(['Station(',int2str(i),')= ',stations(i)])
%	stations(i)
%	xStatText(i) = snum + (i * ((enum + snum)/(2 * numstations)));
%	yStatText(i) = min(Ytickmarks) / 5;
%	hStatText(i) = text(xStatText(i),yStatText(i),stations(i));
%	set(hStatText(i),'Color',line_colour{i});
%end

% Position, axes limits, gridding & labelling
hold off;
grid;
Ytickmarks=log10([0.05 0.1 0.2 0.5 1 2 5 10 20 50 100]);
Yticklabels=['.05';'0.1';'0.2';'0.5';'1  ';'2  ';'5  ';'10 ';'20 ';'50 ';'100'];
% axes positions
rect = [0.1 0.3 0.85 0.6];
set(gca,'position', rect,'LineWidth',[2],'XLim',[snum enum], ...
'YLim', [min(Ytickmarks) max(Ytickmarks)],'YTick',Ytickmarks,'YTickLabel',Yticklabels);
DateTickLabel('x',gca);

% Add title and axes labels
maxt=calculate_maxt(t,numstations);
tstr=sprintf('%s %s UT',volcano,datestr(maxt,0));
title(tstr,'Color',[0 0 0],'FontSize',[16], 'FontWeight',['bold']');
xlabel('UT'); 
ylabel(ystr); 

% Add legend
try
for i = 1:numstations
  text((.1*(i-1.2)),-.16,stations(i),'units','normalized','Color',line_colour{i}, ...
       'FontName','Helvetica','FontSize',[14],'FontWeight','bold');
end
catch
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function maxt=calculate_maxt(t,numstations);
for station_num=1:numstations
	temp=t{station_num};
	if isempty(temp)
		maxtemp(station_num)=-1;
	else
		maxtemp(station_num)=temp(length(temp));
	end
end
maxt=max(maxtemp);


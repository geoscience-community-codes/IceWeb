function plotdr(t,dr,volcano,stations,snum,enum);
% plots the supplied reduced displacement data

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
	lindr = dr{station_num};  % use log plots
	if isempty(lindr)
		send_IceWeb_error(['No dr data to plot for ',stations{station_num}]);
	else
		plot(t{station_num},lindr,[line_colour{station_num},symbol]);
	end
end

% add wind data
ystr = 'Dr (cm^2)';
if windstation == 'nowind'
	disp('no windstation');
else
	[wt,wind,NO_WIND_DATA]=grabwinddata(snum,enum,windstation);
	if NO_WIND_DATA==FALSE
		switch windstation
			case 'cbwind', wsstr='Cold Bay';
			case 'howind', wsstr='Homer';
			case 'ilwind', wsstr='Iliamna';
			case 'dhwind', wsstr='Dutch Harbour';
			case 'kswind', wsstr='King Salmon';
			case 'gkwind', wsstr='Glennallen';
		end
		ystr = sprintf('Dr (cm^2) and surface winds @ %s (miles/h)',wsstr);
		plot(wt,wind,'k-x');
	end
end

% Position, axes limits, gridding & labelling
hold off;
grid;
DateTickLabel('x',gca);

% Add title and axes labels
maxt=calculate_maxt(t,numstations);
tstr=sprintf('%s %s UT',volcano,datestr(maxt,0));
title(tstr,'Color',[0 0 0],'FontSize',[16], 'FontWeight',['bold']');
xlabel('UT'); 
ylabel(ystr); 

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


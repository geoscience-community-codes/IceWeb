function [stations,numstations]=stations_to_use(volcano);

% read stations
[stations,pss,NO_PARAMETER_FILE]=read_iceweb_stations(volcano);
numstations=length(stations);

disp(' ');
disp(['Current IceWeb stations for ',volcano,' are:']);
disp(stations);

disp(' ');
choice=input('Do you want to plot all these stations (y/n) ? ','s');
if lower(choice(1))=='n'
	disp(' ');
	numstations=input('Enter number of stations you want to plot  ? ');
	numstations=min(numstations,5);
	disp(' ');
	disp('Enter stations you want plotting: ');
	stations={};
	for c=1:numstations
		stations{c}=input(['Enter station ',num2str(c),' ? '],'s');
	end
	disp(['The following stations will be plotted:']);
	disp(stations);
end

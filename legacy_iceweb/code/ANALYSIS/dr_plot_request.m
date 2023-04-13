function [stations]=dr_plot_request(volcano,snum,enum);

global TRUE FALSE;
days=enum-snum;

% use which stations?
[stations,numstations]=stations_to_use(volcano);

% station corrections?
choice=input('Do you want to apply station corrections (y/n) ? ','s');
if lower(choice(1))=='y'
	SCF=TRUE;
else
	SCF=FALSE;
end

% load drs data (for all plots)
for station_num=1:numstations
	[t,y,DATA_FOUND(station_num)]=...
	load_dr_data(volcano,stations{station_num},snum,enum);
	if SCF==TRUE
		sc(station_num)=input(['Enter station correction for ',stations{station_num}]);
		y=y*sc(station_num);
	else
		sc(station_num)=1;
	end
	drs{station_num}=y;
	dnum{station_num}=t;
end

if sum(DATA_FOUND)>=1
	choice=input(['Do you want (1) linear or (2) log scale  (3) average ? ']);

	switch choice
		case 1, plotlindr(dnum,drs,volcano,stations,snum,enum);
		case 2, plotdr(dnum,drs,volcano,stations,snum,enum);
		case 3, plotdrav(dnum,drs,stations,snum,enum);
	end

	saveit=input('Do you want to save this dataset','s');
	if lower(saveit(1))=='y'
		fname=input('Enter file name to save this to: ','s');
		eval(['save ',fname,'.mat dnum drs stations volcano snum enum']);
	end

	if choice~=3
		lchoice = input('Add legend (y/n) ? ','s');
		if lchoice(1)=='y' | lchoice(1)=='Y'
			for station_num=1:numstations
				labels{station_num}=sprintf('%s %5.2f',stations{station_num},sc(station_num));
			end
			legend(labels,0);
		end
	end
else
	disp('No data was found to match your request');
end
disp(stations);

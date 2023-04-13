function spec_bands(volcano,snum,enum,choice)

global TRUE FALSE;
TRUE=1;FALSE=0;

close all;

% set other important variables
F=0.5:0.1:15.0;  % this is frequency range of archived SSAM data

% read set of stations for each volcano from controlfile
stations=read_iceweb_stations(volcano);
numstations=length(stations);

% frequency bands
oms_min=0.5;
oms_max=0.7;
tremor_min=0.8;
tremor_max=2.5;
wind_min=10.0;
wind_max=15.0;

% indexes
oa=oms_min*10-3;
ob=oms_max*10-3;
ta=tremor_min*10-3;
tb=tremor_max*10-3;
wa=wind_min*10-3;
wb=wind_max*10-3;

% loop over all stations in controlfile for this volcano
for c=numstations:-1:1
	station=stations{c};

	% initialise arrays
	T_array=[];
	oms_array=[];
	tremor_array=[];
	wind_array=[];

	% loop over all specified days
	for dnum=snum:enum

		% get day, month & year
		% this is used for filenames
		[yr,mn,dy]=yyyymmdd(dnum);


		% load spectral data for this day
		[data,DATA_FOUND]=load_spec_data(yr,mn,dy,station);

		if DATA_FOUND==TRUE
			l=size(data(:,2),1);
			for cc=1:l
				T(cc,1)=data(cc,1);
				oms(cc,1)=nanmean(data(cc,oa:ob));
				tremor(cc,1)=nanmean(data(cc,ta:tb));
				wind(cc,1)=nanmean(data(cc,wa:wb));	
			end

			% append to array
			T_array=[T_array;T];
			oms_array=[oms_array;oms];
			tremor_array=[tremor_array;tremor];
			wind_array=[wind_array;wind];
		end
	end % loop over days

	if ~isempty(T_array)

		figure;
		if lower(choice(1))=='r'
			plot_ratios(T_array,oms_array,tremor_array,wind_array);
		else
			plot_absolutes(T_array,oms_array,tremor_array,wind_array);
		end
		ylabel(station);
		xlabel('Time');
		title([datestr(snum,0),'  to  ',datestr(enum,0)]);
		a=axis;
		axis([snum enum a(3) a(4)]);
		DateTickLabel('x');
	end
end % loop over stations

disp(['Tremor band is ',num2str(tremor_min),'-',num2str(tremor_max),' Hz']);
disp(['OMS    band is ',num2str(tremor_min),'-',num2str(tremor_max),' Hz']);
disp(['Wind   band is ',num2str(tremor_min),'-',num2str(tremor_max),' Hz']);

function plot_ratios(T_array,oms_array,tremor_array,wind_array);
oms_ratio=tremor_array./oms_array;
wind_ratio=tremor_array./wind_array;
semilogy(T_array,oms_ratio,'bo', T_array,wind_ratio,'bx');
legend('trem:oms','trem:wind');

function plot_absolutes(T_array,oms_array,tremor_array,wind_array);
semilogy(T_array,oms_array,'bo',T_array,tremor_array,'gx', T_array,wind_array,'k.');
legend('oms','tremor','wind');

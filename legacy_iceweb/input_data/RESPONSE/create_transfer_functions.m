%function create_transfer_functions();

RESPONSE_PATH = ['/home/iceweb/DATA/RESPONSE'];

eval(['load ',RESPONSE_PATH,'/f.ext']); %Frequencies for resampling

%calfile=[RESPONSE_PATH,'/transfer_OKMOK.in'];
%calfile=[RESPONSE_PATH,'/Summary_Guy.in'];
%calfile=[RESPONSE_PATH,'/transfer_KOROVIN.in'];
%calfile=[RESPONSE_PATH,'/transfer_PEULIK.in'];
%calfile=[RESPONSE_PATH,'/transfer_SEMISOPOCHNOI.in'];
%calfile=[RESPONSE_PATH,'/transfer_LITTLESITKIN.in'];
%calfile=[RESPONSE_PATH,'/transfer_AUGUSTINE.in'];
calfile=[RESPONSE_PATH,'/transfer_AUNW.in'];

fcal=fopen(calfile,'r');
station=fscanf(fcal,'%s',1)

while(length(station)>0),
	filler=fscanf(fcal,'%s',1);
	[sdate,edate]=fscanf(fcal,'%f',2);
	samples=fscanf(fcal,'%d',1);

	for i=1:samples
		p(i)=fscanf(fcal,'%f',1);
		data(i)=fscanf(fcal,'%f',1);
	end

	transferfile=[RESPONSE_PATH,'/',station,'.ext'];
	disp(['Processing: ',station])

	for count=1:samples
		fi(count)=1/p((samples+1) - count);
		response(count)=data((samples+1)-count);
	end

	if fi(samples)==fi(samples-1)
		samples=samples-1;
	end

	newresponse=spline(fi(1:samples),response(1:samples),f);
	eval(['save ',transferfile,' newresponse -ASCII']);
	station=fscanf(fcal,'%s',1);
end
fclose(fcal);


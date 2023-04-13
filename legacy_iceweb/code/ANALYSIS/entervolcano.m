function volname=entervolcano();

% read all controlfile data
volcanoes=read_iceweb_volcanoes;
numvolcanoes=length(volcanoes);

volnumber =0;
while (volnumber<1 | volnumber>numvolcanoes),
	disp(' ');
	disp(['Volcanoes on IceWeb are:']);
	for c=1:numvolcanoes
		disp(['   (',num2str(c),') ',volcanoes{c}]);
	end
	volnumber=input('Which volcano ? ');
end
volname=volcanoes{volnumber};

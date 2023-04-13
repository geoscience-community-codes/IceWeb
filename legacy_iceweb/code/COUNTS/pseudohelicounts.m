function pseudohelicounts();
% Glenn Thompson 23/9/1998
% Modified 10/11/1998 to work with a loop
% Plots pseudo-helicorder counts for Akutan, Pavlof & Shishaldin on same graph
% Outputs a postscript file (which is then send to the Sparcprinter)
close all;
ndays=input('How many days of data do you want to plot ?');
axisbox=[now-ndays now -2 32];
if ndays<100
	datetickstyle = 6;
else
	datetickstyle = 12;
end

for fig=1:3
	switch fig
		case 1, volname='Akutan';
		case 2, volname='Shishaldin';
		case 3, volname='Pavlof';
	end
	dvector=[]; cvector=[];
	fname=['/home/glenn/COUNTS/',lower(volname),'.ext'];
	fid=fopen(fname,'r');
	datestamp=fscanf(fid,'%c',8);
	first=1;
	while(length(datestamp)==8),
		counts=fscanf(fid,'%f',1);
		counts=round(counts);
		crap=fgetl(fid);
		dnum=datenum(datestamp);
		if first == 1
			cvector=counts; dvector=dnum; first=0;
		else
			cvector=[cvector counts]; dvector=[dvector dnum];
		end
		datestamp=fscanf(fid,'%c',8);
	end
	figure(fig);
	axes('position',[0.1 0.1 0.8 0.75]);
	bar(dvector,cvector);
	axis(axisbox);
	datetick('x',datetickstyle);
	tstr=sprintf('Pseudo-helicorder counts for %s\n%s',volname,datestr(now,1));
	title(tstr,'FontSize',[18]);
	ylabel('Normalised counts per day');
	grid;
	print -dps counts.ps
	!lp counts.ps
end

function plotdrav(dnum,drs,stations,snum,enum);
numstations=length(stations);
m=0;
for c=1:numstations
	eval(['dr',num2str(c),'=drs{',num2str(c),'};']);
	eval([sprintf('m(c)=length(dr%d);',c)]);
end
m=max(m);
if m~=0
	cmdstr=[];
	t=dnum{1};
	t(m+1)=NaN;
	for c=1:numstations
		eval([sprintf('dr%d(m+1)=NaN;',c)]);
		cmdstr=[cmdstr,' ',sprintf('dr%d;',c)];
	end

	eval(['dr=[',cmdstr,'];']);
	avdr=mean(dr);
	plot(t,avdr);
	xlabel('UT');
	ylabel('Dr (cm^2)');
	%axis([snum enum 0 max(avdr)*1.05]);
	DateTickLabel('x');
	grid;
	%title(sprintf('Average Dr of %s',stations),...
	%'Color',[0 0 0],'FontSize',[16], 'FontWeight',['bold']'); 
end




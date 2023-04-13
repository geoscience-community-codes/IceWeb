function doerte(dr,t,volname,numstations,stations,weatherstation,snum,enum);
days=enum-snum

figure

% HACK - code below assumes there are 5 stations per volcano!
l=length(dr);
if numstations<5
	for c=numstations+1:5
		dr(1:l,c)=ones(1:l,1)*NaN;
		t(1:l,c)=dr(1:l,c);
	end
end


ystr = sprintf('Dr (cm^2)');
plot(t(:,5),dr(:,5),'c+',t(:,4),dr(:,4),'m+',t(:,3),dr(:,3),'g+', ...
t(:,2),dr(:,2),'r+',t(:,1),dr(:,1),'b+');

% Grid it!
grid

datetick('x',15);

creation_time = epoch2dnum(0);

% Add title and axes labels
tstr=sprintf('Last data point is %s UT',datestr(max(max(t)),0));
title(tstr,'Color',[0 0 0],'FontSize',[10], 'FontWeight',['bold']');
xlabel('UT time'); 
ylabel(ystr); 

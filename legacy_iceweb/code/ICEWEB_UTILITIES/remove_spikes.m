function [t,y]=remove_spikes(t,y);
for c=2:length(t)-1
	if y(c)>2*y(c-1) & y(c)>2*y(c+1)
		y(c)=NaN;
	end
end
figure(2);
plot(t,y);

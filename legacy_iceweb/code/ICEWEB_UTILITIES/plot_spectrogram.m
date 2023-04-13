function plot_spectrogram(A,F,T,station,frame_num,spectrogram_position,Xtickmarks,Xticklabels);

% get parameters from parameter file
global parameterspf;
blue=pfget_num(parameterspf,'blue');
red=pfget_num(parameterspf,'red');
min_freq=pfget_num(parameterspf,'min_freq');
max_freq=pfget_num(parameterspf,'max_freq');

% make axes box
axes('position',spectrogram_position);

% convert spectral amplitudes to dB (for plotting)
% 40=blue (100 counts), red=100 (100000 counts), colormap jet
a=20*log10(abs(A));

% plot
imagesc(T,F,a,[blue red]); axis xy; colormap(jet); 
% clip frequency range (otherwise 0.1-51.3 Hz)
set(gca,'YLim',[min_freq max_freq]);

% add station name as y-axis title
ystr=sprintf('%s',station);
ylabel(ystr,'Color',[0 0 0]); 

% add labels & tick marks if this is bottom trace (trace 1)
% if Xtickmarks is empty, 24 hour plot has been requested
% rather than 15 minute plot
if frame_num ~= 1
	if isempty(Xtickmarks)
		DateTickLabel('x');
		set (gca,'XtickLabel',['']);
	else
		set (gca,'Xtick',Xtickmarks,'XtickLabel',['']);
	end
else
	if isempty(Xtickmarks)
		DateTickLabel('x');
		xlabel('UT');
	else
		set (gca,'Xtick',Xtickmarks,'XtickLabel',Xticklabels);
	end
end
 





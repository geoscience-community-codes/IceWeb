function add_colorbar();
global parameterspf;

% get dB values for dark blue & bright red
blue=pfget_num(parameterspf,'blue');
red=pfget_num(parameterspf,'red');

% set axes position for colorbar
axes('position',[0.15 0.05 0.7 0.008]);

% draw colorbar
ch = imagesc(blue:1:red,1:2,blue:1:red,[blue red]);

% add labels
set(gca,'XTickmode','auto','XColor', [0 0 0],'Ytick',[],'FontSize',[8]); 
xlabel('~cts/Hz in dB','FontSize', [8],'Color',[0 0 0]); 
%orient tall

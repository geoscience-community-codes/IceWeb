function update_counts_plots();
% Glenn Thompson, September 1998

% globals
global COUNTS TEMP HELIWEB;
COUNTS=['/home/glenn/ICEWEB/COUNTS'];
TEMP=['/tmp'];
HELIWEB=['/usr/local/Mosaic/AVO/internal/heli'];

% add current directory to paths
path(path,COUNTS);

% loop for all volcanoes in 'volcanoes.ext'
fid=fopen('COUNTS/volcanoes.ext','r');
volcano=fgetl(fid);
while(length(volcano)>4),
	webcounts(volcano);
	volcano=fgetl(fid);
end
quit;


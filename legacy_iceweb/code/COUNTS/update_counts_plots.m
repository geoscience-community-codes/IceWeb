function update_counts_plots();
% Glenn Thompson, September 1998
%
%
%  Modified by Celso Reyes, October 2005

% globals
global COUNTS TEMP HELIWEB;
COUNTS=['/home/glenn/ICEWEB/COUNTS'];
TEMP=['/tmp'];
HELIWEB=['/usr/local/Mosaic/AVO/internal/heli'];

% add current directory to paths
path(path,COUNTS);

% % % loop for all volcanoes in 'volcanoes.ext'
% % fid=fopen('COUNTS/volcanoes.ext','r');
% % volcano=fgetl(fid);
% % while(length(volcano)>4),
% % 	webcounts(volcano);
% % 	volcano=fgetl(fid);
% % end
% % quit;


%grab all volcano names & pass to webcounts
volcano = textread([COUNTS,'/volcanoes.ext'],'%s'); %puts all names into cell
for n = 1:numel(volcano);
    %disp(volcano{n})
    webcounts(volcano{n});
end
%quit

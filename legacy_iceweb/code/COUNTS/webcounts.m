function webcounts(volcano)
% Glenn Thompson, September 1998
% Modified: Celso Reyes, July 2003
% Re-modified : Celso Reyes, October 2005
%
% This function produces 4 graphs on 1 page for the volcano specified
% This is written to a gif file for display on the internal web page
% From the top, the graphs are:
%   helicorder counts
%   pseudo-helicorder counts
%   detected VT events (a-types)
%   detected LP events (b-types)
%  Each graph displays about 6 months worth of data, and is overlain
%  with the cumulative count for that time period.

% global
global COUNTS TEMP HELIWEB;
COUNTS='/home/glenn/ICEWEB/COUNTS';
TEMP='/tmp';
HELIWEB='/usr/local/Mosaic/AVO/internal/heli';

% set up main variables
volcano=deblank(volcano);
ndays=180; % was 3 months, changed to 6  CR

maxcounts=20;
mincounts=0;

%set up dates
datelist = [fix(now) - ndays : now]; 
blankvalues = zeros(size(datelist));



% close all figures
close all;

% titles
CapVolcano = [upper(volcano(1)) , volcano(2:end)];
tstr{1}=['Helicorder counts for ',CapVolcano];
tstr{2}=['Pseudo-helicorder counts for ',CapVolcano];
tstr{3}=['Detected a-type events for ',CapVolcano];
tstr{4}=['Detected b-type events for ',CapVolcano];

% filenames
fname{1}=['/home/guy/avo/counts/helicorder/',volcano,'.dat'];
fname{2}=[COUNTS,'/',volcano,'.ext'];
fname{3}=['/home/guy/avo/counts/detected/',volcano,'a.dat'];
fname{4}=['/home/guy/avo/counts/detected/',volcano,'b.dat'];

% Y-axis labels
ystr{1}='Counts per day';
ystr{2}=['Norm ',ystr{1}];
ystr{3}=ystr{1};
ystr{4}=ystr{1};

% loop for detected events and helicorder counts

%disp(volcano); %TESTING

for subfig=1:4
    %disp(fname{subfig}) %TESTING

    %if the file doesn't exist, show it as NO DATA and move on
    if ~exist(fname{subfig},'file')
        % disp(['couldn''t open ' fname{subfig}]);
        show_no_data(subfig);
        title(tstr{subfig});
        continue;
    end

    switch subfig
        case 1, [dnum,counts]=getdata(fname{subfig},ndays);
        case {3,4}, [dnum,counts]=get_detected_data(fname{subfig},ndays);
        case 2, [dnum,counts]=get_pseudoheli_data(fname{subfig},ndays);
	otherwise
	  warning('Unknown figure');
    end

    %squeeze data into the appropriate form
    data = blankvalues;
    [tf, loc] = ismember(dnum,datelist);
    data(loc(loc>0)) = counts(loc>0);
    dnum = datelist;
    counts = data;
    clear data tf loc
    
    % Following added for graph scaling - CR
    if max(counts) > maxcounts
        maxcounts = max(counts) + 5;
    end;

    subplot(4,1,subfig)
    if numel(dnum) == 0
       show_no_data(subfig)
       continue
    end
    bar(dnum,counts,1);
    enum = floor(now);
    shading flat
    axis([enum-ndays enum mincounts maxcounts]);
    DateTickLabel('x');
    title(tstr{subfig});
    ylabel(ystr{subfig}, 'color', [0 0 0.6]);

    h1 = gca;
    if subfig < 4,
        set(gca,'xticklabel',[]);
    end

    %overlay the cumulative plots...
    counts(counts < 0) = 0;
    ccum = cumsum(counts);

    h2 = axes('Position',get(h1,'Position'));
    plot(dnum,(ccum - ccum(1)),'r','LineWidth',1);
    set(h2,'YAxisLocation','right','Color','none','XTickLabel',[],'xtick',[])
    set(h2,'XLim',get(h1,'XLim'),'Layer','top')

    %adjust the cumulative counts' ranges
    v = axis(gca);
    v(3) = 0; % set min y-value to zero
    if v(4) < 20
        v(4) = 20; %set y-scale maximum to 20 if it is less
    end
    axis(v);

    ylabel('Cumulative', 'color', [0.6 0 0]);
    % set(gcf,'PaperPositionMode','auto')


end

add_last_update_time;
convert_to_gif(volcano);
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function add_last_update_time()
        rect = [0.15 0.01 0.7 0.05 ];
        axes('position',rect);
        set(gca,'Xtick',[],'Ytick',[],'visible','off');
        text(0.35,0.5,['Data ends at ',datestr(now,1)]);
        return


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function convert_to_gif(volcano)
            global TEMP HELIWEB;
            psfile=[TEMP,'/',volcano,'.ps'];
            % resize on screen
            %set(gcf,'Position',[40 100 700 700]);
            eval(['print -dpsc ',psfile]);
            giffile=[HELIWEB,'/',volcano,'.gif'];

            % the program used to create the gif is called Image Alchemy.
            % Here are the options described
            % -Zm2          color mode 2
            % -Zc1          clip white space from edge of image
            % -Zo 1000p     output page size  at one point, it was 600p instead...
            % -Z+
            % giffile       preserve output ratio
            % -go           gif (not sure what the 'o' is about)
            % -Q            Quiet - no status message
            eval(['!/usr/local/bin/alchemy ',psfile,' -Zm2 -Zc1 -Zo 1000p -Z+ ',giffile,' -go -Q']); % my try
            %eval(['!rm ',psfile]);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function show_no_data(subfig)
            subplot(4,1,subfig), plot(10);
            axis([0 1 0 20]);
            text(0.1,10.0,'no data');
            set(gca,'xticklabel',[],'yticklabel',[],'xtick',[],'ytick',[]);

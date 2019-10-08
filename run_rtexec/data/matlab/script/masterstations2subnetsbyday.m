function sites = get_closest_sites(lon, lat, distkm, sitesdb, maxsta, snum, enum)
%GET_CLOSEST_SITES 
% sites = get_closest_sites(lon, lat, distkm, sitesdb, maxsta, snum, enum)
% load sites within distkm km of a given (LON, LAT) 
% from site database sitesdb
%
% The sites structure returned has the followed fields:
%	channeltag - net.sta.loc.chan a channeltag object
%	longitude	- sites longitude
%	latitude	- sites latitude
%	elev	- sites elevation
%	distance	- distance (in km) from input (LON, LAT)
%
% Example: Get sites within 100km of (-150.0, 60.5) that were
% operational in 1990:
% sites = get_closest_sites(-150.0, 60.5, 100.0, '/avort/oprun/dbmaster/master_stations', 10, datenum(1990,1,1), datenum(1991,1,1));

% AUTHOR: Glenn Thompson, UAF-GI
% $Date: $
% $Revision: -1 $
if ~exist('maxsta', 'var')
	maxsta = 999;
end
if ~exist(sprintf('%s.site',sitesdb))
    sitesdb = input('Please enter sites database path', 's')
end
disp(sprintf('sites db is %s',sitesdb))
db = dbopen(sitesdb, 'r');

% Filter the site table
db = dblookup_table(db, 'site');
nrecs = dbquery(db, 'dbRECORD_COUNT');
disp(sprintf('Site table has %d records', nrecs));
db = dbsubset(db, sprintf('distance(lon, lat, %.4f, %.4f)<%.4f',lon,lat,km2deg(distkm)));
nrecs = dbquery(db, 'dbRECORD_COUNT');
disp(sprintf('After distance subset to lat %f and lon %f: %d records', lat, lon, nrecs));

if ~exist('snum', 'var')
    % No start time given, so assume we just want sites that exist today.
    % Remove any sites that have been decommissioned
    db = dbsubset(db, sprintf('offdate == NULL'));
else
    % Remove any sites that were decommissioned before the start time
    disp(sprintf('offdate == NULL || offdate > %s',datenum2julday(snum)));
    db = dbsubset(db, sprintf('offdate == NULL || offdate > %s',datenum2julday(snum)));
end
% Remove any sites that were installed after the end time (this may remove
% some sites that exist today)
if exist('enum', 'var')
    disp(sprintf('ondate  < %s',datenum2julday(enum)));
    db = dbsubset(db, sprintf('ondate  < %s',datenum2julday(enum)));
end
nrecs = dbquery(db, 'dbRECORD_COUNT');
disp(sprintf('After time subset: %d records', nrecs));

% Filter the sitechan table
db2 = dblookup_table(db, 'sitechan');
nrecs = dbquery(db2, 'dbRECORD_COUNT');
disp(sprintf('sitechan has %d records', nrecs));

db2 = dbsubset(db2, 'chan=~/[BES]H[ENZ]/  || chan=~/BD[FL]/');
nrecs = dbquery(db2, 'dbRECORD_COUNT');
disp(sprintf('After chan subset: %d records', nrecs));

if ~exist('snum', 'var')
    % No start time given, so assume we just want sites that exist today.
    % Remove any sites that have been decommissioned
    db2 = dbsubset(db2, sprintf('offdate == NULL'));
else
    % Remove any sites that were decommissioned before the start time
    disp(sprintf('offdate == NULL || offdate > %s',datenum2julday(snum)));
    db2 = dbsubset(db2, sprintf('offdate == NULL || offdate > %s',datenum2julday(snum)));
end
% Remove any sites that were installed after the end time (this may remove
% some sites that exist today)
if exist('enum', 'var')
    disp(sprintf('ondate  < %s',datenum2julday(enum)));
    db2 = dbsubset(db2, sprintf('ondate  < %s',datenum2julday(enum)));
end
nrecs = dbquery(db2, 'dbRECORD_COUNT');
disp(sprintf('After time subset: %d records', nrecs));

% Join site and sitechan
db2 = dbjoin(db, db2);
nrecs = dbquery(db2, 'dbRECORD_COUNT');
disp(sprintf('After join site-sitechan %d records', nrecs));

% Join to snetsta
db3 = dblookup_table(db, 'snetsta');
nrecs = dbquery(db3, 'dbRECORD_COUNT');
disp(sprintf('snetsta has %d records', nrecs));
db3 = dbjoin(db2, db3);
nrecs = dbquery(db3, 'dbRECORD_COUNT');
disp(sprintf('After join site-sitechan-snetsta: %d records', nrecs));

% Read net vector 
if nrecs == 0
    sites = [];
    return
end
net = dbgetv(db3, 'snet');
if ~iscell(net)
    net = {net};
end

latitude = dbgetv(db3, 'lat');
longitude = dbgetv(db3, 'lon');
elev = dbgetv(db3, 'elev');
staname = dbgetv(db3, 'sta');
if ~iscell(staname)
	staname = {staname};
end
channame = dbgetv(db3, 'chan');
if ~iscell(channame)
	channame = {channame};
end
ondatestr = dbgetv(db3, 'sitechan.ondate');
offdatestr = dbgetv(db3, 'sitechan.offdate');
dbclose(db);

for c=1:numel(ondatestr)
    yyyystr = ondatestr(c,1:4);
    jjjstr = ondatestr(c,5:7);
    ondnum(c) = datenum(str2num(yyystr),1,str2num(jjjstr));
end

for c=1:numel(offdatestr)
    yyyystr = offdatestr(c,1:4);
    jjjstr = offdatestr(c,5:7);
    offdnum(c) = datenum(str2num(yyystr),1,str2num(jjjstr));
end

numsites = length(latitude);
for c=1:length(latitude)
    stadist(c) = deg2km(distance(lat, lon, latitude(c), longitude(c)));
end

% order the sites by distance
[y,i]=sort(stadist);
c=1;
while ((c<=numsites) && (stadist(i(c)) < distkm))
	%sites(c).name = staname{i(c)};
	%sites(c).channel = channame{i(c)};
	%sites(c).scnl = scnlobject(sites(c).name, sites(c).channel, net{i(c)});
    sites(c).channeltag = channeltag(net{i(c)}, staname{i(c)}, '', channame{i(c)});
	sites(c).longitude = longitude(i(c));
	sites(c).latitude = latitude(i(c));
	sites(c).elev = elev(i(c));
	sites(c).distance = stadist(i(c));
    sites(c).ondnum = ondnum(i(c));
    sites(c).offdnum = offdnum(i(c));
	c = c + 1;
end

% remove any duplicate sites
%[~,j]=unique({sites.name});
%sites = sites(sort(j));

% limit the number of sites
numsites = min([maxsta numel(sites)]);
sites = sites(1:numsites);



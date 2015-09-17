function createruntimematfiles()
%for snum=datenum(1997,1,31):7:datenum(2007,12,31)
for snum=datenum(2003,1,1):7:datenum(2003,1,10)
    d=datevec(snum);
    matfile = sprintf('pf/MN%4d%02d%02d.mat', d(1), d(2), d(3))
    %dbpath = sprintf('db/db%4d%02d%02d',d(1),d(2),d(3))
    dbpath = sprintf('db/allnets_glenn');
    %try
        setup('snum', snum, 'enum', snum+1, 'RUNTIMEMATFILE', matfile, 'runmode', 'auto', 'dbpath', dbpath)
    %catch
     %   disp(sprintf('crashed making %s',matfile));
    %end
end


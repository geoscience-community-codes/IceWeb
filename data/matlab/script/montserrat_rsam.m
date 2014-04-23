function montserrat_rsam()
for snum=datenum(1996,10,1):datenum(2007,12,31)

    % load waveform
    d=datevec(snum);
    dbpath = sprintf('db/mvodb%4d',d(1));
    if exist(dbpath,'file')
        ds=datasource('antelope',dbpath);
        scnl=scnlobject('*','*','MN','--');
        enum=snum+1;
        try
            disp(datestr(snum));
            w=waveform(ds, scnl, snum, enum);
            if ~isempty(w)
                for c=1:length(w)
                    % create SAM from waveform object, and save to file
                    s=waveform2rsam(w(c));
                    s.save('db/SSSS_CCC_YYYY.DAT');
                end
            end
        catch
            disp('- crashed')
            continue;
        end
    end
end
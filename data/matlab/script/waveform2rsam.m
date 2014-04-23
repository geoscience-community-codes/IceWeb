function self = waveform2rsam(wv, newFs)
% WAVEFORM2RSAM
%  Compute RSAM data from waveform object
%  The default for newFs is 1/60 Hz, i.e. 1 sample per minute
%  samobject = waveform2rsam(waveformobject) will create 1 minute RSAM data
%  samobject = waveform2rsam(waveformobject, 1.0) will create 1 second RSAM data
%
%  Example:
%    ds=datasource('antelope','db/mvodb1997')
%    scnl=scnlobject('MBWH','SHZ','MN','--')
%    w=waveform(ds, scnl, datenum(1997,2,1),datenum(1997,2,1,0,5,0))
%    s=waveform2sam(w, 1.0) % 1-second RSAM
%    figure;subplot(2,1,1),plot(w,'xunit','date');subplot(2,1,2);plot(s);
%    s.toTextFile('rsam_MBWH_SHZ.txt')
%    
%    s2=waveform2rsam(w)
%    s2.save('rsam_MBWH_SHZ')
%    s3 = sam('rsam_MBWH_SHZ_1997.bob', 'snum', snum, 'enum', enum)

    if ~exist('newFs','var')
        newFs = 1/60;
    end
    
    for c=1:length(wv)
        w=wv(c);
        self = sam('snum', get(w,'start'), 'enum', get(w,'end'), 'sta', get(w,'station'), ...
        'chan', get(w,'channel'), 'measure', 'mean', 'units', get(w, 'units') );
        self.dnum = datenum(w);
        % compute the data
        oldFs = get(w, 'freq');
        compression_factor = round(oldFs / newFs);
        w = fillgaps(w, 0);
        w = detrend(w);
        wr = resample(w, 'absmean', compression_factor);
        self.data = get(wr, 'data');
        self.dnum = datenum(wr);
        self.reduced = get(w, 'reduced');
    end
end 
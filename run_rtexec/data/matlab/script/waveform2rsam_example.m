% load waveform
ds=datasource('antelope','db/mvodb1997');
scnl=scnlobject('MBWH','SHZ','MN','--');
enum=datenum(1997,2,2,0,0,0);
snum=enum-1;
w=waveform(ds, scnl, snum, enum);

% create SAM from waveform object, and save to file
s=waveform2rsam(w)
s.save('SSSS_CCC_YYYY.DAT')

% load SAM from BOB file
s2 = sam('file','MBWH_SHZ_1997.DAT', 'snum', snum, 'enum', enum);

% plot - check that s & s2 are the same
figure;
subplot(3,1,1),plot(w,'xunit','date');
subplot(3,1,2);plot(s);
subplot(3,1,3);plot(s2)

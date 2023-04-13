function push_plot();
sflag=checkdate(sd,sm,sy);
eflag=checkdate(ed,em,ey);
if sflag==1
	errordlg('Start date invalid');
	return;
end
if eflag==1
	errordlg('End date invalid');
	return;
end
snum=datenum(sy,sm,sd);
enum=datenum(ey,em,ed);
if snum>=enum
	errordlg('End date must be AFTER start date');
else
	switch plot_type
		case 1, dr_plot_request(snum,enum,volcano);
		case 2, spectrogram_request(snum,enum,volcano);
		case 3, errordlg('Sorry: that option not available');
	end
end


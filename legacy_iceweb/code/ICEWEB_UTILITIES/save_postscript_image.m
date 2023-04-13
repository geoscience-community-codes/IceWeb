function save_postscript_image(volcano,stem);
psfile =['/tmp/',stem,'_',volcano,'.ps'];
disp(['Saving ',psfile]);
feval('print','-dpsc',psfile);

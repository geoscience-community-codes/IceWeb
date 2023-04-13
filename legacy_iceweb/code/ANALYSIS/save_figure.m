function save_figure();
disp(' ');
figno=input('Enter number of figure window you want to save      ? ');
if figno>gcf
	disp('figure does not exist');
	return;
end

psfile=input('Enter name of file you wish to save this figure to  ? ','s');
pspath=input('Enter path of directory where you wish to save it   ? ','s');

e=exist(pspath);
switch e
	case 7, disp(['saving to ',pspath,'/',psfile]), eval(['print -dpsc -f',num2str(figno),' ',pspath,'/',psfile]);
	case 0,	disp('directory does not exist');
end

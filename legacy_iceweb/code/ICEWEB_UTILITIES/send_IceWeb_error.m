function send_IceWeb_error(ERROR_MSG);

global parameterspf;
IceWeb_manager=pfget(parameterspf,'IceWeb_manager');
disp(ERROR_MSG);
%eval(['!echo ',ERROR_MSG,' | mailx -s "IceWeb error" ',IceWeb_manager]);

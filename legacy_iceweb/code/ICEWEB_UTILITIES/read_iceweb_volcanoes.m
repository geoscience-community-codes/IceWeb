function volcanoes=read_iceweb_volcanoes();

% create pointer to iceweb parameter file
pf=dbpf('/home/iceweb/PARAMETER_FILES/volcanoes');

% read volcanoes
volcanoes=pfget_tbl(pf,'volcanoes');

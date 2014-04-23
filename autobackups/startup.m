cwd=pwd;
startup_universal % need to modify this to use absolute paths
cd(cwd);
%warning off;
%matlab_antelope=getenv('MATLAB_ANTELOPE');
%addpath(genpath(matlab_antelope));
addpath(genpath('GISMO'));
addpath(genpath('matlab'));
%javaaddpath('lib/swarm.jar');
%javaaddpath('lib/usgs.jar');
%javaaddpath('lib/swarm-bin.jar');



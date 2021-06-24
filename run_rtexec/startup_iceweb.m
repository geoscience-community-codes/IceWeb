cwd=pwd;
% Add Antelope Toolbox for MATLAB if not already
matlab_antelope=getenv('MATLAB_ANTELOPE');
if ~exist('dbopen','file')
    addpath(genpath(matlab_antelope));
end
% Use local GISMO and matlab toolboxes if in directory 'run_iceweb'
[p,b]=fileparts(cwd);
if strcmp(b, 'run_iceweb')
    addpath(fullfile(cwd,'GISMO'));
    startup_GISMO;
    addpath(genpath(fullfile(cwd,'matlab')));
end
%javaaddpath('lib/swarm.jar');
%javaaddpath('lib/usgs.jar');
%javaaddpath('lib/swarm-bin.jar');
% add paths to IceWeb MATLAB codes
addpath(genpath('data/matlab'))



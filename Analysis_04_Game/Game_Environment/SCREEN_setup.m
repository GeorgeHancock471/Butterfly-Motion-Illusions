%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Script
%....................

% NAME:  SCREEN setup

% Function:

% This script will open MATLAB with the correct screen configurations for a
% PC.

% Requirements:
%   o. Psychtoolbox
%   OPTIONAL
%   o. OpenGL (FPS > 60 hz)
%   o. Graphics Card (FPS > 60 hz)
%   o. Gaming Screen (FPS > 60 hz)

%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Usage Information
%....................

% Authors: George RA Hancock

% Contact information: ghancockzoology@gmail.com

% All code presented here was created by George RA Hancock
% Please do not redistribute without permission or citation (following
% publication)

% As a prerequesite you must have both MATLAB and psychtoolbox installed!!

%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Instructions
%....................

% Open this script in MATLAB, go to editor and press run.
% / Alternatively right click script and select run.

%If it is working correctly the display screen should go black and a message 
% for successful initialisaiton should appear.

%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


function a__toc_screen_setup()

dataRow =  f_screen_fetchInfo();

Nmonitor = str2num(dataRow{1});
SideCODE = dataRow{2};


f_screen_switch(SideCODE);

scriptPath = fullfile('f_screen_initialise.m');

% Build the system command string using the script path
systemCommand = sprintf('matlab -r "run(''%s'');" &', scriptPath);

% Execute the system command
system(systemCommand);

quit;

end

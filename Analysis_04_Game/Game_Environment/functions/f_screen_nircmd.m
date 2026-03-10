
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Script
%....................

% NAME:  function for screen, nircmd

% Function:
%   
%   This code uses the nircmd.exe to switch the primary monitor.
%   nircmd must be installed and the directiory specified.
%   https://www.nirsoft.net/utils/nircmd2.html
%   Can be extracted from ZIP in the installation guide.

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



function nircmd_switchscreen(MonitorNumber)

% Define the full path to the nircmd.exe executable
nircmdPath = fullfile('nircmd\nircmd.exe');

% Define the command to set monitor 1 as the primary display
command = [nircmdPath ' setprimarydisplay ' num2str(MonitorNumber)];


% Execute the command
status = system(command);
%system([nircmdPath ' win hide class Shell_TrayWnd']);


% Check if the command executed successfully
if status == 0
    disp(['Primary display set']);
else
    disp('Error setting primary display.');
end





end
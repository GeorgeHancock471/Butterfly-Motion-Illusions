


%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Script
%....................

% NAME:  function for screen, make GUI window

% Function:
% This script sets up a window used by the GUI and returns the window info

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



function [guiWin, guiRect, guiScreen]=f_screen_make_guiWindow()

PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'VisualDebugLevel', 0); 

screenNumber =  f_screen_fetchNumber();

guiScreen=(1-(screenNumber-1))+1;

%guiScreen=screenNumber;

monitors = get(0, 'MonitorPositions');
screenSize2 = monitors(1, :);  % Returns [left, bottom, width, height] of the screen.
screenSize1 = monitors(2, :);  % Returns [left, bottom, width, height] of the screen.

bgColor = [200, 200, 200];
[guiWin, guiRect] = Screen('OpenWindow', guiScreen, bgColor);

end
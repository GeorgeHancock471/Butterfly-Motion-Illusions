
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Script
%....................

% NAME:  function for game, initialise the psychtoolbox (PTB)

% Function:

% This script is used to initialise the psychtoolbox with the correct
% settings, e.g. won't show the psychtoolbox screen.

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








function [game, window, windowRect,offscreenWindow] = f_game_initialisePTB(game,waitScreenColor)
d = load('peckLocation.mat'); %Load PECK path
peckPath = d.peckPath;


f_screen_switch(game.side); %Set screen locations

 % Never forget to add this line!!!!!!!
% Without it everytime Matlab restarts it defaults to a set rng seed.


% Initialize Psychtoolbox
%....................................................................
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'VisualDebugLevel', 0);  % Reduces visual debugging
Screen('Preference', 'Verbosity', 1);         % Reduces command window output



% Set up screen
%TOC monitor should always be the left screen.


% Obtain Screen Number
%...................................................
f_screen_switch(game.side); %Set screen locations

screenNumber = f_screen_fetchNumber();

game.screenNumber = screenNumber;


game.screenNumber2 =2-(screenNumber-1);

% Obtain Touch Info
%...................................................
game.touchE = 0;
if(game.useTouch)
    numTouchDevices = length(GetTouchDeviceIndices([], 1));
    if(numTouchDevices>0)
      game.touchDev = max(GetTouchDeviceIndices([], 1));
      fprintf('Touch device properties:\n');
      info = GetTouchDeviceInfo(game.touchDev);
      disp(GetTouchDeviceIndices);
      game.touchE = 1;
    end
end

%return

% Psychtoolbox Info
%...................................................
% Open an on screen window and use the set waitScreenColor
%[window, windowRect] = PsychImaging('OpenWindow', game.screenNumber, waitScreenColor,game.windowSize);
[window, windowRect] = PsychImaging('OpenWindow', game.screenNumber, waitScreenColor);
[offscreenWindow, ~] = Screen('OpenOffscreenWindow', window, [0 0 0]);
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('BlendFunction', offscreenWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
f_screen_ramp(window,waitScreenColor);


[platformImage, ~, platformAlpha] = imread([fullfile(peckPath,'misc\','platform.png')]);
game.platformTexture = Screen('MakeTexture', window, cat(3, platformImage, platformAlpha));

[ringImage, ~, ringAlpha] = imread([fullfile(peckPath,'misc\','ring.png')]);
game.ringTexture = Screen('MakeTexture', window, cat(3, ringImage, ringAlpha));


% Get the vertical refresh rate of the monitor
game.ifi = Screen('GetFlipInterval', window);

topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);
flipSecs = 1/game.screenFrameRate;
game.waitFrames = round(flipSecs / game.ifi);

% Flip outside of the loop to get a time stamp
game.vbl = Screen('Flip', window);

end


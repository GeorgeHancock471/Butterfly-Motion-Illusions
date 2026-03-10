%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Script
%....................

% NAME:  SCREEN test frameRate

% Function:

% This script will test the framerate of all active monitors.

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

% If it is working correctly each window should one by one 
% display a screen stating the predicted frame rate, 
% then measure the actual frame rate.
% Higher frame rates should make the window ramp from gray to black faster.

%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@




% Clear the workspace and the screen
sca;
close all;
clear;

PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'VisualDebugLevel', 0);  % Reduces visual debugging
Screen('Preference', 'Verbosity', 1);         % Reduces command window output


targetSettings = struct();
dataRow =  f_screen_fetchInfo();
Nmonitor = str2num(dataRow{1});
nScreens = str2num(dataRow{2});
SideTOC= dataRow{3};
screenW = str2num(dataRow{4});
screenH = str2num(dataRow{5});
screenCM = str2num(dataRow{6});
screenFPS = str2num(dataRow{7});



% Get the screen numbers. This gives us a number for each of the screens
% attached to our computer.
screens = Screen('Screens');


sI=1;



if(length(screens)>1)sI=2; end

for(i=sI:length(screens))
screenNumber = screens(i);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, [0,0,0]);
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

hz = Screen('FrameRate', window);

% Get the vertical refresh rate of the monitor
ifi = Screen('GetFlipInterval', window);

% Here we use to a waitframes number greater then 1 to flip at a rate not
% equal to the monitors refreash rate. For this example, once per second,
% to the nearest frame
flipSecs = 1/hz;
waitframes = round(flipSecs / ifi);

% Flip outside of the loop to get a time stamp
vbl = Screen('Flip', window);


Screen('TextSize', window, 60);
Screen('TextFont', window, 'Courier');

lineText =  sprintf('Screen Number: %d', i-1);
textWidth = length(lineText)*60; 

DrawFormattedText(window, lineText, 'center', windowRect(4)*0.4, [1,1,1]);

lineText =  sprintf('FrameRate: %.2f', hz);
textWidth = length(lineText)*60; 

DrawFormattedText(window, lineText , 'center', windowRect(4)*0.6, [1,1,1]);

Screen('Flip', window);

pause(2);

tic
v=0;
c=0;
f=-1;
while(toc<3)
f=f+1;
   % Color the screen a random color
    Screen('FillRect', window, [v,v,v]);

    v=v+0.01;
    if(v>1) v=0; c=c+1; end

    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
end

frameR = f/toc;

Screen('FillRect', window, [0,0,0]);
Screen('TextSize', window, 60);

lineText =  sprintf('Screen Number: %d', i-1);
textWidth = length(lineText)*60; 

DrawFormattedText(window, lineText, 'center', windowRect(4)*0.4, [1,1,1]);

lineText =  sprintf('Actual FrameRate: %.2f', frameR);
textWidth = length(lineText)*60; 

DrawFormattedText(window, lineText , 'center', windowRect(4)*0.6, [1,1,1]);
Screen('Flip', window);

disp('.............');
disp(sprintf('ScreenNumber: %.2f', num2str(screenNumber)));
disp(sprintf('Framerate: %.2f', hz));
disp(sprintf('Actual Framerate: %.2f', frameR));
disp('.............');

pause(2);

Screen('CloseAll');
end

disp("Done, check command line for recap of values")



%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Script
%....................

% NAME:  function for screen, primary Right  minimise

% Function:
%
% EXPERIMENTAL!!!
% Switches the primary monitor to the right  monitor, can be used as a quick
% shortcut and minimises all windows. Designed to potentially help mitigate
% flashing screens.


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


nircmdPath = fullfile('nircmd\nircmd.exe');

% Set the screen settings
ScreenSetting = "Game";  % Can be "Game" or other settings based on your needs
Side = "R";  % "L" or "R" for left or right screen

% Hide the taskbar
system([nircmdPath ' win hide class Shell_TrayWnd']);


% Get the MATLAB desktop instance
jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance();

% Get the main window frame (Java Frame)
jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance();
jFrame = jDesktop.getMainFrame();

% Get screen dimensions using Java Toolkit
toolkit = java.awt.Toolkit.getDefaultToolkit();
screenSize = toolkit.getScreenSize();

% Get screen width and height
screenWidth = screenSize.width;
screenHeight = screenSize.height;

% Set the window size to half the screen size
halfWidth = screenWidth / 2;
halfHeight = screenHeight / 2;

% Set the size of the MATLAB window to half the screen size
jFrame.setSize(halfWidth, halfHeight);

% Minimize MATLAB window using nircmd
system([nircmdPath ' sendkeypress "LWin+m"']);

pause(1);

system([nircmdPath ' win min ititle "MATLAB R"']);  % Minimize the window

% Pause to ensure MATLAB window is minimized
pause(0.2);



% Optionally switch to a desired screen (if needed)
f_screen_switch(Side);  % Switch to the "Game" screen (L or R)


pause(0.2);

% Restore the MATLAB window to the reduced size (half the screen size)
jFrame.setSize(halfWidth, halfHeight);

% Center the window (optional)
xPos = (screenWidth - halfWidth) / 2;
yPos = (screenHeight - halfHeight) / 2;
%jFrame.setLocation(0, 0);

% Pause for 2 seconds
pause(0.2);
% Maximize the MATLAB window (set to MAXIMIZED)
jFrame.setExtendedState(6);  % 6 corresponds to java.awt.Frame.MAXIMIZED_BOTH

% Step 4: Show the taskbar again (after the task is complete)
%system([nircmdPath ' win show class Shell_TrayWnd']);  % Restore the taskbar

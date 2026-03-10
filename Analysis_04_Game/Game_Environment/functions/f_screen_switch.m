

%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Script
%....................

% NAME:  function for screen, switch

% Function:
% An integral script, this is used by PECK to swtch the primary monitor.

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


function f_screen_switch(Side)


ScreenSetting = "Game";

d = load('peckLocation.mat');
peckPath = d.peckPath;

nircmdPath =  char(fullfile(peckPath,'\nircmd\nircmd.exe'));

% Hide the taskbar
system([nircmdPath ' win hide class Shell_TrayWnd']);




% Get screen information using Java's AWT package
screens = java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment().getScreenDevices();



% File name to store the primary monitor number
filename = fullfile(peckPath,"functions",'f_screen_nircmd_primaryMonitor.txt');

% Check if the file exists
if isfile(filename)
    % Load the primary monitor number from the file
    fileID = fopen(filename, 'r');
    primaryMonitorN = fscanf(fileID, '%d');
    fclose(fileID);
else
    % Set the default primary monitor number to 1
    primaryMonitorN = 1;
end


% Loop through each screen and determine its position
for i = 1:length(screens)
    % Get the screen's bounds (position and size)
    bounds = screens(i).getDefaultConfiguration().getBounds();
    
    % Determine the position of the monitor
    if bounds.x == 0
        position = 'P';
    elseif bounds.x < 0
        position = 'L';
    else
        position = 'R';
    end

    disp("Position");


   if(Side=="L") 
        if (position(1) == 'R' & ScreenSetting=="Code")
                primaryMonitorN = (1-(primaryMonitorN-1))+1; 
        end
    
        if (position(1) == 'L' & ScreenSetting=="Game")
                primaryMonitorN = (1-(primaryMonitorN-1))+1; 
        end
   end


  if(Side=="R") 
        if (position(1) == 'L' & ScreenSetting=="Code")
                primaryMonitorN = (1-(primaryMonitorN-1))+1; 
        end
    
        if (position(1) == 'R' & ScreenSetting=="Game")
                primaryMonitorN = (1-(primaryMonitorN-1))+1; 
        end
   end


    % Display monitor information
    fprintf('Monitor %d: Position = %s, Resolution = %dx%d\n', ...
            i, position, bounds.width, bounds.height);
end


%Move mouse to corner
mouse = java.awt.Robot;

%% Switch Screen

% Define the full path to the nircmd.exe executable
nircmdPath =  char(fullfile(peckPath,'\nircmd\nircmd.exe'));

disp(nircmdPath);
disp(primaryMonitorN);

screenSize = get(0, 'ScreenSize');
mouse.mouseMove(screenSize(3), round(screenSize(4)*1));



% Define the command to set monitor 1 as the primary display
system([nircmdPath ' setprimarydisplay ' num2str(primaryMonitorN)]);

%% Adjust Mouse

%Move mouse to corner
mouse = java.awt.Robot;

screenSize = get(0, 'ScreenSize');
mouse.mouseMove(screenSize(3), round(screenSize(4)*1));


fileID = fopen(filename, 'w');
fprintf(fileID, '%d', primaryMonitorN);
fclose(fileID);

% Display the updated primary monitor number
fprintf('Current primary monitor number saved: %d\n', primaryMonitorN);


system([nircmdPath ' win show class Shell_TrayWnd']);
end




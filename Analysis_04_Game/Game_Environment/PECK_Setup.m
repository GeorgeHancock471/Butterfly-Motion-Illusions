%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Script
%....................

% NAME:  PECK Setup


% Function:

% This script allows the user to setup the PECK directories.

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

%If it is working correctly a completion message should appear.

%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


function setupPECK()


% Get the active file in the MATLAB editor
activeFile = matlab.desktop.editor.getActive;

% Check if a file is open and retrieve its path
if ~isempty(activeFile) && ~isempty(activeFile.Filename)
    % Extract the directory of the file
    [filePath, ~, ~] = fileparts(activeFile.Filename);
    disp(['Directory of the open file: ', filePath]);
else
    disp('No file is currently open in the editor.');
end


currentDir = filePath;

disp(["Current PECK location:", pwd]);

peckFunctionPath = fullfile(currentDir, 'functions'); 
disp(["PECK function:", peckFunctionPath]);

peckActionPath = fullfile(currentDir, 'actions'); 
disp(["PECK action:", peckActionPath]);


addpath(peckFunctionPath);
savepath;


peckPath = fullfile(currentDir,"\");


addpath(peckPath);
savepath;

save('peckLocation.mat', 'peckPath');

% Get screen information using Java's AWT package
screens = java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment().getScreenDevices();

% File name to store the primary monitor number
filename = 'primaryMonitorN.txt';

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

% Initialize variables to hold the leftmost and rightmost screen
leftScreen = [];
rightScreen = [];

% Loop through each screen and determine its position
for i = 1:length(screens)
    % Get the screen's bounds (position and size)
    bounds = screens(i).getDefaultConfiguration().getBounds();
    xs(i) = bounds.x;
end

min = 999999;
max = -99999;
for i = 1:length(xs)
    if(xs(i) > max)
        right = i;
        max = xs(i);
    end
    if(xs(i) < min)
        left = i;
        min = xs(i);
    end
end


d = load('peckLocation.mat'); %Load PECK path
peckPath = d.peckPath;

%% Define the full path to the nircmd.exe executable
nircmdPath = fullfile(peckPath, 'nircmd', 'nircmd.exe');  % Full path to nircmd.exe

%% LEFT
    % File name and path for the batch file
    batchFileName = fullfile(peckPath, 'SCREEN_Primary_Left.bat');
    
    % Open the file for writing
    fid = fopen(batchFileName, 'w');
    if fid == -1
        error('Error creating the batch file. Ensure the directory is writable.');
    end
    
    % First line: Disable echoing in the batch file
    line1 = "@echo off";
    


    % Full path for the batch file command
    line2 = sprintf('"%s" sendkeypress "LWin+m"', nircmdPath);
    line3 = sprintf("timeout /t 0.2 /nobreak");
    line4 = sprintf('"%s" setprimarydisplay %d', nircmdPath, left);  % Full command

    % Write the lines to the batch file
    fprintf(fid, '%s\n', line1);  % Write "@echo off"
    fprintf(fid, '%s\n', line2);  % Write the command
    fprintf(fid, '%s\n', line3);  % Write the command  
    fprintf(fid, '%s\n', line4);  % Write the command  
    % Close the file
    fclose(fid);

%% RIGHT
    % File name and path for the batch file
    batchFileName = fullfile(peckPath, 'SCREEN_Primary_Right.bat');
    
    % Open the file for writing
    fid = fopen(batchFileName, 'w');
    if fid == -1
        error('Error creating the batch file. Ensure the directory is writable.');
    end
    
    % First line: Disable echoing in the batch file
    line1 = "@echo off";
    
    % Full path for the batch file command

    line2 = sprintf('"%s" sendkeypress "LWin+m"', nircmdPath);
    line3 = sprintf("timeout /t 0.2 /nobreak");
    line4 = sprintf('"%s" setprimarydisplay %d', nircmdPath, right);  % Full command

    % Write the lines to the batch file
    fprintf(fid, '%s\n', line1);  % Write "@echo off"
    fprintf(fid, '%s\n', line2);  % Write the command
    fprintf(fid, '%s\n', line3);  % Write the command  
    fprintf(fid, '%s\n', line4);  % Write the command  
    
    % Close the file
    fclose(fid);


disp("PECK, PECK Directory has now been added");
disp("PECK, Bat Switch Primary to Left Added");
disp("PECK, Bat Switch Primary to Right Added");
disp(".........");
disp("PECK, Setup Complete");
end
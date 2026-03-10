%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Script
%....................

% NAME:  SCREEN adjust settings


% Function:

% This script allows the user to create screen settings .csv file for there computer.

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

%If it is working correctly a UI should appear for entering your screen
%settings.

%The custom name deterimes where it will be saved in the folder 
% /screen_settings/

%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


function SCREEN_adjust_settings()
    % Check if the settings file exists

    d = load('peckLocation.mat');
    peckPath = d.peckPath;
    settingsFile = fullfile(peckPath,'screen_settings.csv');
    
    % Create a figure for the UI
    f = figure('Position', [500, 500, 300, 300], 'MenuBar', 'none', ...
               'Name', 'Input Monitor Settings', 'NumberTitle', 'off', ...
               'Resize', 'off');

    % Create labels and input fields for each variable

    uicontrol('Style', 'text', 'Position', [20, 270, 100, 20], ...
              'String', 'customName:');
    customNameInput = uicontrol('Style', 'edit', 'Position', [120, 270, 150, 20]);
    
    uicontrol('Style', 'text', 'Position', [20, 240, 100, 20], ...
              'String', 'nMonitors:');
    nMonitorsInput = uicontrol('Style', 'edit', 'Position', [120, 240, 150, 20]);
    
    uicontrol('Style', 'text', 'Position', [20, 210, 100, 20], ...
              'String', 'userMonitor (l/p/r):');
    userMonitorInput = uicontrol('Style', 'edit', 'Position', [120, 210, 150, 20]);

    uicontrol('Style', 'text', 'Position', [20, 180, 100, 20], ...
              'String', 'tocMonitor (l/p/r):');
    tocMonitorInput = uicontrol('Style', 'edit', 'Position', [120, 180, 150, 20]);

    uicontrol('Style', 'text', 'Position', [20, 150, 100, 20], ...
              'String', 'screenW(px):');
    screenWInput = uicontrol('Style', 'edit', 'Position', [120, 150, 150, 20]);

    uicontrol('Style', 'text', 'Position', [20, 120, 100, 20], ...
              'String', 'screenH(px):');
    screenHInput = uicontrol('Style', 'edit', 'Position', [120, 120, 150, 20]);

    uicontrol('Style', 'text', 'Position', [20, 90, 100, 20], ...
              'String', 'screenW(cm):');
    screenWcmInput = uicontrol('Style', 'edit', 'Position', [120, 90, 150, 20]);

    uicontrol('Style', 'text', 'Position', [20, 60, 100, 20], ...
              'String', 'frameRate:');
    frameRateInput = uicontrol('Style', 'edit', 'Position', [120, 60, 150, 20]);

    % Create a button to save the data
    saveButton = uicontrol('Style', 'pushbutton', 'Position', [90, 20, 120, 30], ...
                           'String', 'Save to .csv', ...
                           'Callback', @(src, event) saveData());

    % Load existing data if the file exists
    if exist(settingsFile, 'file') == 2
        % Read the CSV file
        fileContents = fileread(settingsFile);
        
        % Split the string using newline as delimiter
        fileRows = strsplit(fileContents, '\n');

        dataRow = strsplit( fileRows{2}, ',');

        % Ensure there are enough rows
            % Map loaded data to corresponding input fields
             set(customNameInput, 'String', 'custom');  %CustomName
             set(nMonitorsInput, 'String', dataRow{1});  % nMonitors
            set(nMonitorsInput, 'String', dataRow{1});  % nMonitors
            set(userMonitorInput, 'String', dataRow{2});  % userMonitor
            set(tocMonitorInput, 'String', dataRow{3});  % tocMonitor
            set(screenWInput, 'String', dataRow{4});  % screenW(px)
            set(screenHInput, 'String', dataRow{5});  % screenH(px)
            set(screenWcmInput, 'String', dataRow{6});  % screenW(cm)
            set(frameRateInput, 'String', dataRow{7});  % frameRate
    end

    % Function to save data to a .csv file
    function saveData()
        customName=get(customNameInput, 'String');
        nMonitors = get(nMonitorsInput, 'String');
        userMonitor = get(userMonitorInput, 'String');
        tocMonitor = get(tocMonitorInput, 'String');
        screenW = get(screenWInput, 'String');
        screenH = get(screenHInput, 'String');
        screenWcm = get(screenWcmInput, 'String');
        frameRate = get(frameRateInput, 'String');
        
        % Create a table for saving data
        outputTable = table({nMonitors}, {userMonitor}, {tocMonitor}, ...
                            {screenW}, {screenH}, {screenWcm}, {frameRate}, ...
                            'VariableNames', {'nMonitors', 'userMonitor', ...
                            'tocMonitor', 'screenW_px', 'screenH_px', ...
                            'screenW_cm', 'frameRate'});

        % Write the table to a CSV file
        writetable(outputTable, settingsFile, 'WriteRowNames', true);

        mkdir(fullfile(peckPath,'screen_settings',customName));
        settingsFile2 = fullfile(peckPath,'screen_settings',customName,'screen_settings.csv');
        writetable(outputTable, settingsFile2, 'WriteRowNames', true);
        
        % Notify user and close the dialog box
        msgbox('Data saved successfully!', 'Success');
        pause(1); % Optional pause to let the message box be seen
        close(f); % Close the UI window
    end
end

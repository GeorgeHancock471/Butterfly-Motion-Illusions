

%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Script
%....................

% NAME:  function for screen, fetch info

% Function:
% This script is used to grab the screen info stored in the screen_settings
% .csv file

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


function dataRow = f_screen_fetchInfo()


d = load('peckLocation.mat');
peckPath = d.peckPath;

settingsFile = fullfile(peckPath','screen_settings.csv');

    % Load existing data if the file exists
    if exist(settingsFile, 'file') == 2
        % Read the CSV file
        fileContents = fileread(settingsFile);
        % Split the string using newline as delimiter
        fileRows = strsplit(fileContents, '\n');
        dataRow = strsplit( fileRows{2}, ',');

    else
    disp("WARNING WARNING");
    disp("No Screen Settings provided!");
    disp("Please run action: TOC screen ADJUST settings");

    sca;
    return

    end


end
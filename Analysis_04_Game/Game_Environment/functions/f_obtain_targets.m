 
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Script
%....................

% NAME:  function for obtaining things, targets

% Function:
% This script can be used to obtain all of the targets in a given folder.
% It will return a list of target names.

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


function targetFiles = f_obtain_targets(game)

directory = game.targets;

itemList = dir(directory);

targetFiles={};

% Filter out only the CSV files
Files = itemList([itemList.isdir]); 
for(i=1:length(Files))
if Files(i).isdir  && ~strcmp(Files(i).name, '.') && ~strcmp(Files(i).name, '..')
    nm = Files(i).name;
targetFiles = [targetFiles,nm];
end
end

end




%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Script
%....................

% NAME:  function for randomisation, backgrounds

% Function:
% This script can be used to automatically randomise the order for
% backgrounds. 

%Methods:

% "repeatBlocks" = creates repeating blocks, where the same two images
% can't occur in a row and the order is alphabetical by image name.

% "randomBlocks" = creates random repeating blocks, where the same two images
% can't occur in a row

% "random" = randomly chooses backgrounds, where the same two images
% can't occur in a row


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

 


function backgroundImages = f_randomise_backgrounds(game,method)

itemList = dir(game.backgrounds);

% Filter out only the CSV files

if(game.animatedBackgrounds)
imgFiles = itemList([itemList.isdir]); % Select non-directory items
else
imgFiles = itemList(~[itemList.isdir]); % Select non-directory items
imgFiles = imgFiles(endsWith({imgFiles.name}, '.png') | endsWith({imgFiles.name}, '.PNG')| endsWith({imgFiles.name}, '.jpg') | endsWith({imgFiles.name}, '.JPG') | endsWith({imgFiles.name}, '.jpeg') | endsWith({imgFiles.name}, '.JPEG')); % Filter out GameInfo CSV files
end

% Extract just the file names from the imgFiles structure
fileNames = {imgFiles.name};  % This creates a cell array of file names
fileNames = fileNames(~ismember(fileNames, {'.', '..'})); % Exclude '.' and '..'

disp(fileNames);

% Display the list of file names (optional)game.nTreatments


backgroundImages = {};

if(method=="repeatBlocks")
while length(backgroundImages)<game.nRepeats*game.nTreatments*2
backgroundImages = [backgroundImages,fileNames];
end
end


if(method=="randomBlocks")
while length(backgroundImages)<game.nRepeats*game.nTreatments*2
shuffledNames = fileNames(:, randperm(size(fileNames, 2)));


    g=0;
    if(g==0 & length(backgroundImages)>2)
        nm1=shuffledNames{1};
        nm2=backgroundImages{length(backgroundImages)};
        disp(nm1);
        disp(nm2);
        disp(size(nm1));
        disp(size(nm2));

        if(nm1(1)==nm2(1))
         shuffledNames =  fileNames(randperm(size(fileNames, 1)), :);
        else
         g=1;
        end

    end
backgroundImages = [backgroundImages,shuffledNames];
end
end


if(method=="random")
while length(backgroundImages)<game.nRepeats*game.nTreatments*2
shuffledNames = fileNames(:, randperm(size(fileNames, 2)));
shuffledName = shuffledNames{1};
    g=0;
    if(g==0 & length(backgroundImages)>1)
        nm1=shuffledName
        nm2=backgroundImages{length(backgroundImages)};
        disp(nm1);
        disp(nm2);
        if(nm1(1)==nm2(1))
        shuffledNames =  fileNames(randperm(size(fileNames, 1)), :);
        shuffledName = shuffledNames{1};
        else
         g=1;
        end

    end
backgroundImages = [backgroundImages,shuffledName];
end
end


end


%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Script
%....................

% NAME:  function for images, used to cycle images

% Function:
% This script is used to cycle through target images

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



function target = f_images_cycles(game,target,window)

     for(m = 1:game.nTargets) % Loop for each Target


            folderPaths = fullfile(game.targets, char(target.TargetD(m)));

            % Get the directory content
            items = dir(folderPaths);
            
            % Filter only directories
            folders = items([items.isdir]); % Logical indexing to get only directories
            
            % Remove '.' and '..' from the list
            folderNames = {folders.name}; % Get names of the directories
            folderNames = folderNames(~ismember(folderNames, {'.', '..'})); % Exclude '.' and '..'

            for( z = 1:length(folderNames))

            imagePath = fullfile(game.targets, char(target.TargetD(m)),folderNames(z))

            disp(imagePath);



            imageFiles = dir(fullfile(imagePath, '*.png'));  % Get list of all PNG files

            disp(imageFiles(1));

             for k = 1:length(imageFiles)
                 currentPath = fullfile(imageFiles(1).folder,"\",imageFiles(k).name);
                    % Load the current image and its alpha channel
                    [currentImage, ~, currentAlpha] = imread(currentPath);
                    
                    texture = Screen('MakeTexture', window, cat(3, currentImage, currentAlpha));
                    target.Animation(m,z,k) = texture; 
                    
             end

             target.animationLength(m,z) = length(imageFiles);

            end

            temp= size(currentImage)*target.targetScale(m);
            target.bodySize(m) = temp(2);
            target.animationSize(m) = temp(2);
            
            
        if(game.useHitbox)
        imagePath = fullfile(game.folderPath,'Targets', char(target.TargetD(m)), 'Hitbox.png');
        [TargetHitboxImage, ~, TargetHitboxImageAlpha] = imread(imagePath);
        target.hitboxTexture(m) = Screen('MakeTexture', window, cat(3, TargetHitboxImage, TargetHitboxImageAlpha));
        temp = size(TargetHitboxImage)*target.targetScale(m);
        target.hitboxSize(m) = temp(2);
        end

        end

end
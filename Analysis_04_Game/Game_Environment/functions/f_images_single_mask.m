

%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Script
%....................

% NAME:  function for images, single

% Function:
% This script is used to load the mask if the target is a single image.

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

function target = f_images_single_mask(game,target,window)

    for(m = 1:game.nTargets) % Loop for each Target
   
    imagePath = fullfile(game.folderPath,'Targets', char(target.TargetD(m)), 'Target.png');
    disp(imagePath);
    [TargetBodyImage, ~, TargetBodyAlpha] = imread(imagePath);
    target.BodyTexture(m) = Screen('MakeTexture', window, cat(3, TargetBodyAlpha, TargetBodyAlpha));
    temp= size(TargetBodyImage)*target.targetScale(m);
    target.bodySize(m) = temp(2);
  

    if(game.useHitbox)
    imagePath = fullfile(game.folderPath,'Targets', char(target.TargetD(m)), 'Hitbox.png');
    [TargetHitboxImage, ~, TargetHitboxImageAlpha] = imread(imagePath);
    target.hitboxTexture(m) = Screen('MakeTexture', window, cat(3, TargetHitboxImage, TargetHitboxImageAlpha));
    temp = size(TargetHitboxImage)*target.targetScale(m);
    target.hitboxSize(m) = temp(2);
    end

    end

end
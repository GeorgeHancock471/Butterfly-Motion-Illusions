

%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Script
%....................

% NAME:  function for images, moth 2D

% Function:
% This script is used to load the masks for 2D moths/butterflies/insects
% Body, tail, forewings and hindwings.

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

            
function target = f_images_flight2D(game,target,window)

    for(m = 1:game.nTargets) % Loop for each Target
   
    imagePath = fullfile(game.folderPath,'Targets', char(target.TargetD(m)), 'Body.png');
    disp(imagePath);
    [TargetBodyImage, ~, TargetBodyAlpha] = imread(imagePath);
    target.BodyTexture(m) = Screen('MakeTexture', window, cat(3, TargetBodyAlpha, TargetBodyAlpha));
    temp= size(TargetBodyImage)*target.targetScale(m);
    target.bodySize(m) = temp(2);
  

     imagePath = fullfile(game.folderPath,'Targets', char(target.TargetD(m)), 'Tail.png');
    [TargetTailImage, ~, TargetTailAlpha] = imread(imagePath);
    target.TailTexture(m) = Screen('MakeTexture', window, cat(3, TargetTailAlpha, TargetTailAlpha));
    temp = size(TargetTailImage)*target.targetScale(m);
    target.tailSize(m) = temp(2);

     imagePath = fullfile(game.folderPath,'Targets', char(target.TargetD(m)), 'ForeWing.png');
    [TargetForeWingImage, ~, TargetForeWingAlpha] = imread(imagePath);
    target.ForeWingTextureR(m) = Screen('MakeTexture', window, cat(3, TargetForeWingImage, TargetForeWingAlpha)); % Right
    target.ForeWingTextureL(m) = Screen('MakeTexture', window, cat(3, flipdim(TargetForeWingAlpha, 2),  flipdim(TargetForeWingAlpha, 2))); % Left, Flipped
    temp = size(TargetForeWingImage)*target.targetScale(m);
    target.foreWingSize(m) = temp(2);

    imagePath = fullfile(game.folderPath,'Targets', char(target.TargetD(m)), 'HindWing.png');
    [TargetHindWingImage, ~, TargetHindWingAlpha] = imread(imagePath);
    target.HindWingTextureR(m) = Screen('MakeTexture', window, cat(3, TargetHindWingImage, TargetHindWingAlpha));
    target.HindWingTextureL(m) = Screen('MakeTexture', window, cat(3, flipdim(TargetHindWingAlpha, 2),  flipdim(TargetHindWingAlpha, 2))); % Left, Flipped
    temp = size(TargetHindWingImage)*target.targetScale(m);
    target.hindWingSize(m) = temp(2);

    if(game.useHitbox)
    imagePath = fullfile(game.folderPath,'Targets', char(target.TargetD(m)), 'Hitbox.png');
    [TargetHitboxImage, ~, TargetHitboxImageAlpha] = imread(imagePath);
    target.hitboxTexture(m) = Screen('MakeTexture', window, cat(3, TargetHitboxAlpha, TargetHitboxImageAlpha));
    temp = size(TargetHitboxImage)*target.targetScale(m);
    target.hitboxSize(m) = temp(2);
    end

    target.Flight_HitTime(m) = 0;
    target.Static_HitTime(m)  = 0;

    end

end
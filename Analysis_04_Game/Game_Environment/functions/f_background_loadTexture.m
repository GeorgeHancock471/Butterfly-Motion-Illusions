%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Script
%....................

% NAME:  function for backgrounds, load texture

% Function:

% This script renders a black background

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


function game = f_background_loadTexture(game,window)

    if(game.animatedBackgrounds)
    game.backgroundTextures={};
    game.backgroundTextures = f_background_cycles(game,window);
    if( game.overlayBackgrounds)
    game.overlayTextures={};
    game.overlayTextures = f_overlay_cycles(game,window);
    end
    else
    game.backgroundTextures={};
    game.overlayTextures={};
    backgroundImage = imread(game.background); % Will need to be replaced with an array
    game.backgroundTextures{1} = Screen('MakeTexture', window, backgroundImage);
    if( game.overlayBackgrounds)
    [currentImage, ~, currentAlpha]= imread(game.bgOverlay); % Will need to be replaced with an array
    game.overlayTextures{1}= Screen('MakeTexture', window,  cat(3, currentImage, currentAlpha));
    end
    end

end
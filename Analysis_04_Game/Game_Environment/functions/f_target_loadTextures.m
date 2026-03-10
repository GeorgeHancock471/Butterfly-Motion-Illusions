

%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Script
%....................

% NAME:  function for targets, load Textures

% Function:
% This function will load the image textures for the different methods of rendering
% stimuli 2DMoths, Cycles and single Images.


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


function target = f_target_loadTextures(game,target,window)

    if(game.animationMethod=="Cycles")
    target = f_images_cycles(game,target,window);
    end
    
    if(game.animationMethod=="moth2D")
    target = f_images_moth2D(game,target,window);
    end
    
    if(game.animationMethod=="Image")
    target = f_images_single(game,target,window);
    end


end
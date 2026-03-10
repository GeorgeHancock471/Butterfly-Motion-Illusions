
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Script
%....................

% NAME:  function for game, draw game

% Function:

% This script is used to draw the images for the game.
% First it draws the background
% Then it draws the target
% Then it draws the overlay

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


function f_game_drawGame(game, target, window,windowRect, nFrames, f, motionPaths)

    L = length(game.backgroundTextures);
    v = (f / L) * pi * 2; % Angle in radians for this frame
    cx = cos(v);
    cy = sin(v);
    a = atan2(cy, cx); 
    normalized_angle = (a + pi) / (2 * pi); % Map [-pi, pi] to [0, 1]
  
    f2 = ceil(normalized_angle * L);  
      if(f2<1) f2=length(game.backgroundTextures); end
    backgroundTexture = game.backgroundTextures{f2};
    Screen('DrawTexture', window, backgroundTexture, [], windowRect);

    %ANIMATE TARGET
    %...................................................................................

    f_draw_targets(game, target, window, nFrames, f, motionPaths);

    %DRAW OVERLAY
    %...................................................................................

    if(game.overlayBackgrounds & length(game.overlayTextures)>0)
    L = length(game.overlayTextures);
    v = (f / L) * pi * 2; % Angle in radians for this frame
    cx = cos(v);
    cy = sin(v);
    a = atan2(cy, cx); 
    normalized_angle = (a + pi) / (2 * pi); % Map [-pi, pi] to [0, 1]
    f2 = ceil(normalized_angle * L);  
      if(f2<1) f2=length(game.overlayTextures); end
    overlayTexture = game.overlayTextures{f2};
    Screen('DrawTexture', window, overlayTexture, [], windowRect);
    end

end

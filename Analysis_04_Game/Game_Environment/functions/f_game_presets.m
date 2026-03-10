
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Script
%....................

% NAME:  function for game, presets
% Function:

% This script is used to load preset settings for the PECK game.
% you can edit this script to add new presets by adding in new cases.
%..............................
% E.g. case 'Custom'
% Followed by all the game settings.
%..............................

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


function game = f_game_presets(gameType,gamePath,playerID)


    % Obtain Screen Info from .csv file
    targetSettings = struct();
    dataRow =  f_screen_fetchInfo();
    Nmonitor = str2num(dataRow{1});
    SideUser = dataRow{2};
    SideTOC = dataRow{3};
    screenW = str2num(dataRow{4});
    screenH = str2num(dataRow{5});
    screenCM = str2num(dataRow{6});
    screenFPS = str2num(dataRow{7});


    %Paths
    game.folderPath =  gamePath;                                                %The main path to where the game files will be stored.
    game.playerID = playerID;                                                   %The ID of the player e.g. G01, P001 etc.
    game.savePath =  fullfile(game.folderPath,"\","Players",playerID,"\");      %The path for where the data will be saved.
    game.ui = fullfile(game.folderPath,"\","UI");                               %The path for the UI images, these are labelled with a numeric.
    game.targets = fullfile(game.folderPath,"\","Targets");             %The path for the background images.
    game.backgrounds = fullfile(game.folderPath,"\","Backgrounds");             %The path for the background images.
    game.bgOverlays = fullfile(game.folderPath,"\","Backgrounds_Overlay");       %The path for the background image overlay's
    


    game.useMiss=0;
  
    switch gameType


    case 'Blank'
        %Default setting for a cycle based game where a mouse is used
        %rather than a touch screen.
  

        %Backgrounds
        game.animatedBackgrounds=0;                                                 %Should animated backgrounds be used?
        game.overlayBackgrounds=0;                                                  %Is an overlay background used? (useful for occlusion or to hide unde objects).
        game.background =  fullfile(game.backgrounds,"\1.png");                     %The image or folder which will be used for the background, should be replaced.

        %Screen
        game.windowSize = [0 0 screenW screenH];                                    %The dimensions of the psychtoolbox figures, figures smaller then the screen are in windowed mode.
        game.screenFrameRate=screenFPS;                                             %The FPS of the game.
        game.pixelWidth = screenW;%px                                               %The pixel width of the screen.
        game.cmWidth = screenCM;%cm                                                 %The size of the screen in cm.
        game.pxPcm = game.pixelWidth/game.cmWidth;                                  %The ratio of pixels to cm, used for speed calculations.
        game.side = SideTOC;                                                        %Which side the game is played on left or right (2-monitors only)
        game.side2 = SideUser;                                                        %Which side the game is played on left or right (2-monitors only)
        
        %Duration and hits
        game.timeLimit = 10;%s                                                      %The max duration the game will last in seconds.
        game.allowHit = 1;                                                          %1/0 Can the target be clicked on to end the trial?
        game.killableTargets = 0;                                                   %1/0 Determines whether death is used (required for multi kill).
        game.deathDuration = 1;                                                     %1/0 Number of seconds with death animation.
        game.deathJitter = 0;                                                       %Does the target shake when dead. Numbers beteen 0-4 for sensible amplitdes. 0 is no jitter.
        game.multiKill=0;                                                           %Determines whether the player is allowed to click multiple target, (requires killable).
        
        %Animation
        game.animationMethod="Image";                                              %Image, Moth2D or Cycles
        game.recordMode=0;                                                          %1/0 Do you want to record each frame? (massively slows down, shouldn't be used to play)
        game.wingTestMode=0;                                                        %REDUNDANT
        
        %Mouse and Touch
        game.useTouch = 0;                                                          %Is the touch screen enabled.
        game.useDrag = 0;                                                           %1/0 Are you allowed to drag the mouse?
        game.useHitbox=0;                                                           %1/0 Use a hitbox.png otherwise it will use a hit radius.
        game.expandHitbox = 20;                                                     %How much larger to make the hitbox in Px (pixels) (uses dilation)
        game.touchD = 0.1;                                                          %How much of a delay must there be between clicks / prevents spam.
        game.expandHitR = 2;                                                        %How much larger to make the hit radius then the targets, e.g. 2 = double , 0.5 = half

        game.showMouse=0;                                                           %Whether the mouse location should be shown with a dot (also applies to touch screen)
        game.mouseSize=20;%px                                                       %How large the mouse should be in pixels.
        game.mouseColor=[1 0 0];                                                    %What colour the mouse should be.

        game.showHitbox=0;                                                          %1/0, For testing only, whether the hitbox should be shown on a hot
        game.showHitDot=0;                                                          %Whether the dot colour should change to indicate hit detection.


        %Revel Hidden Targets
        game.revealDead = 0;                                                        %1/0 Should the target be revealed on death, i.e. when clicked? Draws a white ring around it
        game.revealFail = 0;                                                        %1/0 Should the target be revealed on a time out? Draws a white ring around it and plays a miss sound.
       
        
        %Pathing & Position
        game.showMoveTo=0;                                                          %1/0 Show where the target is going. Only useful for.
        game.platform=0;                                                            %1/0 Whether a gray platform should be put behind the target?
        game.Turning=1;                                                             %1/0, determines whether the target is allowed to turn when it moves.
        game.nTargets=1;                                                            %1/0,  Determines whow many targets are shown on the screen at any one time.
        game.invertPath=1;                                                          %1/0 Is the flight path inverted, i.e. the end x, y and rotation are now the start (this is important for looping paths)
        

        %Sound
        game.useSoundMiss = 0;                                                      %1/0 Determines whether sounds are played on a hit.
        game.useSoundHit = 0;                                                       %0/1 Determines whether sounds are played on a miss.
        game.soundD = fullfile(game.folderPath,"Sound");
        
       
        %UI
        game.useUI = 1;                                                             %1/0 Determines whether to show a UI (human games only), note as the UI is now seperate this is REDUNDANT
        
        %Misc
        game.animationTest=0;                                                       %REDUNDANT
        game.startAlign=0;                                                          %REDUNDANT
        game.rampFrames = 0;                                                        %1/0 Whether 30 frames of the waitScreenColor are played before starting, Dot to Start makes this redundant.



    case 'Mouse'
        %Default setting for a cycle based game where a mouse is used
        %rather than a touch screen.
  
        %Backgrounds
        game.animatedBackgrounds=0;                                                 %Should animated backgrounds be used?
        game.overlayBackgrounds=0;                                                  %Is an overlay background used? (useful for occlusion or to hide unde objects).
        game.background =  fullfile(game.backgrounds,"\1.png");                     %The image or folder which will be used for the background, should be replaced.

        %Screen
        game.windowSize = [0 0 screenW screenH];                                    %The dimensions of the psychtoolbox figures, figures smaller then the screen are in windowed mode.
        game.screenFrameRate=screenFPS;                                             %The FPS of the game.
        game.pixelWidth = screenW;%px                                               %The pixel width of the screen.
        game.cmWidth = screenCM;%cm                                                 %The size of the screen in cm.
        game.pxPcm = game.pixelWidth/game.cmWidth;                                  %The ratio of pixels to cm, used for speed calculations.
        game.side = SideTOC;                                                        %Which side the game is played on left or right (2-monitors only)
        game.side2 = SideUser;                                                        %Which side the game is eplayed on left or right (2-monitors only)     

        %Duration and hits
        game.timeLimit = 10;%s                                                      %The max duration the game will last in seconds.
        game.allowHit = 1;                                                          %1/0 Can the target be clicked on to end the trial?
        game.killableTargets = 1;                                                   %1/0 Determines whether death is used (required for multi kill).
        game.deathDuration = 1;                                                     %1/0 Number of seconds with death animation.
        game.deathJitter = 0;                                                       %Does the target shake when dead. Numbers beteen 0-4 for sensible amplitdes. 0 is no jitter.
        game.multiKill=0;                                                           %Determines whether the player is allowed to click multiple target, (requires killable).
        
        %Animation
        game.animationMethod="Image";                                              %Image, Moth2D or Cycles
        game.recordMode=0;                                                          %1/0 Do you want to record each frame? (massively slows down, shouldn't be used to play)
        game.wingTestMode=0;                                                        %REDUNDANT
        
        %Mouse and Touch
        game.useTouch = 0;                                                          %Is the touch screen enabled.
        game.useDrag = 0;                                                           %1/0 Are you allowed to drag the mouse?
        game.useHitbox=0;                                                           %1/0 Use a hitbox.png otherwise it will use a hit radius.
        game.expandHitbox = 20;                                                     %How much larger to make the hitbox in Px (pixels) (uses dilation)
        game.touchD = 0.1;                                                          %How much of a delay must there be between clicks / prevents spam.
        game.expandHitR = 2;                                                        %How much larger to make the hit radius then the targets, e.g. 2 = double , 0.5 = half

        game.showMouse=1;                                                           %Whether the mouse location should be shown with a dot (also applies to touch screen)
        game.mouseSize=20;%px                                                       %How large the mouse should be in pixels.
        game.mouseColor=[1 0 0];                                                    %What colour the mouse should be.

        game.showHitbox=0;                                                          %1/0, For testing only, whether the hitbox should be shown on a hot
        game.showHitDot=0;                                                          %Whether the dot colour should change to indicate hit detection.


        %Revel Hidden Targets
        game.revealDead = 1;                                                        %1/0 Should the target be revealed on death, i.e. when clicked? Draws a white ring around it
        game.revealFail = 1;                                                        %1/0 Should the target be revealed on a time out? Draws a white ring around it and plays a miss sound.
       
        
        %Pathing & Position
        game.showMoveTo=0;                                                          %1/0 Show where the target is going. Only useful for.
        game.platform=0;                                                            %1/0 Whether a gray platform should be put behind the target?
        game.Turning=1;                                                             %1/0, determines whether the target is allowed to turn when it moves.
        game.nTargets=1;                                                            %1/0,  Determines whow many targets are shown on the screen at any one time.
        game.invertPath=1;                                                          %1/0 Is the flight path inverted, i.e. the end x, y and rotation are now the start (this is important for looping paths)
        

        %Sound
        game.useSoundMiss = 1;                                                      %1/0 Determines whether sounds are played on a hit.
        game.useSoundHit = 1;                                                       %0/1 Determines whether sounds are played on a miss.
        game.soundD = fullfile(game.folderPath,"Sound");
        
       
        %UI
        game.useUI = 1;                                                             %1/0 Determines whether to show a UI (human games only), note as the UI is now seperate this is REDUNDANT
        
        %Misc
        game.animationTest=0;                                                       %REDUNDANT
        game.startAlign=0;                                                          %REDUNDANT
        game.rampFrames = 0;                                                        %1/0 Whether 30 frames of the waitScreenColor are played before starting, Dot to Start makes this redundant.

case 'Touch'
        %Default setting for a cycle based game where a mouse is used
        %rather than a touch screen.
  
        %Backgrounds
        game.animatedBackgrounds=0;                                                 %Should animated backgrounds be used?
        game.overlayBackgrounds=0;                                                  %Is an overlay background used? (useful for occlusion or to hide unde objects).
        game.background =  fullfile(game.backgrounds,"\1.png");                     %The image or folder which will be used for the background, should be replaced.

        %Screen
        game.windowSize = [0 0 screenW screenH];                                    %The dimensions of the psychtoolbox figures, figures smaller then the screen are in windowed mode.
        game.screenFrameRate=screenFPS;                                             %The FPS of the game.
        game.pixelWidth = screenW;%px                                               %The pixel width of the screen.
        game.cmWidth = screenCM;%cm                                                 %The size of the screen in cm.
        game.pxPcm = game.pixelWidth/game.cmWidth;                                  %The ratio of pixels to cm, used for speed calculations.
        game.side = SideTOC;                                                        %Which side the game is played on left or right (2-monitors only)
        game.side2 = SideUser;                                                        %Which side the game is eplayed on left or right (2-monitors only)     

        %Duration and hits
        game.timeLimit = 10;%s                                                      %The max duration the game will last in seconds.
        game.allowHit = 1;                                                          %1/0 Can the target be clicked on to end the trial?
        game.killableTargets = 1;                                                   %1/0 Determines whether death is used (required for multi kill).
        game.deathDuration = 0;                                                     %1/0 Number of seconds with death animation.
        game.deathJitter = 0;                                                       %Does the target shake when dead. Numbers beteen 0-4 for sensible amplitdes. 0 is no jitter.
        game.multiKill=0;                                                           %Determines whether the player is allowed to click multiple target, (requires killable).
        
        %Animation
        game.animationMethod="Image";                                              %Image, Moth2D or Cycles
        game.recordMode=0;                                                          %1/0 Do you want to record each frame? (massively slows down, shouldn't be used to play)
        game.wingTestMode=0;                                                        %REDUNDANT
        
        %Mouse and Touch
        game.useTouch = 1;                                                          %Is the touch screen enabled.
        game.useDrag = 1;                                                           %1/0 Are you allowed to drag the mouse?
        game.useHitbox=0;                                                           %1/0 Use a hitbox.png otherwise it will use a hit radius.
        game.expandHitbox = 20;                                                     %How much larger to make the hitbox in Px (pixels) (uses dilation)
        game.touchD = 0.3;                                                          %How much of a delay must there be between clicks / prevents spam.
        game.expandHitR = 1;                                                        %How much larger to make the hit radius then the targets, e.g. 2 = double , 0.5 = half

        game.showMouse=0;                                                           %Whether the mouse location should be shown with a dot (also applies to touch screen)
        game.mouseSize=20;%px                                                       %How large the mouse should be in pixels.
        game.mouseColor=[1 0 0];                                                    %What colour the mouse should be.

        game.showHitbox=0;                                                          %1/0, For testing only, whether the hitbox should be shown on a hot
        game.showHitDot=0;                                                          %Whether the dot colour should change to indicate hit detection.


        %Revel Hidden Targets
        game.revealDead = 0;                                                        %1/0 Should the target be revealed on death, i.e. when clicked? Draws a white ring around it
        game.revealFail = 0;                                                        %1/0 Should the target be revealed on a time out? Draws a white ring around it and plays a miss sound.
       
        
        %Pathing & Position
        game.showMoveTo=0;                                                          %1/0 Show where the target is going. Only useful for.
        game.platform=0;                                                            %1/0 Whether a gray platform should be put behind the target?
        game.Turning=1;                                                             %1/0, determines whether the target is allowed to turn when it moves.
        game.nTargets=1;                                                            %1/0,  Determines whow many targets are shown on the screen at any one time.
        game.invertPath=1;                                                          %1/0 Is the flight path inverted, i.e. the end x, y and rotation are now the start (this is important for looping paths)
        

        %Sound
        game.useSoundMiss = 1;                                                      %1/0 Determines whether sounds are played on a hit.
        game.useSoundHit = 1;                                                       %0/1 Determines whether sounds are played on a miss.
        game.soundD = fullfile(game.folderPath,"Sound");
        
       
        %UI
        game.useUI = 1;                                                             %1/0 Determines whether to show a UI (human games only), note as the UI is now seperate this is REDUNDANT
        
        %Misc
        game.animationTest=0;                                                       %REDUNDANT
        game.startAlign=0;                                                          %REDUNDANT
        game.rampFrames = 0;                                                        %1/0 Whether 30 frames of the waitScreenColor are played before starting, Dot to Start makes this redundant.


end

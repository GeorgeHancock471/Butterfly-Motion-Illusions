

%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Script
%....................

% NAME:  function for screen setup, blank game
% Function:
% This script is used to create a blank game that displays as black to make
% sure the screen is working and to prevent psychtoolbox initialisation
% from delaying the very first experiment run after MATLAb has been
% started.

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

function f_screen_blankgame()
rng("shuffle");
beep off;

%% 1) Settings Section
%..........................................................................
%..........................................................................

% Game Location & Information
%.........................................

Info.player = "blank"; % Use index 1 instead of 0

d = load('peckLocation.mat');
peckPath = d.peckPath;


gamePath=fullfile(peckPath ,"blank");

game = f_game_presets("Blank",gamePath,"blank");

game.folderPath =  fullfile(peckPath ,"blank");
game.playerID = "blank";
game.savePath =  fullfile(game.folderPath);
game.backgrounds = fullfile(game.folderPath,"\","Backgrounds");
game.ui = fullfile(game.folderPath,"\","UI");
game.showMouse=0;


game.timeLimit = 0.5;


game.nRepeats=1;

Appearances = f_obtain_targets(game);


game.nTreatments=1;


% Generate Random Backgrounds Array

backgroundImages = f_randomise_backgrounds(game,"randomBlocks");


% Fetch Screen Settings
%.........................................
dataRow =  f_screen_fetchInfo();
Nmonitor = str2num(dataRow{1});
nScreens = str2num(dataRow{2});
SideTOC= dataRow{3};
screenW = str2num(dataRow{4});
screenH = str2num(dataRow{5});
screenCM = str2num(dataRow{6});
screenFPS = str2num(dataRow{7});




% Check if the directory exists 
if ~exist(game.savePath, 'dir')
% If the directory doesn't exist, create it
mkdir(game.savePath);
disp(['Folder created at ' game.savePath]);
else
disp(['Folder already exists at ' game.savePath]);
end


% GAME SETTINGS
%.........................................



game.background =  fullfile(game.folderPath,"Backgrounds\1.png"); % NB this will be replaced as this game uses random backgrounds

waitScreenColor = [0,0,0];


%% 2) Psychtoolbox Initialisation
%..........................................................................
%..........................................................................

f_screen_switch(game.side); %Set screen locations

 % Never forget to add this line!!!!!!!
% Without it everytime Matlab restarts it defaults to a set rng seed.


% Initialize Psychtoolbox
%....................................................................
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'VisualDebugLevel', 0);  % Reduces visual debugging
Screen('Preference', 'Verbosity', 1);         % Reduces command window output



% Set up screen
%TOC monitor should always be the left screen.


% Obtain Screen Number
%...................................................
f_screen_switch(game.side); %Set screen locations

screenNumber = f_screen_fetchNumber();

game.screenNumber = 0;


% Obtain Touch Info
%...................................................
game.touchE = 0;
if(game.useTouch)
    numTouchDevices = length(GetTouchDeviceIndices([], 1));
    if(numTouchDevices>0)
      game.touchDev = max(GetTouchDeviceIndices([], 1));
      fprintf('Touch device properties:\n');
      info = GetTouchDeviceInfo(game.touchDev);
      disp(GetTouchDeviceIndices);
      game.touchE = 1;
    end
end

%return

% Psychtoolbox Info
%...................................................
% Open an on screen window and use the set waitScreenColor
[window, windowRect] = PsychImaging('OpenWindow', game.screenNumber, waitScreenColor,game.windowSize);
[offscreenWindow, ~] = Screen('OpenOffscreenWindow', window, [0 0 0]);
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('BlendFunction', offscreenWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
f_screen_ramp(window,waitScreenColor);



[platformImage, ~, platformAlpha] = imread([fullfile(peckPath,'misc\','platform.png')]);
game.platformTexture = Screen('MakeTexture', window, cat(3, platformImage, platformAlpha));


[ringImage, ~, ringAlpha] = imread([fullfile(peckPath,'misc\','ring.png')]);
game.ringTexture = Screen('MakeTexture', window, cat(3, ringImage, ringAlpha));



% Get the vertical refresh rate of the monitor
game.ifi = Screen('GetFlipInterval', window);

topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);
flipSecs = 1/game.screenFrameRate;
game.waitFrames = round(flipSecs / game.ifi);

% Flip outside of the loop to get a time stamp
game.vbl = Screen('Flip', window);




%% 3) Loop Through Trials
%..........................................................................
%..........................................................................

sumTime=0;


    game.background =  fullfile(game.backgrounds,"/",backgroundImages{1}); % 
        


    if(game.touchE==1) SetMouse(2560*1.5, 1140/2, game.screenNumber); end
    
        
    %% Target Info
    %........................................................................
    % Load Defaults
    %........................................................................
    
    
    targetType = "Demo_Moth";
    target = f_target_loadDefault(game,targetType);


     %% Background Info
    % Load background image/s
    %..............................

    game=f_background_loadTexture(game,window);
    
    
    % Adjust Target Settings
    %........................................................................
    % This code loads in the treatments
    
    for m = 1:game.nTargets 

    
    %Adjust Traits to match variables
    %............................................................................


    target.Info(m) =  "1";
    target.TargetD(m) =  Appearances(1);
    target.speed(m) = 0;

    end
    
    
    % Load Target Images
    %..............................
    
    target = f_images_moth2D(game,target,window);

    

    %% Generate Motion Path
    game.drawMethod="static";


    game.timeLimit = 0.1; 
    motionPaths=f_paths_pointFlight(game,target,window,windowRect);


    %% Run Game

  game.saveData=1;

  %Static Phase 1
  game.drawMethod="mothStatic";
  game.timeLimit = 0.1; 
  game.allowHit = 0;
  staticPaths=f_paths_staticPhase(motionPaths,game,"start");
  [clicks,results,game,target,hitboxImage,hitImage] = f_game_masterCode(game,   motionPaths,target,window,offscreenWindow,windowRect,waitScreenColor);


  
if(game.touchE==1) 
TouchQueueStop(game.touchDev);
TouchEventFlush(game.touchDev);
end
   
f_input_waitForButtonRelease;
f_input_waitForClickRelease;

f_screen_switch(game.side2); 
sca;
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

end

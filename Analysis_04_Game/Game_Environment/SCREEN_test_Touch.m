
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Script
%....................

% NAME:  SCREEN test touch

% Function:

% This script will allow you to check your touchscreen setup.



% Requirements:
%   o. Psychtoolbox
%   OPTIONAL
%   o. OpenGL (FPS > 60 hz)
%   o. Graphics Card (FPS > 60 hz)
%   o. Gaming Screen (FPS > 60 hz)


% Contact information: ghancockzoology@gmail.com

% All code presented here was created by George RA Hancock
% Please do not redistribute without permission or citation (following
% publication)

% As a prerequesite you must have both MATLAB and psychtoolbox installed!!

%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Instructions
%....................

% Open this script in MATLAB, go to editor and press run.
% / Alternatively right click script and select run.

% If it is working correctly the window should appear black and when
% touched, create yellow dots at the touch location.

%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


function SCREEN_test_Touch()
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

game = f_game_presets("Touch",gamePath,"blank");

game.folderPath =  fullfile(peckPath ,"blank");
game.playerID = "blank";
game.savePath =  fullfile(game.folderPath);
game.backgrounds = fullfile(game.folderPath,"\","Backgrounds");
game.ui = fullfile(game.folderPath,"\","UI");
    game.showMouse=1;
    game.useDrag=1;

    game.useSoundMiss = 0;                                                     
    game.useSoundHit = 0;
    game.invertPath=1; 
    game.revealDead = 0;                 
    game.revealFail = 0; 

    game.killableTargets = 0; 
    game.deathDuration = 0; 
    game.deathJitter = 0; 
    game.multiKill=0; 
    game.nTargets=1;

    game.useHitbox=0;
    game.expandHitbox = 50;    


game.timeLimit = 0.5;
 game.mouseSize=40;%

game.nRepeats=1;

Appearances = f_obtain_targets(game);


game.nTreatments=1;


% Generate Random Backgrounds Array

backgroundImages = f_randomise_backgrounds(game,"random");


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
[game, window, windowRect,offscreenWindow] = f_game_initialisePTB(game,waitScreenColor);

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

if(game.touchE==0)

    disp("WARNING, no touch screen device detected")
    return 

end

%return



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
    game.pathMethod="cycles";

    game.timeLimit =60; 
    motionPaths=f_paths_pointFlight(game,target,window, windowRect);


    %% Run Game

  game.saveData=1;

  %Static Phase 1
  game.drawMethod="mothStatic";
  game.timeLimit = 60; 
  game.allowHit = 1;
  staticPaths=f_paths_staticPhase(motionPaths,game,"start");
  [clicks,results,game,target,hitboxImage,hitImage] = f_game_masterCode(game,   motionPaths,target,window,offscreenWindow,windowRect,waitScreenColor);


  
if(game.touchE==1) 
TouchQueueStop(game.touchDev);
TouchEventFlush(game.touchDev);
end
   
f_input_waitForButtonRelease;
f_input_waitForClickRelease;


sca;
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

end

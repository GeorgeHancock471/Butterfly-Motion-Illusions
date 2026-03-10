



%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Script
%....................

% NAME:  function for targets, settings

% Function:
% This script is used to store all of the target settings. You can add new
% target settings by using new cases. E.g. lets say I wanted to make the
% default settings for a swallowtail butterfly I could add a new case
% 'Swallowtail Butterfly',

% Within the defaults the boid settings are the same across all of them and
% so are set outside of the cases. However, should you wish to make
% defaults with boid parameters stored you may change these within the
% case.

% Remember all of these settings can also be changed outside of the default
% settings, this is simply a method of storing settings.

% List of parameters, functions are given along side the line.

% NB hovering is not aplied to targets that don't use pointFlight or
% randWalk movement.


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



function targetSettings = f_target_settings(targetType,game)
    % Initialize an empty struct
    targetSettings = struct();


    targetSettings.overlap = 0; %determines whether targets are allowed to move over eachother

    targetSettings.boidVR = 20;  %grouping distance          
    targetSettings.boidSR = 3;  %seperation radius relative to image size     
    targetSettings.boidCW =  0.0; %cohesionWeight  
    targetSettings.boidAW = 0.2;   %alignmentWeight
    targetSettings.boidSW = 0.4;  %seperationWeight
    targetSettings.boidDF = 0.9;  %how much boids is dampened
    targetSettings.boidRwalk = 0.05;  %how often the boids random walk instead of flock
    targetSettings.boidProb = 0.2;  %how often the boids use boid rules

    targetSettings.allowHit = 1;
	
    switch targetType


      case 'Demo_Camo'
        %//////////////////////////////////////////////////////////////////////////////////////////////////////////
                %Appearance
                
                targetSettings.TargetD =  "Demo_Camo"; % Body & Wing Image Folder
                targetSettings.targetScale = 0.5; % Body Scale
                
                %Flight Speed
                %..............
                
                targetSettings.speed = 0*game.pxPcm/game.screenFrameRate; % How fast the Target 1 fly in cm.second
                
                %Wing Angles
                %...............
                targetSettings.foldAngf =85; %Fold Angle Forwing for Targets
                targetSettings.foldAngh = targetSettings.foldAngf-20; %Fold Angle Hindwing for Targets
                targetSettings.foldRadiusF = 0.6; %Fold Radius
                targetSettings.foldRadiusH = 0.6; %Fold Radius
                targetSettings.foldOffset = 0.2;
                
                targetSettings.flightAngf = +13; %Flight Angle Forwing for Targets
                targetSettings.flightAngh = targetSettings.flightAngf+8; %Flight Angle Hindwing for Targets
                targetSettings.flightRadiusF = 0.5; %Fold Radius
                targetSettings.flightRadiusH = 0.5; %Fold Radius
                targetSettings.flightOffset = 0.2;
                
                
                %Wingbeat Behaviour
                %..............
                targetSettings.cycleF = 1/2 * game.screenFrameRate /  16;    % Wingbeat Hz for Target 1
                targetSettings.flpSU  =  0.7;  % Wingbeat Stroke size for Target 1
                targetSettings.fRF = 12; %Motion Range forwing Target 1
                targetSettings.fRH = 12; %Motion Range hindwing Target 1
                
                %Gliding
                targetSettings.clapGlide = 1; %Does the Target perform bursts of flapping (0 means off)
                targetSettings.clapD = 0.3;  %Duration of a glide seconds.
                targetSettings.clapF = 0.3; %Probability of a glide.
                targetSettings.glideA = 0.05; %How much the wing amplitude is reduce.
                targetSettings.glideCooldown = 0.25; %Cooldown for next glide in seconds.
                targetSettings.glideWB =  1/2 * game.screenFrameRate /  11;; %glideWingBeatFrq
                targetSettings.decoupleWings = 0; %Only use for butterflies with gliding
                
                
                %Jitter Behaviour
                %..............
                targetSettings.jitter = 0; % Does the Target jitter when flying
                targetSettings.FjF = 2; %Jitter frequency Flapping Target 1
                targetSettings.FjA = 90*pi/180; %Jitter Amplitude  Flapping  Target 1
                
                targetSettings.GjF = 1; %Jitter frequency Gliding  Target 1
                targetSettings.GjA = 10*pi/180; %Jitter Amplitude  Gliding  Target 1
                
                %Hover
                %..............
                targetSettings.hover = 0; % Does the Target hover when flying
                
                targetSettings.FhF = 2/FrameRate; %Hover frequency 
                targetSettings.FhA = 5; %Hover Amplitude  Flapping
                
                
                %Movement Pattern
                %..............
                
                targetSettings.waveA = 00*pi/180; %Flight Wave Amplitude Target 1
                targetSettings.waveF = 0.5; %Flight Wave Frequency Target 1
                
                targetSettings.slowTurn = 1;
                targetSettings.angStep = pi/180*0.5; %game.Turning Speed of Target 1
                
                targetSettings.minTravel = 0.1; %How far Target 1 travels before game.Turning
                targetSettings.maxTravel = 0.5;    %How far Target 1 travels before game.Turning
                targetSettings.maxWalkTurn = pi; %How much the target can turn during randomwalk
                
                
                %Movement Range
                %..............
                
                targetSettings.xMin = 0.2; %Minimum x bound during flight
                targetSettings.yMin = 0.2; %Minimum y bound during flight
                
                targetSettings.xMax = 0.8; %Maximum x bound during flight
                targetSettings.yMax = 0.8; %Maximum y bound during flight
                
                
                targetSettings.endX = 0.2+rand*0.6; % X coordinate land
                targetSettings.endY = 0.2+rand*0.6; % Y coordinate land
                targetSettings.endAngle = rand*pi*2;
                    
                targetSettings.sound = 1;

        case 'Demo_Moth'
        %//////////////////////////////////////////////////////////////////////////////////////////////////////////
                %Appearance  
                targetSettings.TargetD =  "Demo_Moth"; % Body & Wing Image Folder
                targetSettings.targetScale = 0.5; % Body Scale
                
                %Flight Speed
                %..............
                
                targetSettings.speed = 12*game.pxPcm/game.screenFrameRate; % How fast the Target 1 fly in cm.second
                
                %Wing Angles
                %...............
                targetSettings.foldAngf =85; %Fold Angle Forwing for Targets
                targetSettings.foldAngh = targetSettings.foldAngf-20; %Fold Angle Hindwing for Targets
                targetSettings.foldRadiusF = 0.6; %Fold Radius
                targetSettings.foldRadiusH = 0.6; %Fold Radius
                targetSettings.foldOffset = 0.2;
                
                targetSettings.flightAngf = +13; %Flight Angle Forwing for Targets
                targetSettings.flightAngh = targetSettings.flightAngf+8; %Flight Angle Hindwing for Targets
                targetSettings.flightRadiusF = 0.5; %Fold Radius
                targetSettings.flightRadiusH = 0.5; %Fold Radius
                targetSettings.flightOffset = 0.2;
                
                
                %Wingbeat Behaviour
                %..............
                targetSettings.cycleF = 1/2 * game.screenFrameRate /  16;    % Wingbeat Hz for Target 1
                targetSettings.flpSU  =  0.7;  % Wingbeat Stroke size for Target 1
                targetSettings.fRF = 12; %Motion Range forwing Target 1
                targetSettings.fRH = 12; %Motion Range hindwing Target 1
                
                %Gliding
                targetSettings.clapGlide = 1; %Does the Target perform bursts of flapping (0 means off)
                targetSettings.clapD = 0.3;  %Duration of a glide seconds.
                targetSettings.clapF = 0.3; %Probability of a glide.
                targetSettings.glideA = 0.05; %How much the wing amplitude is reduce.
                targetSettings.glideCooldown = 0.25; %Cooldown for next glide in seconds.
                targetSettings.glideWB =  1/2 * game.screenFrameRate /  11;; %glideWingBeatFrq
                targetSettings.decoupleWings = 0; %Only use for butterflies with gliding
                
                
                %Jitter Behaviour
                %..............
                targetSettings.jitter = 1; % Does the Target jitter when flying
                targetSettings.FjF = 2; %Jitter frequency Flapping Target 1
                targetSettings.FjA = 90*pi/180; %Jitter Amplitude  Flapping  Target 1
                
                targetSettings.GjF = 1; %Jitter frequency Gliding  Target 1
                targetSettings.GjA = 10*pi/180; %Jitter Amplitude  Gliding  Target 1
                
                %Hover
                %..............
                targetSettings.hover = 1; % Does the Target hover when flying
                
                targetSettings.FhF = 2/FrameRate; %Hover frequency 
                targetSettings.FhA = 5; %Hover Amplitude  Flapping
                
                
                %Movement Pattern
                %..............
                
                targetSettings.waveA = 60*pi/180; %Flight Wave Amplitude Target 1
                targetSettings.waveF = 0.5; %Flight Wave Frequency Target 1
                
                targetSettings.slowTurn = 1;
                targetSettings.angStep = pi/180*0.5; %game.Turning Speed of Target 1
                
                targetSettings.minTravel = 0.1; %How far Target 1 travels before game.Turning
                targetSettings.maxTravel = 0.5;    %How far Target 1 travels before game.Turning
                targetSettings.maxWalkTurn = pi; %How much the target can turn during randomwalk
                
                
                %Movement Range
                %..............
                
                targetSettings.xMin = 0.2; %Minimum x bound during flight
                targetSettings.yMin = 0.2; %Minimum y bound during flight
                
                targetSettings.xMax = 0.8; %Maximum x bound during flight
                targetSettings.yMax = 0.8; %Maximum y bound during flight
                
                
                targetSettings.endX = 0.2+rand*0.6; % X coordinate land
                targetSettings.endY = 0.2+rand*0.6; % Y coordinate land
                targetSettings.endAngle = rand*pi*2;
                    
                targetSettings.sound = 1;

     case 'Demo_Catacola'
        %//////////////////////////////////////////////////////////////////////////////////////////////////////////
                  %Appearance
                
                targetSettings.TargetD =  "Demo_Catacola"; % Body & Wing Image Folder
                targetSettings.targetScale = 0.5; % Body Scale
                
                %Flight Speed
                %..............
                
                targetSettings.speed = 12*game.pxPcm/game.screenFrameRate; % How fast the Target 1 fly in cm.second
                
                %Wing Angles
                %...............
                targetSettings.foldAngf =100; %Fold Angle Forwing for Targets
                targetSettings.foldAngh = targetSettings.foldAngf-35; %Fold Angle Hindwing for Targets
                targetSettings.foldRadiusF = 0.6; %Fold Radius
                targetSettings.foldRadiusH = 0.50; %Fold Radius
                targetSettings.foldOffset = 0.035;
                
                targetSettings.flightAngf = +13; %Flight Angle Forwing for Targets
                targetSettings.flightAngh = targetSettings.flightAngf+8; %Flight Angle Hindwing for Targets
                targetSettings.flightRadiusF = 0.6; %Fold Radius
                targetSettings.flightRadiusH = 0.50; %Fold Radius
                targetSettings.flightOffset =0;
                
                
                %Wingbeat Behaviour
                %..............
                targetSettings.cycleF = 1/2 * game.screenFrameRate /  20;    % Wingbeat Hz for Target 1
                targetSettings.flpSU  =  0.7;  % Wingbeat Stroke size for Target 1
                targetSettings.fRF = 12; %Motion Range forwing Target 1
                targetSettings.fRH = 12; %Motion Range hindwing Target 1
                
                %Gliding
                targetSettings.clapGlide = 0; %Does the Target perform bursts of flapping (0 means off)
                targetSettings.clapD = 0.3;  %Duration of a glide seconds.
                targetSettings.clapF = 0.3; %Probability of a glide.
                targetSettings.glideA = 0.05; %How much the wing amplitude is reduce.
                targetSettings.glideCooldown = 0.25; %Cooldown for next glide in seconds.
                targetSettings.glideWB =  1/2 * game.screenFrameRate /  11;; %glideWingBeatFrq
                targetSettings.decoupleWings = 0; %Only use for butterflies with gliding
                
                
                %Jitter Behaviour
                %..............
                targetSettings.jitter = 1; % Does the Target jitter when flying
                targetSettings.FjF = 0.5; %Jitter frequency Flapping Target 1
                targetSettings.FjA = 40*pi/180; %Jitter Amplitude  Flapping  Target 1
                
                targetSettings.GjF = 0.5; %Jitter frequency Gliding  Target 1
                targetSettings.GjA = 40*pi/180; %Jitter Amplitude  Gliding  Target 1
                
                %Hover
                %..............
                targetSettings.hover = 0; % Does the Target hover when flying
                
                targetSettings.FhF = 2/FrameRate; %Hover frequency 
                targetSettings.FhA = 5; %Hover Amplitude  Flapping
                
                
                %Movement Pattern
                %..............
                
                targetSettings.waveA = 60*pi/180; %Flight Wave Amplitude Target 1
                targetSettings.waveF = 0.5; %Flight Wave Frequency Target 1
                
                targetSettings.slowTurn = 1;
                targetSettings.angStep = pi/180*0.35; %game.Turning Speed of Target 1
                
                targetSettings.minTravel = 0.3; %How far Target 1 travels before game.Turning
                targetSettings.maxTravel = 0.6;    %How far Target 1 travels before game.Turning
                targetSettings.maxWalkTurn = pi; %How much the target can turn during randomwalk
                
                
                %Movement Range
                %..............
                
                targetSettings.xMin = 0.2; %Minimum x bound during flight
                targetSettings.yMin = 0.2; %Minimum y bound during flight
                
                targetSettings.xMax = 0.8; %Maximum x bound during flight
                targetSettings.yMax = 0.8; %Maximum y bound during flight
                
                
                targetSettings.endX = 0.2+rand*0.6; % X coordinate land
                targetSettings.endY = 0.2+rand*0.6; % Y coordinate land
                targetSettings.endAngle = rand*pi*2;
                    
                targetSettings.sound = 1;

        case 'Demo_Heliconius'
        %//////////////////////////////////////////////////////////////////////////////////////////////////////////
                %Appearance
                
                targetSettings.TargetD =  "Demo_Heliconius"; % Body & Wing Image Folder
                targetSettings.targetScale = 0.5; % Body Scale
                
                %Flight Speed
                %..............
                
                targetSettings.speed = 30*game.pxPcm/game.screenFrameRate; % How fast the Target 1 fly in cm.second
                
                %Wing Angles
                %...............
                targetSettings.foldAngf =+20; %Fold Angle Forwing for Targets
                targetSettings.foldAngh = targetSettings.foldAngf+8; %Fold Angle Hindwing for Targets
                targetSettings.foldRadiusH = 0.75; %Fold Radius
                targetSettings.foldRadiusF = 0.75; %Fold Radius
                targetSettings.foldOffset = 0.1;
                
                targetSettings.flightAngf = +10; %Flight Angle Forwing for Targets
                targetSettings.flightAngh = targetSettings.flightAngf+10; %Flight Angle Hindwing for Targets
                targetSettings.flightRadiusH = 0.75; %Fold Radius
                targetSettings.flightRadiusF = 0.75; %Fold Radius
                targetSettings.flightOffset = 0.1;
                
                
                %Wingbeat Behaviour
                %..............
                targetSettings.cycleF = 1/2 * game.screenFrameRate / 6;    % Wingbeat Hz for Target 1
                targetSettings.flpSU  =  0.6;  % Wingbeat Stroke size for Target 1
                targetSettings.fRF = 20; %Motion Range forwing Target 1
                targetSettings.fRH = 18; %Motion Range hindwing Target 1
                
                %Gliding
                targetSettings.clapGlide = 0; %Does the Target perform bursts of flapping (0 means off)
                targetSettings.clapD = 0.3;  %Duration of a glide seconds.
                targetSettings.clapF = 0.3; %Probability of a glide.
                targetSettings.glideA = 0.1; %How much the wing amplitude is reduce.
                targetSettings.glideCooldown = 0.25; %Cooldown for next glide in seconds.
                targetSettings.glideWB =  1/2 * game.screenFrameRate /  3;; %glideWingBeatFrq
                targetSettings.decoupleWings = 0; %Only use for butterflies with gliding
                
                
                
                %Jitter Behaviour
                %..............
                targetSettings.jitter = 1; % Does the Target jitter when flying
                targetSettings.FjF = 2; %Jitter frequency Flapping Target 1
                targetSettings.FjA = 50*pi/180; %Jitter Amplitude  Flapping  Target 1
                
                targetSettings.GjF = 0.25; %Jitter frequency Gliding  Target 1
                targetSettings.GjA = 10*pi/180; %Jitter Amplitude  Gliding  Target 1
                
                %Hover
                %..............
                targetSettings.hover = 0; % Does the Target hover when flying
                
                targetSettings.FhF = 1/game.screenFrameRate; %Hover frequency 
                targetSettings.FhA = 1; %Hover Amplitude  Flapping
                
                
                %Movement Pattern
                %..............
                
                targetSettings.waveA = 30*pi/180; %Flight Wave Amplitude Target 1
                targetSettings.waveF = 2; %Flight Wave Frequency Target 1
                
                targetSettings.slowTurn = 0.5;
                targetSettings.angStep = pi/3/game.screenFrameRate; %game.Turning Speed of Target 1
                
                targetSettings.minTravel = 0.1; %How far Target 1 travels before game.Turning
                targetSettings.maxTravel = 1.5;    %How far Target 1 travels before game.Turning
                targetSettings.maxWalkTurn = pi; %How much the target can turn during randomwalk
                
                %Movement Range
                %..............
                
                targetSettings.xMin = 0.25; %Minimum x bound during flight
                targetSettings.yMin = 0.25; %Minimum y bound during flight
                
                targetSettings.xMax = 0.75; %Maximum x bound during flight
                targetSettings.yMax = 0.75; %Maximum y bound during flight
                
                
                targetSettings.endX = 0.2+rand*0.6; % X coordinate land
                targetSettings.endY = 0.2+rand*0.6; % Y coordinate land
                    
                targetSettings.sound = 1;

                targetSettings.endAngle = rand*pi*2;

        case 'Demo_Butterfly'
        %//////////////////////////////////////////////////////////////////////////////////////////////////////////
                %Appearance
                
                targetSettings.TargetD =  "Demo_Butterfly"; % Body & Wing Image Folder
                targetSettings.targetScale = 0.5; % Body Scale
                
                %Flight Speed
                %..............
                
                targetSettings.speed = 20*game.pxPcm/game.screenFrameRate; % How fast the Target 1 fly in cm.second
                
                %Wing Angles
                %...............
                targetSettings.foldAngf =+20; %Fold Angle Forwing for Targets
                targetSettings.foldAngh = targetSettings.foldAngf+1; %Fold Angle Hindwing for Targets
                targetSettings.foldRadiusF = 0.5; %Fold Radius
                 targetSettings.foldRadiusH = 0.5; %Fold Radius
                 targetSettings.foldOffset = 0.1; %Fold Radius
                
                targetSettings.flightAngf = +10; %Flight Angle Forwing for Targets
                targetSettings.flightAngh = targetSettings.flightAngf+3; %Flight Angle Hindwing for Targets
                targetSettings.flightRadiusF = 0.5; %Fold Radius
                targetSettings.flightRadiusH = 0.5; %Fold Radius
                targetSettings.flightOffset = 0.1; %Fold Radius
                
                
                %Wingbeat Behaviour
                %..............
                targetSettings.cycleF = 1/2 * game.screenFrameRate / 6;    % Wingbeat Hz for Target 1
                targetSettings.flpSU  =  0.85;  % Wingbeat Stroke size for Target 1
                targetSettings.fRF = 15; %Motion Range forwing Target 1
                targetSettings.fRH = 13; %Motion Range hindwing Target 1
                
                %Gliding
                 targetSettings.clapGlide = 1; %Does the Target perform bursts of flapping (0 means off)
                targetSettings.clapD = 0.05;  %Duration of a glide seconds.
                targetSettings.clapF = 0.3; %Probability of a glide.
                targetSettings.glideA = 0.8; %How much the wing amplitude is reduce.
                targetSettings.glideCooldown = 1; %Cooldown for next glide in seconds.
                targetSettings.glideWB =  1/2 * game.screenFrameRate /  1;; %glideWingBeatFrq
                targetSettings.decoupleWings = 0; %Only use for butterflies with gliding
                
                
                %Jitter Behaviour
                %..............
                targetSettings.jitter = 1; % Does the Target jitter when flying
                targetSettings.FjF = 2; %Jitter frequency Flapping Target 1
                targetSettings.FjA = 40*pi/180; %Jitter Amplitude  Flapping  Target 1
                
                targetSettings.GjF = 0.5; %Jitter frequency Gliding  Target 1
                targetSettings.GjA = 20*pi/180; %Jitter Amplitude  Gliding  Target 1
                
                %Hover
                %..............
                targetSettings.hover = 0; % Does the Target hover when flying
                
                targetSettings.FhF = 1/game.screenFrameRate; %Hover frequency 
                targetSettings.FhA = 1; %Hover Amplitude  Flapping
                
                
                %Movement Pattern
                %..............
                
                targetSettings.waveA = 50*pi/180; %Flight Wave Amplitude Target 1
                targetSettings.waveF = 2; %Flight Wave Frequency Target 1
                
                targetSettings.slowTurn = 1;
                targetSettings.angStep = pi/180*0.3; %game.Turning Speed of Target 1
                
                targetSettings.minTravel = 0.1; %How far Target 1 travels before game.Turning
                targetSettings.maxTravel = 0.5;    %How far Target 1 travels before game.Turning
                targetSettings.maxWalkTurn = pi/4; %How much the target can turn during randomwalk
                
                %Movement Range
                %..............
                
                targetSettings.xMin = 0.2; %Minimum x bound during flight
                targetSettings.yMin = 0.2; %Minimum y bound during flight
                
                targetSettings.xMax = 0.80; %Maximum x bound during flight
                targetSettings.yMax = 0.80; %Maximum y bound during flight
                
                
                targetSettings.endX = 0.2+rand*0.6; % X coordinate land
                targetSettings.endY = 0.2+rand*0.6; % Y coordinate land

                targetSettings.sound = 1;

                targetSettings.endAngle = rand*pi*2;

      case 'Demo_Wasp'
        %//////////////////////////////////////////////////////////////////////////////////////////////////////////
                %Appearance
                
                targetSettings.TargetD =  "Demo_Wasp"; % Body & Wing Image Folder
                targetSettings.targetScale = 0.5; % Body Scale
                
                %Flight Speed
                %..............
                
                targetSettings.speed = 6*game.pxPcm/game.screenFrameRate; % How fast the Target 1 fly in cm.second
                
                %Wing Angles
                %...............
                targetSettings.foldAngf =85; %Fold Angle Forwing for Targets
                targetSettings.foldAngh = targetSettings.foldAngf-20; %Fold Angle Hindwing for Targets
                targetSettings.foldRadiusF = 0.5; %Fold Radius
                targetSettings.foldRadiusH = 0.5; %Fold Radius
                targetSettings.foldOffset = 0.1; %Fold Radius
                
                targetSettings.flightAngf = +13; %Flight Angle Forwing for Targets
                targetSettings.flightAngh = targetSettings.flightAngf+12; %Flight Angle Hindwing for Targets
                targetSettings.flightRadius = 0.5; %Fold Radius
                targetSettings.flightRadiusF = 0.5; %Fold Radius
                targetSettings.flightRadiusH = 0.5; %Fold Radius
                targetSettings.flightOffset = 0.1; %Fold Radius
                
                %Wingbeat Behaviour
                %..............
                targetSettings.cycleF = 1/2 * game.screenFrameRate /  40;    % Wingbeat Hz for Target 1
                targetSettings.flpSU  =  0.7;  % Wingbeat Stroke size for Target 1
                targetSettings.fRF = 12; %Motion Range forwing Target 1
                targetSettings.fRH = 12; %Motion Range hindwing Target 1
                
                %Gliding
                targetSettings.clapGlide = 0; %Does the Target perform bursts of flapping (0 means off)
                targetSettings.clapD = 0.1;  %Duration of a glide seconds.
                targetSettings.clapF = 0.02; %Probability of a glide.
                targetSettings.glideA = 0.1; %How much the wing amplitude is reduce.
                targetSettings.glideCooldown = 1; %Cooldown for next glide in seconds.
                targetSettings.glideWB =  1/2 * game.screenFrameRate /  9;; %glideWingBeatFrq
                targetSettings.decoupleWings = 0; %Only use for butterflies with gliding
                
                
                
                %Jitter Behaviour
                %..............
                targetSettings.jitter = 1; % Does the Target jitter when flying
                targetSettings.FjF = 3; %Jitter frequency Flapping Target 1
                targetSettings.FjA = 40*pi/180; %Jitter Amplitude  Flapping  Target 1
                
                targetSettings.GjF = 1; %Jitter frequency Gliding  Target 1
                targetSettings.GjA = 10*pi/180; %Jitter Amplitude  Gliding  Target 1
                
                %Hover
                %..............
                targetSettings.hover = 1; % Does the Target hover when flying
                
                targetSettings.FhF = 0.25/game.screenFrameRate; %Hover frequency 
                targetSettings.FhA = 4; %Hover Amplitude  Flapping
                
                
                %Movement Pattern
                %..............
                
                targetSettings.waveA = 40*pi/180; %Flight Wave Amplitude Target 1
                targetSettings.waveF = 4; %Flight Wave Frequency Target 1
                
                targetSettings.slowTurn = 1;
                targetSettings.angStep = pi/180*0.6; %game.Turning Speed of Target 1
                
                targetSettings.minTravel = 0.1; %How far Target 1 travels before game.Turning
                targetSettings.maxTravel = 0.5;    %How far Target 1 travels before game.Turning
                targetSettings.maxWalkTurn = pi; %How much the target can turn during randomwalk
                
                %Movement Range
                %..............
                
                targetSettings.xMin = 0.2; %Minimum x bound during flight
                targetSettings.yMin = 0.2; %Minimum y bound during flight
                
                targetSettings.xMax = 0.8; %Maximum x bound during flight
                targetSettings.yMax = 0.8; %Maximum y bound during flight
                
                
                targetSettings.endX = 0.2+rand*0.6; % X coordinate land
                targetSettings.endY = 0.2+rand*0.6; % Y coordinate land
                    

                targetSettings.sound = 1;                


                targetSettings.endAngle = rand*pi*2;
        case 'Demo_Dragonfly'
        %//////////////////////////////////////////////////////////////////////////////////////////////////////////
                %Appearance
                
                targetSettings.TargetD =  "Demo_Dragonfly"; % Body & Wing Image Folder
                targetSettings.targetScale = 0.5; % Body Scale
                
                %Flight Speed
                %..............
                
                targetSettings.speed = 18*game.pxPcm/game.screenFrameRate; % How fast the Target 1 fly in cm.second
                
                %Wing Angles
                %...............
                targetSettings.foldAngf =0; %Fold Angle Forwing for Targets
                targetSettings.foldAngh = targetSettings.foldAngf; %Fold Angle Hindwing for Targets
                targetSettings.foldRadiusF = 0.9; %Fold Radius
                targetSettings.foldRadiusH = 0.9; %Fold Radius
                targetSettings.foldOffset = 0.1; %Fold Radius
                
                
                targetSettings.flightAngf = +0; %Flight Angle Forwing for Targets
                targetSettings.flightAngh = targetSettings.flightAngf; %Flight Angle Hindwing for Targets
                targetSettings.flightRadiusF = 0.9; %Fold Radius
                targetSettings.flightRadiusH = 0.9; %Fold Radius
                targetSettings.flightOffset = 0.1; %Fold Radius
                
                %Wingbeat Behaviour
                %..............
                targetSettings.cycleF = 1/2 * game.screenFrameRate /  30;    % Wingbeat Hz for Target 1
                targetSettings.flpSU  =  0.7;  % Wingbeat Stroke size for Target 1
                targetSettings.fRF = 12; %Motion Range forwing Target 1
                targetSettings.fRH = 12; %Motion Range hindwing Target 1
                
                %Gliding
                targetSettings.clapGlide = 0; %Does the Target perform bursts of flapping (0 means off)
                targetSettings.clapD = 0.1;  %Duration of a glide seconds.
                targetSettings.clapF = 0.02; %Probability of a glide.
                targetSettings.glideA = 0.1; %How much the wing amplitude is reduce.
                targetSettings.glideCooldown = 1; %Cooldown for next glide in seconds.
                targetSettings.glideWB =  1/2 * game.screenFrameRate /  9;; %glideWingBeatFrq
                targetSettings.decoupleWings = 0; %Only use for butterflies with gliding
                
                
                
                %Jitter Behaviour
                %..............
                targetSettings.jitter = 1; % Does the Target jitter when flying
                targetSettings.FjF = 2; %Jitter frequency Flapping Target 1
                targetSettings.FjA = 40*pi/180; %Jitter Amplitude  Flapping  Target 1
                
                targetSettings.GjF = 1; %Jitter frequency Gliding  Target 1
                targetSettings.GjA = 10*pi/180; %Jitter Amplitude  Gliding  Target 1
                
                %Hover
                %..............
                targetSettings.hover = 1; % Does the Target hover when flying
                
                targetSettings.FhF = 1/game.screenFrameRate; %Hover frequency 
                targetSettings.FhA = 2.5; %Hover Amplitude  Flapping
                
                
                %Movement Pattern
                %..............
                
                targetSettings.waveA = 40*pi/180; %Flight Wave Amplitude Target 1
                targetSettings.waveF = 4; %Flight Wave Frequency Target 1
                
                targetSettings.slowTurn = 1;
                targetSettings.angStep = pi/180*0.6; %game.Turning Speed of Target 1
                
                targetSettings.minTravel = 0.1; %How far Target 1 travels before game.Turning
                targetSettings.maxTravel = 0.5;    %How far Target 1 travels before game.Turning
                targetSettings.maxWalkTurn = pi; %How much the target can turn during randomwalk
                
                %Movement Range
                %..............
                
                targetSettings.xMin = 0.2; %Minimum x bound during flight
                targetSettings.yMin = 0.2; %Minimum y bound during flight
                
                targetSettings.xMax = 0.8; %Maximum x bound during flight
                targetSettings.yMax = 0.8; %Maximum y bound during flight
                
                
                targetSettings.endX = 0.2+rand*0.6; % X coordinate land
                targetSettings.endY = 0.2+rand*0.6; % Y coordinate land
                    


                targetSettings.sound = 1;

                targetSettings.endAngle = rand*pi*2;


        case 'Train_Dot'
        %//////////////////////////////////////////////////////////////////////////////////////////////////////////
                %Appearance
                
                targetSettings.TargetD =  "Train_Dot"; % Body & Wing Image Folder
                targetSettings.targetScale = 0.5; % Body Scale
                
                %Flight Speed
                %..............
                
                targetSettings.speed = 1*game.pxPcm/game.screenFrameRate; % How fast the Target 1 fly in cm.second
                
                %Wing Angles
                %...............
                targetSettings.foldAngf =+20; %Fold Angle Forwing for Targets
                targetSettings.foldAngh = targetSettings.foldAngf+8; %Fold Angle Hindwing for Targets
                targetSettings.foldRadiusF = 0.5; %Fold Radius
                targetSettings.foldRadiusH = 0.5; %Fold Radius
                targetSettings.foldOffset = 0.1; %Fold Radius
                
                targetSettings.flightAngf = +10; %Flight Angle Forwing for Targets
                targetSettings.flightAngh = targetSettings.flightAngf+10; %Flight Angle Hindwing for Targets
                targetSettings.flightRadiusF = 0.5; %Fold Radius
                targetSettings.flightRadiusH = 0.5; %Fold Radius
                targetSettings.flightOffset = 0.1; %Fold Radius
                
                %Wingbeat Behaviour
                %..............
                targetSettings.cycleF = 1/2 * game.screenFrameRate / 9;    % Wingbeat Hz for Target 1
                targetSettings.flpSU  =  0.6;  % Wingbeat Stroke size for Target 1
                targetSettings.fRF = 20; %Motion Range forwing Target 1
                targetSettings.fRH = 18; %Motion Range hindwing Target 1
                
                %Gliding
                targetSettings.clapGlide = 0; %Does the Target perform bursts of flapping (0 means off)
                targetSettings.clapD = 0.3;  %Duration of a glide seconds.
                targetSettings.clapF = 0.3; %Probability of a glide.
                targetSettings.glideA = 0.1; %How much the wing amplitude is reduce.
                targetSettings.glideCooldown = 0.25; %Cooldown for next glide in seconds.
                targetSettings.glideWB =  1/2 * game.screenFrameRate /  3;; %glideWingBeatFrq
                targetSettings.decoupleWings = 0; %Only use for butterflies with gliding
                
 
                %Jitter Behaviour
                %..............
                targetSettings.jitter = 0; % Does the Target jitter when flying
                targetSettings.FjF = 2; %Jitter frequency Flapping Target 1
                targetSettings.FjA = 80*pi/180; %Jitter Amplitude  Flapping  Target 1
                
                targetSettings.GjF = 2; %Jitter frequency Gliding  Target 1
                targetSettings.GjA = 5*pi/180; %Jitter Amplitude  Gliding  Target 1
                
              
                
                %Hover
                %..............
                targetSettings.hover = 0; % Does the Target hover when flying
                
                targetSettings.FhF = 1/game.screenFrameRate; %Hover frequency 
                targetSettings.FhA = 2.5; %Hover Amplitude  Flapping
                
                
                %Movement Pattern
                %..............
                
                targetSettings.waveA = 0*pi/180; %Flight Wave Amplitude Target 1
                targetSettings.waveF = 0; %Flight Wave Frequency Target 1
                
                targetSettings.slowTurn = 1;
                targetSettings.angStep = pi/180*0.5; %game.Turning Speed of Target 1
                
                targetSettings.minTravel = 0.5; %How far Target 1 travels before game.Turning
                targetSettings.maxTravel = 1.5;    %How far Target 1 travels before game.Turning
                targetSettings.maxWalkTurn = pi; %How much the target can turn during randomwalk
                
                %Movement Range
                %..............
                
                targetSettings.xMin = 0.2; %Minimum x bound during flight
                targetSettings.yMin = 0.2; %Minimum y bound during flight
                
                targetSettings.xMax = 0.8; %Maximum x bound during flight
                targetSettings.yMax = 0.8; %Maximum y bound during flight
                
                
                targetSettings.endX = 0.2+rand*0.6; % X coordinate land
                targetSettings.endY = 0.2+rand*0.6; % Y coordinate land
                    

                targetSettings.sound = 1;
            
                targetSettings.endAngle = rand*pi*2;


       case 'Demo_Boid'
        %//////////////////////////////////////////////////////////////////////////////////////////////////////////
                %Appearance
                
                targetSettings.TargetD =  "Train_Dot"; % Body & Wing Image Folder
                targetSettings.targetScale = 0.5; % Body Scale
                
                %Flight Speed
                %..............
                
                targetSettings.speed = 1*game.pxPcm/game.screenFrameRate; % How fast the Target 1 fly in cm.second
                
                %Wing Angles
                %...............
                targetSettings.foldAngf =+20; %Fold Angle Forwing for Targets
                targetSettings.foldAngh = targetSettings.foldAngf+8; %Fold Angle Hindwing for Targets
                targetSettings.foldRadiusF = 0.5; %Fold Radius
                targetSettings.foldRadiusH = 0.5; %Fold Radius
                targetSettings.foldOffset = 0.1; %Fold Radius
                
                targetSettings.flightAngf = +10; %Flight Angle Forwing for Targets
                targetSettings.flightAngh = targetSettings.flightAngf+10; %Flight Angle Hindwing for Targets
                targetSettings.flightRadiusF = 0.5; %Fold Radius
                targetSettings.flightRadiusH = 0.5; %Fold Radius
                targetSettings.flightOffset = 0.1; %Fold Radius
                
                %Wingbeat Behaviour
                %..............
                targetSettings.cycleF = 1/2 * game.screenFrameRate / 9;    % Wingbeat Hz for Target 1
                targetSettings.flpSU  =  0.6;  % Wingbeat Stroke size for Target 1
                targetSettings.fRF = 20; %Motion Range forwing Target 1
                targetSettings.fRH = 18; %Motion Range hindwing Target 1
                
                %Gliding
                targetSettings.clapGlide = 0; %Does the Target perform bursts of flapping (0 means off)
                targetSettings.clapD = 0.3;  %Duration of a glide seconds.
                targetSettings.clapF = 0.3; %Probability of a glide.
                targetSettings.glideA = 0.1; %How much the wing amplitude is reduce.
                targetSettings.glideCooldown = 0.25; %Cooldown for next glide in seconds.
                targetSettings.glideWB =  1/2 * game.screenFrameRate /  3;; %glideWingBeatFrq
                targetSettings.decoupleWings = 0; %Only use for butterflies with gliding
                
 
                %Jitter Behaviour
                %..............
                targetSettings.jitter = 0; % Does the Target jitter when flying
                targetSettings.FjF = 2; %Jitter frequency Flapping Target 1
                targetSettings.FjA = 80*pi/180; %Jitter Amplitude  Flapping  Target 1
                
                targetSettings.GjF = 2; %Jitter frequency Gliding  Target 1
                targetSettings.GjA = 5*pi/180; %Jitter Amplitude  Gliding  Target 1
                
              
                
                %Hover
                %..............
                targetSettings.hover = 0; % Does the Target hover when flying
                
                targetSettings.FhF = 1/game.screenFrameRate; %Hover frequency 
                targetSettings.FhA = 2.5; %Hover Amplitude  Flapping
                
                
                %Movement Pattern
                %..............
                
                targetSettings.waveA = 0*pi/180; %Flight Wave Amplitude Target 1
                targetSettings.waveF = 0; %Flight Wave Frequency Target 1
                
                targetSettings.slowTurn = 1;
                targetSettings.angStep = pi/180*0.3; %game.Turning Speed of Target 1
                
                targetSettings.minTravel = 0.5; %How far Target 1 travels before game.Turning
                targetSettings.maxTravel = 1.5;    %How far Target 1 travels before game.Turning
                targetSettings.maxWalkTurn = pi/4; %How much the target can turn during randomwalk
                
                %Movement Range
                %..............
                
                targetSettings.xMin = 0.2; %Minimum x bound during flight
                targetSettings.yMin = 0.2; %Minimum y bound during flight
                
                targetSettings.xMax = 0.8; %Maximum x bound during flight
                targetSettings.yMax = 0.8; %Maximum y bound during flight
                
                
                targetSettings.endX = 0.2+rand*0.6; % X coordinate land
                targetSettings.endY = 0.2+rand*0.6; % Y coordinate land
                    

                targetSettings.sound = 1;
            
                targetSettings.endAngle = rand*pi*2;
				
				
				
				

                case 'Demo_Frog'
                %//////////////////////////////////////////////////////////////////////////////////////////////////////////
                %Appearance
                
                targetSettings.TargetD =  "Demo_Heliconius"; % Body & Wing Image Folder
                targetSettings.targetScale = 0.5; % Body Scale
                
                %Flight Speed
                %..............
                
                targetSettings.speed = 35*game.pxPcm/game.screenFrameRate; % How fast the Target 1 fly in cm.second
                
                %Wing Angles
                %...............
                targetSettings.foldAngf =+20; %Fold Angle Forwing for Targets
                targetSettings.foldAngh = targetSettings.foldAngf+8; %Fold Angle Hindwing for Targets
                targetSettings.foldRadiusH = 0.75; %Fold Radius
                targetSettings.foldRadiusF = 0.75; %Fold Radius
                targetSettings.foldOffset = 0.1;
                
                targetSettings.flightAngf = +10; %Flight Angle Forwing for Targets
                targetSettings.flightAngh = targetSettings.flightAngf+10; %Flight Angle Hindwing for Targets
                targetSettings.flightRadiusH = 0.75; %Fold Radius
                targetSettings.flightRadiusF = 0.75; %Fold Radius
                targetSettings.flightOffset = 0.1;
                
                
                %Wingbeat Behaviour
                %..............
                targetSettings.cycleF = 1/2 * game.screenFrameRate / 9;    % Wingbeat Hz for Target 1
                targetSettings.flpSU  =  0.6;  % Wingbeat Stroke size for Target 1
                targetSettings.fRF = 20; %Motion Range forwing Target 1
                targetSettings.fRH = 18; %Motion Range hindwing Target 1
                
                %Gliding
                targetSettings.clapGlide = 1; %Does the Target perform bursts of flapping (0 means off)
                targetSettings.clapD = 0.3;  %Duration of a glide seconds.
                targetSettings.clapF = 0.3; %Probability of a glide.
                targetSettings.glideA = 0.1; %How much the wing amplitude is reduce.
                targetSettings.glideCooldown = 0.25; %Cooldown for next glide in seconds.
                targetSettings.glideWB =  1/2 * game.screenFrameRate /  3;; %glideWingBeatFrq
                targetSettings.decoupleWings = 0; %Only use for butterflies with gliding
                
                
                
                %Jitter Behaviour
                %..............
                targetSettings.jitter = 1; % Does the Target jitter when flying
                targetSettings.FjF = 0.5; %Jitter frequency Flapping Target 1
                targetSettings.FjA = 15*pi/180; %Jitter Amplitude  Flapping  Target 1
                
                targetSettings.GjF = 1; %Jitter frequency Gliding  Target 1
                targetSettings.GjA = 15*pi/180; %Jitter Amplitude  Gliding  Target 1
                
                %Hover
                %..............
                targetSettings.hover = 0; % Does the Target hover when flying
                
                targetSettings.FhF = 1/game.screenFrameRate; %Hover frequency 
                targetSettings.FhA = 1; %Hover Amplitude  Flapping
                
                
                %Movement Pattern
                %..............
                
                targetSettings.waveA = 0*pi/180; %Flight Wave Amplitude Target 1
                targetSettings.waveF = 0.2; %Flight Wave Frequency Target 1
                
                targetSettings.slowTurn = 1;
                targetSettings.angStep = 10*pi/180; %game.Turning Speed of Target 1
                
                targetSettings.minTravel = 0.4; %How far Target 1 travels before game.Turning
                targetSettings.maxTravel = 1;    %How far Target 1 travels before game.Turning
                targetSettings.maxWalkTurn = pi; %How much the target can turn during randomwalk
                
                %Movement Range
                %..............
                
                targetSettings.xMin = 0.25; %Minimum x bound during flight
                targetSettings.yMin = 0.25; %Minimum y bound during flight
                
                targetSettings.xMax = 0.75; %Maximum x bound during flight
                targetSettings.yMax = 0.75; %Maximum y bound during flight
                
                
                targetSettings.endX = 0.2+rand*0.6; % X coordinate land
                targetSettings.endY = 0.2+rand*0.6; % Y coordinate land
                    
                targetSettings.sound = 1;

                targetSettings.endAngle = rand*pi*2;

end

%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Script
%....................

% NAME:  function for targets, load Default

% Function:
% This function will load the default settings for the specified target
% type in a loop transfering them back to the game.


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




function target = f_target_loadDefault(game,targetType)

for m = 1:game.nTargets 

            targetSettings = f_target_settings(targetType,game);
            
            target.Number = m;
            target.Info = "Info";

            target.TargetD(m) = targetSettings.TargetD;
            target.targetScale(m) = targetSettings.targetScale;
        
            target.speed(m) = targetSettings.speed;
			
			target.allowHit(m) =  targetSettings.allowHit;
        
            % Wing Angles
            target.foldAngf(m) = targetSettings.foldAngf;
            target.foldAngh(m) = targetSettings.foldAngh;
            target.foldRadiusF(m) = targetSettings.foldRadiusF;
            target.foldRadiusH(m) = targetSettings.foldRadiusH;
            target.foldOffset(m) = targetSettings.foldOffset;

            
            target.flightAngf(m) = targetSettings.flightAngf;
            target.flightAngh(m) = targetSettings.flightAngh;
            target.flightRadiusF(m) = targetSettings.flightRadiusF;
            target.flightRadiusH(m) = targetSettings.flightRadiusH;
            target.flightOffset(m) = targetSettings.flightOffset;
            
            % Wingbeat Behaviour
            target.cycleF(m) = targetSettings.cycleF;
            target.flpSU(m) = targetSettings.flpSU;
            target.fRF(m) = targetSettings.fRF;
            target.fRH(m) = targetSettings.fRH;
            
            % Gliding
            target.clapGlide(m) =targetSettings.clapGlide;
            target.clapD(m) = targetSettings.clapD;
            target.clapF(m) = targetSettings.clapF;
            target.glideA(m) = targetSettings.glideA;
            target.glideCooldown(m) = targetSettings.glideCooldown;
            target.glideWB(m) = targetSettings.glideWB;
            target.decoupleWings(m) = targetSettings.decoupleWings;
        
            % Jitter Behaviour
            target.jitter(m) = targetSettings.jitter;
            target.FjF(m) = targetSettings.FjF;
            target.FjA(m) = targetSettings.FjA;
            target.GjF(m) = targetSettings.GjF;
            target.GjA(m) = targetSettings.GjA;
        
            % Hover
            target.hover(m) = targetSettings.hover;
            target.FhF(m) = targetSettings.FhF;
            target.FhA(m) = targetSettings.FhA;
        
            % Movement Pattern
            target.waveA(m) = targetSettings.waveA;
            target.waveF(m) = targetSettings.waveF;
            target.slowTurn(m) = targetSettings.slowTurn;
            target.angStep(m) = targetSettings.angStep;
            target.minTravel(m) = targetSettings.minTravel;
            target.maxTravel(m) = targetSettings.maxTravel;
            target.maxWalkTurn(m) = targetSettings.maxWalkTurn;
        
            % Movement Range
            target.xMin(m) = targetSettings.xMin;
            target.yMin(m) = targetSettings.yMin;
            target.xMax(m) = targetSettings.xMax;
            target.yMax(m) = targetSettings.yMax;
        
            target.endX(m) = targetSettings.endX;
            target.endY(m) = targetSettings.endY;
            target.endAngle(m) = targetSettings.endAngle;

            %Sound
            target.sound(m) = targetSettings.sound;


            %Boid
            target.boidVR(m) = targetSettings.boidVR ;  %grouping distance          
            target.boidSR(m) = targetSettings.boidSR;  %seperation radius relative to image size     
            target.boidCW(m) =   targetSettings.boidCW; %cohesionWeight  
            target.boidAW(m) = targetSettings.boidAW;   %alignmentWeight
            target.boidSW(m) = targetSettings.boidSW;  %seperationWeight
            target.boidDF(m) = targetSettings.boidDF;  %how much boids is dampened
            target.boidRwalk(m) = targetSettings.boidRwalk;  %how often the boids random walk instead of flock
            target.boidProb(m) = targetSettings.boidProb;  %how often the boids use boid rules

            target.overlap(m) =  targetSettings.overlap;
    

        end
end
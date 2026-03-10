%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Script
%....................

% NAME:  function for drawing, targets

% Function:

% This script obtains data from the path and the target type to draw it.

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

function f_draw_targets(game,target,window,nFrames,f,motionPaths)

%Calculations for flight game.drawMethod.
    if(game.drawMethod=="Image")

    
    %Draw Targets
        %...................................................................................
        for(m = 1:game.nTargets)  
                if(target.show(m))
    
    
            if(target.dead(m)==0) cf = nFrames-f; end
            if(target.dead(m)>0) cf = nFrames-target.dead(m); end
   

                targetBodyXPos = motionPaths{m,cf}(1);
                targetBodyYPos = motionPaths{m,cf}(2);
                moveAngle = motionPaths{m,cf}(3);

                moveToX = motionPaths{m,cf}(6);
                moveToY = motionPaths{m,cf}(7);
                z = motionPaths{m,cf}(8)+1;
                moveFromX = motionPaths{m,cf}(9);
                moveFromY = motionPaths{m,cf}(10);

                AngTravel =  moveAngle*180/pi - 90;

                if(game.startAlign==1)
                AngTravel=0;
                end
               
                %Draw Settings
                draw.body_X = floor(targetBodyXPos);
                draw.body_Y = floor(targetBodyYPos);
                draw.body_A = AngTravel;
                draw.body_S =  target.bodySize(m);
                draw.body_Tx = target.BodyTexture(m);

                if(target.dead(m)>0)
                 draw.body_Tx = target.BodyTexture(m);
                end
                
                if(abs(target.dead(m)-f)<game.screenFrameRate*game.deathDuration | target.dead(m)==0)
                                
                Screen('DrawTexture', window, draw.body_Tx, [], ...
                    [draw.body_X-draw.body_S, draw.body_Y-draw.body_S, ...
                    draw.body_X+draw.body_S, draw.body_Y+draw.body_S], ...
                    draw.body_A); 

                end


                if(game.revealDead)
                    if(target.dead(m)>0)
                     ringX=draw.body_X;
                     ringY= draw.body_Y;
                     ringSize = draw.body_S*1.5;
            
                    Screen('DrawTexture', window, game.ringTexture, [], ...
                    [ringX-ringSize, ringY-ringSize, ringX+ ringSize, ringY + ringSize], 0); % Tail 
                    end
    
                 end


                if(game.showMoveTo)
                dotColor = [0 1*(m/(game.nTargets)) 1*(game.nTargets/m)];
                dotPosition = [moveToX, moveToY];
                Screen('DrawDots', window, dotPosition, game.mouseSize*1.5, dotColor, [], 1);
                dotColor = [0 1*(m/(game.nTargets))/2 1*(game.nTargets/m)/2];
                dotPosition = [moveFromX, moveFromY];
                Screen('DrawDots', window, dotPosition, game.mouseSize*1.5, dotColor, [], 1);
                end


                    end
        end
    
    end % image






    if(game.drawMethod=="mothFlight" || game.drawMethod=="mothStatic")
    
    %Draw Targets
        %...................................................................................
        for(m = 1:game.nTargets)  
        if(target.show(m))
    
            if(target.dead(m)==0) cf = nFrames-f; end
            if(target.dead(m)>0) cf = nFrames-target.dead(m); end
   
                cycleF =  target.cycleF(m);
                flpSU = target.flpSU (m); 
  
                hindWingRadius=target.bodySize(m)*(target.flightRadiusH(m));
                foreWingRadius=target.bodySize(m)*(target.flightRadiusF(m));
    
                
                if f<nFrames
                targetBodyXPos = motionPaths{m,cf}(1);
                targetBodyYPos = motionPaths{m,cf}(2);
                moveAngle = motionPaths{m,cf}(3)+1*pi;
                moveDir = motionPaths{m,cf}(4)+1*pi;
                moveDestA = motionPaths{m,cf}(5)+1*pi;
                moveToX = motionPaths{m,cf}(6);
                moveToY = motionPaths{m,cf}(7);
                glide = motionPaths{m,cf}(8);
                moveFromX = motionPaths{m,cf}(9);
                moveFromY = motionPaths{m,cf}(10);
                end
    
               %Wing game.drawMethods 
                angV=sin((f/cycleF+0.0)*pi*1);
                if(angV<0) angV=angV*2.5; end
    
                if(glide)
                wv=sin((f/target.glideWB(m))*pi*1);
                 angV=sin((f/target.glideWB(m)+0.0)*pi*1);
                else
                wv=sin((f/cycleF*pi*1)+pi*0.15);
                end
    
     
               %Make upstroke and downstroke asymetric
                if(wv>=0) sV=abs(wv)^2; end
                if(wv<0) sV=(abs(wv)^6)*0.6; end
        
                dsT=0.5;
                if(wv<dsT)
                    upDown=0;end %DownStroke
                if(wv>=dsT)
                    upDown=1;end %Upstroke
    
                sH=0-(wv)/5; 
                sV=sV*1;
    
                  %Glide Behaviour
                if(glide && target.dead(m)==0)
                    sV=(0*(1-target.glideA(m))+0.35*(target.glideA(m)))+(0*(target.glideA(m))+sV*(1-target.glideA(m)));
                    sH=(0*(1-target.glideA(m))-0.1*(target.glideA(m)))+(0*(target.glideA(m))+sH*(1-target.glideA(m)));
                    angV=0*(target.glideA(m))+angV*(1-target.glideA(m));
                end
    
    
    
                  sVR=sV;
                  sVL=sV;
                  sHR=sH;
                  sHL=sH;
    
    
                    angleDiff = atan2(sin(moveDestA - moveAngle), cos(moveDestA - moveAngle)); % Shortest angle difference
            
    
                    if(target.decoupleWings(m)) % Complex turns
    
                        aF=((abs(angleDiff) / pi /2))^0.3;
    
    
                    if angleDiff < 0
                        sVR=sVR*(1-aF/2)+aF*0.7;
                        sVL=sVL*(1-aF/2)+aF*0.2;
    
                        sHR=sHR*(1-aF/2)-(aF*0.7)/3; 
                        sHL=sHL*(1-aF/2)-(aF*0.2)/3; 
                    end
    
                   if angleDiff > 0
                        sVR=sVR*(1-aF/2)+aF*0.2;
                        sVL=sVL*(1-aF/2)+aF*0.7;
    
                        sHR=sHR*(1-aF/2)-(aF*0.2)/3; 
                        sHL=sHL*(1-aF/2)-(aF*0.7)/3; 
                    end
                    end
            
    
    
    
                  sFLA=0;
                  sFRA=0;
                  sHLA=0;
                  sHRA=0;
    
                 if(sVL>0.99) 
                     sVL=0.99; 
                 end
                  if(sVR>0.99) 
                     sVR=0.99; 
                 end
    
                 if(sHL>0.99) 
                     sHL=0.99; 
                 end
                  if(sHR>0.99) 
                     sHR=0.99; 
                 end
    
      
    
            
                if(target.dead(m)>0) % No wing beats when dead
                angV=sin((cf/cycleF+0.0)*pi*1)*4;
                angV=angV+sin((f/cycleF+0.0)*pi*1)/5*game.deathJitter;
                wv=0;
                CG=0;
                sV=0;
                sH=0;
                end
       
    
    
                %Target Orientations
                AngTravel =  moveAngle*180/pi+90;


            
                if(game.Turning==0)
                AngTravel=0;
                end
    
                %Dead Body Jitter
                  if(target.dead(m)>0)
                  AngTravel=AngTravel+rand*5*game.deathJitter;
    
                  targetBodyXPos =targetBodyXPos+rand*0.5*game.deathJitter;
                  targetBodyYPos =targetBodyYPos+rand*0.5*game.deathJitter;
    
                  end
            
            
                HindWingPivotX = targetBodyXPos+cos((AngTravel+90)/180*pi)* -hindWingRadius;
                HindWingPivotY = targetBodyYPos+sin((AngTravel+90)/180*pi)*- hindWingRadius;
            
                ForeWingPivotX = targetBodyXPos+cos((AngTravel+90)/180*pi)*- foreWingRadius;
                ForeWingPivotY = targetBodyYPos+sin((AngTravel+90)/180*pi)*- foreWingRadius;
            
                
            
    
    
                %Target Wing Orientation
                HindWingAngle = target.flightAngh(m) + -angV*target.fRH(m);
                ForeWingAngle = target.flightAngf(m) + -angV*target.fRF(m)*1.2;

                if(game.drawMethod=="mothStatic")

                HindWingAngle = target.foldAngh(m);
                ForeWingAngle =  target.foldAngf(m);

                hindWingRadius=target.bodySize(m)*(target.foldRadiusH(m));
                foreWingRadius=target.bodySize(m)*(target.foldRadiusF(m));
            
                HindWingPivotX = targetBodyXPos+cos((AngTravel+90)/180*pi)* -hindWingRadius;
                HindWingPivotY = targetBodyYPos+sin((AngTravel+90)/180*pi)*- hindWingRadius;
            
                ForeWingPivotX = targetBodyXPos+cos((AngTravel+90)/180*pi)*- foreWingRadius;
                ForeWingPivotY = targetBodyYPos+sin((AngTravel+90)/180*pi)*- foreWingRadius;
        
                sVR=0;
                sVL=0;
                sHR=0;
                sHL=0;
        
                sFRA=0;
                sFLA=0;
                sHRA=0;
                sHLA=0;
                upDown=1;

                offset = target.foldOffset(m);
                else
                offset = target.flightOffset(m);

                end
    
    
    
    
                %Dead Wing Jitter
                if(target.dead(m)>0)
                sVR=sV+0.1;
                sVL=sV+0.1;
                  sFLA=+15;
                  sFRA=0;
                  sHLA=-6;
                  sHRA=-30;
                sHR=sH+0.1;
                sHL=sH+0.1;
                HindWingAngle=HindWingAngle+rand*10*game.deathJitter;
                ForeWingAngle=ForeWingAngle+rand*10*game.deathJitter;
                upDown=0;
                end
            
    
                 if(abs(target.dead(m)-f)<game.screenFrameRate*game.deathDuration | target.dead(m)==0) % Remove Target if dead for more then 1.25 seconds
    
                %Draw Settings
                    draw.body_X = targetBodyXPos;
                    draw.body_Y = targetBodyYPos;
                    draw.body_A = AngTravel;
                    draw.body_S = target.bodySize(m);
                    draw.body_Tx = target.BodyTexture(m);
                    
                    draw.tail_X = targetBodyXPos;
                    draw.tail_Y = targetBodyYPos;
                    draw.tail_A = AngTravel;
                    draw.tail_S = target.tailSize(m);
                    draw.tail_Tx = target.TailTexture(m);
                    draw.tail_U = upDown;
                    
                    draw.foreW_R_X = ForeWingPivotX+cos((AngTravel)/180*pi)*target.bodySize(m)*offset;
                    draw.foreW_R_Y = ForeWingPivotY+sin((AngTravel)/180*pi)*target.bodySize(m)*offset;
                    draw.foreW_R_A = AngTravel+ForeWingAngle+sFRA;
                    draw.foreW_R_S = target.foreWingSize(m);
                    draw.foreW_R_V = sVR*flpSU;
                    draw.foreW_R_H = sHR*flpSU;
                    draw.foreW_R_Tx = target.ForeWingTextureR(m);
    
                    draw.foreW_L_X = ForeWingPivotX-cos((AngTravel)/180*pi)*target.bodySize(m)*offset;
                    draw.foreW_L_Y = ForeWingPivotY-sin((AngTravel)/180*pi)*target.bodySize(m)*offset;
                    draw.foreW_L_A = AngTravel-ForeWingAngle+sFLA;
                    draw.foreW_L_S = target.foreWingSize(m);
                    draw.foreW_L_V = sVL*flpSU;
                    draw.foreW_L_H = sHL*flpSU;
                    draw.foreW_L_Tx = target.ForeWingTextureL(m);
                   
                    draw.hindW_R_X = HindWingPivotX+cos((AngTravel)/180*pi)*target.bodySize(m)*offset;
                    draw.hindW_R_Y = HindWingPivotY+sin((AngTravel)/180*pi)*target.bodySize(m)*offset;
                    draw.hindW_R_A = AngTravel+HindWingAngle+sHRA;
                    draw.hindW_R_S = target.hindWingSize(m);
                    draw.hindW_R_V = sVR*flpSU;
                    draw.hindW_R_H = sHR*flpSU;
                    draw.hindW_R_Tx = target.HindWingTextureR(m);
    
                    draw.hindW_L_X = HindWingPivotX-cos((AngTravel)/180*pi)*target.bodySize(m)*offset;
                    draw.hindW_L_Y = HindWingPivotY-sin((AngTravel)/180*pi)*target.bodySize(m)*offset;
                    draw.hindW_L_A = AngTravel-HindWingAngle+sHLA;
                    draw.hindW_L_S = target.hindWingSize(m);
                    draw.hindW_L_V = sVL*flpSU;
                    draw.hindW_L_H = sHL*flpSU;
                    draw.hindW_L_Tx = target.HindWingTextureL(m);
                    
                if(game.platform)
                     platformX=draw.body_X;
                     platformY= draw.body_Y;
                     platformSize = draw.body_S*4;
            
                    Screen('DrawTexture', window, game.platformTexture, [], ...
                    [platformX-platformSize, platformY-platformSize, platformX+ platformSize, platformY + platformSize], 0); % Tail 
                 end
        
                    f_animate_moth2D(draw,window); %Draw Target

                if(game.revealDead)
                    if(target.dead(m)>0)
                     ringX=draw.body_X;
                     ringY= draw.body_Y;
                     ringSize = draw.body_S*4;
            
                    Screen('DrawTexture', window, game.ringTexture, [], ...
                    [ringX-ringSize, ringY-ringSize, ringX+ ringSize, ringY + ringSize], 0); % Tail 
                    end
    
                 end
    

                if(game.showMoveTo)
                dotColor = [0 1*(m/(game.nTargets)) 1*(game.nTargets/m)];
                dotPosition = [moveToX, moveToY];
                Screen('DrawDots', window, dotPosition, game.mouseSize*1.5, dotColor, [], 1);
                dotColor = [0 1*(m/(game.nTargets))/2 1*(game.nTargets/m)/2];
                dotPosition = [moveFromX, moveFromY];
                Screen('DrawDots', window, dotPosition, game.mouseSize*1.5, dotColor, [], 1);
                end

        end
        end
    end % Flight

    end




    %Calculations for flight game.drawMethod.
    if(game.drawMethod=="moth3D") %outdated method, see cycles for new version
    
    %Draw Targets
        %...................................................................................
        for(m = 1:game.nTargets)  
                    if(target.show(m))
    
    
            if(target.dead(m)==0) cf = nFrames-f; end
            if(target.dead(m)>0) cf = nFrames-target.dead(m); end
    
    

                targetBodyXPos = motionPaths{m,cf}(1);
                targetBodyYPos = motionPaths{m,cf}(2);
                moveAngle = motionPaths{m,cf}(3);

                moveToX = motionPaths{m,cf}(6);
                moveToY = motionPaths{m,cf}(7);
                z = motionPaths{m,cf}(8)+1;
                moveFromX = motionPaths{m,cf}(9);
                moveFromY = motionPaths{m,cf}(10);

                AngTravel =  moveAngle*180/pi - 90;


                if(game.startAlign==1)
                AngTravel=0;
                end


                % Parameters
                animationLength = target.animationLength(m,z);  % Total number of frames in the animation
                frequency = target.cycleF(m);            % Wing beat frequency              % 


                x=cos((f/animationLength)*2*pi);
                y=sin((f/animationLength)*2*pi);
                v=atan2(y,x);


                % Map sine wave to frame index
                k = round(1+ (0.5 + ( v/pi/2 )) * (animationLength - 1));  % Map sine wave to a valid frame index

                %Draw Settings
                draw.body_X = targetBodyXPos;
                draw.body_Y = targetBodyYPos;
                draw.body_A = AngTravel;
                draw.body_S = target.animationSize(m);
                draw.body_Tx = target.Animation(m,z,k);

                if(target.dead(m)>0)
                draw.body_Tx = target.Animation(m,z,1);
                end
                
                if(abs(target.dead(m)-f)<game.screenFrameRate*game.deathDuration | target.dead(m)==0)
                                
                Screen('DrawTexture', window, draw.body_Tx, [], ...
                    [draw.body_X-draw.body_S, draw.body_Y-draw.body_S, ...
                    draw.body_X+draw.body_S, draw.body_Y+draw.body_S], ...
                    draw.body_A); 

                end


                if(game.revealDead)
                    if(target.dead(m)>0)
                     ringX=draw.body_X;
                     ringY= draw.body_Y;
                     ringSize = draw.body_S*1.5;
            
                    Screen('DrawTexture', window, game.ringTexture, [], ...
                    [ringX-ringSize, ringY-ringSize, ringX+ ringSize, ringY + ringSize], 0); % Tail 
                    end
    
                 end


                if(game.showMoveTo)
                dotColor = [0 1*(m/(game.nTargets)) 1*(game.nTargets/m)];
                dotPosition = [moveToX, moveToY];
                Screen('DrawDots', window, dotPosition, game.mouseSize*1.5, dotColor, [], 1);
                dotColor = [0 1*(m/(game.nTargets))/2 1*(game.nTargets/m)/2];
                dotPosition = [moveFromX, moveFromY];
                Screen('DrawDots', window, dotPosition, game.mouseSize*1.5, dotColor, [], 1);
                end


                    end
        end
    
    end % Gif




%Calculations for flight game.drawMethod.
    if(game.drawMethod=="Cycles")

    
    %Draw Targets
        %...................................................................................
        for(m = 1:game.nTargets)  
                    if(target.show(m))
    
    
            if(target.dead(m)==0) cf = nFrames-f; end
            if(target.dead(m)>0) cf = nFrames-target.dead(m); end
   

                targetBodyXPos = motionPaths{m,cf}(1);
                targetBodyYPos = motionPaths{m,cf}(2);
                moveAngle = motionPaths{m,cf}(3);

                moveToX = motionPaths{m,cf}(6);
                moveToY = motionPaths{m,cf}(7);
                z = motionPaths{m,cf}(8)+1;
                moveFromX = motionPaths{m,cf}(9);
                moveFromY = motionPaths{m,cf}(10);

                AngTravel =  moveAngle*180/pi - 90;


                if(game.startAlign==1)
                AngTravel=0;
                end


                % Parameters
                animationLength = target.animationLength(m,z);  % Total number of frames in the animation
                frequency = target.cycleF(m); % Wing beat frequency              % 


                k = motionPaths{m,cf}(11);
    
                
                %Draw Settings
                draw.body_X = targetBodyXPos;
                draw.body_Y = targetBodyYPos;
                draw.body_A = AngTravel;
                draw.body_S = target.animationSize(m);
                draw.body_Tx = target.Animation(m,z,k);

                if(target.dead(m)>0)
                draw.body_Tx = target.Animation(m,z,1);
                end
                
                if(abs(target.dead(m)-f)<game.screenFrameRate*game.deathDuration | target.dead(m)==0)
                                
                Screen('DrawTexture', window, draw.body_Tx, [], ...
                    [draw.body_X-draw.body_S, draw.body_Y-draw.body_S, ...
                    draw.body_X+draw.body_S, draw.body_Y+draw.body_S], ...
                    draw.body_A); 

                end


                if(game.revealDead)
                    if(target.dead(m)>0)
                     ringX=draw.body_X;
                     ringY= draw.body_Y;
                     ringSize = draw.body_S*1.5;
            
                    Screen('DrawTexture', window, game.ringTexture, [], ...
                    [ringX-ringSize, ringY-ringSize, ringX+ ringSize, ringY + ringSize], 0); % Tail 
                    end
    
                 end


                if(game.showMoveTo)
                dotColor = [0 1*(m/(game.nTargets)) 1*(game.nTargets/m)];
                dotPosition = [moveToX, moveToY];
                Screen('DrawDots', window, dotPosition, game.mouseSize*1.5, dotColor, [], 1);
                dotColor = [0 1*(m/(game.nTargets))/2 1*(game.nTargets/m)/2];
                dotPosition = [moveFromX, moveFromY];
                Screen('DrawDots', window, dotPosition, game.mouseSize*1.5, dotColor, [], 1);
                end


                    end
        end
    
    end % cycles




end

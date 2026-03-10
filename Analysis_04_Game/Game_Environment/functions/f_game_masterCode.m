
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Script
%....................

% NAME:  function for game, master code
% Function:

% This script is the main script used to run the game.
% It will output the click data and results.
% It requires game settings, motion paths, target settings and window info
% in order for it to work.

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


function  [clicks, results, game, target,hitboxImage,hitImage] = f_game_masterCode(game,motionPaths,target,window,offscreenWindow,windowRect,waitScreenColor)
rng("shuffle");
results = struct(); 
game.recordData=1;

    %% Game Behaviour

     %% Backgrounds

     %This section encodes how the background will appear

    soundPathH = fullfile(game.folderPath,'Sounds', 'hitSound.wav');
    soundPathM = fullfile(game.folderPath,'Sounds',  'missSound.wav');

    disp(soundPathH);
    [yH, FsH] = audioread(soundPathH);
    [yM, FsM] = audioread(soundPathM);

    %% Setup Window

    [xCenter, yCenter] = RectCenter(windowRect);

    % Load Extra Images



    avgTime=NaN;
    totalTime=0;
         nMiss=0;

    % Get the current date and time as a datetime object
    currentDateTime = datetime('now');
    
    % Convert datetime object to date string
    currentDate = datestr(currentDateTime, 'yyyy-mm-dd');
    
    % Extract the time component as a string
    currentTime2 = datestr(currentDateTime, 'HH:MM:SS');


    %Mouse and Touch Screen Conditions
    if(game.touchE==1)
    TouchQueueCreate(window, game.touchDev);
    TouchQueueStart(game.touchDev);
    %SetMouse(0, 0, game.screenNumber2);
    HideCursor(window); HideCursor;
    end
    if(game.showMouse)  HideCursor(window); HideCursor; end

    nFrames = ceil(game.timeLimit*game.screenFrameRate);


    % Target States
    %..............................
    for(m = 1:game.nTargets)
    
    target.dead(m) = 0;
    
    end



    % Set Margin Size
    %..............................

    margin=windowRect(4)*0;  



if(game.rampFrames)
f_screen_ramp(window,waitScreenColor);
end




disp("..........................................................");
disp('The game should now be running:');
disp('____________________________________');

disp('  Press the SPACE key to trigger a global hit');
disp('          If there are multiple targets you will be asked to confirm');
disp("");
disp('  Press the 1 key to hit target 1');
disp('  Press the 2 key to hit target 2');
disp("");
disp('  Left arrow to hit the left most target');
disp('  Right arrow to hit the right most target');
disp("");

disp("");
disp('  Press the escape key to exit');

disp("..........................................................");



deathTime=0;
game.nClicks = 0;
nHits = 0;
clicks.x(1) = "NaN";
clicks.y(1) = "NaN";
clicks.time(1) = "NaN";
clicks.frame(1) = "NaN";
clicks.hit(1) = "NaN";
clicks.target(1) = "NaN";

for m = 1:game.nTargets
target.hit(m)=0;
target.hitMethod(m) = "NaN";
target.hitTime(m)="NaN";
target.hitFrame(m)="NaN";
target.hitX(m)="NaN";
target.hitY(m)="NaN";
target.hitOrder(m)="NaN";
target.firstHit(m)=0;
target.hitType = "NaN";
target.clickX(m)="NaN";
target.clickY(m)="NaN";
target.clickD(m)="NaN";
target.clicks(m)="NaN";
target.clickN(m)=0;
target.hitN(m)=0;
target.startX(m)=motionPaths{m,nFrames}(1);
target.startY(m)=motionPaths{m,nFrames}(2);
target.show(m)=1;
target.giveUp(m)=0;

if(target.startX(m)>game.windowSize(3)/2)
target.startSide(m)="right";
else
target.startSide(m)="left";
end

hitImage = "NaN";
hitboxImage =  "NaN";

end

order=1;

    keepPlaying = true;
    f=0;
    emergencyTime=0;
    
    tic
    game.touchT=toc;
    [xClickI, yClickI] = GetMouse(window);
    b=1;
    o=1;

    %Start Game Loop
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    while keepPlaying == true

    %if(game.useTouch) SetMouse(0, 0, game.screenNumber2); end


    %DRAW SCREEN
    %...................................................................................
    f_game_drawGame(game, target, window,windowRect, nFrames, f, motionPaths);

    %Draw Dot
    %...................................................................................
    [xMouse, yMouse, ~] = GetMouse(window);
    dotPosition = [xMouse,yMouse];

    if(game.showMouse)
    Screen('DrawDots', window, dotPosition, game.mouseSize, game.mouseColor, [], 1);
    end


    %Target Click
    %...................................................................................
     hit=0; 

    
        if(game.allowHit)

        [~, ~, buttons] = GetMouse(window);
        

            game.touch=0;
            if(game.touchE==1) 
            game = f_input_touch(game,window);
            end
           
            if(game.touchE & game.touch)
            xMouse = game.blobcol.x{1};
            yMouse = game.blobcol.y{1};
            end

            
            %Movement Detection
            game.move=0;
            if(game.useDrag)
            game.move=1; 
            end
                    
            buttons=any(buttons);


            

            if (buttons || game.touch || game.move)

               

            if( min(target.dead)==0)

                
                if(toc > (game.touchT + game.touchD) ) %Min click delay
                game.touchT=toc;
                
                [xClick, yClick] = GetMouse(window);

                if(game.touchE & game.touch)
                else
                game.blobcol={};
                blobcol.x{1}=xMouse;
                blobcol.y{1}=yMouse;
                end

                if(game.touch==0)
                game.blobcol={};
                game.blobcol.x{1}=xMouse;
                game.blobcol.y{1}=yMouse;
                end


                game.touchT=toc;
                
                clicksStr =   strcat(num2str(xClick), ';',num2str(yClick), ";",num2str(toc), ";",num2str(f));
                if(game.nClicks ==  0) clicksS = clicksStr;
                else
                clicksS = sprintf('%s:%s',clicksS,clicksStr);
                end
    
                game.nClicks = game.nClicks+1;
                clicks.x(game.nClicks) = xClick;
                clicks.y(game.nClicks) = yClick;
                clicks.time(game.nClicks) = toc;
                clicks.frame(game.nClicks) = f;
                clicks.hit(game.nClicks) = 0;
                clicks.target(game.nClicks) = 0;
                
                for(b=1:length(game.blobcol.x))
                xClick= game.blobcol.x{b};
                yClick= game.blobcol.y{b};

              
                    for(m = 1:game.nTargets)
                    if(keepPlaying)
                        targetBodyXPos = motionPaths{m,nFrames-f}(1);
                        targetBodyYPos = motionPaths{m,nFrames-f}(2);
                        targetBodyAngle = motionPaths{m,nFrames-f}(3)*180/pi - 90;
                
                        dx = xClick - (targetBodyXPos);
                        dy = yClick - (targetBodyYPos);




                    if(abs(dx)<target.bodySize(m)*game.expandHitR && abs(dy)<target.bodySize(m)*game.expandHitR)


                        value=0;
                        if(game.useHitbox)
                        Screen('FillRect', offscreenWindow,  [0,0,0]);
                        Screen('DrawTexture', offscreenWindow, target.hitboxTexture(m), [], ...
                        [targetBodyXPos- target.hitboxSize(m), targetBodyYPos- target.hitboxSize(m), ...
                        targetBodyXPos+ target.hitboxSize(m), targetBodyYPos+ target.hitboxSize(m)], ...
                         targetBodyAngle); 

                        if(game.showHitbox==2) Screen('CopyWindow', offscreenWindow, window);  end
                        offscreenImage = Screen('GetImage', offscreenWindow);
                        grayImage = rgb2gray(offscreenImage); 
                        binaryMask = grayImage > 30;  % Convert to binary (white pixels -> 1, black -> 0)
                        se = strel('disk', game.expandHitbox);  % Create a circular structuring element with a radius of 10 pixels
                        expandedMask = imdilate(binaryMask, se);  % Dilate the binary mask

                        if xClick >= 1 && xClick <= size(expandedMask, 2) && yClick >= 1 && yClick <= size(expandedMask, 1)
                            value = expandedMask(yClick, xClick); % Get binary value at (x, y)
                            if(value)
                               if(game.showHitDot) Screen('DrawDots', window, [xClick,yClick], game.mouseSize, [0,255,0], [], 1); end
                            else
                               if(game.showHitDot) Screen('DrawDots', window, [xClick,yClick], game.mouseSize, [255,255,0], [], 1); end
                            end
                        else
                              if(game.showHitDot)  Screen('DrawDots', window, [xClick,yClick], game.mouseSize, game.mouseColor, [], 1); end

                        end
                
                        else

                        value=1;
                        end
						
						value=target.allowHit(m);

                        if(value)
                        
                        if(game.showHitbox) 
                            Screen('CopyWindow', offscreenWindow, window); 
                            if(game.showHitDot) 
                               if(game.useTouch) 
                                   Screen('DrawDots', window, [xClick,yClick], game.mouseSize*3, [0,255,0], [], 1);
                               else
                                    Screen('DrawDots', window, [xClick,yClick], game.mouseSize*1, [0,255,0], [], 1);
                               end
                            end
                        end

                        if(target.dead(m)<1)
                            if( game.killableTargets==0) keepPlaying=false; end
                            if( game.killableTargets==1) target.dead(m)=f; end

                        % Play_Sound if enabled
                             if(game.useSoundHit && target.sound(m)) sound(yH, FsH); end
                        
                        hit=1;
                        disp("......................");
                        disp("Clicked Target")
                        disp("TargetN=");
                        disp(m);
                        disp(game.touchT);
                        disp([target.Info(m),"!!!!"]);
                        disp([target.Info(m),"!!!!"]);
                        disp([target.Info(m),"!!!!"]);
                        disp("......................");

                        nHits = nHits + 1;
                        target.hit(m)=1;
                        target.hitMethod(m)="Click";
                        target.hitTime(m)=game.touchT;
                        target.hitFrame(m)=f;
                        target.hitX(m)=targetBodyXPos;
                        target.hitY(m)=targetBodyYPos;
                        target.hitOrder(m)=order;
                        if(nHits==1) target.firstHit(m)=1; end
                        target.hitType = "Click";
                        target.clickX(m)=xClick;
                        target.clickY(m)=yClick;
                        target.clickD(m)=(dx^2+dy^2)^0.5;
                        target.clicks(m) = clicksS;
                        target.clickN(m)=game.nClicks;
                        clicks.hit(game.nClicks) = 1;
                        clicks.target(game.nClicks) = m;
                        order=order+1;


                        end
                    end     
                    end
                    end 
                    end
                    end%blobs

                        
                    if(hit == 0)
                         if(game.useSoundMiss) sound(yM, FsM); end
                         if(game.useMiss>0 && nMiss>=game.useMiss) keepPlaying=false; end
                         nMiss=nMiss+1;
                         %disp(nMiss);
                         %disp(keepPlaying);
                    end

                            
    
    
                end
            end

            

                 
                if(buttons || game.touch)  
                   if(~game.useDrag) game.touchT = toc; end
                end
                buttons=0;

            end

            
        end
    




    %Short pause if death is enabled
    %#################################        
    if(game.killableTargets==1)
        minValue = min(target.dead);
        if(game.multiKill==0) minValue=max(target.dead); end
        if(minValue>0 & deathTime==0) deathTime=f; end
        if(abs(deathTime-f)>game.screenFrameRate*game.deathDuration && minValue>0)  keepPlaying = false;  end
    end
        


    %Escape
    %...................................................................................
    
     [~, ~, keyCode] = KbCheck;


     % EMERGENCY KILL ALL
    if keyCode(KbName('Space'))
        if( game.killableTargets==0) keepPlaying = false;end
        emergencyTime=toc;
        emergencyFrame=f;

        
        if( game.killableTargets==1)
        for(m = 1:game.nTargets)
          target.dead(m)=f;
        end
        end
        
    end

     % EMERGENCY KILL 1
    if keyCode(KbName('1!'))
        if( game.killableTargets==0) keepPlaying = false;end

        m=1;
         if(target.hit(m)==0)
        if(game.useSoundHit && target.sound(m)) sound(yH, FsH); end

        nHits = nHits + 1;
        targetBodyXPos = motionPaths{m,nFrames-f}(1);
        targetBodyYPos = motionPaths{m,nFrames-f}(2);
        target.hit(m)=1;
        target.hitMethod(m)="Press_1";
        target.hitTime(m)=toc;
        target.hitFrame(m)=f;
        target.hitX(m)=targetBodyXPos;
        target.hitY(m)=targetBodyYPos;
        target.hitOrder(m)=order;
         if(nHits==1) target.firstHit(m)=1; end
        target.hitType = "Keyboard";
        target.clickX(m)="NaN";
        target.clickY(m)="NaN";
        target.clickD(m)="NaN";
        target.clickN(m)=game.nClicks;
         
        
        order=order+1;
        target.dead(m)=f;

        disp("......................");
        disp("Clicked Target")
        disp("TargetN=");
        disp(m);
        disp(toc);
        disp([target.Info(m),"!!!!"]);
        disp([target.Info(m),"!!!!"]);
        disp([target.Info(m),"!!!!"]);
        disp("......................");
         end
    end

     % EMERGENCY KILL 2
    if keyCode(KbName('2@'))
        if( game.killableTargets==0) keepPlaying = false;end

        if(game.nTargets==1)
            m=1; 
        end
          if(game.nTargets==2)
            m=2; 
        end

         if(target.hit(m)==0)
        if(game.useSoundHit && target.sound(m)) sound(yH, FsH); end
        nHits = nHits + 1;
        targetBodyXPos = motionPaths{m,nFrames-f}(1);
        targetBodyYPos = motionPaths{m,nFrames-f}(2);
        target.hit(m)=1;
        target.hitMethod(m)="Press_2";
        target.hitTime(m)=toc;
        target.hitFrame(m)=f;
        target.hitX(m)=targetBodyXPos;
        target.hitY(m)=targetBodyYPos;
        target.hitOrder(m)=order;
         if(nHits==1) target.firstHit(m)=1; end
        target.hitType = "Keyboard";
        target.clickX(m)="NaN";
        target.clickY(m)="NaN";
        target.clickD(m)="NaN";
        target.clickN(m)=game.nClicks;
        
        
        order=order+1;
        target.dead(m)=f;
      

        disp("......................");
        disp("Clicked Target")
        disp("TargetN=");
        disp(m);
        disp(toc);
        disp([target.Info(m),"!!!!"]);
        disp([target.Info(m),"!!!!"]);
        disp([target.Info(m),"!!!!"]);
        disp("......................");

    end
    end

    % EMERGENCY KILL LEFT
       if keyCode(KbName('LeftArrow'))
        if( game.killableTargets==0) keepPlaying = false;end

        idx = -1;
        mn = 9999999;
           for(m = 1:game.nTargets)
            targetBodyXPos = motionPaths{m,nFrames-f}(1);
            if(targetBodyXPos<mn)
                mn=targetBodyXPos
                idx=m;
            end

           end
        m=idx;

         if(target.hit(m)==0)
        if(game.useSoundHit && target.sound(m)) sound(yH, FsH); end
        targetBodyXPos = motionPaths{m,nFrames-f}(1);
        targetBodyYPos = motionPaths{m,nFrames-f}(2);
        nHits = nHits + 1;
        target.hit(m)=1;
        target.hitMethod(m)="Press_Left";
        target.hitTime(m)=toc;
        target.hitFrame(m)=f;
        target.hitX(m)=targetBodyXPos;
        target.hitY(m)=targetBodyYPos;
        target.hitOrder(m)=order;
         if(nHits==1) target.firstHit(m)=1; end
        target.hitType = "Keyboard";
        target.clickX(m)="NaN";
        target.clickY(m)="NaN";
        target.clickD(m)="NaN";
        target.clickN(m)=game.nClicks;
        
        
        order=order+1;
        target.dead(m)=f;
      

        disp("......................");
        disp("Clicked Target")
        disp(["Target_Number =", num2str(m)]);
        disp(["Target_Hit_Time =", num2str(toc)]);
        disp(["Target_Texture =", target.TargetD(m)]);
        disp([target.Info(m),"!!!!"]);
        disp([target.Info(m),"!!!!"]);
        disp([target.Info(m),"!!!!"]);
        disp("......................");
         end
    end

% EMERGENCY KILL RIGHT
       if keyCode(KbName('RightArrow'))
        if( game.killableTargets==0) keepPlaying = false;end


        idx = -1;
        mx = -999999;
           for(m = 1:game.nTargets)
            targetBodyXPos = motionPaths{m,nFrames-f}(1);
            if(targetBodyXPos>mx)
                mx=targetBodyXPos
                idx=m;
            end

           end
        m=idx;
        if(target.hit(m)==0)
        if(game.useSoundHit && target.sound(m)) sound(yH, FsH); end
        nHits = nHits + 1;
        targetBodyXPos = motionPaths{m,nFrames-f}(1);
        targetBodyYPos = motionPaths{m,nFrames-f}(2);
        target.hit(m)=1;
        target.hitMethod(m)="Press_Right";
        target.hitTime(m)=toc;
        target.hitFrame(m)=f;
        target.hitX(m)=targetBodyXPos;
        target.hitY(m)=targetBodyYPos;
        target.hitOrder(m)=order;
         if(nHits==1) target.firstHit(m)=1; end
        target.hitType = "Keyboard";
        target.clickX(m)="NaN";
        target.clickY(m)="NaN";
        target.clickD(m)="NaN";
        target.clickN(m)=game.nClicks;
        

        order=order+1;
        target.dead(m)=f;
      

        disp("......................");
        disp("Clicked Target")
        disp("TargetN=");
        disp(m);
        disp(toc);
        disp([target.Info(m),"!!!!"]);
        disp([target.Info(m),"!!!!"]);
        disp([target.Info(m),"!!!!"]);
        disp("......................");
        end
    end
    % Check for the 'Escape' key to end the script
    if keyCode(KbName('Escape'))
        keepPlaying = false;

        if(game.touchE==1) 
        TouchQueueStop(game.touchDev);
        TouchEventFlush(game.touchDev);
        end
        game.recordData=0
        sca;

        
        return

    end


        % Check for the 'Escape' key to end the script
    if keyCode(KbName('Return'))
        keepPlaying = false;
        if(game.touchE==1) 
        TouchQueueStop(game.touchDev);
        TouchEventFlush(game.touchDev);
        end

        Screen('FillRect', window, waitScreenColor);
        Screen('Flip', window);
        game.recordData=0;
        return

    end



    if keyCode(KbName('f'))
        keepPlaying = false;

        for(m=1:game.nTargets)

        target.giveUp(m)=1;

        end

        if(game.touchE==1) 
        TouchQueueStop(game.touchDev);
        TouchEventFlush(game.touchDev);
        end

    end



    if(f>=nFrames-1)
        keepPlaying=false;
    end


    game.vbl = Screen('Flip', window, game.vbl + (game.waitFrames - 0.5) * game.ifi);

    %Screen('Flip', window);

    if(game.recordMode)
    % Capture the frame
    imageArray = Screen('GetImage', window, windowRect);  % Capture the current screen image
    
    % Write the captured frame to the video
    writeVideo(writerObj, imageArray);
    end




    f=f+1; 
    end % End of game loop
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    %


displayFrameRate = f/toc;

disp("Frame Rate =");
disp(displayFrameRate);
disp(toc);
endTime = toc;
endFrame = f;

img = Screen('GetImage', window, windowRect);  % Capture the current screen image
imgTexture = Screen('MakeTexture', window, img);





if(game.revealFail & nHits<game.nTargets)
    for(m=1:game.nTargets)
        target.dead(m) = f-2;
    end
     f_game_drawGame(game, target, window,windowRect, nFrames, f-1, motionPaths);
    Screen('Flip', window);

    if(nHits<game.nTargets)
    if(game.useSoundMiss) sound(yM, FsM); end
    end
   
    pause(game.deathDuration);
    
end

if(game.showHitbox | game.showHitDot) pause(5); end



HideCursor;

function closeFigure(src, event)
disp(['Key pressed: ', event.Key]);  % Display which key was pressed
close(src);  % Close the figure window
end


if(emergencyTime>0)

    disp("EMERGENCY TIME!!!!!!!!!!!!")

    if(game.nTargets==1)

    m=1;

    else

            
            ShowCursor;
            
           %if(game.touchE==1) SetMouse(0, 0, game.screenNumber2); end
            
            
            colours ={"Red","Cyan"};
            R = {0,0.6};
            G = {0.6,0};
            B = {0.6,0};
            
            
            disp("Type '1' for CYAN, or '2' for RED");
              Screen('DrawTexture', window, imgTexture, [], windowRect);
               for(m = 1:game.nTargets)
               r=R{m};
               g=G{m};
               b=B{m};
                dotColor = [r g b];
                dotPosition = [ motionPaths{m,nFrames-emergencyFrame}(1), motionPaths{m,nFrames-emergencyFrame}(2)];
            
                Screen('DrawDots', window, dotPosition, game.mouseSize, dotColor, [], 1);
            
               end
            
            
            Screen('Flip', window);
            
            img = Screen('GetImage', window, windowRect);  % Capture the current screen image


            imgTexture = Screen('MakeTexture', window, img);
            
            
            % Get monitor positions (each row represents a monitor: [left, bottom, width, height])
            monitorPositions = get(0, 'MonitorPositions');
            
            % Choose the second monitor (assuming you have at least two monitors)
            secondMonitor = monitorPositions(1, :);
            % Calculate the position to center the image on the second monitor
            imageSize = size(img);  % Get image dimensions [height, width, channels]
            figureWidth = imageSize(2);
            figureHeight = imageSize(1);
            
            % Calculate the top-left corner to center the figure on the second monitor
            xPos = imageSize(2)+imageSize(2)/4;
            yPos = imageSize(1)/5;
            
            % Create a new figure at the calculated position with corrected syntax
            figHandle = figure('Name', 'Always On Top', 'NumberTitle', 'off', ...
                               'WindowStyle', 'modal', 'MenuBar', 'none', 'ToolBar', 'none', ...
                               'Position', [xPos, yPos, figureWidth, figureHeight]);

            % Display the image in the figure window
            imshow(img);  % Display your image (replace `img` with your image variable)
            
            % Optional: Set up the callback to close the figure when a key is pressed
            set(figHandle, 'WindowKeyPressFcn', @(src, event) close(src));

            
            response=0;
            gate=0;
              while (gate == 0)
                       
                         % Check for key press
                            [~, ~, keyCode] = KbCheck;
                            
                            if keyCode(KbName('1!') ) 
                                disp('You pressed "1" key for the CYAN target.');
                                response = 1;
                                gate = 1;
                            elseif keyCode(KbName('2@')) 
                                disp('You pressed "2" for the RED target.');
                                response = 2;
                                gate = 1;
            
                            elseif keyCode(KbName('Escape'))
                            keepPlaying = false;
                    
                            if(game.touchE==1) 
                            TouchQueueStop(game.touchDev);
                            TouchEventFlush(game.touchDev);
                            end
                            sca;
                    
                            
                            return
                        break;

                        end


              end
                m=response;

                    
               
    end
    if(game.useSoundHit && target.sound(m)) sound(yH, FsH); end
    nHits = nHits + 1;
    targetBodyXPos = motionPaths{m,nFrames-emergencyFrame}(1);
    targetBodyYPos = motionPaths{m,nFrames-emergencyFrame}(2);
    target.hit(m)=1;
    target.hitMethod(m)="Press_Space";
    target.hitTime(m)=toc;
    target.hitFrame(m)=emergencyFrame;
    target.hitX(m)=targetBodyXPos;
    target.hitY(m)=targetBodyYPos;
    target.hitOrder(m)=order;
     if(nHits==1) target.firstHit(m)=1; end
    target.hitType = "Keyboard";
    target.clickX(m)="NaN";
    target.clickY(m)="NaN";
    target.clickD(m)="NaN";
    target.clickN(m)=game.nClicks;
    

    order=order+1;

    disp("......................");
    disp("Clicked Target")
    disp("TargetN=");
    disp(m);
    disp(toc);
    disp([target.Info(m),"!!!!"]);
    disp([target.Info(m),"!!!!"]);
    disp([target.Info(m),"!!!!"]);
    disp("......................");
end




% Get the list of items in the folder
itemList = dir(game.savePath);

% Filter out only the CSV files
csvFiles = itemList(~[itemList.isdir]); % Select non-directory items
csvFiles = csvFiles(endsWith({csvFiles.name}, 'GameInfo.csv')); % Filter out GameInfo CSV files

% Count the number of CSV files
existingTrials = numel(csvFiles);


%if(game.useTouch) SetMouse(0, 0, game.screenNumber2); end


% Get the current date and time as a datetime object
currentDateTime = datetime('now');

% Convert datetime object to date string
currentDate = datestr(currentDateTime, 'yyyy-mm-dd');

% Extract the time component as a string
currentTime1 = datestr(currentDateTime, 'HH:MM:SS');


% Use the 'split' function to separate the path components by the '\' delimiter
pathComponents = split(game.savePath, '\');

pathComponents = pathComponents(~cellfun('isempty', pathComponents));

lastFolderName = pathComponents{end};

disp("..........................................................");
disp('User Info:');
disp('__________________');
disp(["Date:   "+currentDate]);
disp(["StartTime:   "+currentTime2]);
disp(["EndTime:   "+currentTime1]);
disp(["Trial_Duration:   "+num2str(endTime)]);

for(m = 1:game.nTargets)
    target.hitN(m) = nHits;
    if(target.hit(m))
    disp(["Target_Image:   "+target.TargetD(m)]);
    disp([target.Info(m)+ " !!!!"]);
    end
end


TimeOut=0;
if(f>=nFrames-2)
    TimeOut =1; 
disp(["Trial Timed Out!"]);
end
existingTrials
if(nHits==0) 
disp(["No Targets Hit"]);
end
disp('__________________');




% Helper function to convert variables to string
function str = convertToString(var)
    if isnumeric(var)
        str = num2str(var);  % Convert numeric values to string
    elseif iscell(var)
        str = string(cellfun(@convertToString, var, 'UniformOutput', false));  % Recursively handle nested cells
    else
        str = string(var);  % Convert other types directly to string
    end
end


%..........................................................................
%% Results
%..........................................................................
for m = 1:game.nTargets
results.FullDirectory(m) = game.savePath;
results.Directory(m) = convertToString(lastFolderName);
results.Time(m) = convertToString(currentTime1);
results.Date(m) = convertToString(currentDate);
results.Player(m) = convertToString(game.playerID);
results.NumTargets(m) = (game.nTargets);
results.Treatment(m) = (target.Info(m));
results.Target_Number(m) = (m);
results.Target_Texture(m) = (target.TargetD(m));
results.Target_Hit(m) = (target.hit(m));
results.Target_HitMethod(m) =  (target.hitMethod(m));
results.Target_Hit_Time(m) = (target.hitTime(m));
results.Target_Hit_Frame(m) = (target.hitFrame(m));
results.Target_Hit_X(m) = (target.hitX(m));
results.Target_Hit_Y(m) = (target.hitY(m));
results.Target_Hit_Order(m) = (target.hitOrder(m));
results.Target_FirstHit(m) = (target.firstHit(m));
results.Target_GiveUp(m) = (target.giveUp(m));
disp(target.speed(m) / game.pxPcm * game.screenFrameRate);
results.Target_Speed(m) = (target.speed(m) / game.pxPcm * game.screenFrameRate);
results.TimeOut(m) = TimeOut;
results.Click_X(m) = (target.clickX(m));
results.Click_Y(m) = (target.clickY(m));
results.Click_Dist(m) = (target.clickD(m));
results.Click_Number(m) =(target.clickN(m));
results.Clicks(m) = (target.clicks(m));
results.Start_X(m) = (target.startX(m));
results.Start_Y(m) = (target.startY(m));
results.Start_Side(m) = (target.startSide(m));
results.Number_Hit(m) = (target.hitN(m));
results.Window_Width(m) = (game.windowSize(3));
results.Window_Height(m) = (game.windowSize(4));
results.Window_PxCm(m) = (game.pxPcm);
results.Window_Background(m) = (game.background);
results.End_Frame(m) = (endFrame);
results.End_Time(m) = (endTime);
end



end

%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Script
%....................

% NAME:  function for game, dot to start

% Function:

% This script is used to create the starting dot screen.
% It can be customised to change the dot colour, position and text.
% In some instances you may wish to randomised the coordinates, but
% typically it should be at the centre. 
%
% The coordinate is coded as % of the screen size where 0.5 is the middle.

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

function f_game_dotToStart(window,windowRect,game,waitScreenColor,dotColor,dotX,dotY,dotSize,line1,line2);


    Gate=0;
    HideCursor;
    [xClickI, yClickI] = GetMouse(window);
    blobcol={};

    if(game.touchE==1)
    TouchQueueCreate(window, game.touchDev);
    TouchQueueStart(game.touchDev);
    HideCursor(window); HideCursor;
    end
    
    game.touchT=0;
    % DOT Loop
    %}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
    while Gate == 0
        
        
        %Background Image
        %................................................................
       Screen('FillRect', window, waitScreenColor);

         Screen('TextSize', window, 70);
        DrawFormattedText(window,  char(line1), 'center',game.windowSize(4)*0.25, [1 1 1]);


         Screen('TextSize', window, 50);
        DrawFormattedText(window,  char(line2), 'center',game.windowSize(4)*0.30, [1 1 1]);


       [xMouse, yMouse, ~] = GetMouse(window);
       
            draw.X=windowRect(3)*dotX;
            draw.Y=windowRect(4)*dotY;

        dotPosition=[draw.X,draw.Y];
        Screen('DrawDots', window, dotPosition, dotSize, dotColor, [], 1);

        if(game.showMouse)
        dotPosition = [xMouse,yMouse];
        Screen('DrawDots', window, dotPosition, game.mouseSize, game.mouseColor, [], 1);
        end
    
        %Target Click
        %/////////////////////////////////////////////////
    
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
            if(xMouse>xClickI || ~yMouse>yClickI ||xMouse<xClickI || ~yMouse<yClickI) 
            game.move=1; 
            xClickI=xMouse;
            end
            end
                    
            buttons=any(buttons);
            if(game.useDrag) 
                buttons=0; 
            end

            if (buttons || game.touch || game.move)

                buttons=0;

            if(toc > (game.touchT + game.touchD))
            game.touchT=toc;
            
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

                for(b=1:length(game.blobcol.x))
                xClick= game.blobcol.x{b};
                yClick= game.blobcol.y{b};

                SetMouse(xClick, yClick);

                dx = xClick - draw.X;
                dy = yClick - draw.Y;
                d = (dx^2+dy^2)^0.5;
    
                if(abs(d)<game.mouseSize*5)
                    disp("......................");
                    disp("Target Clicked");
                    nS = ["Click Time = " toc];
                    disp( nS );
    
                    Gate=1;
                    disp("......................");
                end
                end
    
            end
            end
    
    
          %Key Commands
        %.................................................................
        
         [~, ~, keyCode] = KbCheck;
    
         if keyCode(KbName('Space')) % Check for 'Escape' key
            Gate=1;
                while KbCheck
                    % Check for keyboard input
                    [~, ~, keyCode] = KbCheck;
                    % If no keys are being pressed, break out of the loop
                    if ~any(keyCode)
                                break;
                    end
                    end
        end
    
    
        if keyCode(KbName('ESCAPE')) % Check for 'Escape' key
            keepPlaying = false;
                    if(game.touchE)
                 TouchQueueStop(game.touchDev);
                 TouchQueueRelease(game.touchDev);
            end
            if(game.touchE==1) 
            TouchQueueStop(game.touchDev);
            TouchEventFlush(game.touchDev);
            end
            sca;
            f_screen_switch("Code",game.side);
            return
        break;
    
        end
    
    
    game.vbl = Screen('Flip', window, game.vbl + (game.waitFrames - 0.5) * game.ifi);
    
    end

   if(game.touchE==1) 
        TouchQueueStop(game.touchDev);
        TouchEventFlush(game.touchDev);
   end



end
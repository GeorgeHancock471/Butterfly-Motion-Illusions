
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Script
%....................

% NAME:  function for game, UI
% Function:

% This script is used to render premade UI images for the player of a game.
% These images are rendered on the player's screen.
% You can render text on the image of different sizes, coordinates and
% colours.
% This is useful for showing the user's performance.
% The uiIndex is used to determine which image from the UI folder is
% selected. 
% This is in alphabetical order e.g. 10 goes before 8 but but 08 before 10.

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



function [mouse] = game_UI(window,windowRect,game,uiIndex,lines,sizes,colors,xCoords,yCoords)


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


    itemList = dir(game.ui);

    % Filter out only the CSV files
    imgFiles = itemList(~[itemList.isdir]); % Select non-directory items
    imgFiles = imgFiles(endsWith({imgFiles.name}, '.png') | endsWith({imgFiles.name}, '.PNG')| endsWith({imgFiles.name}, '.jpg') | endsWith({imgFiles.name}, '.JPG') | endsWith({imgFiles.name}, '.jpeg') | endsWith({imgFiles.name}, '.JPEG')); % Filter out GameInfo CSV files
    
    
    % Extract just the file names from the imgFiles structure
    fileNames = {imgFiles.name};  % This creates a cell array of file names


    uiImage = imread(fullfile(game.ui,"/",fileNames{uiIndex}));
    uiTexture = Screen('MakeTexture', window,  uiImage);

        

    % UI Loop
    %}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
    while Gate == 0
        
        
        %Background Image
        %................................................................

        Screen('DrawTexture', window, uiTexture, [], windowRect);

    
        for(i=1:length(lines))
        Screen('TextSize', window, (sizes{i}));
        lineText = char(lines{i});
        textWidth = length(lineText)*(sizes{i}); % Calculate text width
        DrawFormattedText(window,  char(lines{i}), game.windowSize(3)*(xCoords{i})-textWidth/4,game.windowSize(4)*(yCoords{i}),colors{i});
        end

 
   
       [xMouse, yMouse, ~] = GetMouse(window);
       
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

            [~, ~, keyCode] = KbCheck;
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
            f_screen_switch(game.side);
            return
            end


            if keyCode(KbName('Return')) % Check for 'Escape' key
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
            return
            end



            if (buttons || game.touch )
        
                Gate=1;

            end
    
    
    game.vbl = Screen('Flip', window, game.vbl + (game.waitFrames - 0.5) * game.ifi);
    
    end

   if(game.touchE==1) 
        TouchQueueStop(game.touchDev);
        TouchEventFlush(game.touchDev);
   end


mouse.x = xMouse;
mouse.y = yMouse;
end
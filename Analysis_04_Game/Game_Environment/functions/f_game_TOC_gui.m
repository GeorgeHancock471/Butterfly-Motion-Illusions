
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Script
%....................

% NAME:  function for game, TOC GUI
% Function:

% This script is used to create mouseless GUIs for running TOC experiments.
% It takes assigned title text and an array, normally a list of training
% steps, and adjustments to the number of boxes and renders the UI on the
% operator's screen.


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



function [selectIndex,guiWin,guiRect] = f_game_TOC_gui(TitleText,fileArray,screenNumber,boxs,startIndex,hideMouse,guiWin, guiRect)


    KbName('UnifyKeyNames');

    
    bgColor = [200, 200, 200];


    if(hideMouse)
    HideCursor(guiWin);
    end

    [screenX, screenY] = RectCenter(guiRect);

    Screen('FillRect', guiWin, bgColor);

    numFiles = length(fileArray);

    indexSpace=1-startIndex;
    selectIndex = 1; % Start with the first file selected

    nRowShow = boxs(1);
    boxWidth = boxs(2);
    boxHeight = boxs(3);
    verticalSpacing = boxs(4); % Spacing between items
    itemHeight = boxHeight; % Each file box will have the same height

    baseTextSize = round(boxHeight*0.4);

    disp(baseTextSize);

    % Coordinates for the dropdown (centered)
    boxTopLeftX = screenX - boxWidth / 2;
    boxTopLeftY = screenY *0.4 ;
    
    % Define mouse-related variables
    done = false;


    % Main dropdown menu loop
    while ~done
        % Clear screen
        Screen('FillRect', guiWin, bgColor);

        % Display the title text at the top center of the screen

        
        % Loop to draw up to 5 files at a time
        for i = 1:nRowShow
            % Calculate the Y-position of the current item
            currentY = boxTopLeftY + (i - 1) * (itemHeight + verticalSpacing);
            currentX = boxTopLeftX;
            
            % Check if there is a file to display
            if (startIndex+i)<= numFiles && i+startIndex>0
                % Display the file name, or a placeholder "..." for empty rows
                displayText = fileArray{startIndex+i};
                color = [200, 200, 200]; % Default light grey for items
            else
                displayText = '...'; % Show "..." for blank rows
                color = [150, 150, 150]; % Light gray for "..."
            end
            
            % Highlight the selected item in blue
            if i==indexSpace
                color = [140, 200, 200]; % Blue color for selected item
            end

            if(i==1)
            Screen('TextSize', guiWin, baseTextSize);
            DrawFormattedText(guiWin, char(TitleText), 'center', currentY -itemHeight-verticalSpacing + itemHeight *0.65, [0, 0, 0]);
            end

            Screen('TextSize', guiWin, baseTextSize);
            
            % Draw the current item box
            if(i==indexSpace)
            itemRect = [currentX, currentY, currentX + boxWidth, currentY + itemHeight];
            else
            itemRect = [currentX+boxWidth*0.05, currentY, currentX + boxWidth-boxWidth*0.05, currentY + itemHeight];
            end
            Screen('FillRect', guiWin, color, itemRect);
            Screen('FrameRect', guiWin, [0, 0, 0], itemRect, 3); % Add border
            
            % Display the file name or placeholder in the box
            DrawFormattedText(guiWin, displayText, 'center', currentY + itemHeight *0.55, [0, 0, 0]);
            end
        
        % Flip to update the screen
        Screen('Flip', guiWin);
        
        % Get mouse position and check for clicks
        [mouseX, mouseY, buttons, wheelDelta] = GetMouse;
        
        if any(buttons) % Mouse button pressed
            
            for i = 1:nRowShow
                currentY = boxTopLeftY + (i - 1) * (itemHeight + verticalSpacing);
                itemRect = [boxTopLeftX, currentY, boxTopLeftX + boxWidth, currentY + itemHeight];

                % Check if the click is within the item box
                if mouseX >= itemRect(1) && mouseX <= itemRect(3) && mouseY >= itemRect(2) && mouseY <= itemRect(4)
                    if i <= numFiles
                        % Move clicked file to the top
                        if(startIndex+i-indexSpace<nRowShow)
                        startIndex=startIndex+i-indexSpace;
                        end
                        if(i==indexSpace)
                        done = true;
                        selectIndex=startIndex+indexSpace;
                        end
                    end
                    WaitSecs(0.15); 
                    break; % Exit the loop after processing the click
                end
            end
            
        end


        [~, ~, keyCode] = KbCheck;
        if keyCode(KbName('UpArrow'))
            startIndex = startIndex-1; % Move up
            WaitSecs(0.1); 
        elseif keyCode(KbName('DownArrow'))
            startIndex = startIndex+1; % Move down
            WaitSecs(0.1); 
        elseif keyCode(KbName('Space'))
            done = true; % Confirm selection
            selectIndex=startIndex+indexSpace;
        elseif keyCode(KbName('ESCAPE'))
            selectIndex = -1; % Cancel selection
            done = true;
            sca;
            return
        elseif keyCode(KbName('Return'))
            selectIndex = -1; % Cancel selection
            done = true;
            return
        end



    end


    Screen('FillRect', guiWin, bgColor);
    Screen('Flip', guiWin);
    pause(0.1);

end







%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Script
%....................

% NAME:  function for GUIs, gui keys

% Function:
% This script is used to allow the user to input a key command to change 
% the game settings by providing customisable text on the gui screen
% (operator screen) and outputting the key pressed.
% You can adjust the text, size, colour, x coordinates and y coordinates.

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





function [keyPressed] = f_gui_keys(screenNumber,hideMouse,guiWin, guiRect,lines,sizes,colors,xCoords,yCoords)


keyPressed=-1;
    KbName('UnifyKeyNames');

    
    bgColor = [200, 200, 200];


    if(hideMouse)
    HideCursor(guiWin);
    end

    [screenX, screenY] = RectCenter(guiRect);

    Screen('FillRect', guiWin, bgColor);


    for i = 1:length(lines)
        % Set the text size
        Screen('TextSize', guiWin, sizes{i});
    
        % Convert line text to a character array (string)
        lineText = char(lines{i});
    
        % Get the bounding box of the text to calculate the actual width and height
        [~, ~, textBounds] = DrawFormattedText(guiWin, lineText, 0, 0,  bgColor);
        
        % Calculate the width of the text from the bounds
        textWidth = textBounds(3) - textBounds(1);  % Right x - Left x
        textHeight = textBounds(4) - textBounds(2); % Bottom y - Top y
    
        % Calculate the position to center the text
        xPos = guiRect(3) * xCoords{i};
        yPos = guiRect(4) * yCoords{i};
    
        % Draw the text at the calculated position
        DrawFormattedText(guiWin, lineText, xPos-textWidth/2, yPos-textHeight/2, colors{i});
    end


    Screen('Flip', guiWin);

    
    % Define mouse-related variables
    done = false;


    % Main dropdown menu loop
    while ~done
        % Clear screen

        [keyDown, ~, keyCode] = KbCheck;

        if(keyDown)
            done=true; 
            keyPressed=KbName(find(keyCode));
        end



    Screen('FillRect', guiWin, bgColor);

    for i = 1:length(lines)
        % Set the text size
        Screen('TextSize', guiWin, sizes{i});
    
        % Convert line text to a character array (string)
        lineText = char(lines{i});
    
        % Get the bounding box of the text to calculate the actual width and height
        [~, ~, textBounds] = DrawFormattedText(guiWin, lineText, 0, 0,  bgColor);
        
        % Calculate the width of the text from the bounds
        textWidth = textBounds(3) - textBounds(1);  % Right x - Left x
        textHeight = textBounds(4) - textBounds(2); % Bottom y - Top y
    
        % Calculate the position to center the text
        xPos = guiRect(3) * xCoords{i};
        yPos = guiRect(4) * yCoords{i};
    
        % Draw the text at the calculated position
        DrawFormattedText(guiWin, lineText, xPos-textWidth/2, yPos-textHeight/2, colors{i});
    end


    Screen('Flip', guiWin);

    end


    Screen('FillRect', guiWin, bgColor);
    Screen('Flip', guiWin);
    pause(0.1);

end




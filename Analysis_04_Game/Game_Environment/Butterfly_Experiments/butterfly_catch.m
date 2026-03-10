function butterfly_catch();

rng("shuffle"); %Randomise Seed
beep off; %Turn off warning beeps

d = load('peckLocation.mat'); %Load PECK path
peckPath = d.peckPath;

tutorial = 1;


%% 1) Initialisation
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
maxFrameRate = 240;
totalFrames = 290;
gamePath =  fullfile(peckPath ,"Butterfly_Experiments","butterfly_catch_game");



%Input Player ID
%....................................................................
% Creates a dialog box
% Allows the operator to enter the player.

set(0, 'DefaultFigurePosition', 'default');
defaultPlayerID = 'P001'; % Set your default Player ID here
InfoDlg = inputdlg({'Player ID'}, 'Enter trial info', 1, {defaultPlayerID});
playerID = InfoDlg{1}; % Use index 1 instead of 0



% Game Settings
%.........................................
waitScreenColor = [0.2^0.5,0.2^0.5,0.2^0.5];
game = f_game_presets("Touch",gamePath,playerID); % Imports default game setting.  
game.side="Left";
game.screenFrameRate=maxFrameRate;
[game, window, windowRect,offscreenWindow] = f_game_initialisePTB(game,waitScreenColor);




% Results output setup
%....................................................................
resultsDir = fullfile(gamePath, 'Results');  % <-- change if needed
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

Results = {};
resultRow = 1;







%% 1) Tutorial
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

% Instructions
%....................................................................
lines = {}; % Initialize as a cell array
sizes= {}; % Initialize as a cell array
colors = {}; % Initialize as a cell array
xCoords = {}; % Initialize as a cell array
yCoords = {}; % Initialize as a cell array
f_game_UI (window,windowRect,game,1,lines,colors,xCoords,yCoords); 














%% 2) Experiment
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


% Stimulus Path
% ...............
stimuliRoot = fullfile(gamePath, 'stimuli', 'Brintesia_circe__Male','01');
stimuliT = fullfile(stimuliRoot,'Textured_reduced');
pathRoot = fullfile(stimuliRoot,'flight_data.csv');



% Flip
%................
flipX = rand() > 0.5;
flipY = rand() > 0.5;

% Extract Textures
% ...............
textures = loadStimulusTextures(window, stimuliT, flipX,flipY);



% Extract X, Y and Headings
% ...................................
rawPath = readtable(pathRoot);

nRows = height(rawPath);
rowsPerFrame = 2;

% Compute number of full frames
nFrames = floor(nRows / rowsPerFrame);

fprintf('Total rows: %d, Rows per frame: %d, Full frames: %d\n', nRows, rowsPerFrame, nFrames);

% Trim leftover rows that don't make a full frame
rawPath = rawPath(1:(nFrames*rowsPerFrame), :);


frameIdx = repelem((1:nFrames)', rowsPerFrame);
rawPath.frameIdx = frameIdx;

% Aggregate 2 rows per frame
rowsPerFrame = 2;
nFrames = floor(height(rawPath)/rowsPerFrame);

rawPath = rawPath(1:(nFrames*rowsPerFrame), :);

frameIdx = repelem((1:nFrames)', rowsPerFrame);
rawPath.frameIdx = frameIdx;

% Groupsummary
aggPath = groupsummary(rawPath, 'frameIdx', 'mean', {'x','y','heading_deg'});

% Select only the mean columns + frame index
aggPath = aggPath(:, {'frameIdx','mean_x','mean_y','mean_heading_deg'});

% Rename columns
aggPath.Properties.VariableNames = {'frame','x','y','heading_deg'};

% Now path is ready
path = aggPath;


if flipX
    path.x = -path.x;                     % mirror horizontally
    path.heading_deg = mod(180 - path.heading_deg, 360); % flip heading horizontally
end

% Flip Y
if flipY
    path.y = -path.y;                     % mirror vertically
    path.heading_deg = mod(-path.heading_deg, 360);      % flip heading vertically
end



% Dot to Start
% ...................................

f_input_waitForClickRelease;
startX=0.05;
startY=0.95;
dotSize=70;
dotColor=[1,1,1];
line1="";
   line2="";
f_game_dotToStart(window,windowRect,game,waitScreenColor,dotColor,startX,startY,dotSize,line1,line2);
f_input_waitForClickRelease;


track=0;



captureFrame = 0;
captureTime = 0;
xMouse=0;
yMouse=0;
slow_speed = 1;



if(game.touchE==1)
TouchQueueCreate(window, game.touchDev);
TouchQueueStart(game.touchDev);
HideCursor(window); HideCursor;
end




playGame=1;
f=0;
tic;
while(playGame)

f0 = floor(f/slow_speed);

tex = textures{f0+1};  

% Butterfly
Screen('DrawTexture', window, tex, [], ...
[0, ...
0, ...
windowRect(3), ...
windowRect(4)], ...
0); 



%Detect Clicks and Touches
%..........................................
% Get mouse coordinates and buttons
[xMouse, yMouse, buttons] = GetMouse(window);  
buttons = any(buttons);  % true if any button is pressed

% Reset touch
game.touch = 0;

% Check touch input if enabled
if game.touchE
    game = f_input_touch(game, window);  % updates game.touch
    if game.touch
        xMouse = game.blobcol.x{1};
        yMouse = game.blobcol.y{1};
    end
end

% End loop if click or touch
if buttons || game.touch

    Ds = ((xMouse-startX*windowRect(3))^2 + (yMouse-startY*windowRect(4))^2)^0.5;
    
    if(Ds>windowRect(3)/10)
        captureTime = toc;
        captureFrame = f0-1;
        playGame = 0;
    end
end
......................................


Screen('Flip', window);

f=f+1;

if(f>=totalFrames*slow_speed)
playGame=0;
end
end



if(game.touchE==1) 
TouchQueueStop(game.touchDev);
TouchEventFlush(game.touchDev);
end


disp(captureFrame);


%Show Capture Point
%.....................................

hitboxSlide = [sprintf('%04d', f0), '.png'];
hitboxD = fullfile(stimuliRoot,"Hitbox_reduced",hitboxSlide)
[currentImage, ~, currentAlpha]= imread(hitboxD ); % Will need to be replaced with an array
tex={};
tex = Screen('MakeTexture', window,  cat(3, currentImage, currentAlpha));

if(captureFrame>1)
f=0;

    f0 = captureFrame;
    
    
    % Butterfly
    Screen('DrawTexture', window, tex, [], ...
    [0, ...
    0, ...
    windowRect(3), ...
    windowRect(4)], ...
    0); 

    Screen('Flip', window);


    [imgH, imgW, ~] = size(currentImage);
    
    imgX = round(xMouse * imgW / windowRect(3));
    imgY = round(yMouse * imgH / windowRect(4));
    
    imgX = max(1, min(imgW, imgX));
    imgY = max(1, min(imgH, imgY));

    radius = 20;

    xRange = max(1, imgX-radius) : min(imgW, imgX+radius);
    yRange = max(1, imgY-radius) : min(imgH, imgY+radius);
    
    [X, Y] = meshgrid(xRange, yRange);
    mask = (X - imgX).^2 + (Y - imgY).^2 <= radius^2;


    roi = currentImage(yRange, xRange, :);

    R = roi(:,:,1);
    G = roi(:,:,2);
    B = roi(:,:,3);
    
    meanR = mean(R(mask));
    meanG = mean(G(mask));
    meanB = mean(B(mask));
    
    meanRGB_int = uint8(round([meanR; meanG; meanB]));
    % Convert RGB to text
    rgbText = sprintf('RGB: R=%d  G=%d  B=%d', meanRGB_int(1), meanRGB_int(2), meanRGB_int(3));
    


    % Get tracker coordinates and heading from path table
    x = path.x(f0+1)*windowRect(3)/2 + windowRect(3)/2;             % x-coordinate for frame f
    y = -path.y(f0+1)*windowRect(4)/2 + windowRect(4)/2;             % y-coordinate for frame f
    heading = path.heading_deg(f0+1);  % heading in degrees


    
 
    %tex = textures{f0+1};       
    % Butterfly
    Screen('DrawTexture', window, tex, [], ...
    [0, ...
    0, ...
    windowRect(3), ...
    windowRect(4)], ...
    0); 


    % Get tracker coordinates and heading from path table
    x = path.x(f0+1)*windowRect(3)/2 + windowRect(3)/2;             % x-coordinate for frame f
    y = -path.y(f0+1)*windowRect(4)/2 + windowRect(4)/2;             % y-coordinate for frame f
    heading = path.heading_deg(f0+1);  % heading in degrees







    % Set text properties
    Screen('TextSize', window, 24);
    Screen('TextFont', window, 'Arial');
    




    % Draw text (top-left corner)
    DrawFormattedText(window, rgbText, windowRect(3)/2, windowRect(4)/10, [255 255 255]);



    % Draw Mouse
    dotPosition = [xMouse,yMouse]; 
    Screen('DrawDots', window, dotPosition, game.mouseSize, game.mouseColor, [], 1);



    % Draw Angles
    % Compute vector from tracker to mouse
    dx = xMouse - x;  % x difference
    dy = yMouse - y;  % y difference
    
    % Draw line from tracker to mouse
    Screen('DrawLine', window, [0 255 255], x, y, xMouse, yMouse, 2); % yellow line, 2 px thick
    
    % Angle from tracker to mouse (degrees, 0 = right, CCW positive)
    angleMouse = atan2d(dy, dx);  % MATLAB atan2d: dy first, dx second
    
    % Trackers heading: convert to screen coordinates if needed
    % In your code, tracker heading seems screen-oriented
    headingScreen = -heading ;  % already used in DrawTexture
    
    % Compute relative angle: mouse vs tracker heading
    relativeAngle = angleMouse - headingScreen;
    
    % Normalize to [-180, 180]
    relativeAngle = mod(relativeAngle + 180, 360) - 180;
    
    % Determine front/back
    if abs(relativeAngle) <= 90
        frontBack = 'Front';
    else
        frontBack = 'Behind';
    end
    
    % Determine left/right
    if relativeAngle > 0
        leftRight = 'Right';
    else
        leftRight = 'Left';
    end
    
    % Create display text
    lineText = sprintf('Angle: %.1f°  |  %s | %s', relativeAngle, frontBack, leftRight);
    
    % Draw text (top of screen)
    Screen('TextSize', window, 24);
    Screen('TextFont', window, 'Arial');
    DrawFormattedText(window, lineText, windowRect(3)/2, windowRect(4)/6, [255 255 255]);




    %-------------------------------
    % Draw heading-based color-coded lines
    %-------------------------------

    % Base radius
    baseRadius = windowRect(3)/10;
    
    % Red line is 1.5x longer
    lineLengths = [1.5, 1, 1, 1] * baseRadius;
    
    % Colors: Red, Yellow, Green, Blue
    lineColors = [255 0 0; 255 255 0; 0 255 0; 0 0 255];
    
    % Angles relative to tracker heading (degrees)
    angles = [0, 90, 180, 270];
    
    % Tracker heading in screen coordinates
    headingScreen = -heading;  % same as you used in DrawTexture
    
    for i = 1:4
        % Absolute angle in screen coordinates
        absAngle = headingScreen + angles(i);
    
        % Compute line end point
        endX = x + lineLengths(i) * cosd(absAngle);
        endY = y + lineLengths(i) * sind(absAngle);
    
        % Draw the line
        Screen('DrawLine', window, lineColors(i,:), x, y, endX, endY, 2); % thickness = 2 px
    end




    
    Screen('Flip', window);
   


    while f < 3
        f = f + 1;
        pause(1);   % pauses for 1 second
    end

end








sca;
return



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
f_input_waitForClickRelease;



% Loading
%....................................................................
% Fill screen with color
Screen('FillRect', window, waitScreenColor);

% Set text properties
Screen('TextSize', window, 48);          % Large text
Screen('TextFont', window, 'Arial');     % Font
textColor = [255 255 255];               % White

% Draw centered text
DrawFormattedText(window, 'Loading', 'center', 'center', textColor);

% Flip to display
Screen('Flip', window);









%% 2) Experiment
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


% Adjustable for testing
nPaths = 3;   % e.g. 30, change to 6 for testing
flightPaths = arrayfun(@(x) sprintf('%02d', x), 1:nPaths, 'UniformOutput', false);
flightPaths = flightPaths(randperm(nPaths));


%Loop through all trials
for nT = 1:nPaths


Butterfly_ID =  'Lycaena_tityrus__Female';
Flight_Path =  flightPaths{nT};


% Stimulus Path
% ...............
stimuliRoot = fullfile(gamePath, 'stimuli', Butterfly_ID, Flight_Path);
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



% Adjust Coordinates to Match Flip
% ...................................
startX=0.05;
startY=0.95;


if flipX
    path.x = -path.x;                     % mirror horizontally
    path.heading_deg = mod(180 - path.heading_deg, 360); % flip heading horizontally
    startX = 1-startX;
end

% Flip Y
if flipY
    path.y = -path.y;                     % mirror vertically
    path.heading_deg = mod(-path.heading_deg, 360);      % flip heading vertically
    startY=1-startY;
end





% Get the current date and time as a datetime object
currentDateTime = datetime('now');

% Convert datetime object to date string
currentDate = datestr(currentDateTime, 'yyyy-mm-dd');

% Extract the time component as a string
currentTime2 = datestr(currentDateTime, 'HH:MM:SS');




%Results Pre Load
%..............................
nT = 1;

results.trialNumber = nT
results.butterfly =  Butterfly_ID;
results.pathNumber = Flight_Path;
results.flipX = flipX;
results.flipY = flipY;
results.clickX = 0; %Fill by game
results.clickY = 0; %Fill by game
results.clickDeg = 0; %Fill by game
results.clickDist = 0; %Fill by game
results.clickLeftRight = "NaN"; %Fill by game
results.clickFrontBack = "NaN"; %Fill by game
reults.clickRGB_R = 0; %Fill by game
reults.clickRGB_G = 0; %Fill by game
reults.clickRGB_B = 0; %Fill by game
results.clickTime = 0; %Fill by game
results.clickFrame = 0; %Fill by game
reults.butterflyX = 0; %Fill by game
reults.butterflyY = 0; %Fill by game
reults.butterflyDeg = 0; %Fill by game
results.hitBinary = 0; %Fill by game
results.stimuliDuration =  0; %Fill by game
results.displayRate = 0; %Fill by game
results.date = currentDate;
results.Time = currentTime2;




% Dot to Start
% ...................................


dotSize=70;
dotColor=[1,1,1];
line1="";
   line2="";
f_game_dotToStart(window,windowRect,game,waitScreenColor,dotColor,startX,startY,dotSize,line1,line2);
f_input_waitForClickRelease;




% Initiate Game
% ...................................
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


%Start Game
%....................................................................................
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
    
    Screen('Flip', window);
    
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

    f=f+1;
    
    if(f>=totalFrames*slow_speed)
    playGame=0;
    end

end % End of Game
%....................................................................................

 displayFrameRate = f/toc;
 endTime = toc;



results.stimuliDuration =  endTime; %Fill by game
results.displayRate = displayFrameRate; %Fill by game



% Clear Touch Events
if(game.touchE==1) 
TouchQueueStop(game.touchDev);
TouchEventFlush(game.touchDev);
end



%Show Capture Point
%.....................................................................................

% If Occured
if(captureFrame>1)

% Obtain Hitbox Texture
hitboxSlide = [sprintf('%04d', f0), '.png'];
hitboxD = fullfile(stimuliRoot,"Hitbox_reduced",hitboxSlide);
[img, ~, alpha] = imread(hitboxD);

% Apply flips
if flipX
    img = flip(img, 2); % flip left-right
    if ~isempty(alpha)
        alpha = flip(alpha, 2);
    end
end
if flipY
    img = flip(img, 1); % flip up-down
    if ~isempty(alpha)
        alpha = flip(alpha, 1);
    end
end

tex={};
tex = Screen('MakeTexture', window,  cat(3,img,alpha));


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


    [imgH, imgW, ~] = size(img);
    
    imgX = round(xMouse * imgW / windowRect(3));
    imgY = round(yMouse * imgH / windowRect(4));
    
    imgX = max(1, min(imgW, imgX));
    imgY = max(1, min(imgH, imgY));

    radius = 20;

    xRange = max(1, imgX-radius) : min(imgW, imgX+radius);
    yRange = max(1, imgY-radius) : min(imgH, imgY+radius);
    
    [X, Y] = meshgrid(xRange, yRange);
    mask = (X - imgX).^2 + (Y - imgY).^2 <= radius^2;


    roi = img(yRange, xRange, :);

    R = roi(:,:,1);
    G = roi(:,:,2);
    B = roi(:,:,3);
    
    validMask = mask & (G ~= 0) & (B ~= 0);

    if any(validMask(:))
        meanR = mean(R(validMask));
        meanG = mean(G(validMask));
        meanB = mean(B(validMask));
    else
        % Fallback if all pixels were excluded
        meanR = 0;
        meanG = 0;
        meanB = 0;
    end

    
    meanRGB_int = uint8(round([meanR; meanG; meanB]));
    
    % Convert RGB to text
    rgbText = sprintf('RGB: R=%d  G=%d  B=%d', meanRGB_int(1), meanRGB_int(2), meanRGB_int(3));
    

    % Get tracker coordinates and heading from path table
    x = path.x(f0+1)*windowRect(3)/2 + windowRect(3)/2;             % x-coordinate for frame f
    y = -path.y(f0+1)*windowRect(4)/2 + windowRect(4)/2;             % y-coordinate for frame f
    heading = path.heading_deg(f0+1);  % heading in degrees


    
 
    tex = textures{f0+1};       
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
    




    % Draw Mouse
    dotPosition = [xMouse,yMouse]; 
    Screen('DrawDots', window, dotPosition, game.mouseSize, game.mouseColor, [], 1);



    % Draw Angles
    % Compute vector from tracker to mouse
    dx = xMouse - x;  % x difference
    dy = yMouse - y;  % y difference

    touchDistance = (dx^2 + dy^2)^0.5;
    
    % Draw line from tracker to mouse
    Screen('DrawLine', window, [127 127 127], x, y, xMouse, yMouse, 2); % yellow line, 2 px thick
    
    % Angle from tracker to mouse (degrees, 0 = right, CCW positive)
    angleMouse = atan2d(dy, dx);  % MATLAB atan2d: dy first, dx second
    
    % Trackers heading: convert to screen coordinates if needed
    % In your code, tracker heading seems screen-oriented
    headingScreen = -heading ;  % already used in DrawTexture
    
    % Compute relative angle: mouse vs tracker heading
    relativeAngle = angleMouse - headingScreen;
    
    % Normalize to [-180, 180]
    relativeAngle = mod(relativeAngle + 180, 360) - 180;
    
    % Define a small threshold around 0 degrees for "Centre"
    centreThreshold = 10;  % degrees
    
    % Determine front/back/centre
    if abs(relativeAngle) <= centreThreshold
        frontBack = '"Centre"';
    elseif abs(relativeAngle) <= 90
        frontBack = '"Front"';
    else
        frontBack = '"Back"';
    end

    
    % Determine left/right
    if  relativeAngle > 0
        leftRight = '"Right"';
    else
        leftRight = '"Left"';
    end






    %-------------------------------
    % Draw heading-based color-coded lines
    %-------------------------------

    % Base radius
    baseRadius = windowRect(3)/15;
    
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


    % Create display text
    lineText = sprintf('Your attack was to the %s and %s of the butterfly', frontBack, leftRight);
    if(meanR>1)
    hit=1;
    rgbText = 'HIT!!!';
    rgbColour = [0,255,127];
    else
    hit=0;
    rgbText = 'Oh no you missed!';
    rgbColour = [1,0.75,0];
    end
    if(y<windowRect(4)/2)
    % Draw text (top of screen)
    Screen('TextSize', window, 30);
    Screen('TextFont', window, 'Arial');
    DrawFormattedText(window, rgbText, x-100,y+baseRadius*1.5-50, rgbColour);
        Screen('TextSize', window, 24);
    DrawFormattedText(window, lineText, x-300,y+baseRadius*1.5, [255 255 255]);
   

    else
    Screen('TextSize', window, 30);
    Screen('TextFont', window, 'Arial');
    DrawFormattedText(window, rgbText, x-100,y-baseRadius*1.5-50,rgbColour);
        Screen('TextSize', window, 24);
    DrawFormattedText(window, lineText, x-300,y-baseRadius*1.5, [255 255 255]);
    
    end


    results.clickX = xMouse;
    results.clickY = yMouse;
    results.clickDeg = relativeAngle; 
    results.clickDist = touchDistance; 
    results.clickLeftRight = leftRight;
    results.clickFrontBack = frontBack; 
    reults.clickRGB_R = meanR; 
    reults.clickRGB_G = meanG; 
    reults.clickRGB_B = meanB; 
    reults.butterflyX = x;      
    reults.butterflyY = y;      
    reults.butterflyDeg = headingScreen;
 
    results.hitBinary = hit; 
    results.clickTime = captureTime; 
    results.clickFrame = captureFrame;


    
    Screen('Flip', window);
   




% Butterfly Escaped
%....................................................................................    
else

% Fill screen with color
Screen('FillRect', window, waitScreenColor);

% Set text properties
Screen('TextSize', window, 48);          % Large text
Screen('TextFont', window, 'Arial');     % Font
textColor = [255 255 255];               % White

txt = "I'm sorry, it got away!";
DrawFormattedText(window, char(txt), 'center', 'center', textColor);

% Flip to display
Screen('Flip', window);


end
%.................................................................................... 


% Store trial results
Results(resultRow, :) = { ...
    results.trialNumber, ...   % Trial number
    results.butterfly, ...     % Butterfly
    results.pathNumber, ...    % Flight Path
    results.flipX, ...         % Flip Stimulus X
    results.flipY, ...         % Flip Stimulus Y
    results.clickX, ...        % Click X
    results.clickY, ...        % Click Y
    results.clickDeg, ...      % Degrees relative to butterfly heading
    results.clickDist,...      % Dlick Distance
    results.clickLeftRight,...  % Click to left or right
    results.clickFrontBack,...  % Click to front or back
    reults.clickRGB_R,...       % Click R
    reults.clickRGB_G,...       % Click G
    reults.clickRGB_B,...       % Click B
    results.clickTime, ...      % Time of click
    results.clickFrame,...      % Frame of click
    reults.butterflyX,...       % Butterfly X
    reults.butterflyY ,...       % Butterfly Y
    reults.butterflyDeg,...       % Butterfly Heading Degrees
    results.hitBinary, ...      % Correct (1/0)
    results.stimuliDuration, ... % Measured fDuration
    results.displayRate, ...    % Measured frame rate
    results.date, ...           % Date
    results.Time ...           % Time
    };

resultRow = resultRow + 1;



end


pause(2);


    %% Save results to CSV
    variableNames = { ...
               'trialNumber', ...   % Trial number
               'butterfly', ...     % Butterfly
               'pathNumber', ...    % Flight Path
               'flipX', ...         % Flip Stimulus X
               'flipY', ...         % Flip Stimulus Y
               'clickX', ...        % Click X
               'clickY', ...        % Click Y
               'clickDeg', ...      % Degrees relative to butterfly heading
               'clickDist',...      % Dlick Distance
               'clickLeftRight',...  % Click to left or right
               'clickFrontBack',...  % Click to front or back
               'clickRGB_R',...       % Click R
               'clickRGB_G',...       % Click G
               'clickRGB_B',...       % Click B
               'clickTime', ...      % Time of click
               'clickFrame',...      % Frame of click
               'butterflyX',...       % Butterfly X
               'butterflyY',...       % Butterfly Y
               'butterflyDeg',...       % Butterfly Heading Degrees
               'hitBinary', ...      % Correct (1/0)
               'stimuliDuration', ... % Measured fDuration
               'displayRate', ...    % Measured frame rate
               'Date', ...           % Date
               'Time' ...           % Time
        };
    
    ResultsTable = cell2table(Results, 'VariableNames', variableNames);
    
    % Create timestamped filename
    csvFileName = fullfile(resultsDir, ['Results_' playerID  '.csv']);
    
    writetable(ResultsTable, csvFileName);
    
    disp(['Results saved to: ' csvFileName]);




sca;
return



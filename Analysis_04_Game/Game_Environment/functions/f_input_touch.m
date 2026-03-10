

%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Script
%....................

% NAME:  function for input, touch

% Function:
% This script is used to collect touch sreen input and output it to the
% game.

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
           
function game= f_input_touch(game,window)
game.touch=0;
game.blobcol = {}; 

%TOUCHES
while TouchEventAvail(game.touchDev)
% Process next touch event 'evt':
evt = TouchEventGet(game.touchDev, window);
id = evt.Keycode;

   eR=0;
   b=0;

if(game.useDrag) 
if ( evt.Type == 2 ||  evt.Type == 3 ||evt.Type == 4 ) 
eR=1;
end
else
if (evt.Type == 2  ) 
eR=1;
end
end

if (eR==1)
b=b+1;
% New touch point -> New blob!
game.blobcol.x{b} = evt.MappedX;
game.blobcol.y{b} = evt.MappedY;
if(game.showMouse) Screen('DrawDots', window, [evt.MappedX,evt.MappedY], game.mouseSize*3, [1,1,0], [], 1); end
game.touch=1;
end

end



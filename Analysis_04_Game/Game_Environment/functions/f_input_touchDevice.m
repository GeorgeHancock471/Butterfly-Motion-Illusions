

%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% Script
%....................

% NAME:  function for input, touch device

% Function:
% This script is used to obtain the touchscreen device info and return it
% to the game.

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
                      
function game= f_input_touchDevice(game,window)
game.touchE = 0;
if(game.useTouch)
    numTouchDevices = length(GetTouchDeviceIndices([], 1));
    if(numTouchDevices>0)
      game.touchDev = max(GetTouchDeviceIndices([], 1));
      fprintf('Touch device properties:\n');
      info = GetTouchDeviceInfo(game.touchDev);
      disp(GetTouchDeviceIndices);
      game.touchE = 1;
    end
end

end



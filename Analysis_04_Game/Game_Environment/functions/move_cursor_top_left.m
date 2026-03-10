function test
function move_cursor_top_left()

    % Coordinates for the top-left corner of the screen (0, 0)
    x = 0;
    y = 0;

    % Time for the loop (2 seconds)
    duration = 2;  % Duration in seconds
    frameRate = 30;  % Frames per second (FPS)
    frames = duration * frameRate;  % Total number of frames
mouse = java.awt.Robot;
    % Run the loop for the given duration
    for i = 1:frames
        % Move the cursor to the top-left corner (0, 0)
        mouse.mouseMove(-3, -3);
        
        % Wait for the next frame (based on frameRate)
        pause(1 / frameRate);
    end
end

% Call the function to move the cursor
move_cursor_top_left();
end

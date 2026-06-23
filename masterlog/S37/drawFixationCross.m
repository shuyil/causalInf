function drawFixationCross(window, windowRect, fixCrossDimPix, lineWidthPix, color)
    % Function to set up alpha blending, text properties, and draw a fixation cross
    % Inputs:
    %   window         - The window pointer where the cross will be drawn
    %   windowRect     - The window rectangle
    %   fixCrossDimPix - Length of each arm of the cross (in pixels)
    %   lineWidthPix   - Width of the cross lines (in pixels)
    %   color          - Color of the cross (RGB array)

    % Set up alpha-blending for smooth (anti-aliased) lines
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

    % Get the center coordinates of the window
    [xCenter, yCenter] = RectCenter(windowRect);

    % Set the coordinates for the fixation cross
    xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
    yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
    allCoords = [xCoords; yCoords];

    % Draw the fixation cross in the specified color at the center of the screen
    Screen('DrawLines', window, allCoords, lineWidthPix, color, [xCenter yCenter], 2);
end


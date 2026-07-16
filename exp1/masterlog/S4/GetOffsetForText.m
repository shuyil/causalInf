function [offsetX, offsetY] = GetOffsetForText(textString, textSize, windowPtr)
% Returns the horizontal offset (offsetX) and the vertical offset (offsetY) required to centre a text string of a particular size

Screen(windowPtr, 'TextFont', 'Arial');
Screen(windowPtr, 'TextSize', textSize);

woff = Screen(windowPtr, 'OpenOffscreenWindow', [], [0 0 3*textSize*length(textString) 2*textSize]);
Screen(woff, 'TextFont', 'Arial');
Screen(woff, 'TextSize', textSize);
bounds = TextBounds(woff, textString);
Screen(woff, 'Close');

offsetX = bounds(3)/2;
offsetY = bounds(4)/2;
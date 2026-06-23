function [startTime,resp_end] = rateTarget(window, scan, imageSource, effectSource, previousRating, stiCoor, coCoor, xCenter, barRect, barWidth, MarkerXPos,labelPos, IO,ioObj,address)
    % Function to display two images (one superimposed on the other) and allow the user to rate the cause-effect relationship using a slider.
    % The slider shows a target point based on the previous rating.
    
    % Enable alpha blending for transparency
    Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    % Load image with transparency
    [img_efi, ~, alpha_efi] = imread(effectSource);
    imgWithAlpha_eff = cat(3, img_efi, alpha_efi);
    
    [img_sti, ~, alpha_sti] = imread(imageSource);
    imgWithAlpha_sti = cat(3, img_sti, alpha_sti);

    % Create texture
    textureIndex_eff = Screen('MakeTexture', window, imgWithAlpha_eff);
    textureIndex_sti = Screen('MakeTexture', window, imgWithAlpha_sti);

    % Initial rating value
    rating = 0;
    maxRating = 100;
    minRating = -100;


    % Calculate the position of the target point based on the previous rating
    targetXPos = xCenter + (previousRating / maxRating) * (barWidth / 2);
    
    % define buttons
    if scan
        keyCode = zeros(1,size(IO.buttons,1)); 
        button  = -1; 
        byte_in = -1;
    end

    %%
    
    % Draw sti & colorframe
    Screen('DrawTexture', window, textureIndex_sti, [], stiCoor);
    Screen('DrawTexture', window, textureIndex_eff, [], coCoor);

    % Draw the rating bar background
    Screen('FillRect', window, [200 200 200], barRect);

    % Draw the middle, min, and max markers
    Screen('FillRect', window, [255 255 255], [MarkerXPos(1) - 2, barRect(2) - 10, MarkerXPos(1) + 2, barRect(4) + 10]);
    Screen('FillRect', window, [255 255 255], [MarkerXPos(2) - 2, barRect(2) - 10, MarkerXPos(2) + 2, barRect(4) + 10]);
    Screen('FillRect', window, [255 255 255], [MarkerXPos(3) - 2, barRect(2) - 10, MarkerXPos(3) + 2, barRect(4) + 10]);
    
    % Draw the labels under the slider
    Screen('DrawText', window, '100% not the cause', labelPos(1,1), labelPos(1,2), [255 255 255]);
    Screen('DrawText', window, 'not sure', labelPos(2,1), labelPos(2,2), [255 255 255]);
    Screen('DrawText', window, '100% the cause', labelPos(3,1), labelPos(3,2), [255 255 255]);
    
    % Calculate the position of the marker based on the rating
    markerXPos = xCenter + (rating / maxRating) * (barWidth / 2);

    % Draw the marker on the rating bar
    Screen('FillRect', window, [255 165 0], [markerXPos - 5, barRect(2), markerXPos + 5, barRect(4)]);

    % Flip to the screen
    startTime = Screen('Flip', window);
        
    
    % target point hidden initially
    targetPointVisible = false;
    
    % Rating adjustment loop
    targetNotReached = true;
    
    while targetNotReached 
        % Draw sti & color frame
        Screen('DrawTexture', window, textureIndex_sti, [], stiCoor);
        Screen('DrawTexture', window, textureIndex_eff, [], coCoor);

        % Draw the rating bar background
        Screen('FillRect', window, [200 200 200], barRect);

        % Draw the middle, min, and max markers
        Screen('FillRect', window, [255 255 255], [MarkerXPos(1) - 2, barRect(2) - 10, MarkerXPos(1) + 2, barRect(4) + 10]);
        Screen('FillRect', window, [255 255 255], [MarkerXPos(2) - 2, barRect(2) - 10, MarkerXPos(2) + 2, barRect(4) + 10]);
        Screen('FillRect', window, [255 255 255], [MarkerXPos(3) - 2, barRect(2) - 10, MarkerXPos(3) + 2, barRect(4) + 10]);
       
        % Draw the labels under the slider
        Screen('DrawText', window, '100% not the cause', labelPos(1,1), labelPos(1,2), [255 255 255]);
        Screen('DrawText', window, 'not sure', labelPos(2,1), labelPos(2,2), [255 255 255]);
        Screen('DrawText', window, '100% the cause', labelPos(3,1), labelPos(3,2), [255 255 255]);

        % Calculate the position of the marker based on the rating
        markerXPos = xCenter + (rating / maxRating) * (barWidth / 2);

        % Draw the marker on the rating bar
        Screen('FillRect', window, [255 165 0], [markerXPos - 5, barRect(2), markerXPos + 5, barRect(4)]);
        
        % Draw the target point if it is visible
        if targetPointVisible
            Screen('FillOval', window, [255 0 0], [targetXPos - 5, barRect(2) - 5, targetXPos + 5, barRect(4) + 5]);
        end

        % Flip to the screen
        Screen('Flip', window);

        % Check if 300ms have passed to display the target point
        if ~targetPointVisible && (GetSecs - startTime) > 0.3
            targetPointVisible = true;
        end
        
        if ~scan

            % Check for key presses
            [keyIsDown, ~, keyCode] = KbCheck;
            if keyIsDown
                if keyCode(KbName('LeftArrow'))
                    rating = max(minRating, rating - 1);
                elseif keyCode(KbName('RightArrow'))
                    rating = min(maxRating, rating + 1);
                end
                
                % Check if the target point has been reached
                if targetPointVisible && abs(rating - previousRating) <= 1
                    resp_end =  GetSecs;
                    targetNotReached = false;
                end
    
                % Debounce key press
                WaitSecs(0.01);
            end
        else
            byte_in=io64(ioObj,address);
                % remember first one is inverted! 
            if button==-1 & (~bitget(byte_in,IO.buttonBit(1)) | any(bitget(byte_in,IO.buttonBit(2:end)))) 
                if ~bitget(byte_in,IO.buttonBit(1)) 
                    button = 1; 
                elseif bitget(byte_in,IO.buttonBit(3)) 
                    button = 3; 
                end 
            end 

            WaitSecs(0.010); 

            if button~=-1 
                keyCode(button) = 1; 
            end 

            if keyCode(1) == 1 
                rating = max(minRating, rating - 1);
                keyCode(1) = 0;
                button = -1;
            elseif keyCode(3) == 1 
                rating = min(maxRating, rating + 1);
                keyCode(3) = 0;
                button = -1;
            end 

            % Check if the target point has been reached
            if targetPointVisible && abs(rating - previousRating) == 0
                targetNotReached = false;
            end
        end

    end
    
    % Wait for the spacebar press after reaching the target
    spaceDown = false;
    while ~spaceDown
        if ~scan
            [keyIsDown, ~, keyCode] = KbCheck;
            if keyIsDown && keyCode(KbName('space'))
                resp_end =  GetSecs;
                spaceDown = true;
            end
            WaitSecs(0.01); % Small delay to prevent CPU overload
        else
            byte_in=io64(ioObj,address);
            if bitget(byte_in,IO.buttonBit(2)) 
               resp_end =  GetSecs;
               spaceDown = true;
            end
            WaitSecs(0.01); 
        end
    end

end

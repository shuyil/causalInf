function showSti(window, imageSource, effectSource, stiCoor, coCoor)
    % Function to draw two textures with transparency and time the onset and duration.
    % Inputs:
    %   window       - The window pointer where the textures will be drawn
    %   imageSource  - Fruit image
    %   effectSource - Colorframe image
    %   stiCoor      - Coordinates for drawing the base stimulus texture
    %   coCoor       - Coordinates for drawing the overlay texture with transparency


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

    % Draw sti & color frame
    Screen('DrawTexture', window, textureIndex_sti, [], stiCoor);
    Screen('DrawTexture', window, textureIndex_eff, [], coCoor);

end

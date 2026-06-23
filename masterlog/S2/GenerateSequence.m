clear all; clc;

% change the subject number here:
subject = 1;

% timing
outcome_isi = 2;

pd=makedist('Exponential','mu',4);
t = truncate(pd,3,5);

pd2=makedist('Exponential','mu',1.5);
t2 = truncate(pd,1,2);

% generate block sequence
for b = 1:2
    [colorframe,fruit,structSeq] = taskSchedule();
    % Save colorframe and fruit in a structure
    stimuliStruct.(['block' num2str(b)]).color = colorframe;
    stimuliStruct.(['block' num2str(b)]).struct = structSeq;
    stimuliStruct.(['block' num2str(b)]).fruit = fruit;
    
    
    for trial = 1:length(stimuliStruct.(['block' num2str(b)]).struct)
        
        stimuliStruct.(['block' num2str(b)]).fixation_duration(trial,:) = [random(t) random(t) random(t) random(t) random(t) random(t)];
        stimuliStruct.(['block' num2str(b)]).sti_duration(trial,:) = [random(t2) random(t2)];
    end

end

% Save the struct to a .mat file
save(['S' num2str(subject) '_stimuli.mat'], 'stimuliStruct');

%% functions
function [colorframe,fruit,structSeq] = taskSchedule()
    % Define the indices and stimuli
    fruitInd = 1:18;
    fruitSti = cell(length(fruitInd), 3); % Initialize as a cell array with 3 columns
    for i = 1:length(fruitInd)
        fruitSti{i, 1} = sprintf('img/M%d.png', fruitInd(i));
        fruitSti{i, 2} = sprintf('img/S%d1.png', fruitInd(i));
        fruitSti{i, 3} = sprintf('img/S%d2.png', fruitInd(i));
    end

    % ---------- * color frame * ------------%
    colorUnknown = 'img/color1.png';
    colorPos = {'img/color2.png', 'img/color4.png', 'img/color6.png'};
    colorNeg = {'img/color3.png', 'img/color5.png', 'img/color7.png'};

    % Sequence structure
    structOrder = [1, 2, 1, 3, 1, 2, 1];
    % 1 = backwards blocking; 2 = one-cause; 3 = two-cause
    structSeq = [];

    % Generate struct sequence
    for element = structOrder
        rep = randi([3, 5]); % Get a random number between 3 and 5
        unit = repmat(element, 1, rep);

        % Insert the first control trial (0)
        zeroPosition1 = randi(length(unit));
        unit = [unit(1:zeroPosition1-1) 0 unit(zeroPosition1:end)];

        % Insert the second control trial (0)
        zeroPosition2 = zeroPosition1;
        while zeroPosition2 == zeroPosition1
            zeroPosition2 = randi(length(unit) + 1);
        end
        unit = [unit(1:zeroPosition2-1) 0 unit(zeroPosition2:end)]';

        structSeq = [structSeq; unit];
    end

    % Based on struct sequence, create sequence of colorframe
    colorframe = cell(length(structSeq), 3); % Initialize as a cell array with 3 columns
    for i = 1:length(structSeq)
        element = structSeq(i);
        if element == 0
            [color1, color2] = getTwoDifferentColors(colorNeg);
        elseif element == 1 || element == 3
            [color1, color2] = getTwoDifferentColors(colorPos);
        elseif element == 2
            color1 = getRandomColor(colorPos);
            color2 = getRandomColor(colorNeg);
        end
        colorframe{i, 1} = color1;
        colorframe{i, 2} = color2;
        colorframe{i, 3} = colorUnknown;
    end

    % Shuffle and expand fruitSti
    fruitStiShuffled = fruitSti(randperm(size(fruitSti, 1)), :);
    fruit = repmat(fruitStiShuffled, ceil(length(structSeq) / size(fruitStiShuffled, 1)), 1);
    fruit = fruit(1:length(structSeq), :);

    % Switch the second and third columns for each row based on random condition
    for i = 1:length(fruit)
        % Switch the second and third columns for each row based on random condition
        if rand > 0.5
            temp = fruit{i, 2};
            fruit{i, 2} = fruit{i, 3};
            fruit{i, 3} = temp;
        end
        % Switch the first and third columns based on structSeq
        if structSeq(i) == 3
            temp = fruit{i, 1};
            fruit{i, 1} = fruit{i, 3};
            fruit{i, 3} = temp;
        end
    end



    
end

% Auxiliary functions
function color = getRandomColor(colorArray)
    color = colorArray{randi(length(colorArray))};
end

function [color1, color2] = getTwoDifferentColors(colorArray)
    while true
        color1 = getRandomColor(colorArray);
        color2 = getRandomColor(colorArray);
        if ~strcmp(color1, color2)
            break;
        end
    end
end

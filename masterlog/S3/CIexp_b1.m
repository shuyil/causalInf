clc; clearvars; close all

%%% social credit assignment experiment - block1 
scan = 1;

data.individual.id = input('Subject Id: ');
data.individual.age = input('Subject age: ');
data.individual.gender =  input('male or female: ', 's');
resultFileName  =  ['S', int2str(data.individual.id) , '_CI_b1' ];

scheduleFileName = ['S' int2str(data.individual.id) '_stimuli'];
load(scheduleFileName)

%% open the screen

Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'VisualDebugLevel', 0); 
% turn off sone of the Psychtoolbox messages 
oldLevel = Screen('Preference', 'Verbosity', 1);
%HideCursor;

whichScreen = 0;
[window, windowRect] = Screen(whichScreen, 'OpenWindow');


% Choose a smaller window size for testing
%windowSize = [0 0 800 600]; % [left top right bottom]

% Open a window with the specified size (windowed mode)
%[window, windowRect] = PsychImaging('OpenWindow', max(Screen('Screens')), [0 0 0], windowSize);


% enable PTB to take processing priority over other system and applicaiton processes
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

% determine the values of color
white = WhiteIndex(window);
black = BlackIndex(window);
grey = (white + black)/2;
% set the background to be black
Screen(window, 'FillRect', grey); 

% get the size of the screen
scrW = windowRect(3);
scrH = windowRect(4);

% 
if scan
    ratio = 1;
else
    ratio = 0.4;
end

%% keyboard information
% upKey = KbName('UpArrow');
% downKey = KbName('DownArrow');
% leftKey = KbName('LeftArrow');
% rightKey = KbName('RightArrow');

%% triger part
if scan
    [ioObj, status] = IOport_open;    
    
    % FMRIB: 0x378 data, 0x379 status, 0x37a control
    address = hex2dec('379'); %standard LPT1/parallel port address
    
    % opens serial port to scanner
    [IO] = IOport_logic; %returns IO.trig, IO.trigbit, IO.def, IO.buttons (4 rows), IO.buttonBit                                                           % defines IO.trig, IO.def, IO.buttons (4 rows)
    %buttonbox     = 1;

    %open_IOport;
    %IOport_logic;

% Wait for first two scan trigger (after dummies)
% ======================================================================= %
    %dispInstructScan;
    
    %-wait for scanner to start (fmrib: one trigger per volume)
    byte_in = 0;
    while ~bitget(byte_in,IO.trigBit)                                       % (byte_in~=IO.trig)
        byte_in=io64(ioObj,address);
        WaitSecs(0.005);
    end
   data.tTrig1 = GetSecs;
    
    %-wait for trigger to be reset again (80ms)
    %byte_in = 0;
    while bitget(byte_in,IO.trigBit) %(byte_in~=IO.def)
        byte_in=io64(ioObj,address);
        WaitSecs(0.005);
    end
    
    %-apparently at FMRIB no triggers for 5 dummy vols send, so just
    % wait for one more then start
    volumeCtt = 1;
    while volumeCtt<2                                                       % SLICE.dummy
        byte_in=io64(ioObj,address);
        if bitget(byte_in,IO.trigBit)                                       % byte_in==IO.trig
            volumeCtt = volumeCtt+1;
        end
        WaitSecs(0.005);
    end
    data.tTrig2 = GetSecs;
else
    IO = 0;
    ioObj = 0;
    address = 0;
end

%% setting parameter
schedule = stimuliStruct.block1;
data.schedule = schedule;

% general
bgColor = grey;

% fixation
fixCrossDimPix = 20;
lineWidthPix = 5;
crossColor = white;

% stimulus
size_sti = [550 550]*ratio;
skew = 50;

stiCoor = [(scrW - size_sti(1))/2 (scrH-size_sti(2))/2-skew (scrW + size_sti(1))/2 (scrH+size_sti(2))/2-skew];

% colorframe
size_co= [650 650]*ratio;
coCoor = [(scrW - size_co(1))/2 (scrH-size_co(2))/2-skew (scrW + size_co(1))/2 (scrH+size_co(2))/2-skew];

% rating bar
[xCenter, yCenter] = RectCenter(stiCoor);

barWidth = 750*ratio;
barHeight = 30*ratio;
barRect = [xCenter - barWidth / 2, yCenter + 400*ratio - skew, xCenter + barWidth / 2, yCenter + 400*ratio + barHeight - skew];
MarkerXPos = [xCenter xCenter - barWidth / 2 xCenter + barWidth / 2];

% marker text
textSize = 35;
labelXY = [MarkerXPos(2) barRect(4)+50*ratio; MarkerXPos(1) barRect(4)+50*ratio; MarkerXPos(3) barRect(4)+50*ratio];
labelOffset = zeros(3, 2);
% Get the offsets for each text and store them in the array
[labelOffset(1, 1), labelOffset(1, 2)] = GetOffsetForText('100% not the cause', textSize, window);
[labelOffset(2, 1), labelOffset(2, 2)] = GetOffsetForText('not sure', textSize, window);
[labelOffset(3, 1), labelOffset(3, 2)] = GetOffsetForText('100% the cause', textSize, window);

labelPos = labelXY - labelOffset;

%% start experiment

Screen(window, 'TextFont', 'Arial');
Screen(window, 'TextSize', 40);

DrawFormattedText(window, 'Welcome to the experiment! You are about to start Part 1.',...
    'center', 'center', white);
data.block.start = Screen('Flip', window);
WaitSecs(5);


%% experiment loop

for trial = 1:length(schedule.struct)
    
    %% draw fixation point
    Screen(window, 'FillRect', grey);
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

    % fixation 1
    Screen('DrawDots', window, [scrW/2; scrH/2], 20 , [255 0 0], [], 2);
    data.output.timing.start(trial,1) = Screen(window,'Flip'); % onset
    WaitSecs(schedule.fixation_duration(trial,1));  
    
    %% stage 1 
    %% first stimulus
    % Enable alpha blending for transparency
    showSti(window, schedule.fruit{trial,1}, schedule.color{trial,1}, stiCoor, coCoor)
    
    data.output.timing.sti1_onset(trial,1) = Screen(window,'Flip');
    WaitSecs(schedule.sti_duration(trial,1));
    
    % fixation 2
    drawFixationCross(window, windowRect, fixCrossDimPix, lineWidthPix, crossColor)    
    data.output.timing.fixation2_onset(trial,1) = Screen(window,'Flip');
    WaitSecs(schedule.fixation_duration(trial,2));
    
    %% first rating phase
    % if order = 1, l - un; order = 2, un - l
    if rand > 0.5
        data.output.s1_order(trial,1) = 1; % save order information for stage 1
        
        % rating - learn
        [data.output.l_rating1(trial,1), data.output.timing.l_rating1_onset(trial,1), data.output.timing.l_rating1_end(trial,1)] = rateCause(window, scan, schedule.fruit{trial,2}, schedule.color{trial,3}, stiCoor, coCoor, xCenter, barRect, barWidth, MarkerXPos, labelPos,IO,ioObj,address);
        
        % fixation 3
        drawFixationCross(window, windowRect, fixCrossDimPix, lineWidthPix, crossColor)    
        data.output.timing.fixation3_onset(trial,1) = Screen(window,'Flip');
        WaitSecs(schedule.fixation_duration(trial,3));
        
        % rating - unlearn
        [data.output.un_rating1(trial,1), data.output.timing.un_rating1_onset(trial,1), data.output.timing.un_rating1_end(trial,1)] = rateCause(window, scan, schedule.fruit{trial,3}, schedule.color{trial,3}, stiCoor, coCoor, xCenter, barRect, barWidth, MarkerXPos, labelPos,IO,ioObj,address);
    else        
        data.output.s1_order(trial,1) = 2; % save order information for stage 1
        
        % rating - unlearn
        [data.output.un_rating1(trial,1), data.output.timing.un_rating1_onset(trial,1), data.output.timing.un_rating1_end(trial,1)] = rateCause(window, scan, schedule.fruit{trial,3}, schedule.color{trial,3}, stiCoor, coCoor, xCenter, barRect, barWidth, MarkerXPos, labelPos,IO,ioObj,address);
        
        % fixation 3
        drawFixationCross(window, windowRect, fixCrossDimPix, lineWidthPix, crossColor)    
        data.output.timing.fixation3_onset(trial,1) = Screen(window,'Flip');
        WaitSecs(schedule.fixation_duration(trial,3));
        
        % rating - learn
        [data.output.l_rating1(trial,1), data.output.timing.l_rating1_onset(trial,1), data.output.timing.l_rating1_end(trial,1)] = rateCause(window, scan, schedule.fruit{trial,2}, schedule.color{trial,3}, stiCoor, coCoor, xCenter, barRect, barWidth, MarkerXPos, labelPos,IO,ioObj,address);
    end
    
    % fixation 4
    drawFixationCross(window, windowRect, fixCrossDimPix, lineWidthPix, crossColor)    
    data.output.timing.fixation4_onset(trial,1) = Screen(window,'Flip');
    WaitSecs(schedule.fixation_duration(trial,4));
    
    %% stage 2
    %% second stimulus + target point
    % if order = 1, target - un-rating - first sti
    % if order = 2, target - first sti - un-rating (remove this condition after participant 2)
    % if order = 3, first sti - target - un-rating
    
    ind = rand;
    if ind > 0.5
        data.output.s2_order(trial,1) = 1;
        
        % target
        previousRating = data.output.l_rating1(trial);
        [data.output.timing.l_target_onset(trial,1), data.output.timing.l_target_end(trial,1)] = rateTarget(window, scan,  schedule.fruit{trial,2}, schedule.color{trial,2}, previousRating, stiCoor, coCoor, xCenter, barRect, barWidth, MarkerXPos, labelPos,IO,ioObj,address);

        % fixation 5
        drawFixationCross(window, windowRect, fixCrossDimPix, lineWidthPix, crossColor)    
        data.output.timing.fixation5_onset(trial,1) = Screen(window,'Flip');
        WaitSecs(schedule.fixation_duration(trial,5));
        
        % un-rating
        [data.output.un_rating2(trial,1), data.output.timing.un_rating2_onset(trial,1), data.output.timing.un_rating2_end(trial,1)] = rateCause(window, scan, schedule.fruit{trial,3}, schedule.color{trial,3}, stiCoor, coCoor, xCenter, barRect, barWidth, MarkerXPos, labelPos,IO,ioObj,address);
        
        % fixation 6
        drawFixationCross(window, windowRect, fixCrossDimPix, lineWidthPix, crossColor)    
        data.output.timing.fixation6_onset(trial,1) = Screen(window,'Flip');
        WaitSecs(schedule.fixation_duration(trial,6));
        
        % first-sti rep
        showSti(window, schedule.fruit{trial,1}, schedule.color{trial,1}, stiCoor, coCoor)
        data.output.timing.sti1_rep_onset(trial,1) = Screen(window,'Flip');
        WaitSecs(schedule.sti_duration(trial,2)); % duration for repeating the first stimulus 
        
    else
        data.output.s2_order(trial,1) = 3;

        % first-sti rep
        showSti(window, schedule.fruit{trial,1}, schedule.color{trial,1}, stiCoor, coCoor)
        data.output.timing.sti1_rep_onset(trial,1) = Screen(window,'Flip');
        WaitSecs(schedule.sti_duration(trial,2)); % duration for repeating the first stimulus
        
        % fixation 5
        drawFixationCross(window, windowRect, fixCrossDimPix, lineWidthPix, crossColor)    
        data.output.timing.fixation5_onset(trial,1) = Screen(window,'Flip');
        WaitSecs(schedule.fixation_duration(trial,5));        
        
        % target
        previousRating = data.output.l_rating1(trial);
        [data.output.timing.l_target_onset(trial,1), data.output.timing.l_target_end(trial,1)] = rateTarget(window, scan,  schedule.fruit{trial,2}, schedule.color{trial,2}, previousRating, stiCoor, coCoor, xCenter, barRect, barWidth, MarkerXPos, labelPos,IO,ioObj,address);
        
        % fixation 6
        drawFixationCross(window, windowRect, fixCrossDimPix, lineWidthPix, crossColor)    
        data.output.timing.fixation6_onset(trial,1) = Screen(window,'Flip');
        WaitSecs(schedule.fixation_duration(trial,6));
        
        % un-rating
        [data.output.un_rating2(trial,1), data.output.timing.un_rating2_onset(trial,1), data.output.timing.un_rating2_end(trial,1)] = rateCause(window, scan, schedule.fruit{trial,3}, schedule.color{trial,3}, stiCoor, coCoor, xCenter, barRect, barWidth, MarkerXPos, labelPos,IO,ioObj,address);        
    end
    
    %% save the data every trial
    save(resultFileName,'data');
    
end

%% end of every block
text = ['End of Part 1.'];
DrawFormattedText(window, text, 'center', 'center', white);
data.block.end = Screen('Flip', window);
WaitSecs(5)

save(resultFileName,'data');

Priority(0);
% turn on Psychtoolbox messages again
Screen('Preference', 'Verbosity', oldLevel);
Screen('CloseAll'); 

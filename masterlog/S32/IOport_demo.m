% Script demonstrating how to open and close the IO port and wait for a
% trigger
%
% Miriam Klein-Flügge @FMRIB, Sep 2015

[ioObj, status] = IOport_open;

% FMRIB: 0x378 data, 0x379 status, 0x37a control
address = hex2dec('379'); %standard LPT1/parallel port address

% Here all we need is IO.trigBit = 7; %so can use that line instead of the 
% call to IOport_logic for simplicity if buttonbox not needed
[IO] = IOport_logic; %returns IO.trig, IO.trigbit, IO.def, IO.buttons (4 rows), IO.buttonBit
disp(['Trigger bit is ',num2str(IO.trigBit)]);

% Wait for scanner to start (FMRIB: one trigger per volume)
byte_in = 0;
disp('Waiting for scan trigger...');
while ~bitget(byte_in,IO.trigBit)
    byte_in=io64(ioObj,address);
    WaitSecs(0.005);
end

% % for PsychToolBox users: you can use this to wait for any button press
% disp(['Button bits are ',num2str(IO.buttonBit)]);
% PsychDefaultSetup(2);
% disp('Waiting for button press...');
% [tKeyPress,keyCode] = IOWaitButton(IO,Inf,ioObj,address);
% disp(['Button ',num2str(find(keyCode)),' pressed...']);
% sca;

% close IO port
clear io64;

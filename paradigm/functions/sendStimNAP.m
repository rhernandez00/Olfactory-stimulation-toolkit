function sendStimNAP(a,stimType)
% sends a puff of a determined stimType.
% a - arduino.If a is false, means that it is testing, stimType takes 1-5
% sending a puff switches on one of the digital outputs of arduino (a)
% waits onSecs s and switches off the digital output offSecs
totalTimeOn = 1;
onSecs = 0.8; %time that the digital output remains on

switch stimType %selects the digital output
    case 1
        digitalOutput = 'D3';
    case 2
        digitalOutput = 'D4';
    case 3
        digitalOutput = 'D5';
    case 4
        digitalOutput = 'D6';
    case 5
        digitalOutput = 'D7';
end
if isequal(a,false) %means it is testing
    disp(['Test mode, stim sent was: ',num2str(stimType)]);
    disp('pausing')
    pause(onSecs);
    disp('end of puff');
else %means this is a real trial
    writeDigitalPin(a, digitalOutput, 1);
    pause(onSecs);
    writeDigitalPin(a, digitalOutput, 0);
end
pause(totalTimeOn-onSecs);
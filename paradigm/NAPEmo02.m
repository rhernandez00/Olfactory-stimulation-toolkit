%This script runs a detection test using the olfactory delivery device and
%the vacuum cleaner. The test is intended to be run in the MR and uses the
%parallell stim box from the MR to trigger the start of the trial
%testVacuum, testOlfactory and testStimBox are variables used to change
%whether those devices are in testing mode (run everything normally but
%dont use the device) or normal mode (operates the device)
% Author: Raul Hernandez 22/Jan/2024
%

clear all
participant = input('Participant name? ', 's'); %participant name

addpath([pwd,'\functions']); %adds needed functions

testVacuum = true; %true - testing mode, doesn't use device but everything 
%else remains the same, false - normal mode, opens the port and uses de device
testOlfactory = true; %true - testing mode, doesn't use device but everything 
%else remains the same, false - normal mode, opens the port and uses de device
testStimBox = true; %true - testing mode, doesn't use device but everything 
%else remains the same, false - normal mode, opens the port and uses de device
 
%Variables regarding experiment duration, repetitions, padding, etc.
stimTypes = 1:2;
repetitionsPerStim = 24; %repetitions per stim
stimTime = 1;
paddedTimeBefore = 11;
paddedTimeAfter = 6; %which actually amounts to paddedTimeAfter+minITI (6 + 4 = 10)
minITI = 4;
maxITI = 8;

[complete,totalDuration] = createTimeLine(stimTypes,repetitionsPerStim,...
    stimTime,paddedTimeBefore,paddedTimeAfter,minITI,maxITI);
%%
portOlfactory = "COM3"; %port of the olfactory delivery device
portVacuum = "COM4"; %port of the vaccum cleaner

%---Preparing vacuum cleaner and olfactory delivery device ---
if testVacuum %testing
    aVacuum = false;
else %real
    aVacuum = arduino(portVacuum,'ProMini328_5V'); %#ok<*UNRCH>
%     writeDigitalPin(portVacuum, 'D09', 1); %vacuum on
end
if testOlfactory %testing
    aOlfactory = false;
else %real
    aOlfactory = arduino(portOlfactory,'Uno'); 
    
end
%---finished preparing vacuum cleaner and olfactory delivery device --------------



%---preparing paralell trigger for MR stim box ------
trigger = 's';

if strcmp(trigger, 'k')
    disp('Trigger with keyboard only');
    trigchk = 0;
elseif testStimBox
    disp('MR stim box off, will use keyboard');
    trigchk = 0;
else
    trigchk = 1;
    % Prepare parallel port
    par_interface=1;
    par_port_address=55549;
    rpstring{1}='read_parallel(par_port_address,ioObj)';
    rpstring{2}='lptread(par_port_address)';
    % prepare parallel port, load x64 IO parallel port
    ioObj = io64;
    % initialize the interface to the inpoutx64 system driver
    status = io64(ioObj);
end

if trigchk == 1
    switch par_interface
        case 1
            write_parallel(55549,bitset(uint8(read_parallel(55549,ioObj)),6,1));
        case 2
            lptread_init(par_port_address);
        otherwise
    end
    eval(rpstring{par_interface});
end
% ---- stopped preparing paralell box for MR ------


%%
%waits to start
pause(1)
disp('Waiting for start')

% Wait for trigger
wfsignal = 1;
while wfsignal == 1
    [keyisdown, secs, keycode]=KbCheck;
    if  (keyisdown) || (trigchk && bitand(uint8(eval(rpstring{par_interface})),uint8(64)))
        wfsignal=0;
    end
end

dateAndTime = datetime('now'); %gets the date to save the file
tic; %starts counting the time
disp('starting')
if ~testVacuum
    writeDigitalPin(aVacuum, 'D9', 1); %turns on vacuum cleaner
    disp('Vacuum cleaner on');
else
    disp('Vacuum cleaner on, testing mode');
end


eventsLog = zeros(1,size(complete,2));
%%
pauseVacuum = 1;
for nEvent = 1:size(complete,2)
    
    eventType = complete(nEvent).eventType;
    eventTime = complete(nEvent).onset;
    currentTime = toc; %takes the current time
    
    pause(eventTime-currentTime-pauseVacuum); %pauses until the event -pauseVacuum to turn off vacuum
    if ~testVacuum
        disp(['This many seconds have passed since the start: ',num2str(toc)]);
        writeDigitalPin(aVacuum, 'D9', 0); %turns off vacuum cleaner
        disp('Vacuum cleaner off');
    else
        disp(['This many seconds have passed since the start: ',num2str(toc)]);
        disp('Vacuum cleaner off, testing mode');
    end
    currentTime = toc; %takes the current time
    pause(eventTime-currentTime); %pauses until the event
    disp(['Event: ', num2str(eventType), ', This many seconds have passed since the start: ',num2str(toc)]);
    sendStimNAP(aOlfactory,eventType);
    
    if ~testVacuum
        disp(['This many seconds have passed since the start: ',num2str(toc)]);
        writeDigitalPin(aVacuum, 'D9', 1); %turns on vacuum cleaner
        disp('Vacuum cleaner on');
    else
        disp(['This many seconds have passed since the start: ',num2str(toc)]);
        disp('Vacuum cleaner on, testing mode');
    end
    
    eventsLog(nEvent) = toc; 
    
    save(['logs\',participant,'_',date,'_',sprintf('%02d',hour(dateAndTime)),sprintf('%02d',minute(dateAndTime))],'eventsLog','complete');
end
if ~testVacuum
    writeDigitalPin(aVacuum, 'D9', 0); %turns off vacuum cleaner
    disp('Vacuum cleaner off');
else
    disp('Vacuum cleaner off, testing mode');
end

disp(['Experiment ending, waiting ', num2str(paddedTimeAfter), ' for baseline...']);
pause(paddedTimeAfter);
disp(['This many seconds have passed since the start: ',num2str(toc)]);
disp('Experiment ended.')

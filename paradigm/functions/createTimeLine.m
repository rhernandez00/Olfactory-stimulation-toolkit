function [complete,totalDuration] = createTimeLine(stimTypes,repetitionsPerStim,...
    stimTime,paddedTimeBefore,paddedTimeAfter,minITI,maxITI)
%Creates a timeLine and an event list for a event related paradigm with a
% random ITI of mean meanTime. It adds a padded time before the first
% stimuli and at the end of the stimulation period

% stimTypes: vector of times of stimuli in numerical form
% repetitionsPerStim: number of repetitions per type of stim
% stimTime: duration of stimulation
% paddedTimeAfter: padded time before stimulation beggins
% minITI: minimal duration of ITI
% maxITI: maximum ITI
meanTime = (minITI + maxITI)/2;

nEvents = numel(stimTypes)*repetitionsPerStim;
availableTime = meanTime*nEvents;


intervals = shake(splitIntervals(availableTime,nEvents,meanTime,minITI,maxITI));

%creates a randomized event list
eventsList = [];
for nStimType = 1:numel(stimTypes)
    stimType = stimTypes(nStimType);
    eventsList = [eventsList,ones(1,repetitionsPerStim).*stimType]; %#ok<AGROW>
end
eventsList = shake(eventsList);

eventsTimeLine = paddedTimeBefore;
for n = 1:nEvents
    eventsTimeLine = [eventsTimeLine,stimTime + intervals(n)]; %#ok<AGROW>
end

eventsTimeLine = cumsum(eventsTimeLine);
for nEvent = 1:numel(eventsList)
    complete(nEvent).onset =eventsTimeLine(nEvent);
    complete(nEvent).eventType = eventsList(nEvent);
end
totalDuration = eventsTimeLine(end) + stimTime + paddedTimeAfter;
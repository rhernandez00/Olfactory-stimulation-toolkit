function intervals = splitIntervals(totalTime,nSplits,meanTime,minTime,maxTime)
%The function splits the total time (totalTime) into a number of intervals 
% (nSplits). The intervals have a minimum time of minTime, a maximum time 
% of maxTime and an average of meanTime

%Initialize the output vector
intervals = zeros(1,nSplits);

%Check if the input parameters are valid
if totalTime < nSplits*minTime || totalTime > nSplits*maxTime || meanTime < minTime || meanTime > maxTime
    error('Invalid input parameters');
end

%Generate random intervals that sum up to the total time
while sum(intervals) ~= totalTime
    %Generate nSplits-1 random numbers between minTime and maxTime
    intervals(1:end-1) = randi([minTime,maxTime],1,nSplits-1);
    %Compute the last interval as the difference between the total time and the sum of the previous intervals
    intervals(end) = totalTime - sum(intervals(1:end-1));
    %Check if the last interval is within the range [minTime,maxTime]
    if intervals(end) < minTime || intervals(end) > maxTime
        %If not, repeat the process
        continue;
    end
    %Check if the average of the intervals is close to the mean time (within 0.01 tolerance)
    if abs(mean(intervals) - meanTime) > 0.01
        %If not, repeat the process
        continue;
    end
end


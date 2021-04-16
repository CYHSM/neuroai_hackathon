% Example that shows how to read NWB file
%
% This function reads information about spike timestamps and position values
% from NWB files. It plots raw position data and makes a path plot
% of one cell.
%
%  USAGE
%    readNwb(filename)
%
%    filename        Path to a NWB file.
%
function [posx,posy,post, unitList, unitData] = readNwb_wdc(filename)
    %% plot raw position data
    % read epoch information to find out session ID
    epochs = h5info(filename, '/epochs');
    % take the name of the very first epoch
    [~, epochName] = fileparts(epochs.Groups(1).Name);
    % use it to read raw position data
    posDataPath = sprintf('/acquisition/timeseries/%s-LED1/data', epochName);
    % pos is Nx2 matrix of coordinates in form [x y]
    pos = h5read(filename, posDataPath)';
    % convert pos to provided units
    posScaleFactor = h5readatt(filename, posDataPath, 'conversion');
    pos = pos * posScaleFactor;
    posUnit = h5readatt(filename, posDataPath, 'unit');
    % plot raw position data
    maxValue = max(max(pos)) + 100; % this is used for visualization
%     figure, plot(pos(:, 1), pos(:, 2), '.');
%     axis([0 maxValue 0 maxValue]);
%     xlabel(posUnit);
%     ylabel(posUnit);
%     title('Raw position data');

    % number of eeg streams:
    acqusitionInfo = h5info(filename, '/acquisition/timeseries/');
    acqusitionGroupNames = {acqusitionInfo.Groups(:).Name}; % 1xN cell array of group names
    % fetch grups that contain 'eeg-' in their name
    eegIndices = find(cellfun(@(x) ~isempty(strfind(x, 'eeg-')), acqusitionGroupNames));
%     fprintf('There are %u EEG streams in file\n', length(eegIndices));

    if ~isempty(eegIndices)
        %% read one eeg signal
        eegDataPath = sprintf('/acquisition/timeseries/%s-eeg-0/data', epochName);
        eegData = h5read(filename, eegDataPath);
        eegScaleFactor = h5readatt(filename, eegDataPath, 'conversion');
        eegUnit = h5readatt(filename, eegDataPath, 'unit');
        eegData = eegData * eegScaleFactor;
        startTimePath = sprintf('/acquisition/timeseries/%s-eeg-0/starting_time', epochName);
        eegStartTime = h5read(filename, startTimePath);
        eegFs = h5readatt(filename, startTimePath, 'rate');
        eegTs = eegStartTime:1/eegFs:(length(eegData)-1)/eegFs;
    end


    %% obtain information about units and make one plot with spikes on top of the path
    % read processed position data
    bodyPosPath = '/processing/matlab_scripts/Position/body/data';
    % pos is Nx2 matrix of coordinates in form [x y]
    pos = h5read(filename, bodyPosPath)';
    posScaleFactor = h5readatt(filename, bodyPosPath, 'conversion');
    pos = pos * posScaleFactor;
    posUnit = h5readatt(filename, bodyPosPath, 'unit');
    posx = pos(:, 1);
    posy = pos(:, 2);

    % read timestamps assigned to positions
    post = h5read(filename, '/processing/matlab_scripts/Position/body/timestamps');

    % read information about spikes
    unitList = h5read(filename, '/processing/matlab_scripts/UnitTimes/unit_list');
    unitData = cell(size(unitList));
    numUnits = numel(unitList);
    for i = 1:numUnits
        unitPath = sprintf('/processing/matlab_scripts/UnitTimes/%u/times', i-1);
        unitData{i} = h5read(filename, unitPath);
%         fprintf('Unit %u, number of spikes: %u\n', i, numel(unitData));
    end
end

% Get spike positions in space
%
% This function converts spike timestamps to x-coordinates.
%
%  USAGE
%   [spkPos, rejected] = mapSpikes2Positions(spikeTs, post, posx)
%   spikeTs     Column-vector of spike timestamps in seconds, size Sx1.
%   post        Nx1 vector of position timestamps in seconds.
%   pos         Nx2 vector of position spatial coordinate.
%   spkPos      Matrix Mx3 of spike positions. 1 column is time, 2 - x-coordinate,
%               3 - y-coordinate.
%               M is the number of valid spikes, can be less than S.
%   rejected    Indices of rejected spikes. These indices correspond to input vector spikeTs.
%               length(rejected) + size(spkPos, 1) = length(spikeTs);
%
function [spkPos, rejected] = mapSpikes2Positions(spikeTs, post, pos)
    sampleTime = mean(diff(post));
    minTime = min(post);
    maxTime = max(post) + sampleTime;
    rejected = [];
    numRejected = 0;

    % make column vector instead of row vector
    if size(spikeTs, 1) == 1 && size(spikeTs, 2) > 1
        spikeTs = spikeTs';
    end
    if size(post, 1) == 1 && size(post, 2) > 1
        post = post';
    end

    N = size(spikeTs, 1);
    spkPos = zeros(N, 2);

    count = 0;
    tmpSpkInd = knnsearch(post, spikeTs); % another option:
                                          % >> tri = delaunayn(post');
                                          % >> dsearchn(post', tri, spikeTs)

    for i = 1:length(tmpSpkInd)
        ind = tmpSpkInd(i);
        if spikeTs(i) < minTime || spikeTs(i) > maxTime
            numRejected = numRejected + 1;
            rejected(numRejected, 1) = i; %#ok<*AGROW>
            continue;
        end
        if any(isnan(pos(ind, :)))
            numRejected = numRejected + 1;
            rejected(numRejected, 1) = i;
        else
            count = count + 1;
            spkPos(count, 1) = post(ind);
            spkPos(count, 2) = pos(ind, 1);
            spkPos(count, 3) = pos(ind, 2);
        end
    end

    spkPos = spkPos(1:count, :);
end
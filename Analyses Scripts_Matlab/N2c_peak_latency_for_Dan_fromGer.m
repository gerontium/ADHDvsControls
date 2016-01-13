% PARAMETERS AT THE TOP OF THE SCRIPT
% NB: this is quarter the window size in samples, each sample = 2ms and
% it's this either side. See line 18.
window_size = 25; 
% contra and search frames encompass the entire negativity.
contra_peak_t = [150,500]; contra_peak_ts(1) = find(t==contra_peak_t(1)); contra_peak_ts(2) = find(t==contra_peak_t(2));

% SEARCHING FOR PEAK LATENCY
clear N2c_peak_latencies
% for each trial...

for trial = 1:size(ERP_temp,3) % ERP_temp is chan x time x trial
    % search your search timeframe, defined above by contra_peak ts, in sliding windows
    % NB this is done in samples, not time, it's later converted.
    clear win_mean win_mean_inds
    counter = 1;
    for j = contra_peak_ts(1)+window_size:contra_peak_ts(2)-window_size
        % get average amplitude of sliding window from N2pc electrode
        win_mean(counter) = squeeze(mean(mean(ERP_temp(ch_lr(side,:),j-window_size:j+window_size,trial),1),2));
        % get the middle sample point of that window
        win_mean_inds(counter) = j;
        counter = counter+1;
    end
    % find the most negative amplitude in the resulting windows
    [~,ind_temp] = min(win_mean);
    % get the sample point which had that negative amplitude
    N2pc_min_ind = win_mean_inds(ind_temp);
    
    % if the peak latency is at the very start or end of the search
    % timeframe, it will probably be bogus. set to NaN.
    if ind_temp==1 | ind_temp==length(win_mean)
        N2c_peak_latencies(trial) = NaN;
    else 
        % it's good! add it in.
        N2c_peak_latencies(trial)= t(N2pc_min_ind);
    end
end
% you can get rid of these nans afterwards if you need... make sure you do
% the same to other vectors if you're correlating them or adding them in fo
% r R analysis
N2c_peak_latencies(find(isnan(N2c_peak_latencies))) = [];
% The first 8 lines are settings which go at the top of your code.
% The rest is inside the subject loop after you have their erp and conds

% These 8 lines go at the top of the script.
% Define CPP onset search window, from 0 to 1000ms
CPP_search_t  = [0,1000];
% Same window in samples
CPP_search_ts  = [find(t==CPP_search_t(1)),find(t==CPP_search_t(2))];
% Size of sliding window. This is in fact 1/4 of the search window in ms.
% So 25 is 100ms. (25 samples x 2ms either side of a particular sample).
max_search_window = 25;

clear CPPs
% This is done after you have your erp matrix. Here, we're comparing onsets across 2 coherences.
for coh = 1:2
    CPP_temp = squeeze(mean(erp(ch_CPP,:,[conds{s,coh,:,:,:}]),1)); % time x trial
    CPPs(:,coh) = squeeze(mean(CPP_temp(:,:),2)); % average across trial for plot later on, not used to find onsets.
    % constrain the search window according to parameters above.
    CPP_temp = squeeze(CPP_temp(find(t>=CPP_search_t(1) & t<=CPP_search_t(2)),:));
    prestim_temp = find(t<CPP_search_t(1)); % so we can add it on after getting max peak.
    
    % we want sliding windows for each trial, create smoothed waveform.
    clear win_mean win_mean_inds tstats ps
    for trial = 1:size(CPP_temp,2)
        counter = 1;
        for j = max_search_window:2:size(CPP_temp,1)-max_search_window
            win_mean(counter,trial) = mean(CPP_temp([j-max_search_window+1:j+max_search_window-1],trial));
            win_mean_inds(counter) = j;
            counter = counter+1;
        end
    end
    
    % do t-test to zero across the smoothed trials.
    for tt = 1:size(win_mean,1)
        [~,P,~,STATS] = ttest(win_mean(tt,:));
        tstats(tt) = STATS.tstat;
        ps(tt) = P;
    end
    
    % when does the ttest cross 0.05? If at all?
    onsetp05 = find(ps<0.05 & tstats>0,1,'first'); 
    
    % get timepoint of min index.
    if ~isempty(onsetp05)
        onset_ind = win_mean_inds(onsetp05);
        CPP_onset_ind = onset_ind + length(prestim_temp); % see above, this needs to be added to get the overall time with respect to t.
        CPP_coh_onsets(s,coh) = t(CPP_onset_ind);
    else % onsetp05 is empty, no significant CPP.
        disp([allsubj{s},': bugger'])
        CPP_coh_onsets(s,coh) = 0;
    end
    
    % plot the smoothed waveforms, the corresponding t-tests and p-values.
    % Make sure the 10 following p-values from onset are also lower than
    % 0.05. Could code this above, but I found it was unnecessary. Still,
    % be aware.
    figure
    subplot(3,1,1)
    plot(win_mean_inds,mean(win_mean,2))
    title(allsubj{s})
    subplot(3,1,2)
    plot(win_mean_inds,tstats)
    subplot(3,1,3)
    plot(win_mean_inds,ps), hold on
    line(xlim,[0.05,0.05],'Color','k','LineWidth',1);
    if ~isempty(onsetp05)
        line([onset_ind,onset_ind],ylim,'Color','g','LineWidth',1);
    else
        line([0,0],ylim,'Color','r','LineWidth',1);
    end
end
% plot the average CPPs across coherences, with onsets plotted for each.
figure
for coh = 1:2
    plot(t,squeeze(CPPs(:,coh)),'Color',colors3{coh},'LineWidth',2), hold on
    line([mean(CPP_coh_onsets(s,coh),1),mean(CPP_coh_onsets(s,coh),1)],ylim,'Color',colors3{coh},'LineWidth',1.5);
    line([0,0],ylim,'Color','k','LineWidth',1);
    line(xlim,[0,0],'Color','k','LineWidth',1);
end
title(allsubj{s})



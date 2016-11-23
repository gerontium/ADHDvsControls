clear all
close all
clc
chanlocs = readlocs('cap64.loc');

% path='C:\Users\Dan\Dropbox\Monash\My Papers\ADHD vs Controls EEG QBI\Dots Data Downward\';
path='S:\R-MNHS-SPP\Bellgrove-data\4. Dan Newman\QBI ADHD dots data\Dots Data Downward\';

subject_folder = {'AD40C' 'AD11C' 'AD43C' 'AD18C' 'AD24C' 'AD52C' 'AD5C'...
    'AD54C' 'AD75C' 'AD15C' 'AD49C' 'AD69C' 'AD32C' 'AD16C'	'AD72C'...
    'AD59C'	'AD27C'	'AD46C'	'AD22C'	'AD26C'	'AD99C'	'AD48C'	'AD57C'...
    'AD51C' 'AD19C' 'AD98C' 'AD25C' 'AD23C'...
    '001_KK' 'C12' 'C21' '002_LK' 'C50' 'C131' 'C20' 'C132' 'C213'...
    'C204'	'C171' 'C13' 'C119'	'C121'	'C194'	'C168' ...
    'C14' 'C49' 'C400' 'C100' 'C117' 'C115' 'C110' 'C183' 'C144' 'C252' ...
    'C140' 'C259' 'C143' 'C89' 'C62' 'C88' 'C84' 'C87'};

allsubj=   {'1_40' '1_11' '1_43' '1_18' '1_24' '1_52' '1_5'...
    '1_54' '1_75' '1_15' '1_49' '1_69' '1_32' '1_16'...
    '1_72'	'1_59'	'1_27'	'1_46'	'1_22'	'1_26'	'1_99'	'1_48'	'1_57'...
    '1_51' '1_19' '1_98' '1_25' '1_23'...
    '001'	'12'	'21'	'002'	'50'	'131'	'20'	'132'...
    '213'	'204'	'171'	'13'	'119'	'121'	'194'	'168'...
    '14' '49' '400' '100' '117' '115' '110' '183'  '144' '252' ...
    '140' '259' '143' '89' '62' '88' '84' '87'};

% duds = [12,16,17,24,26,... %ADHD: %'AD69C', 'AD59C', 'AD27C', 'AD51C', 'AD98C' % These are kicked out due to clinical cuttoff filter_CPRS_N_B
%     43,45,56];  %Controls: %C194 not enough trials %('C14' and 'C259' filter_CPRS_N_B);
duds = [];  
single_participants = [];
file_start = 1;

%%
subject_folder_ADHD = {'AD40C' 'AD11C' 'AD43C' 'AD18C' 'AD24C' 'AD52C' 'AD5C'...
    'AD54C' 'AD75C' 'AD15C' 'AD49C' 'AD69C' 'AD32C' 'AD16C'	'AD72C'...
    'AD59C'	'AD27C'	'AD46C'	'AD22C'	'AD26C'	'AD99C'	'AD48C'	'AD57C'...
    'AD51C' 'AD19C' 'AD98C' 'AD25C' 'AD23C'};
allsubj_ADHD = {'1_40' '1_11' '1_43' '1_18' '1_24' '1_52' '1_5'...
    '1_54' '1_75' '1_15' '1_49' '1_69' '1_32' '1_16'...
    '1_72'	'1_59'	'1_27'	'1_46'	'1_22'	'1_26'	'1_99'	'1_48'	'1_57'...
    '1_51' '1_19' '1_98' '1_25' '1_23'};


subject_folder_Control = {'001_KK' 'C12' 'C21' '002_LK' 'C50' 'C131' 'C20' 'C132' 'C213'...
    'C204'	'C171' 'C13' 'C119'	'C121'	'C194'	'C168' ...
    'C14' 'C49' 'C400' 'C100' 'C117' 'C115' 'C110' 'C183' 'C144' 'C252' ...
    'C140' 'C259' 'C143' 'C89' 'C62' 'C88' 'C84' 'C87'};

allsubj_Control = {'001'	'12'	'21'	'002'	'50'	'131'	'20'	'132'...
    '213'	'204'	'171'	'13'	'119'	'121'	'194'	'168'...
    '14' '49' '400' '100' '117' '115' '110' '183'  '144' '252' ...
    '140' '259' '143' '89' '62' '88' '84' '87'};
%%

if ~isempty(duds) && isempty(single_participants)
    subject_folder([duds]) = [];
    allsubj([duds]) = [];
end

if ~isempty(single_participants)
    subject_folder = subject_folder(single_participants);
    allsubj = allsubj(single_participants);
end

%%

% side,instance
targcodes = zeros(2,3);
targcodes(1,:) = [101 103 105]; % left patch,
targcodes(2,:) = [102 104 106]; % right patch


fs=500;
numch=64;
rtlim=[0.2 1.88]; %200ms too fast to be a real RT. 1880ms is longer than dot motion

[B,A]=butter(4,8*2/fs);

ch_LR = [23;60];
ch_N2c = [60;23]; % right hemi channels for left target, vice versa.
ch_for_ipsicon(1,:) = [60;23];
ch_for_ipsicon(2,:) = [23;60];
ch_l = [23];
ch_r = [60];
% ch_front = 47; %47=FCz
ch_front = 38; %38=Fz
ch_CPP = [31];


ts = -0.8*fs:1.880*fs;   % in sample points, the ERP epoch
t = ts*1000/fs;

ts_crop = -0.8*fs:1.880*fs;
t_crop = ts_crop*1000/fs;

trs = [-.800*fs:fs*.100];
tr = trs*1000/fs;



BLint = [-100 0];   % baseline interval in ms

HPF=0; %Use high-pass filtered erp? 1=yes, 0=no

mat_file='_8_to_13Hz_neg800_to_1880_64ARchans_35HzLPF_point0HzHPF_ET';

%% Plotting colours lables etc
Patchside = {'Left Target ','Right Target '};
ADHD_Control = {'ADHD ','Control '};
colors = {'b' 'r' 'g' 'm' 'c'};
line_styles = {'-' '--'};
line_styles2 = {'--' '--' '-' '-'};
colors_coh = {'r' 'b'};
line_styles3 = {'-' '--' '-' '--'};
linewidths = [1.5 1.5 1.5 1.5 1.3 1.3 1.3 1.3];
linewidths2 = [1.5 1.5 1.3 1.3];
colors3 = {'b' 'b' 'r' 'r'};
[B,A]=butter(4,8*2/fs);
%%

for s=file_start:length(allsubj)
    
    erp=[];erp_HPF=[]; Alpha=[]; FixationBreak_PretargetToTarget_n=[]; FixationBreak_BLintTo100msPostResponse_n=[]; FixationBreak_BLintTo450ms_n=[]; Pupil_baselined=[];
    allRT=[]; allrespLR=[]; GAZE_X=[]; GAZE_Y=[];
    
    if ismember(subject_folder{s},subject_folder_ADHD)
        group=1;
        group_vector(s)=1;
        load([path 'ADHD\' subject_folder{s} '\' allsubj{s} mat_file])
    elseif ismember(subject_folder{s},subject_folder_Control)
        group=2;
        group_vector(s)=2;
        load([path 'Controls\' subject_folder{s} '\' allsubj{s} mat_file])
    else
        keyboard
    end
    
    if length(allRT)<length(allrespLR)
        allRT(length(allRT)+1:length(allrespLR))=0; %DN: in case they missed the last RT add a zero on
    end
    
    erpr = zeros(size(erp,1),length(tr),size(erp,3));
    
    %% Find and index pre and post-target blinks and fixation breaks
    
    %Screen parameters and viewing distance from Monitor at QBI
    dist = 57;  % viewing distance in cm is closer than using LCD (57)
    scres = [1024 768]; %screen resolution
    cm2px = scres(1)/39;% for Monitor at QBI
    deg2px = dist*cm2px*pi/180;
    %   par.patchloc = [-10 -4; 10 -4;]; % patch location coordinates [x y] in degrees relative to center of screen
    
    if length(GAZE_X(1,:))~=length(allRT)
        keyboard
    end
    
    %%% if fixation breaks 3deg or blink, mark trial
    for trial=1:length(GAZE_X(1,:))
        
        %         figure
        %         plot(GAZE_X(find(t_crop==-500):find(t_crop==0),trial),GAZE_Y(find(t_crop==-500):find(t_crop==0),trial))
        %         circle(512,384,(3*deg2px));
        %         set(gca,'xlim',[312,712],'ylim',[184,584])
        
        %               if any(sqrt(((GAZE_X(:,trial)-(scres(1)/2)).^2)+((GAZE_Y(:,trial)-(scres(2)/2)).^2))>(3*deg2px)) || any(GAZE_X(:,trial)==0)
        %Pre-target:
        if any(sqrt(((GAZE_X(find(t_crop==-500):find(t_crop==0),trial)-(scres(1)/2)).^2))>(3*deg2px))|| any(GAZE_X(find(t_crop==-500):find(t_crop==0),trial)==0) %DN: here we only care about blinks and fixation breaks along the x axis (line above does both x and y axis)
            FixationBreak_PretargetToTarget_n(trial) = 1;
        else
            FixationBreak_PretargetToTarget_n(trial) = 0;
        end
        %BLint to 100ms after RT:
        if allRT(trial)>0 && allRT(trial)*1000/fs <1900 %if there was an RT, search for fixation freak from BLint to 100ms after RT:
            if any(sqrt(((GAZE_X(find(t_crop==BLint(1)):find(t_crop==allRT(trial)*1000/fs + 100),trial)-(scres(1)/2)).^2))>(3*deg2px))|| any(GAZE_X(find(t_crop==BLint(1)):find(t_crop==allRT(trial)*1000/fs+ 100),trial)==0) %DN: here we only care about blinks and fixation breaks along the x axis (line above does both x and y axis)
                FixationBreak_BLintTo100msPostResponse_n(trial) = 1;
            else
                FixationBreak_BLintTo100msPostResponse_n(trial) = 0;
            end
            %else there was no RT so search from BLint until end of epoch:
        elseif any(sqrt(((GAZE_X(find(t_crop==BLint(1)):end,trial)-(scres(1)/2)).^2))>(3*deg2px))|| any(GAZE_X(find(t_crop==BLint(1)):end,trial)==0)
            FixationBreak_BLintTo100msPostResponse_n(trial) = 1;
        else
            FixationBreak_BLintTo100msPostResponse_n(trial) = 0;
        end
        %BLint to 450ms:
        if any(sqrt(((GAZE_X(find(t_crop==BLint(1)):find(t_crop==450),trial)-(scres(1)/2)).^2))>(3*deg2px))|| any(GAZE_X(find(t_crop==BLint(1)):find(t_crop==450),trial)==0) %DN: here we only care about blinks and fixation breaks along the x axis (line above does both x and y axis)
            FixationBreak_BLintTo450ms_n(trial) = 1;
        else
            FixationBreak_BLintTo450ms_n(trial) = 0;
        end
    end
    
    %%
    
    
    if HPF
        erp=erp_HPF;
    end
    
    
    disp(['################################']);
    
    
    %Calculate mean pre-target pupil diameter for each trial. Just used to
    %kick out trials where pre-target pupil diameter is 0
    PrePupilDiameter=zeros(1,size(Pupil,2));
    for trial=1:size(Pupil,2)
        PrePupilDiameter(trial)=mean(Pupil(find(t_crop==-500):find(t_crop==0),trial));
    end
    
    
    erpr = zeros(size(erp,1),length(tr),size(erp,3));
    
    validrlock = zeros(1,length(allRT)); % length of RTs.
    for n=1:length(allRT);
        [blah,RTsamp] = min(abs(t*fs/1000-allRT(n))); % get the sample point of the RT.
        if RTsamp+trs(1) >0 & RTsamp+trs(end)<=length(t) & allRT(n)>0 % is the RT larger than 1st stim RT point, smaller than last RT point.
            erpr(:,:,n) = erp(:,RTsamp+trs,n);
            validrlock(n)=1;
        end
    end
    
    
    % patch,ITI
    clear conds1
    for patch = 1:2
        for i = 1:3
            % calcs the indices of the triggers for each
            % appropriate trial type.
            conds1{patch,i} = find(allTrig==targcodes(patch,i) & allrespLR==1 & ...
                allRT>rtlim(1)*fs & allRT<rtlim(2)*fs & validrlock & ~rejected_trial_n);
        end
    end
    
    conds_all = [conds1{:,:}];
    allRT_zscores = zeros(size(allRT));
    allRT_zscores(conds_all) = zscore(log(allRT(conds_all)*1000/fs));
    PrePupilDiameter_zscores = zeros(size(allRT));
    PrePupilDiameter_zscores(conds_all) = zscore(PrePupilDiameter(conds_all));
    
    %Baseling correct each single trial Pupil diameter
    for trial=1:size(Pupil,2)
        bl_diameter = mean(Pupil(find(t_crop==-500):find(t_crop==0),trial)); % baseline from -500ms before onset.
        Pupil_baselined(:,trial) = Pupil(:,trial) - repmat(bl_diameter,[size(Pupil,1),1]);
    end
    
    
    clear conds_erp conds_N2 conds_RT conds_Alpha_pre conds_Alpha_post conds_pupil_pre conds_pupil_post CPPs
    for patch = 1:2
        for i = 1:3
            conds_erp{patch,i} = find(allTrig==targcodes(patch,i) & allrespLR==1 & allRT>rtlim(1)*fs & allRT<rtlim(2)*fs & ...
                allRT_zscores>-3 & allRT_zscores<3 & ~artifact_BLintTo100msPostResponse_n &...
                ~FixationBreak_BLintTo100msPostResponse_n & ~rejected_trial_n);
            ERP_temp = squeeze(erp(1:numch,:,[conds_erp{patch,i}]));
            ERP_cond(s,:,:,patch,i,group) = squeeze(mean(ERP_temp,3));  %ERP_cond(Subject, channel, samples, patch, i, group)
            clear ERP_temp
            if isnan(ERP_cond(s,:,:,patch,i,group))
                keyboard
            end
            
            ERPr_temp = squeeze(erpr(1:numch,:,[conds_erp{patch,i}]));
            ERPr_cond(s,:,:,patch,i,group) = squeeze(mean(ERPr_temp,3));  %ERPr_cond(Subject, channel, samples, patch, i, group)
            clear ERPr_temp
            if isnan(ERPr_cond(s,:,:,patch,i,group))
                keyboard
            end
            
            conds_N2{patch,i} = find(allTrig==targcodes(patch,i) & allrespLR==1 & allRT>rtlim(1)*fs & allRT<rtlim(2)*fs & ...
                allRT_zscores>-3 & allRT_zscores<3 & ~artifact_BLintTo450ms_n & ~FixationBreak_BLintTo450ms_n & ~rejected_trial_n);
            N2_temp = squeeze(erp(1:numch,:,[conds_N2{patch,i}]));
            N2_cond(s,:,:,patch,i,group) = squeeze(mean(N2_temp,3));  %N2_cond(Subject, channel, samples, patch, i, group)
            clear N2_temp
            if isnan(N2_cond(s,:,:,patch,i,group))
                keyboard
            end
            
            conds_RT{patch,i} = find(allTrig==targcodes(patch,i) & allrespLR==1 & allRT>rtlim(1)*fs & allRT<rtlim(2)*fs & ...
                allRT_zscores>-3 & allRT_zscores<3);
            avRT{s,patch,i,group} = allRT(conds_RT{patch,i})*1000/fs;
            RT_Zs{s,patch,i,group} = allRT_zscores(conds_RT{patch,i});
            
            
            %Pre Alpha
            conds_Alpha_pre{patch,i} = find(allTrig==targcodes(patch,i) & allrespLR==1 & allRT>rtlim(1)*fs & allRT<rtlim(2)*fs & ... %make a different conds for Pupil kicking out pre-target pupil outliers
                ~artifact_PretargetToTarget_n & ~ FixationBreak_PretargetToTarget_n & ~rejected_trial_n);
            Alpha_temp = squeeze(Alpha(1:numch,:,[conds_Alpha_pre{patch,i}]));
            Alpha_cond_pre(s,:,:,patch,i,group) = squeeze(mean(Alpha_temp,3)); %Alpha_cond_pre (Subject, channel, samples, patch, i, group)
            clear Alpha_temp
            if isnan(Alpha_cond_pre(s,:,:,patch,i,group))
                keyboard
            end
            
            %Post Alpha  - kick out pre-target artifacts too because I need to baseline to the pre-target interval for post target alpha desync
            conds_Alpha_post{patch,i} = find(allTrig==targcodes(patch,i) & allrespLR==1 & allRT>rtlim(1)*fs & allRT<rtlim(2)*fs & ... %make a different conds
                ~artifact_BLintTo100msPostResponse_n & ~ FixationBreak_BLintTo100msPostResponse_n & ~ FixationBreak_PretargetToTarget_n & ~rejected_trial_n & allRT_zscores>-3 & allRT_zscores<3);
            Alpha_temp = squeeze(Alpha(1:numch,:,[conds_Alpha_post{patch,i}]));
            Alpha_cond_post(s,:,:,patch,i,group) = squeeze(mean(Alpha_temp,3)); %Alpha_cond (Subject, channel, samples, patch, i, group)
            clear Alpha_temp
            if isnan(Alpha_cond_post(s,:,:,patch,i,group))
                keyboard
            end
            
            %Pre target pupil
            conds_pupil_pre{patch,i} = find(allTrig==targcodes(patch,i) & allrespLR==1 & allRT>rtlim(1)*fs & allRT<rtlim(2)*fs & ... %make a different conds for Pupil kicking out pre-target pupil outliers
                PrePupilDiameter~=0 & ~FixationBreak_PretargetToTarget_n & ~rejected_trial_n);
            PUPIL_temp=squeeze(Pupil(:,[conds_pupil_pre{patch,i}]));
            Pupil_cond_pre(s,:,patch,i,group)=squeeze(mean(PUPIL_temp,2));
            clear PUPIL_temp
            if isnan(Pupil_cond_pre(s,:,patch,i,group))
                keyboard
            end
            
            %Post target pupil
            conds_pupil_post{patch,i} = find(allTrig==targcodes(patch,i) & allrespLR==1 & allRT>rtlim(1)*fs & allRT<rtlim(2)*fs & ... %make a different conds for Pupil kicking out pre-target pupil outliers
                allRT_zscores>-3 & allRT_zscores<3 & PrePupilDiameter~=0 & ~FixationBreak_BLintTo100msPostResponse_n...
                & abs(PrePupilDiameter_zscores)<3 & ~rejected_trial_n & allRT_zscores>-3 & allRT_zscores<3);
            PUPIL_temp=squeeze(Pupil_baselined(:,[conds_pupil_post{patch,i}]));
            Pupil_cond_post(s,:,patch,i,group)=squeeze(mean(PUPIL_temp,2));
            clear PUPIL_temp
            if isnan(Pupil_cond_post(s,:,patch,i,group))
                keyboard
            end
            
        end
        
        %% Code adapted from Ger's Current Biology cpp code to pull out CPP onset latency:
        % These 8 lines go at the top of the script.
        % Define CPP onset search window, from 0 to 1000ms
        CPP_search_t  = [0,1000];
        % Same window in samples
        CPP_search_ts  = [find(t==CPP_search_t(1)),find(t==CPP_search_t(2))];
        % Size of sliding window. This is in fact 1/4 of the search window in ms.
        % So 25 is 100ms. (25 samples x 2ms either side of a particular sample).
        max_search_window = 25;
        
        %DN: in Ger's N2/CPP paper this is set to 10, but our dots
        %coherence is lower, so setting it to 25 to ensure cpp onset
        %actually started and it's not just noise
        consecutive_windows=25;%Number of consecutive windows that p must be less than .05 for in order to call it a CPP onset
        
        
        CPP_temp = squeeze(mean(erp(ch_CPP,:,[conds_erp{patch,:}]),1)); % time x trial
        CPPs(:,patch) = squeeze(mean(CPP_temp(:,:),2)); % average across trial for plot later on, not used to find onsets.
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
            
            if strcmp( subject_folder(s),'AD48C') %This participant has strainge CPP baseline, so do CPP onset t-test against -1.5 instead of against 0
                [~,P,~,STATS] = ttest(win_mean(tt,:),-1.5);
            else
                [~,P,~,STATS] = ttest(win_mean(tt,:));
            end
            tstats(tt) = STATS.tstat;
            ps(tt) = P;
        end
        
        % when does the ttest cross 0.05? If at all?
%         onsetp05 = find(ps<0.05 & tstats>0,1,'first');

        %DN: added this in to explicitly make sure the "consecutive_windows" number of following p-values from onset are also lower than 0.05.
        clear allp05
        allp05= find(ps<0.05 & tstats>0);
        onsetp05=[];
        for i = 1:length(allp05)
            if  (i+consecutive_windows-1)<=length(allp05)
                if allp05(i+consecutive_windows-1)-allp05(i)==consecutive_windows-1 %if there is at least 10 consecutive windows where p<.05
                    onsetp05=allp05(i);
                    break
                end
            else
                onsetp05=allp05(i);
                break
            end
        end

        
        % get timepoint of min index.
        if ~isempty(onsetp05)
            onset_ind = win_mean_inds(onsetp05);
            CPP_onset_ind = onset_ind + length(prestim_temp); % see above, this needs to be added to get the overall time with respect to t.
            CPP_patch_onsets(s,patch) = t(CPP_onset_ind);
        else % onsetp05 is empty, no significant CPP.
            disp([allsubj{s},': bugger']) %AD48C has no CPP onset
            CPP_patch_onsets(s,patch) = 0;
        end
        
% % %     plot the smoothed waveforms, the corresponding t-tests and p-values.
% % %     Make sure the 10 (DN:30) following p-values from onset are also lower than
% % %     0.05.
%         
%         if patch==1
%             figure
%             subplot(3,2,1)
%             plot(win_mean_inds,mean(win_mean,2))
%             title(subject_folder{s})
%             subplot(3,2,3)
%             plot(win_mean_inds,tstats)
%             subplot(3,2,5)
%             plot(win_mean_inds,ps), hold on
%             line(xlim,[0.05,0.05],'Color','k','LineWidth',1);
%             if ~isempty(onsetp05)
%                 line([onset_ind,onset_ind],ylim,'Color','g','LineWidth',1);
%             else
%                 line([0,0],ylim,'Color','r','LineWidth',1);
%             end
%         else
%             subplot(3,2,2)
%             plot(win_mean_inds,mean(win_mean,2))
%             title(subject_folder{s})
%             subplot(3,2,4)
%             plot(win_mean_inds,tstats)
%             subplot(3,2,6)
%             plot(win_mean_inds,ps), hold on
%             line(xlim,[0.05,0.05],'Color','k','LineWidth',1);
%             if ~isempty(onsetp05)
%                 line([onset_ind,onset_ind],ylim,'Color','g','LineWidth',1);
%             else
%                 line([0,0],ylim,'Color','r','LineWidth',1);
%             end
%         end
        
    end
    
% %     plot CPP with onset marked    
%     figure
%     for patch = 1:2
%         plot(t,squeeze(CPPs(:,patch)),'Color',colors{patch},'LineWidth',2), hold on
%         line([mean(CPP_patch_onsets(s,patch),1),mean(CPP_patch_onsets(s,patch),1)],ylim,'Color',colors{patch},'LineWidth',1.5);
%         line([0,0],ylim,'Color','k','LineWidth',1);
%         line(xlim,[0,0],'Color','k','LineWidth',1);
%     end
%     title(subject_folder{s})
    
%%    
    
    disp(['Subject ',subject_folder{s},' Total Valid Pre Alpha: ',num2str(length([conds_Alpha_pre{:,:}]))])
    disp(['Subject ',subject_folder{s},' Total Valid N2 Trials: ',num2str(length([conds_N2{:,:}]))])
    disp(['Subject ',subject_folder{s},' Total Valid CPP Trials: ',num2str(length([conds_erp{:,:}]))])
    disp(['Subject ',subject_folder{s},' Total Valid RT Trials: ',num2str(length([conds_RT{:,:}]))])
    
    RT_index(s) = (mean([avRT{s,1,:,group}])-mean([avRT{s,2,:,group}]))/ ((mean([avRT{s,1,:,group}])+mean([avRT{s,2,:,group}]))/2)';
    
    RT(s)= mean([avRT{s,:,:,group}])';
    RT_Left(s)=mean([avRT{s,1,:,group}])';
    RT_Right(s)=mean([avRT{s,2,:,group}])';
    
    ValidPreAlphaTrials(s)=length([conds_Alpha_pre{:,:}])';
    ValidN2Trials(s)=length([conds_N2{:,:}])';
    ValidCPPTrials(s)=length([conds_erp{:,:}])';
    Valid_RT_Trials(s)=length([conds_RT{:,:}])';
    
    
    
end



%% find the best ALPHA LH and RH ROI electrodes for each participant
 for s=file_start:length(allsubj)
    if ismember(subject_folder{s},subject_folder_ADHD)
        group=1;
    elseif ismember(subject_folder{s},subject_folder_Control)
        group=2;
    end
    for elec=1:numch  %Alpha_cond (Subject, channel, samples, patch, i, group)
        left_minus_right_per_subject(s,elec) = squeeze(mean(mean(Alpha_cond_post(s,elec,find(Alpha_smooth_time==300):find(Alpha_smooth_time==1000),1,:,group),5),3))-...
            squeeze(mean(mean(Alpha_cond_post(s,elec,find(Alpha_smooth_time==300):find(Alpha_smooth_time==1000),2,:,group),5),3));
    end

    LH_elec=[20:23 25:27];
    RH_elec=[57:60 62:64];
    %For each participant this specify the 4 occipito-pariatal electrodes for each hemisphere that show the greatest desyncronisation difference between cont/ipsilateral targets
        LH_desync(s,:)= left_minus_right_per_subject(s,LH_elec);
    [temp1,temp2] = sort(LH_desync(s,:));
    LH_ROI(s,:)= LH_elec(temp2(5:7)); %DN: pick the 3 Left Hemisphere parieto-occipito that show the highest left_minus_right values (5:7)
    LH_ROI_s =  LH_ROI(s,:);
    
    RH_desync(s,:)= left_minus_right_per_subject(s,RH_elec);
    [temp1,temp2] = sort(RH_desync(s,:));
    RH_ROI(s,:)= RH_elec(temp2(1:3)); %DN: pick the 3 Right Hemisphere parieto-occipito that show the lowest left_minus_right values (1:3)
    RH_ROI_s =  RH_ROI(s,:);
    
    group_path={'ADHD\','Controls\'};       
    save([path, group_path{group}, subject_folder{s} '\ROIs.mat'],'LH_ROI_s','RH_ROI_s')
 end
 
%% DN: combine LH_ROI = and RH_ROI electrodes together in ROIs_LH_RH, and ROIs_RH_LH for an ipsicon type thing
ROIs_LH_RH=zeros(length(allsubj),length(LH_ROI(1,:)),2);
ROIs_LH_RH(:,:,1)=LH_ROI;
ROIs_LH_RH(:,:,2)=RH_ROI;
ROIs_RH_LH=zeros(length(allsubj),length(LH_ROI(1,:)),2);
ROIs_RH_LH(:,:,2)=LH_ROI;
ROIs_RH_LH(:,:,1)=RH_ROI;
%%

IDs=subject_folder'; open IDs

Patchside = {'Left Target ','Right Target '};
ADHD_Control = {'ADHD ','Control '};
colors = {'b' 'r' 'g' 'm' 'c'};
line_styles = {'-' '--'};
line_styles2 = {'--' '--' '-' '-'};
colors_coh = {'r' 'b'};
line_styles3 = {'-' '--' '-' '--'};
linewidths = [1.5 1.5 1.5 1.5 1.3 1.3 1.3 1.3];
linewidths2 = [1.5 1.5 1.3 1.3];
colors3 = {'b' 'b' 'r' 'r'};

%% N2 scalp plot 
figure
counter=0;
scalp_plot_times=[220, 340]; %in ms
for group=1:2
    for targetside=1:2
        counter=counter+1; %N2_cond(Subject, channel, samples, patch, i,group)
        temp=squeeze(mean(mean(mean(N2_cond(N2_cond(:,1,1,1,1,group)~=0,:,:,targetside,:,group),5),1),6));
        subplot(2,2,counter)
        topoplot(mean(temp(:,find(t_crop==scalp_plot_times(1)):find(t_crop==scalp_plot_times(2))),2),chanlocs,'maplimits', ...
             [-1  2],'electrodes','numbers','plotchans',1:64); %colorbar
         set(gca,'FontSize',16);
        title([ADHD_Control{group} Patchside{targetside} num2str(scalp_plot_times(1)) '-' num2str(scalp_plot_times(2)) 'ms']);
    end
end


%% Plot N2c and N2i by TargetSide:
clear ch_for_ipsicon
% ch_for_ipsicon(1,1,:)=[60,59,62]; %Left Target Contra
% ch_for_ipsicon(1,2,:)=[23,22,25]; %Left Target Ipsi
% ch_for_ipsicon(2,1,:)=ch_for_ipsicon(1,2,:);
% ch_for_ipsicon(2,2,:)=ch_for_ipsicon(1,1,:);

ch_for_ipsicon(1,:) = [60;23];
ch_for_ipsicon(2,:) = [23;60];

patch_ipsi_contra = {'N2c Left target','N2i Left Target','N2c Right Target','N2i Right Target'};
figure
% xy_axes = axes('Parent',figure,'FontName','Arial','FontSize',20);
for group=1:2
    subplot(1,2,group)
    counter = 1;
    for side=1:2
        for channels = 1:2 %N2_cond(Subject, channel, samples, patch, i,group)
            avERP_temp = squeeze(mean(mean(mean(N2_cond(N2_cond(:,1,1,1,1,group)~=0,:,find(t==-100):find(t==500),side,:,group),5),1),6));%(channel, samples)
            avERP_plot = squeeze(mean(avERP_temp(ch_for_ipsicon(side,channels,:),:),1)); 
            h(counter) = plot(t(find(t==-100):find(t==500)),avERP_plot,'Color',colors3{counter},'LineStyle',line_styles3{counter}, ...
                'Linewidth',4); hold on;
            set(gca, 'XLim', [-100 500],'YLim', [-3 2])
            line(xlim,[0,0],'Color','k');
            line([0,0],ylim,'Color','k');
            counter = counter+1;
        end
    end
    set(gca,'FontSize',20,'xlim',[-100,500],'xtick',[-100,0:100:500],'ylim',[-3,2],'ytick',[-3:1:2]);
    ylabel('Amplitude (\muVolts)','FontName','Arial','FontSize',20)
    xlabel('Time (ms)','FontName','Arial','FontSize',20)
    legend(h,patch_ipsi_contra,'Location','NorthWest');
    clear h;
    title([ADHD_Control{group}])
end





%% Extract N2c and N2i amplitude, using amplitude latency window based on GRAND AVERAGE N2c/i:

window=25; %this is the time (in samples) each side of the peak latency (so it's 50ms each side of peak latency - so a 100ms window) 
group_path={'ADHD\','Controls\'};

%N2 amplitude for Stats
%N2_cond(Subject, channel, samples, patch, i, group)

for s = 1:size(allsubj,2)
    if ismember(subject_folder{s},subject_folder_ADHD)
        group=1;
    elseif ismember(subject_folder{s},subject_folder_Control)
        group=2;
    end
    for TargetSide=1:2 
        %to use the grand average N2c/i to get peak
        %latency index around which we measure peak amplitude:
        avN2c=squeeze(mean(mean(mean(mean(mean(N2_cond(:, ch_N2c(TargetSide,:),:,:,:,:),5),4),2),1),6)); %(sample)
        avN2i=squeeze(mean(mean(mean(mean(mean(N2_cond(:, ch_LR(TargetSide,:),:,:,:,:),5),4),2),1),6));
        avN2c_peak_amp=min(avN2c(find(t==150):find(t==400)));
        avN2i_peak_amp=min(avN2i(find(t==150):find(t==400)));
        avN2c_peak_amp_index(s,TargetSide)=find(avN2c==avN2c_peak_amp);%Find Left target max peak latency for N2c
        avN2i_peak_amp_index(s,TargetSide)=find(avN2i==avN2i_peak_amp);%Find Left target max peak latency for N2i
        avN2c_peak_amp_index_t(s,TargetSide)=t_crop(avN2c_peak_amp_index(s,TargetSide));
        avN2i_peak_amp_index_t(s,TargetSide)=t_crop(avN2i_peak_amp_index(s,TargetSide));
        max_peak_N2c(s,TargetSide)=squeeze(mean(mean(mean(N2_cond(s,ch_N2c(TargetSide,:),avN2c_peak_amp_index(s)-window:avN2c_peak_amp_index(s)+window, TargetSide,:,group),2),3),5));
        max_peak_N2i(s,TargetSide)=squeeze(mean(mean(mean(N2_cond(s,ch_LR(TargetSide,:),avN2i_peak_amp_index(s)-window:avN2i_peak_amp_index(s)+window, TargetSide,:,group),2),3),5));
    end
        avN2c_GrandAverage_peak_amp_index_s=avN2c_peak_amp_index(s,:);
        save([path, group_path{group}, subject_folder{s} '\avN2c_GrandAverage_peak_amp_index.mat'],'avN2c_GrandAverage_peak_amp_index_s');
        avN2i_GrandAverage_peak_amp_index_s=avN2i_peak_amp_index(s,:);
        save([path, group_path{group}, subject_folder{s} '\avN2i_GrandAverage_peak_amp_index.mat'],'avN2i_GrandAverage_peak_amp_index_s');
end
N2cN2i_amp_ByTargetSide_GrandAverage = [max_peak_N2c,max_peak_N2i]; %(LeftTargetN2c, RightTargetN2c, LeftTargetN2i, RightTargetN2i)

%% Extract N2c and N2i amplitude and latency, using amplitude latency window based on each INDIVIDNAL PARTICIPANT'S N2c/i:

window=25; %this is the time (in samples) each side of the peak latency (so it's 50ms each side of peak latency - so a 100ms window) 
group_path={'ADHD\','Controls\'};

%N2 amplitude for Stats
%N2_cond(Subject, channel, samples, patch, i, group)

for s = 1:size(allsubj,2)
    if ismember(subject_folder{s},subject_folder_ADHD)
        group=1;
    elseif ismember(subject_folder{s},subject_folder_Control)
        group=2;
    end
    for TargetSide=1:2 
%         to use each participant's average N2c/i to get their peak latency index around which we measure peak amplitude:
        avN2c=squeeze(mean(mean(mean(mean(mean(N2_cond(s, ch_N2c(TargetSide,:),:,TargetSide,:,group),5),4),2),1),6)); %(sample)
        avN2i=squeeze(mean(mean(mean(mean(mean(N2_cond(s, ch_LR(TargetSide,:),:,TargetSide,:,group),5),4),2),1),6)); 
        avN2c_peak_amp=min(avN2c(find(t==150):find(t==400)));
        avN2i_peak_amp=min(avN2i(find(t==150):find(t==400)));
        avN2c_peak_amp_index(s,TargetSide)=find(avN2c==avN2c_peak_amp);%Find Left target max peak latency for N2c
        avN2i_peak_amp_index(s,TargetSide)=find(avN2i==avN2i_peak_amp);%Find Left target max peak latency for N2i
        avN2c_peak_amp_index_t(s,TargetSide)=t_crop(avN2c_peak_amp_index(s,TargetSide));
        avN2i_peak_amp_index_t(s,TargetSide)=t_crop(avN2i_peak_amp_index(s,TargetSide));
        max_peak_N2c(s,TargetSide)=squeeze(mean(mean(mean(N2_cond(s,ch_N2c(TargetSide,:),avN2c_peak_amp_index(s)-window:avN2c_peak_amp_index(s)+window, TargetSide,:,group),2),3),5));
        max_peak_N2i(s,TargetSide)=squeeze(mean(mean(mean(N2_cond(s,ch_LR(TargetSide,:),avN2i_peak_amp_index(s)-window:avN2i_peak_amp_index(s)+window, TargetSide,:,group),2),3),5));
    end    
        avN2c_ParticipantLevel_peak_amp_index_s=avN2c_peak_amp_index(s,:);
        save([path, group_path{group}, subject_folder{s} '\avN2c_ParticipantLevel_peak_amp_index.mat'],'avN2c_ParticipantLevel_peak_amp_index_s');        
        avN2i_ParticipantLevel_peak_amp_index_s=avN2i_peak_amp_index(s,:);
        save([path, group_path{group}, subject_folder{s} '\avN2i_ParticipantLevel_peak_amp_index.mat'],'avN2i_ParticipantLevel_peak_amp_index_s');
end
N2cN2i_amp_ByTargetSide_ParticipantLevel = [max_peak_N2c,max_peak_N2i]; %(LeftTargetN2c, RightTargetN2c, LeftTargetN2i, RightTargetN2i)

%%N2c Latency:
N2cN2i_latency_ByTargetSide = [avN2c_peak_amp_index_t,avN2i_peak_amp_index_t]; %(LeftTargetN2c_latency, RightTargetN2c_latency, LeftTargetN2i_latency, RightTargetN2i_latency)


%% Extract N2c and N2i peak latency using sliding window:
% 
% % NB: this is quarter the window size in samples, each sample = 2ms and
%         % it's this either side.
%         window_size = 25;
%         % contra and search frames encompass the entire negativity.
%         contra_peak_t = [100,450]; contra_peak_ts(1) = find(t_crop==contra_peak_t(1)); contra_peak_ts(2) = find(t_crop==contra_peak_t(2));
%         % SEARCHING FOR PEAK LATENCY
%         clear N2c_peak_latencies
%         % for each trial...
%         % search your search timeframe, defined above by contra_peak ts, in sliding windows
%         % NB this is done in samples, not time, it's later converted.
%         clear win_mean win_mean_inds
%         counter = 1;
%     
%         for s = 1:size(allsubj,2)
%             if ismember(subject_folder{s},subject_folder_ADHD)
%                 group=1;
%             elseif ismember(subject_folder{s},subject_folder_Control)
%                 group=2;
%             end
%             
%             for TargetSide=1:2
%                 avN2c=squeeze(mean(mean(mean(mean(mean(N2_cond(s, ch_N2c(TargetSide,:),:,TargetSide,:,group),5),4),2),1),6)); %(sample)
%                 avN2i=squeeze(mean(mean(mean(mean(mean(N2_cond(s, ch_LR(TargetSide,:),:,TargetSide,:,group),5),4),2),1),6));
%                               
%                 for j = contra_peak_ts(1)+window_size:contra_peak_ts(2)-window_size
%                     % get average amplitude of sliding window from N2pc electrode
%                     win_mean_N2c(counter) = mean(avN2c(j-window_size:j+window_size));
%                     win_mean_N2i(counter) = mean(avN2i(j-window_size:j+window_size));
%                     
%                     % get the middle sample point of that window
%                     win_mean_N2_inds(counter) = j;
%                     counter = counter+1;
%                 end
%                 % find the most negative amplitude in the resulting windows
%                 [~,ind_temp_N2c] = min(win_mean_N2c);
%                 [~,ind_temp_N2i] = min(win_mean_N2i);
%                 % get the sample point which had that negative amplitude
%                 N2c_min_ind = win_mean_N2_inds(ind_temp_N2c);
%                 N2i_min_ind = win_mean_N2_inds(ind_temp_N2i);
%                 
%                 % if the peak latency is at the very start or end of the search
%                 % timeframe, it will probably be bogus. set to NaN.
%                 if ind_temp_N2c==1 | ind_temp_N2c==length(win_mean_N2c)
%                     N2c_peak_latency(s,TargetSide)=0;%DN: make it 0 instead of NaN, will remove these in R
%                 else
%                     % it's good! add it in.
%                     N2c_peak_latency(s,TargetSide)=t_crop(N2c_min_ind);
%                 end
%                 
%                 if ind_temp_N2i==1 | ind_temp_N2i==length(win_mean_N2i)
%                     N2i_peak_latency(s,TargetSide)=0;%%DN: make it 0 instead of NaN, will remove these in R
%                 else
%                     % it's good! add it in.
%                     N2i_peak_latency(s,TargetSide)=t_crop(N2i_min_ind);
%                 end
%             end
%         end
%         
  %% Plot N2c and N2i by TargetSide PER PARTICIPANT:
%     % and with a line to test the latency measures
% clear ch_for_ipsicon
% 
% ch_for_ipsicon(1,:) = [60;23];
% ch_for_ipsicon(2,:) = [23;60];
% 
% patch_ipsi_contra = {'N2c Left target','N2i Left Target','N2c Right Target','N2i Right Target'};
% 
% % xy_axes = axes('Parent',figure,'FontName','Arial','FontSize',20);
% for s=file_start:length(allsubj)
%     if ismember(subject_folder{s},subject_folder_ADHD)
%         group=1;
%     elseif ismember(subject_folder{s},subject_folder_Control)
%         group=2;
%     end
%     figure
%     counter = 1;
%     for side=1:2
%         for channels = 1:2 %N2_cond(Subject, channel, samples, patch, i,group)
%             avERP_temp = squeeze(mean(mean(N2_cond(s,:,find(t==-100):find(t==500),side,:,group),5),6));%(channel, samples)
% %             avERP_temp = filtfilt(B,A,squeeze(mean(mean(mean(s,:,find(t==-100):find(t==500),side,:,group),5),1),6)));%smooth
%             avERP_plot = squeeze(mean(avERP_temp(ch_for_ipsicon(side,channels,:),:),1)); 
%             h(counter) = plot(t(find(t==-100):find(t==500)),avERP_plot,'Color',colors3{counter},'LineStyle',line_styles3{counter}, ...
%                 'Linewidth',4); hold on;
%             set(gca, 'XLim', [-100 500],'YLim', [-8 3])
%             line(xlim,[0,0],'Color','k');
%             line([0,0],ylim,'Color','k');
%             if side==1
%             %Shows a line calculated using sliding window way of calculating N2 peak latency
% %             line([N2i_peak_latency(s,side),N2i_peak_latency(s,side)],ylim,'Color','g','LineStyle',':', 'Linewidth',2);
% %             line([N2c_peak_latency(s,side),N2c_peak_latency(s,side)],ylim,'Color','m','LineStyle',':', 'Linewidth',2);
%             %Shows a line calculated using simple max peak way of calculating N2 peak latency
%             line([avN2i_peak_amp_index_t(s,side),avN2i_peak_amp_index_t(s,side)],ylim,'Color','g', 'Linewidth',2);
%             line([avN2c_peak_amp_index_t(s,side),avN2c_peak_amp_index_t(s,side)],ylim,'Color','m', 'Linewidth',2);
%             else
%                 %Shows a line calculated using sliding window way of calculating N2 peak latency
% %             line([N2i_peak_latency(s,side),N2i_peak_latency(s,side)],ylim,'Color','g', 'LineStyle',':', 'Linewidth',1);
% %             line([N2c_peak_latency(s,side),N2c_peak_latency(s,side)],ylim,'Color','m', 'LineStyle',':', 'Linewidth',1);
%                  %Shows a line calculated using simple max peak way of calculating N2 peak latency
%             line([avN2i_peak_amp_index_t(s,side),avN2i_peak_amp_index_t(s,side)],ylim,'Color','g','Linewidth',1);
%             line([avN2c_peak_amp_index_t(s,side),avN2c_peak_amp_index_t(s,side)],ylim,'Color','m','Linewidth',1);    
%             end
%             counter = counter+1;
%         end
%     end
%     set(gca,'FontSize',12,'xlim',[-100,500],'xtick',[-100,0:100:500],'ylim',[-8,3],'ytick',[-8:1:3]);
%     ylabel('Amplitude (\muVolts)','FontName','Arial','FontSize',12)
%     xlabel('Time (ms)','FontName','Arial','FontSize',12)
%     legend(h,patch_ipsi_contra,'Location','SouthWest');
%     clear h;
%     title([subject_folder{s}])
% end



%% Plot stim-locked CPP by TargetSide:
labels = {'ADHD Left target','ADHD Right Target','Control Left Target','Control Right Target'};
colors4 = {'b' 'r' 'b' 'r'};
figure
counter=0;
for group=1:2
    for targetside=1:2
        counter=counter+1;
            avERP_temp = squeeze(mean(mean(mean(ERP_cond(N2_cond(:,1,1,1,1,group)~=0,:,find(t==-100):find(t==1000),targetside,:,group),5),1),6));%(channel, samples)
        avERP_plot = squeeze(mean(avERP_temp(ch_CPP,:),1));
        h(counter) = plot(t(find(t==-100):find(t==1000)),avERP_plot,'Color',colors4{counter},'LineStyle',line_styles2{counter},'Linewidth',2); hold on;
        set(gca, 'XLim', [-100 1000],'YLim', [-1 10])
        line(xlim,[0,0],'Color','k');
        line([0,0],ylim,'Color','k');
    end
end
set(gca,'FontSize',20,'xlim',[-100,1000],'xtick',[-100,0:100:1000],'ylim',[-1,10],'ytick',[-3:1:2]);
ylabel('Amplitude (\muVolts)','FontName','Arial','FontSize',20)
xlabel('Time (ms)','FontName','Arial','FontSize',20)
legend(h,labels,'Location','NorthWest');
clear h;
title('CPP by TargetSide')


%% Plot Resp-locked CPP by TargetSide:
labels = {'ADHD Left target','ADHD Right Target','Control Left Target','Control Right Target'};
colors4 = {'b' 'r' 'b' 'r'};
figure
counter=0;
for group=1:2
    for targetside=1:2
        counter=counter+1;
            avERPr_temp = squeeze(mean(mean(mean(ERPr_cond(ERPr_cond(:,1,1,1,1,group)~=0,:,:,targetside,:,group),5),1),6));%(channel, samples)
        avERPr_plot = squeeze(mean(avERPr_temp(ch_CPP,:),1));
        h(counter) = plot(tr(find(tr==-800):find(tr==100)),avERPr_plot,'Color',colors4{counter},'LineStyle',line_styles2{counter},'Linewidth',2); hold on;
        set(gca, 'XLim', [-800 100],'YLim', [-1 13])
        line(xlim,[0,0],'Color','k');
        line([0,0],ylim,'Color','k');
    end
end
ylabel('Amplitude (\muVolts)','FontName','Arial','FontSize',20)
xlabel('Time (ms)','FontName','Arial','FontSize',20)
legend(h,labels,'Location','NorthWest');
clear h;
title('Response Locked CPP by TargetSide')

%% Plot resp-locked CPP by TargetSide PER PARTICIPANT 

% labels = {'Left target','Right Target'};
% colors4 = {'b' 'r' 'b' 'r'};
% 
% slope_timeframe = [-400,-50];
% 
% for s=file_start:length(allsubj)
%     if ismember(subject_folder{s},subject_folder_ADHD)
%         group=1;
%     elseif ismember(subject_folder{s},subject_folder_Control)
%         group=2;
%     end
%     figure
%     for targetside=1:2
%         avERPr_temp = squeeze(mean(mean(ERPr_cond(s,:,:,targetside,:,group),5),6));%(channel, samples)
%         avERPr_plot = squeeze(mean(avERPr_temp(ch_CPP,:),1));
%         coef = polyfit(tr(tr>slope_timeframe(1) & tr<slope_timeframe(2)),(avERPr_plot(tr>slope_timeframe(1) & tr<slope_timeframe(2))),1);% coef gives 2 coefficients fitting r = slope * x + intercept
%         CPP_slope(s,targetside)=coef(1);
%         r = coef(1) .* tr(tr>slope_timeframe(1) & tr<slope_timeframe(2)) + coef(2); %r=slope(x)+intercept, r is a vectore representing the linear curve fitted to the erpr during slope_timeframe
%         h(targetside) = plot(tr(find(tr==-800):find(tr==100)),avERPr_plot,'Color',colors4{targetside},'Linewidth',3); hold on;
%         plot(tr(tr>slope_timeframe(1) & tr<slope_timeframe(2)), r, ':','Color',colors4{targetside},'Linewidth',2);
%         set(gca, 'XLim', [-800 100],'YLim', [-3 20])
%         line(xlim,[0,0],'Color','k');
%         line([0,0],ylim,'Color','k');
%         line([slope_timeframe(1),slope_timeframe(1)],ylim,'linestyle',':','Color','k');
%         line([slope_timeframe(2),slope_timeframe(2)],ylim,'linestyle',':','Color','k');
%     end
%     ylabel('Amplitude (\muVolts)','FontName','Arial','FontSize',12)
%     xlabel('Time (ms)','FontName','Arial','FontSize',12)
%     legend(h,labels,'Location','NorthWest');
%     clear h;
%     title([subject_folder{s}, ' Response Locked CPP by TargetSide'])
% end

%% Extract Response Locked CPP slope" 
    %CPP build-up defined as the slope of a straight line fitted to the response-locked waveform at -400 to -50ms
slope_timeframe = [-400,-50];
for s=file_start:length(allsubj)
    if ismember(subject_folder{s},subject_folder_ADHD)
        group=1;
    elseif ismember(subject_folder{s},subject_folder_Control)
        group=2;
    end
    for targetside=1:2
        avERPr_temp = squeeze(mean(mean(ERPr_cond(s,:,:,targetside,:,group),5),6));%(channel, samples)
        avERPr_plot = squeeze(mean(avERPr_temp(ch_CPP,:),1));
        coef = polyfit(tr(tr>slope_timeframe(1) & tr<slope_timeframe(2)),(avERPr_plot(tr>slope_timeframe(1) & tr<slope_timeframe(2))),1);% coef gives 2 coefficients fitting r = slope * x + intercept
        CPP_slope(s,targetside)=coef(1);
    end
end



%% Plot post target Alpha by Hemisphere and TargetSide:

left_hemi_ROI = [25,26,27];
right_hemi_ROI = [62,63,64];
alpha_ch=[left_hemi_ROI;right_hemi_ROI];

patch_ipsi_contra = {'Left target Ipsi','Left Target Contra','Right Target Contra','Right Target Ipsi'};
line_styles4={ '--' '-'  '-'    '--'};
figure
% xy_axes = axes('Parent',figure,'FontName','Arial','FontSize',20);
for group=1:2
    subplot(1,2,group)
    counter = 1;
    for TargetSide=1:2
        for Hemi = 1:2 
            avAlpha_temp = squeeze(mean(mean(mean(Alpha_cond_post(Alpha_cond_post(:,1,1,1,1,group)~=0,:,find(Alpha_smooth_time==-500):find(Alpha_smooth_time==1500),TargetSide,:,group),5),1),6));%(channel, samples)
            avAlpha_plot = squeeze(mean(avAlpha_temp(alpha_ch(Hemi,:),:),1)); %DN: smooth
            
            BLamp=mean(avAlpha_plot(1:10));%grabs mean alpha from -500 to 0
            avAlpha_plot=avAlpha_plot-repmat(BLamp,1,length(avAlpha_plot));
            
            h(counter) = plot(Alpha_smooth_time(find(Alpha_smooth_time==-500):find(Alpha_smooth_time==1500)),avAlpha_plot,'Color',colors3{counter},'LineStyle',line_styles4{counter}, ...
                'Linewidth',4); hold on;
            set(gca, 'XLim', [-500 1500],'YLim', [-1 1])
            line(xlim,[0,0],'Color','k');
            line([0,0],ylim,'Color','k');
            counter = counter+1;
        end
    end
    set(gca,'FontSize',16,'xlim',[-500,1500],'xtick',[-500,0:200:1500],'ylim',[-1,1],'ytick',[-1:1:2]);
    ylabel('Amplitude (\muVolts)','FontName','Arial','FontSize',16)
    xlabel('Time (ms)','FontName','Arial','FontSize',16)
    legend(h,patch_ipsi_contra,'Location','NorthWest');
    clear h;
    title([ADHD_Control{group}])
end


%% Plot post target Alpha by Hemisphere and TargetSide PER PARTICIPANT:

% % alpha_ch=[left_hemi_ROI;right_hemi_ROI]; %use indicidulised ROIs instead 
% patch_ipsi_contra = {'Left target Ipsi','Left Target Contra','Right Target Contra','Right Target Ipsi'};
% line_styles4={ '--' '-'  '-'    '--'};
% % xy_axes = axes('Parent',figure,'FontName','Arial','FontSize',20);
% for s=1:length(allsubj)
%     if ismember(subject_folder{s},subject_folder_ADHD)
%         group=1;
%     elseif ismember(subject_folder{s},subject_folder_Control)
%         group=2;
%     end
%     figure
%         counter = 1;
%         for TargetSide=1:2
%             for Hemi = 1:2
%                 avAlpha_temp = squeeze(mean(mean(Alpha_cond_post(s,:,find(Alpha_smooth_time==-500):find(Alpha_smooth_time==1500),TargetSide,:,group),5),6));%(channel, samples)
%                 avAlpha_plot = squeeze(mean(avAlpha_temp(ROIs_LH_RH(s,:,Hemi),:),1)); %DN: use individulised ROIs
%                 
%                 BLamp=mean(avAlpha_plot(1:10));%grabs mean alpha from -500 to 0
%                 avAlpha_plot=avAlpha_plot-repmat(BLamp,1,length(avAlpha_plot));
%                 
%                 h(counter) = plot(Alpha_smooth_time(find(Alpha_smooth_time==-500):find(Alpha_smooth_time==1500)),avAlpha_plot,'Color',colors3{counter},'LineStyle',line_styles4{counter}, ...
%                     'Linewidth',4); hold on;
%                 line(xlim,[0,0],'Color','k');
%                 line([0,0],ylim,'Color','k');
%                 counter = counter+1;
%             end
%         end
%         set(gca,'FontSize',12,'xlim',[-500,1500],'xtick',[-400:200:1500],'ylim',[-4,1],'ytick',[-4:.2:2]);
%         ylabel('Amplitude (\muVolts)','FontName','Arial','FontSize',12)
%         xlabel('Time (ms)','FontName','Arial','FontSize',12)
%         legend(h,patch_ipsi_contra,'Location','SouthWest');
%         clear h;
%         title([subject_folder{s}])
% end

%% Extract mean Contra and Ipsi Post-target Alpha Dysnc from 300-1000ms (baselined from -500-0ms):

for s=1:length(allsubj)
    if ismember(subject_folder{s},subject_folder_ADHD)
        group=1;
    elseif ismember(subject_folder{s},subject_folder_Control)
        group=2;
    end
    for TargetSide=1:2
        for Hemi = 1:2   %Alpha_cond (Subject, channel, samples, patch, i, group)
            clear avAlpha
            BLamp(s,TargetSide,Hemi) = squeeze(mean(mean(mean(mean(mean(Alpha_cond_post(s,ROIs_LH_RH(s,:,Hemi),find(Alpha_smooth_time==-500):find(Alpha_smooth_time==0),TargetSide,:,group),1),2),3),5),6));% %grabs mean alpha from -500 to 0 from individulised ROIs
            avAlpha_post(s,TargetSide,Hemi) = squeeze(mean(mean(mean(mean(mean(Alpha_cond_post(s,ROIs_LH_RH(s,:,Hemi),find(Alpha_smooth_time==300):find(Alpha_smooth_time==1000),TargetSide,:,group),1),2),3),5),6));%(samples) %DN: use individulised ROIs
            avAlpha_post_desync(s,TargetSide,Hemi) = avAlpha_post(s,TargetSide,Hemi)- BLamp(s,TargetSide,Hemi); 
        end
    end
end


%% Plot Alpha asymmetry by Group and TargetSide:

left_hemi_ROI = [25,26,27];
right_hemi_ROI = [62,63,64];
alpha_ch=[left_hemi_ROI;right_hemi_ROI];

patch_ipsi_contra = {'ADHD Left target','ADHD Right Target','Control Left Target','Control Right Target'};
line_styles4={ '--' '-'  '--' '-'};

% xy_axes = axes('Parent',figure,'FontName','Arial','FontSize',20);
figure
counter = 1;
for group=1:2
    for TargetSide=1:2

            avAlpha_temp = squeeze(mean(mean(mean(Alpha_cond_post(N2_cond(:,1,1,1,1,group)~=0,:,find(Alpha_smooth_time==-500):find(Alpha_smooth_time==1500),TargetSide,:,group),5),1),6));%(channel, samples)
            avAlpha_plot = squeeze(mean(avAlpha_temp(alpha_ch(2,:),:),1)) -squeeze(mean(avAlpha_temp(alpha_ch(1,:),:),1)); %DN: Right Hemi - Left Hemi
                        
            h(counter) = plot(Alpha_smooth_time(find(Alpha_smooth_time==-500):find(Alpha_smooth_time==1500)),avAlpha_plot,'Color',colors3{counter},'LineStyle',line_styles4{counter}, ...
                'Linewidth',4); hold on;
            set(gca, 'XLim', [-500 1500],'YLim', [-1 1])
            line(xlim,[0,0],'Color','k');
            line([0,0],ylim,'Color','k');
            counter = counter+1;
    end
end
    set(gca,'FontSize',14,'xlim',[-500,1500],'xtick',[-500:100:1500],'ylim',[-1,1],'ytick',[-1:.2:1]);
    ylabel('Hemispheric Alpha Asymmetry ( \muVolts)','FontName','Arial','FontSize',14)
    xlabel('Time (ms)','FontName','Arial','FontSize',14)
    legend(h,patch_ipsi_contra,'Location','NorthWest');
    clear h;
    title(['Hemispheric Alpha Asymmetry'])



%% Overall Post target alpha scalp plot 
figure
counter=0;
scalp_plot_times=[400, 850]; %in ms
for group=1:2
    for targetside=1:2
        counter=counter+1; %Alpha_cond (Subject, channel, samples, patch, i)
            temp=squeeze(mean(mean(mean(Alpha_cond_post(Alpha_cond_post(:,1,1,1,1,group)~=0,:,:,TargetSide,:,group),5),1),6));%(channel, samples)
            for i=1:numch
                BLamp=mean(temp(i,find(Alpha_smooth_time==-350):find(Alpha_smooth_time==0)));%grabs mean alpha from -100 to 0 for each channel 
                temp(i,:)=temp(i,:)-repmat(BLamp,1,length(temp(i,:)));
            end
        subplot(2,2,counter)
        topoplot(mean(temp(:,find(Alpha_smooth_time==scalp_plot_times(1)):find(Alpha_smooth_time==scalp_plot_times(2))),2),chanlocs,'maplimits', ...
            [-1  0],'electrodes','numbers','plotchans',1:numch); %colorbar
        title(['Alpha Desync. ' ADHD_Control{group} Patchside{targetside} num2str(scalp_plot_times(1)) '-' num2str(scalp_plot_times(2)) 'ms']);
    end
end

%% Left minus Right Target alpha Desync scalp plot 
figure
counter=0;
scalp_plot_times=[300, 1500]; %in ms
for group=1:2
        counter=counter+1; %Alpha_cond (Subject, channel, samples, patch, i, group)
            temp=squeeze(mean(mean(mean(mean(Alpha_cond_post(Alpha_cond_post(:,1,1,1,1,group)~=0,:,:,2,:,group),5),1),6),4))...
                - squeeze(mean(mean(mean(mean(Alpha_cond_post(Alpha_cond_post(:,1,1,1,1,group)~=0,:,:,1,:,group),5),1),6),4));

        subplot(2,1,counter)
        topoplot(mean(temp(:,find(Alpha_smooth_time==scalp_plot_times(1)):find(Alpha_smooth_time==scalp_plot_times(2))),2),chanlocs,'maplimits', ...
            [-1  1],'electrodes','numbers','plotchans',1:numch); %colorbar
        title(['Alpha Left minus Right Target ' ADHD_Control{group} num2str(scalp_plot_times(1)) '-' num2str(scalp_plot_times(2)) 'ms']);
end


%% Try alpha Left minus Right Target alpha Topoplot
%Alpha_cond (Subject, channel, samples, patch, i, group)
Group_tag = {'ADHD','Controls'};
for group=1:2
  Alpha_Group(:,:,group)=squeeze(mean(mean(mean(mean(Alpha_cond_post(Alpha_cond_post(:,1,1,1,1,group)~=0,:,:,[1],:,group),6),5),4),1))-...
  squeeze(mean(mean(mean(mean(Alpha_cond_post(Alpha_cond_post(:,1,1,1,1,group)~=0,:,:,[2],:,group),6),5),4),1)); %Alpha_Group(channel, samples, group)
end
figure
plottopo(Alpha_Group(:,:,:),'chanlocs',chanlocs,'limits',[Alpha_smooth_time(1) Alpha_smooth_time(end) min(min(min(Alpha_Group(:,:,:))))  max(max(max(Alpha_Group(:,:,:))))], ...
    'title',['Alpha LEFT MINUS RIGHT TARGET by Group'],'legend',Group_tag,'showleg','on','ydir',1,'chans',1:64);

%% Extract Pre-target Alpha per participant 
 %Alpha_cond_pre (Subject, channel, samples, patch, i, group)
 for s=1:length(allsubj)
     if ismember(subject_folder{s},subject_folder_ADHD)
         group=1;
     elseif ismember(subject_folder{s},subject_folder_Control)
         group=2;
     end
     for hemi=1:2
         PreAlpha_mean(s,hemi)=squeeze(mean(mean(mean(mean(Alpha_cond_pre(s,ROIs_LH_RH(s,:,hemi),find(Alpha_smooth_time==-500):find(Alpha_smooth_time==0),:,:,group),3),5),4),2));
     end
 end
% open PreAlpha_mean

%% Plot stim-locked Frontal Negativity by TargetSide:
% labels = {'ADHD Left target','ADHD Right Target','Control Left Target','Control Right Target'};
% colors4 = {'b' 'r' 'b' 'r'};
% figure
% counter=0;
% for group=1:2
%     for targetside=1:2
%         counter=counter+1;
%             avERP_temp = squeeze(mean(mean(mean(ERP_cond(N2_cond(:,1,1,1,1,group)~=0,:,find(t==-100):find(t==1000),targetside,:,group),5),1),6));%(channel, samples)
%         avERP_plot = squeeze(mean(avERP_temp(ch_front,:),1));
%         h(counter) = plot(t(find(t==-100):find(t==1000)),avERP_plot,'Color',colors4{counter},'LineStyle',line_styles2{counter},'Linewidth',2); hold on;
%         set(gca, 'XLim', [-100 1000],'YLim', [-7 1])
%         line(xlim,[0,0],'Color','k');
%         line([0,0],ylim,'Color','k');
%     end
% end
% legend(h,labels,'Location','SouthWest');
% clear h;
% title('Stimulus Locked Frontal Negativity by TargetSide')

%% Plot Resp-locked Frontal Negativity by TargetSide:
labels = {'ADHD Left target','ADHD Right Target','Control Left Target','Control Right Target'};
colors4 = {'b' 'r' 'b' 'r'};
figure
counter=0;
for group=1:2
    for targetside=1:2
        counter=counter+1;
            avERPr_temp = squeeze(mean(mean(mean(ERPr_cond(ERPr_cond(:,1,1,1,1,group)~=0,:,:,targetside,:,group),5),1),6));%(channel, samples)
        avERPr_plot = squeeze(mean(avERPr_temp(ch_front,:),1));
        h(counter) = plot(tr(find(tr==-800):find(tr==100)),avERPr_plot,'Color',colors4{counter},'LineStyle',line_styles2{counter},'Linewidth',2); hold on;
        set(gca, 'XLim', [-800 100],'YLim', [-11 1])
        line(xlim,[0,0],'Color','k');
        line([0,0],ylim,'Color','k');
    end
end
legend(h,labels,'Location','SouthWest');
clear h;
title('Response Locked Frontal Negativity by TargetSide')

%% Plot resp-locked CPP by TargetSide PER PARTICIPANT 

% labels = {'Left target','Right Target'};
% colors4 = {'b' 'r' 'b' 'r'};
% 
% slope_timeframe = [-200,-0];
% 
% for s=file_start:length(allsubj)
%     if ismember(subject_folder{s},subject_folder_ADHD)
%         group=1;
%     elseif ismember(subject_folder{s},subject_folder_Control)
%         group=2;
%     end
%     figure
%     for targetside=1:2
%         avERPr_temp = squeeze(mean(mean(ERPr_cond(s,:,:,targetside,:,group),5),6));%(channel, samples)
%         avERPr_plot = squeeze(mean(avERPr_temp(ch_front,:),1));
%         coef = polyfit(tr(tr>slope_timeframe(1) & tr<slope_timeframe(2)),(avERPr_plot(tr>slope_timeframe(1) & tr<slope_timeframe(2))),1);% coef gives 2 coefficients fitting r = slope * x + intercept
%         FrontalNeg_slope(s,targetside)=coef(1);
%         r = coef(1) .* tr(tr>slope_timeframe(1) & tr<slope_timeframe(2)) + coef(2); %r=slope(x)+intercept, r is a vectore representing the linear curve fitted to the erpr during slope_timeframe
%         h(targetside) = plot(tr(find(tr==-800):find(tr==100)),avERPr_plot,'Color',colors4{targetside},'Linewidth',3); hold on;
%         plot(tr(tr>slope_timeframe(1) & tr<slope_timeframe(2)), r, ':','Color',colors4{targetside},'Linewidth',2);
%         set(gca, 'XLim', [-800 100],'YLim', [-20 3])
%         line(xlim,[0,0],'Color','k');
%         line([0,0],ylim,'Color','k');
%         line([slope_timeframe(1),slope_timeframe(1)],ylim,'linestyle',':','Color','k');
%         line([slope_timeframe(2),slope_timeframe(2)],ylim,'linestyle',':','Color','k');
%     end
%     ylabel('Amplitude (\muVolts)','FontName','Arial','FontSize',12)
%     xlabel('Time (ms)','FontName','Arial','FontSize',12)
%     legend(h,labels,'Location','SouthWest');
%     clear h;
%     title([subject_folder{s}, ' Response Locked Frontal Negitivity by TargetSide'])
% end

%% Extract Response Locked Frontal Negitivity slope" 
    %CPP build-up defined as the slope of a straight line fitted to the response-locked waveform at -400 to -50ms
slope_timeframe = [-200,0];
for s=file_start:length(allsubj)
    if ismember(subject_folder{s},subject_folder_ADHD)
        group=1;
    elseif ismember(subject_folder{s},subject_folder_Control)
        group=2;
    end
    for targetside=1:2
        avERPr_temp = squeeze(mean(mean(ERPr_cond(s,:,:,targetside,:,group),5),6));%(channel, samples)
        avERPr_plot = squeeze(mean(avERPr_temp(ch_front,:),1));
        coef = polyfit(tr(tr>slope_timeframe(1) & tr<slope_timeframe(2)),(avERPr_plot(tr>slope_timeframe(1) & tr<slope_timeframe(2))),1);% coef gives 2 coefficients fitting r = slope * x + intercept
        FrontalNeg_slope(s,targetside)=coef(1);
    end
end



%% Make participant level matrix for export into SPSS or R

%(1)Left_RT; (2)Right_RT; (3)RT_index; (4)NumRTtrials;
%(5)NumPreAlphaTrials; (6)NumN2trials; (7)NumCPPTrials
participant_level(:,1)= RT_Left;
participant_level(:,2)= RT_Right;
participant_level(:,3)= RT_index;
participant_level(:,4)= Valid_RT_Trials;
participant_level(:,5)= ValidPreAlphaTrials;
participant_level(:,6)= ValidN2Trials;
participant_level(:,7)= ValidCPPTrials; %this is also numttrials for frontal_negitivity and post-target alpha
participant_level(:,8:9)=PreAlpha_mean; %Left Hemi, Right Hemi  (from individualised ROI)
participant_level(:,10:13)=N2cN2i_amp_ByTargetSide_GrandAverage; %N2 amplitude using window based on GRAND AVERAGE N2c/i - Contra LeftTarget; Contra RightTarget; Ipsi LeftTarget; Ipsi RightTarget;
participant_level(:,14:17)=reshape(avAlpha_post_desync,length(subject_folder),4); %AlphaDesync - LeftHemi/Left-target, LeftHemi/Right-target, RightHemi/Left-target, RightHemi/Right-target 
participant_level(:,18:19)=CPP_patch_onsets; %Stim. locked CPP onset
participant_level(:,20:23)=N2cN2i_latency_ByTargetSide; %N2 Latency - %(LeftTargetN2c, RightTargetN2c, LeftTargetN2i, RightTargetN2i)  N2c_latency_LeftTarget
participant_level(:,24:25)=CPP_slope; %LeftTarget, RightTarget
participant_level(:,26:27)=FrontalNeg_slope;% FrontalNeg_slope
participant_level(:,28)=group_vector;
participant_level(:,29:32)=N2cN2i_amp_ByTargetSide_ParticipantLevel; %N2 amplitude using window based on PARTICIPANT's AVERAGE N2c/i - Contra LeftTarget; Contra RightTarget; Ipsi LeftTarget; Ipsi RightTarget;

open participant_level

csvwrite (['participant_level_matrix.csv'],participant_level)

subject_folder=subject_folder';
cell2csv ('IDs.csv',subject_folder)




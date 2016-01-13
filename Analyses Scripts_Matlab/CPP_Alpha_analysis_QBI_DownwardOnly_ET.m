

targcodes = [101:106]; % Continuous Dots

old_fs=1024; % old sample rate
fs = 500;

% in sample points, the ERP epoch
% GL: Define your epoch here, I have epoch and a cropped epoch as this
% code also does alpha TSE, so needed to crop 200ms either side. These
% might need to be changed to be valid for a sampling rate of 512
ts = -1*fs:2.080*fs; % -1000ms to 1880ms with 200ms either side.
t = ts*1000/fs;
ts_crop = -0.8*fs:1.880*fs;
t_crop = ts_crop*1000/fs;

BLint = [-100 0];   % baseline interval in ms
default_response_time = 2.080-0.1; % GL: i.e. length of coherent dot motion (1880ms) + 100ms

% Alpha_samps = ((abs(t_crop(1))+abs(t_crop(end)))/50)-1; %50ms alpha samples
Alpha_samps = 52; % GL: Size of epochs in samples, alpha TSE had 52 samples here, depends on the size of the epoch above.

ERP_samps = length(t_crop);
Pupil_samps = ERP_samps;

nchan = 64; % or 72 if you want to include EOGs.

LPFcutoff=35;       % Low Pass Filter cutoff
HPFcutoff=0;       % High Pass Filter - either 0.01, 0.1, or 0.25 for cuttoff as 

LPF = 1;    % 1 = low-pass filter the data, 0=don't.
HPF = 0;

bandlimits(1,1) = 8; % defining the filter for alpha bandpass.
bandlimits(1,2) = 13;
[H1,G1]=butter(4,[2*(bandlimits(1,1)/fs) 2*(bandlimits(1,2)/fs)]); % alpha bandpass

PretargetARwindow=[-0.500,0];%time window (in seconds, must be factor of the 50ms alpha samples) to search for pre-target artifacts

ARchans = [1:64];
ARchans_for_blinks = [1:64];
% ARchans=[1,2,3,6,7,20,21,22,23,25,26,27,30,31,32,33,34,35,36,38,57,58,59,60,62,63,64]; %DN: "SelectElectrodes"
% ARchans_for_blinks=[1,2,3,6,7,20,21,22,23,25,26,27,30,31,32,33,34,35,36,38,57,58,59,60,62,63,64]; %DN: "SelectElectrodes"
% ARchans=[20,21,22,23,25,26,27,30,31,32,38,57,58,59,60,62,63,64]; %DN: "VerySelectElectrodes" if you want to only use Eyetracker for blinks  instead of Eyetracker plus frontal electrodes for blinks 
% ARchans_for_blinks=[20,21,22,23,25,26,27,30,31,32,38,57,58,59,60,62,63,64]; %DN: "VerySelectElectrodes" if you want to only use Eyetracker for blinks  instead of Eyetracker plus frontal electrodes for blinks 

artifth = 100;
artifchans=[];  % keep track of channels on which the threshold is exceeded, causing trial rejection

chanlocs = readlocs('cap64.loc');
chanlocs = chanlocs(1:nchan)';

clear files matfiles; k=0;
for n=1:length(blocks)
    k=k+1;
    paths{k} = [path subject_folder{s} '\'];
    files{k} = [path subject_folder{s} '\' allsubj{s} '_C' num2str(blocks(n)) '.bdf'];
    matfiles{k} = [path subject_folder{s} '\' allsubj{s} '_C' num2str(blocks(n)) '.mat'];
    ET_files{k} = [path 'SamplesAndEvents_combined\' allsubj{s} '_C' num2str(blocks(n)) '.asc'];
    ET_matfiles{k} = [path subject_folder{s} '\' allsubj{s} '_C' num2str(blocks(n)) '_ET.mat'];
end


rejected_trial_n=[];
artifact_PretargetToTarget_n=[];
artifact_BLintTo100msPostResponse_n=[];
artifact_BLintTo450ms_n=[];
artifact_neg1000_to_0ms_n=[];

erp = [];erp_HPF = []; Alpha = []; Pupil=[]; GAZE_X=[]; GAZE_Y=[]; n=0; artifacts_anywhereInEpoch = 0;
allRT=[]; allrespLR=[]; allTrig=[]; numtr=0;    % note allRT will be in sample points
for f=1:length(files)
    disp(f)
    filename=[files{f}];
    EEG = pop_biosig(filename, 'blockepoch', 'off','channels',[1:nchan]);
    EEG2 = pop_resample(EEG,fs);%use pop_resample here to get the trigs (EEG2.event(i).type) and stimes (EEG2.event(i).latency) of 
                                %the downsampled data but do my own dowmsampling of eeg.data later using matlab's resample() function 
    
    numev = length(EEG2.event);
    
    load(matfiles{f}); %DN
    trialCond = trialCond+100;
    
    % First LP Filter
%      if LPF, EEG.data = eegfilt(EEG.data,old_fs,0,LPFcutoff); end %old FIR Filter
    if LPF, EEG = pop_eegfiltnew(EEG, 0, LPFcutoff); end %new FIR filter

    % interpolate bad channels
    if ~isempty(badchans)
        EEG.chanlocs = chanlocs;
        EEG=eeg_interp(EEG,[badchans],'spherical');
    end
    
    EEG.data = double(EEG.data);
    EEG_HPF = EEG;
  
    %new HPF method
    if HPF, EEG_HPF = pop_eegfiltnew(EEG_HPF, HPFcutoff,0); end
    
    %old HPF method:
%      if HPF
%         [H_HP1,G_HP1]=butter(4,2*HPFcutoff/old_fs,'high');   % low cutoff
%         EEG_HPF.data = double(EEG.data(1:nchan,:));
%         for q=1:nchan
%             EEG_HPF.data(q,:) = filtfilt(H_HP1,G_HP1,EEG.data(q,:)); % high pass filtering 
%         end
%         disp('HPF finished')
%      else
%         EEG_HPF.data=double(EEG.data);
%     end
    
    % average-reference the whole continuous data (safe to do this now after interpolation):
    EEG.data = EEG.data - repmat(mean(EEG.data([1:nchan],:),1),[nchan,1]);
    EEG_HPF.data = EEG_HPF.data - repmat(mean(EEG_HPF.data([1:nchan],:),1),[nchan,1]);
               
    %% Sync up the Eyelink data:
%     if ~exist(ET_matfiles{f}, 'file') %DN: if ET matfile has NOT has been saved previouslty,
        FixEyelinkMessages %then calculate and save it now
%     end
        
    load(ET_matfiles{f}) %DN: load the ET mat file
    %Add an extra 4 rows into the EEG struct - 'TIME'
    %'GAZE_X' 'GAZE_Y' 'AREA'. This will add these as extra channels onto EEG.data
    %So the final channel is the pupil area (i.e. diameter):
    
        if strcmp(subject_folder(s),'C183') && f==8  % C183's block 8 has first trigger missing in the EEG, so make first trigger for Eyetracker the first target existing in the EEG which is "105" for syncing up EEG and eyetracking
            first_event=105;
        end
        
        if strcmp(subject_folder(s),'AD46C') && f==6  % AD46C's block 6 has first few triggers missing in the EEG, so make first trigger for Eyetracker the first target existing in the EEG which is "104" for syncing up EEG and eyetracking
            first_event=104;
        end
               
    
    EEG = pop_importeyetracker(EEG,ET_matfiles{f},[first_event last_event]...
        ,[1:4] ,{'TIME' 'GAZE_X' 'GAZE_Y' 'AREA'},0,1,0,1);
    
    
    Pupil_ch=length(EEG.data(:,1)); %Now that the eyelink data is added to the EEG struct Find the channel number for pupil area/diameter
    GAZE_X_ch=length(EEG.data(:,1))-2;
    GAZE_Y_ch=length(EEG.data(:,1))-1;
    
    %% Downsample to 500Hz 
    resamp_data = [];
    EEG.data = double(EEG.data);
    for elec = 1:size(EEG.data,1)
        resamp_data(elec,:) = resample(EEG.data(elec,:),fs,old_fs,0);%resample(data,P,Q), cut off 100 samples from either end.
    end
    EEG.data = resamp_data;
    EEG.pnts = size(resamp_data,2);
    EEG.srate = fs;
    
%     EEG = pop_resample(EEG,fs);
    
    if HPF %now downsample the HPF data
    resamp_data = [];
    EEG_HPF.data = double(EEG_HPF.data);
    for elec = 1:size(EEG_HPF.data,1)
        resamp_data(elec,:) = resample(EEG_HPF.data(elec,:),fs,old_fs,0);%resample(data,P,Q), cut off 100 samples from either end.
    end
    EEG_HPF.data = resamp_data;
    EEG_HPF.pnts = size(resamp_data,2);
    EEG_HPF.srate = fs;
    else 
        EEG_HPF = EEG;
    end 

%     if HPF %now downsample the HPF data
%     EEG_HPF = pop_resample(EEG_HPF,fs);
%     else 
%         EEG_HPF = EEG;
%     end 
    
    %%
    
    % Fish out the event triggers and times
    clear trigs stimes RT
    for i=1:numev
        trigs(i)=EEG2.event(i).type;
        stimes(i)=round(EEG2.event(i).latency);
    end
    
    targtrigs = [];
    for n=1:length(trigs)
        if any(targcodes(:)==trigs(n))
            targtrigs = [targtrigs n];
        end
    end
    
    if trigs(targtrigs(end))==trialCond(1)
        motion_on = targtrigs(1:end-1); % GL: indices of trigs when motion on. get rid of last trig, it was a repeat
    else
        motion_on = targtrigs;
    end
    
    cohmo_trigs = find(PTBtrig>100); %DN
    rtlim=[0.2 2]; %DN: RT must be between 200ms and 2000ms
    if length(RespLR)<length(RTs)
        RespLR(length(RTs))=0; %DN: this is just for if they missed the last target the paradigm code won't have recorded "0" for RespLR this makes it 0
    end
    
    found = 0;
    % GL: take care of blocks with wonky triggers, replaces a trial with a
    % missing trigger with a NaN value, this only happens on the very odd
    % occasion where there was a port conflict with two simultanious
    % triggers
    if length(motion_on)<length(trialCond) % There's a trigger missing
        disp('Trigger Missing')
        for n=1:length(motion_on)
            if trigs(motion_on(n))~=trialCond(n)
                found = 1;
                motion_on = [motion_on(1:n-1),NaN,motion_on(n:end)];
            end
        end
        if found==0
            motion_on = [motion_on,NaN];
        end
    elseif length(motion_on)>length(trialCond) % There's an extra trigger
        disp('Extra Trigger')
        for n=1:length(trialCond)
            if trigs(motion_on(n))~=trialCond(n) % e.g. trigger 12 extra, trigs(motion_on(49))==trialCond(48)
                motion_on(n) = [];
            end
        end
    end
    
    
    
    for n=1:length(motion_on)
        clear ep ep_HPF ep_alpha ep_art_reject ep_test ep_filt_Alpha_Hz ep_filt_abs_cut ep_pupil ep_GAZE_X ep_GAZE_Y
        if ~isnan(motion_on(n))
            locktime = stimes(motion_on(n)); % Lock the epoch to coherent motion onset.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %If they completed the original version of paradigm (i.e. the first 5 ADHD kids only) must calculate RT and accuracy like this:
            try
                if ismember(subject_folder{s},original_paradigm)
                    stimtime = PTBtrigT(cohmo_trigs(n));
                    nextresp = find(RespT>stimtime & RespT<stimtime+rtlim(2),1);
                    if ~isempty(nextresp)
                        response_time = (RespT(nextresp) - stimtime)*fs;
                        response_time = floor(response_time); % round it off.
                    else
                        response_time = default_response_time*fs; % there was no response, set response to 1980ms. This is just to define the epoch for artifact rejection
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %Else they completed the updated paradigm (i.e. everybody else) can calculate RT like this:
                elseif RespLR(n) %if a response was made:
                    stimtime = PTBtrigT(cohmo_trigs(n));
                    if ~RespT_LeftClick1st(n) && ~RespT_RightClick1st(n)
                        if RespT(n)>stimtime
                            response_time = (RespT(n) - stimtime)*fs;
                            response_time = floor(response_time); % round it off.
                        else %else response was made before the stimtime or at exactly the stimtime
                            response_time = default_response_time*fs; % since response was made before or at stimtime, set response to 1980ms. This is just to define the epoch for artifact rejection
                        end
                    elseif RespT_LeftClick1st(n)
                        if (RespT(n)+RespT_LeftClick1st(n))/2 > stimtime
                            response_time =((RespT(n)+RespT_LeftClick1st(n))/2 - stimtime)*fs; %RT is average of when the two buttons were pressed
                            response_time = floor(response_time); % round it off.
                        else % else response was made before the stimtime or at exactly the stimtime
                            response_time = default_response_time*fs; % since response was made before or at stimtime, set response to 1980ms. This is just to define the epoch for artifact rejection
                        end
                    elseif RespT_RightClick1st(n)
                        if (RespT(n)+RespT_RightClick1st(n))/2 > stimtime
                            response_time =((RespT(n)+RespT_RightClick1st(n))/2 - stimtime)*fs; %RT isaverage of when the two buttons were pressed
                            response_time = floor(response_time); % round it off.
                        else %else response was made before the stimtime or at exactly the stimtime
                            response_time = default_response_time*fs; % since response was made before or at stimtime, set response to 1980ms. This is just to define the epoch for artifact rejection
                        end
                    end
                else % there was no response
                    stimtime = PTBtrigT(cohmo_trigs(n));
                    response_time = default_response_time*fs; % there was no response, set response to 1980ms. This is just to define the epoch for artifact rejection
                end
            catch
                disp('EEG ended too soon') % I had a few trials where EEG was cutoff too soon...
                response_time = default_response_time*fs;
            end
            try
                ep = EEG.data(1:nchan,locktime+ts);   % chop out an epoch
                ep_HPF = EEG_HPF.data(1:nchan,locktime+ts);
            catch
                disp('EEG ended too soon')
                %%%%%%%%%
                numtr = numtr+1;
                rejected_trial_n(numtr)=1;
                %%%%%%%%%
                allTrig(numtr) = 0;
                allblock_count(numtr) = f;
                allrespLR(numtr) = 0;
                allRT(numtr) = 0;
                
                erp(:,:,numtr) = zeros(nchan,ERP_samps);
                erp_HPF(:,:,numtr) = zeros(nchan,ERP_samps);
                Alpha(:,:,numtr) = zeros(nchan,Alpha_samps);
                
                Pupil(:,numtr) = zeros(1,Pupil_samps);
                GAZE_X(:,numtr) = zeros(1,Pupil_samps);
                GAZE_Y(:,numtr) = zeros(1,Pupil_samps);
        
%                         keyboard
                continue;
            end
            
            try
                ep_pupil = EEG.data(Pupil_ch,locktime+ts);   % chop out an epoch of pupil diameter
                ep_GAZE_X = EEG.data(GAZE_X_ch,locktime+ts); % chop out an epoch of GAZE_X
                ep_GAZE_Y = EEG.data(GAZE_Y_ch,locktime+ts); % chop out an epoch of GAZE_Y
            catch
                disp('Pupil Diameter data ended too soon')
                %%%%%%%%%
                numtr = numtr+1;
                rejected_trial_n(numtr)=1;
                %%%%%%%%%
                allTrig(numtr) = 0;
                allrespLR(numtr) = 0;
                allRT(numtr) = 0;
                allblock_count(numtr) = f;
                Pupil(:,numtr) = zeros(1,Pupil_samps);
                GAZE_X(:,numtr) = zeros(1,Pupil_samps);
                GAZE_Y(:,numtr) = zeros(1,Pupil_samps);

                keyboard
                continue;
            end
            
            BLamp =mean(ep(:,find(t>BLint(1) & t<BLint(2))),2); % record baseline amplitude (t<0) for each channel,
            ep = ep - repmat(BLamp,[1,length(t)]); % baseline correction
            
            BLamp = mean(ep_HPF(:,find(t>BLint(1) & t<BLint(2))),2);
            ep_HPF = ep_HPF - repmat(BLamp,[1,length(t)]); % baseline correction
            
            
            ep_test = [find(ts==-0.8*fs):find(ts==(0*fs))];
            if isempty(ep_test)
                disp('Empty epoch for art rejection')
                keyboard
            end
            ep_test = [find(t>BLint(1) & t<floor(((response_time*1000/fs)+100)))];
            if isempty(ep_test)
                disp('Empty epoch for art rejection2')
                keyboard
            end
            
            %%%%%%%%%
            numtr = numtr+1;
            rejected_trial_n(numtr)=0;
            %%%%%%%%% 
            allblock_count(numtr) = f;
            
            artifchans_thistrial = ARchans(find(max(abs(ep_HPF(ARchans,find(t<0))),[],2)>artifth | max(abs(ep_HPF(ARchans,find(t>BLint(1) & t<floor(((response_time*1000/fs)+100))))),[],2)>artifth));
            
            artifchans_blinks_thistrial = ARchans(find(max(abs(ep_HPF(ARchans_for_blinks,find(t<0))),[],2)>artifth));
            
            artifchans_blinks_thistrial(find(ismember(artifchans_blinks_thistrial,artifchans_thistrial))) = [];
            artifchans_thistrial = [artifchans_thistrial,artifchans_blinks_thistrial(find(~ismember(artifchans_blinks_thistrial,artifchans_thistrial)))];
            artifchans = [artifchans artifchans_thistrial];
            
            artifchans_PretargetToTarget_thistrial = ARchans(find(max(abs(ep_HPF(ARchans,find(ts==PretargetARwindow(1)*fs):find(ts==0))),[],2)>artifth));  % pre-target artifact rejection from -500-0ms only [find(ts==-.500*fs) gives you the point in samples -500ms before the target]
            artifchans_BLintTo100msPostResponse_thistrial = ARchans(find(max(abs(ep_HPF(ARchans,find(t>BLint(1) & t<floor(((response_time*1000/fs)+100))))),[],2)>artifth)); %Baseling until 100ms after response.
            
            artifchans_BLintTo450ms_thistrial = ARchans(find(max(abs(ep_HPF(ARchans,find(ts==-0.1*fs):find(ts==0.45*fs))),[],2)>artifth));  % artifact rejection from -100 to 500ms only
            

            if ~isempty(artifchans_thistrial)
                artifacts_anywhereInEpoch = artifacts_anywhereInEpoch+1;
            end   % artifact rejection (threshold test)
            
            if artifchans_PretargetToTarget_thistrial
                artifact_PretargetToTarget_n(numtr)=1;
            else 
                artifact_PretargetToTarget_n(numtr)=0;
            end
            
            if artifchans_BLintTo100msPostResponse_thistrial
                artifact_BLintTo100msPostResponse_n(numtr)=1;
            else
                artifact_BLintTo100msPostResponse_n(numtr)=0;
            end
            
            if artifchans_BLintTo450ms_thistrial
                artifact_BLintTo450ms_n(numtr)=1;
            else
                artifact_BLintTo450ms_n(numtr)=0;
            end
            


            %%
            ep_pupil = double(ep_pupil);
            ep_GAZE_X = double(ep_GAZE_X);
            ep_GAZE_Y = double(ep_GAZE_Y);
            
            ep = double(ep); % filtfilt needs doubles
            %%  Ger's method for alpha::
%             ep_filt_Alpha_Hz = filtfilt(H1,G1,ep')'; % alpha filter.
            for q = 1:size(ep,1) % alpha filter
                ep_filt_Alpha_Hz(q,:) = filtfilt(H1,G1,ep(q,:));
            end
            
            %%%%%%%% rectifying the data and chopping off ends %%%%%%%%
            ep_filt_abs_cut = abs(ep_filt_Alpha_Hz(:,find(ts==ts_crop(1)):find(ts==ts_crop(end)))); % 64x701
            % Smoothing. This goes from 1:700, leaving out the final
            % sample, 0ms.
            alpha_temp = []; Alpha_smooth_time = []; Alpha_smooth_sample = [];
            for q = 1:size(ep_filt_abs_cut,1)
                counter = 1;
                for windowlock = 26:25:size(ep_filt_abs_cut,2)-25 % 1,26,51,etc. 26 boundaries = 1:50, 51 boundaries = 26:75, 676 boundaries = 651:
                    alpha_temp(q,counter) = mean(ep_filt_abs_cut(q,windowlock-25:windowlock+24));
                    Alpha_smooth_time(counter) = t_crop(windowlock);
                    Alpha_smooth_sample(counter) = ts_crop(windowlock);
                    counter = counter+1;
                end
            end
            
            %             figure
            %             plot(ep_filt_abs_cut(54,:))
            %             figure
            %             plot(Alpha_smooth_time,alpha_temp(54,:))
            %             keyboard
            
            %             figure, hold on, for i = 1:64, plot(ep(i,find(ts==ts_crop(1)):find(ts==ts_crop(end))),'b'), end; keyboard
            

            erp(:,:,numtr) = ep(:,find(ts==ts_crop(1)):find(ts==ts_crop(end)));
            erp_HPF(:,:,numtr) = ep_HPF(:,find(ts==ts_crop(1)):find(ts==ts_crop(end)));
            Pupil(:,numtr)= ep_pupil(find(ts==ts_crop(1)):find(ts==ts_crop(end)));
            GAZE_X(:,numtr)= ep_GAZE_X(find(ts==ts_crop(1)):find(ts==ts_crop(end)));
            GAZE_Y(:,numtr)= ep_GAZE_Y(find(ts==ts_crop(1)):find(ts==ts_crop(end)));
            Alpha(:,:,numtr) = alpha_temp;
            allTrig(numtr) = trigs(motion_on(n));
            
            try % get reaction time data for further analysis
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %If they completed the original version of paradigm (i.e. the first 5 ADHD kids only) must calculate RT and accuracy like this:
                if ismember(subject_folder{s},original_paradigm)
                    stimtime = PTBtrigT(cohmo_trigs(n));
                    nextresp = find(RespT>stimtime & RespT<stimtime+rtlim(2),1);
                    if ~isempty(nextresp)
                        allrespLR(numtr) = 1;
                        allRT(numtr) = round((RespT(nextresp) - stimtime)*fs);
                    else %there was no response
                        allrespLR(numtr) = 0;
                        allRT(numtr) = 0;
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %Else they completed the updated paradigm (i.e. everybody else) can calculate RT more accuratly like this:
                elseif RespLR(n) %if a response was made:
                    stimtime = PTBtrigT(cohmo_trigs(n));
                    allrespLR(numtr) = 1; %correct response
                    if ~RespT_LeftClick1st(n) && ~RespT_RightClick1st(n) %they clicked both buttons at exactly the same time
                        if RespT(n)>stimtime
                            allRT(numtr) = round((RespT(n) - stimtime)*fs);
                        end
                    elseif RespT_LeftClick1st(n)
                        if (RespT(n)+RespT_LeftClick1st(n))/2 > stimtime
                            allRT(numtr) =round(((RespT(n)+RespT_LeftClick1st(n))/2 - stimtime)*fs); %RT is average of when the two buttons were pressed
                        end
                    elseif RespT_RightClick1st(n)
                        if (RespT(n)+RespT_RightClick1st(n))/2 > stimtime
                            allRT(numtr) =round(((RespT(n)+RespT_RightClick1st(n))/2 - stimtime)*fs); %RT isaverage of when the two buttons were pressed
                        end
                    end
                else %there was no response
                    allrespLR(numtr) = 0;
                    allRT(numtr) = 0;
                end
            catch
                allrespLR(numtr) = 0;
                allRT(numtr) = 0;
            end
        else
            %%%%%%%%%
            numtr = numtr+1;
            rejected_trial_n(numtr)=1;
            %%%%%%%%%
            allTrig(numtr) = 0;
            allblock_count(numtr) = f;
            allrespLR(numtr) = 0;
            allRT(numtr) = 0;
            erp(:,:,numtr) = zeros(nchan,ERP_samps);
            erp_HPF(:,:,numtr) = zeros(nchan,ERP_samps);
            Alpha(:,:,numtr) = zeros(nchan,Alpha_samps);
            Pupil(:,numtr) = zeros(1,Pupil_samps);
            GAZE_X(:,numtr) = zeros(1,Pupil_samps);
            GAZE_Y(:,numtr) = zeros(1,Pupil_samps);
        end
    end
end
Alpha = Alpha(1:nchan,:,:);
erp = erp(1:nchan,:,:);
erp_HPF = erp_HPF(1:nchan,:,:);
Pupil=Pupil(:,:);
GAZE_X=GAZE_X(:,:);
GAZE_Y=GAZE_Y(:,:);
figure;
hist(artifchans,[1:nchan]); title([allsubj{s} ': ' num2str(artifacts_anywhereInEpoch) ' artifacts = ',num2str(round(100*(artifacts_anywhereInEpoch/length(allRT)))),'%']) % s from runafew
disp([allsubj{s},' number of trials: ',num2str(length(allRT))])
if length(allRT)~=size(Alpha,3)
    disp(['WTF ',allsubj{s},' number of trials: ',num2str(length(allRT)),' not same as Alpha'])
end
save([path subject_folder{s} '\' allsubj{s} '_',num2str(bandlimits(1,1)),'_to_',num2str(bandlimits(1,2)), ...
    'Hz_neg',num2str(abs(t_crop(1))),'_to_',num2str(t_crop(end)),'_',num2str(length(ARchans)),'ARchans',...
    '_',num2str(LPFcutoff),'HzLPF_point',strrep(num2str(HPFcutoff),'0.',''),'HzHPF_ET'],...
    'Alpha','erp','erp_HPF','Pupil','GAZE_Y','GAZE_X','allRT','allrespLR','allTrig','allblock_count', ...
    'artifchans','t_crop','Alpha_smooth_time','Alpha_smooth_sample',...
    'artifact_PretargetToTarget_n','artifact_BLintTo100msPostResponse_n',...
    'rejected_trial_n','artifact_BLintTo450ms_n')
close all
return;


% %% STFT:
% nchan=64;
% fs=500;
% clear stftC
% TC = [-1500:100:700];%100ms sliding window
% fftlen = 300;
% F = [0:20]*fs/fftlen; %Frequencies
% for tt=1:length(TC)
%     temp = abs(fft(erp(:,find(t_crop>=TC(tt),1)-fftlen/2+[1:fftlen],:),[],2))./(fftlen/2);
%     stftC(:,:,tt,:) = reshape(temp(:,1:length(F),:),[nchan length(F) 1 size(erp,3)]);
% end %stftC(Electrode,Frequency,Time,Trial)
%
% %Isolate time-range and collapse accross it
% Trange = find(TC>0 & TC<800);
% spec =squeeze(mean(stftC(:,:,Trange,:),3)); %spec(Electrode,Frequency,Trial)
% %Isolate frequency band within that time range and collapse accross it:
% band = find(F>8 & F<14);
%
% PreAlpha=squeeze(mean(spec(:,band,:),2)); %PreAlpha(electrode trial)
%
%
% Alpha_simon=squeeze(mean(stftC(:,band,:,:),2)); %Alpha_simon(Electrode,Time,Trial)
% %
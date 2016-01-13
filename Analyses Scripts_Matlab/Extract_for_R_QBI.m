clear all
close all
clc

% path='C:\Users\Dan\Dropbox\Monash\My Papers\ADHD vs Controls EEG QBI\Dots Data Downward\';
path='C:\Users\newmand\Dropbox\Monash\My Papers\ADHD vs Controls EEG QBI\Dots Data Downward\';

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

duds = []; %
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


ch_CPP = [31]; %Pz


if ~isempty(duds) && isempty(single_participants)
    subject_folder([duds]) = [];
    allsubj([duds]) = [];
end

if ~isempty(single_participants)
    subject_folder = subject_folder(single_participants);
    allsubj = allsubj(single_participants);
end

% side,ITI
targcodes = zeros(2,3);
targcodes(1,:) = [101 103 105]; % left patch,
targcodes(2,:) = [102 104 106]; % right patch

rtlim=[0.2 2]; %RT must be between 200ms and 2000ms
fs=500; % sample rate %500Hz

BLint = [-100 0];   % baseline interval in ms

ts = -0.8*fs:1.880*fs;   % in sample points, the ERP epoch
t = ts*1000/fs;

ts_crop = -0.8*fs:1.880*fs;
t_crop = ts_crop*1000/fs;

trs = [-.800*fs:fs*.100];
tr = trs*1000/fs;


master_matrix_R = []; % This saves the matrix for SPSS/R analysis.
total_numtr = 0;
ID_vector=cell(30000,1); %this will save the subjects ID for each single trial can be pasted into SPSS for ID column. Code at the end of the script clear the emplt cells

HPF=0; %Use high-pass filtered erp? 1=yes, 0=no
matfile='_8_to_13Hz_neg800_to_1880_64ARchans_35HzLPF_point0HzHPF_ET.mat';

for s=1:length(allsubj)
    disp(['Subject: ',num2str(s)])
    disp(['Subject: ',allsubj{s}])
    
    
    %     load([path subject_folder{s} '\' allsubj{s} '_ROIs.mat']); %load the participant's individualised Alpha ROI electrodes sensitive to Light
    if ismember(subject_folder{s},subject_folder_Control)
        load([path 'Controls\' subject_folder{s} '\' allsubj{s} matfile]);
        load([path 'Controls\' subject_folder{s} '\' 'avN2c_GrandAverage_peak_amp_index.mat']);
        load([path 'Controls\' subject_folder{s} '\' 'avN2i_GrandAverage_peak_amp_index.mat']);
        load([path 'Controls\' subject_folder{s} '\' 'avN2c_ParticipantLevel_peak_amp_index.mat']);
        load([path 'Controls\' subject_folder{s} '\' 'avN2i_ParticipantLevel_peak_amp_index.mat']);
    elseif ismember(subject_folder{s},subject_folder_ADHD)
        load([path 'ADHD\' subject_folder{s} '\' allsubj{s} matfile]);
        load([path 'ADHD\' subject_folder{s} '\' 'avN2c_GrandAverage_peak_amp_index.mat']);
        load([path 'ADHD\' subject_folder{s} '\' 'avN2i_GrandAverage_peak_amp_index.mat']);
        load([path 'ADHD\' subject_folder{s} '\' 'avN2c_ParticipantLevel_peak_amp_index.mat']);
        load([path 'ADHD\' subject_folder{s} '\' 'avN2i_ParticipantLevel_peak_amp_index.mat']);
    else
        keyboard
    end
    
    
    %if the final trial was a miss there will be no RT recorded, just need
    %to add a zero for RT in that case
    if length(allRT)<length(allrespLR)
        allRT(length(allRT):length(allrespLR))=0;
    end
    
    
    if HPF %Use high-pass filtered erp?
        erp=erp_HPF;
    end
    
    allTrials=allTrig; % just renamed this because it makes more sense to me to call it trials
    
    %% calculate the response locked ERPs
    erpr = zeros(size(erp,1),length(tr),size(erp,3));
    validrlock = zeros(1,length(allRT)); % length of RTs.
    for n=1:length(allRT);
        [blah,RTsamp] = min(abs(t_crop*fs/1000-allRT(n))); % get the sample point of the RT.
        if RTsamp+trs(1) >0 & RTsamp+trs(end)<=length(t_crop) & allRT(n)>0 % is the RT larger than 1st stim RT point, smaller than last RT point.
            erpr(:,:,n) = erp(:,RTsamp+trs,n);
            validrlock(n)=1;
        end
    end
    
    %% Find and index pre and post-target blinks and fixation breaks:
    
    degrees=3;  %Set the degrees deviation which defines a fixation break
    %Screen parameters and viewing distance from Monitor at QBI
    dist = 57;  % viewing distance in cm is closer than using LCD (57)
    scres = [1024 768]; %screen resolution
    cm2px = scres(1)/39;% for Monitor at QBI
    deg2px = dist*cm2px*pi/180;
    %   par.patchloc = [-10 -4; 10 -4;]; % patch location coordinates [x y] in degrees relative to center of screen
    
    for trial=1:length(GAZE_X(1,:))
        %% Blinks:
        
        %Blinkneg500to0
        if any(GAZE_X(find(t_crop==-500):find(t_crop==0),trial)==0)
            Blinkneg500to0(trial)=1;
        else
            Blinkneg500to0(trial)=0;
        end
        %Blinkneg100_100PR
        if allRT(trial)~=0 && allRT(trial)*1000/fs <1900 %if there was an RT, search for blink from BLint to 100ms after RT:
            if any(GAZE_X(find(t_crop==-100):find(t_crop==allRT(trial)*1000/fs+ 100),trial)==0)
                Blinkneg100_100PR(trial) = 1;
            else
                Blinkneg100_100PR(trial) = 0;
            end
            %else there was no RT so search from BLint until end of epoch:
        elseif any(GAZE_X(find(t_crop==-100):end,trial)==0)
            Blinkneg100_100PR(trial) = 1;
        else
            Blinkneg100_100PR(trial) = 0;
        end
        %Blinkneg100_450
        if any(GAZE_X(find(t_crop==-100):find(t_crop==450),trial)==0)
            Blinkneg100_450(trial)=1;
        else
            Blinkneg100_450(trial)=0;
        end
        
        %% LeftFixBreak:
        
        %LeftFixBreakneg500to0
        if any(((GAZE_X(find(t_crop==-500):find(t_crop==0),trial)-scres(1)/2))<-(degrees*deg2px)) &&...
                ~any(((GAZE_X(find(t_crop==-500):find(t_crop==0),trial)-scres(1)/2))>(degrees*deg2px))
            
            LeftFixBreakneg500to0(trial)=1;
        else
            LeftFixBreakneg500to0(trial)=0;
        end
        
        %LeftFixBreakneg100_100PR
        if allRT(trial)~=0 && allRT(trial)*1000/fs <1900 %if there was an RT, search for LeftFixBreak from BLint to 100ms after RT:
            if any(((GAZE_X(find(t_crop==-100):find(t_crop==allRT(trial)*1000/fs+ 100),trial)-scres(1)/2))<-(degrees*deg2px)) &&...
                    ~any(((GAZE_X(find(t_crop==-100):find(t_crop==allRT(trial)*1000/fs+ 100),trial)-scres(1)/2))>(degrees*deg2px))
                LeftFixBreakneg100_100PR(trial) = 1;
            else
                LeftFixBreakneg100_100PR(trial) = 0;
            end
            %else there was no RT so search from BLint until end of epoch:
        elseif any(((GAZE_X(find(t_crop==-100):end,trial)-scres(1)/2))<-(degrees*deg2px)) &&...
                ~any(((GAZE_X(find(t_crop==-100):end,trial)-scres(1)/2))>(degrees*deg2px))
            LeftFixBreakneg100_100PR(trial) = 1;
        else
            LeftFixBreakneg100_100PR(trial) = 0;
        end
        
        %LeftFixBreakneg100_450
        if any(((GAZE_X(find(t_crop==-100):find(t_crop==450),trial)-scres(1)/2))<-(degrees*deg2px)) &&...
                ~any(((GAZE_X(find(t_crop==-100):find(t_crop==450),trial)-scres(1)/2))>(degrees*deg2px))
            LeftFixBreakneg100_450(trial)=1;
        else
            LeftFixBreakneg100_450(trial)=0;
        end
        
        %% RightFixBreak:
        
        %RightFixBreakneg500to0
        if ~any(((GAZE_X(find(t_crop==-500):find(t_crop==0),trial)-scres(1)/2))<-(degrees*deg2px)) &&...
                any(((GAZE_X(find(t_crop==-500):find(t_crop==0),trial)-scres(1)/2))>(degrees*deg2px))
            RightFixBreakneg500to0(trial)=1;
        else
            RightFixBreakneg500to0(trial)=0;
        end
        
        %RightFixBreakneg100_100PR
        if allRT(trial)~=0 && allRT(trial)*1000/fs <1900 %if there was an RT, search for RightFixBreak from BLint to 100ms after RT:
            if ~any(((GAZE_X(find(t_crop==-100):find(t_crop==allRT(trial)*1000/fs+ 100),trial)-scres(1)/2))<-(degrees*deg2px)) &&...
                    any(((GAZE_X(find(t_crop==-100):find(t_crop==allRT(trial)*1000/fs+ 100),trial)-scres(1)/2))>(degrees*deg2px))
                RightFixBreakneg100_100PR(trial) = 1;
            else
                RightFixBreakneg100_100PR(trial) = 0;
            end
            %else there was no RT so search from BLint until end of epoch:
        elseif ~any(((GAZE_X(find(t_crop==-100):end,trial)-scres(1)/2))<-(degrees*deg2px)) &&...
                any(((GAZE_X(find(t_crop==-100):end,trial)-scres(1)/2))>(degrees*deg2px))
            RightFixBreakneg100_100PR(trial) = 1;
        else
            RightFixBreakneg100_100PR(trial) = 0;
        end
        
        %RightFixBreakneg100_450
        if ~any(((GAZE_X(find(t_crop==-100):find(t_crop==450),trial)-scres(1)/2))<-(degrees*deg2px)) &&...
                any(((GAZE_X(find(t_crop==-100):find(t_crop==450),trial)-scres(1)/2))>(degrees*deg2px))
            RightFixBreakneg100_450(trial)=1;
        else
            RightFixBreakneg100_450(trial)=0;
        end
        
        %% Both Left AND Right FixBreak in same epoch:
        
        %BothFixBreakneg500to0
        if any(((GAZE_X(find(t_crop==-500):find(t_crop==0),trial)-scres(1)/2))<-(degrees*deg2px)) &&...
                any(((GAZE_X(find(t_crop==-500):find(t_crop==0),trial)-scres(1)/2))>(degrees*deg2px))
            BothFixBreakneg500to0(trial)=1;
        else
            BothFixBreakneg500to0(trial)=0;
        end
        
        %BothFixBreakneg100_100PR
        if allRT(trial)~=0 && allRT(trial)*1000/fs <1900 %if there was an RT, search for BothFixBreak from BLint to 100ms after RT:
            if any(((GAZE_X(find(t_crop==-100):find(t_crop==allRT(trial)*1000/fs+ 100),trial)-scres(1)/2))<-(degrees*deg2px)) &&...
                    any(((GAZE_X(find(t_crop==-100):find(t_crop==allRT(trial)*1000/fs+ 100),trial)-scres(1)/2))>(degrees*deg2px))
                BothFixBreakneg100_100PR(trial) = 1;
            else
                BothFixBreakneg100_100PR(trial) = 0;
            end
            %else there was no RT so search from BLint until end of epoch:
        elseif any(((GAZE_X(find(t_crop==-100):end,trial)-scres(1)/2))<-(degrees*deg2px)) &&...
                any(((GAZE_X(find(t_crop==-100):end,trial)-scres(1)/2))>(degrees*deg2px))
            BothFixBreakneg100_100PR(trial) = 1;
        else
            BothFixBreakneg100_100PR(trial) = 0;
        end
        
        %BothFixBreakneg100_450
        if any(((GAZE_X(find(t_crop==-100):find(t_crop==450),trial)-scres(1)/2))<-(degrees*deg2px)) &&...
                any(((GAZE_X(find(t_crop==-100):find(t_crop==450),trial)-scres(1)/2))>(degrees*deg2px))
            BothFixBreakneg100_450(trial)=1;
        else
            BothFixBreakneg100_450(trial)=0;
        end
        
    end
    
    %%
    
    %DN: master_matrix_R columns:
    %1.Subject number 2.
    
    for trial=1:length(allTrials) % get rid of last trigger?
        total_numtr = total_numtr+1;
        ID_vector(total_numtr) = subject_folder(s);
        %% 1. Subject number:
        master_matrix_R(total_numtr,1) = s;
        %% 2. ADHD or Control (1 or 2):
        if ismember(subject_folder{s},subject_folder_ADHD)
            master_matrix_R(total_numtr,2) = 1; % (1=ADHD)
        elseif ismember(subject_folder{s},subject_folder_Control)
            master_matrix_R(total_numtr,2) = 2; % (2=Control)
        else keyboard
        end
        %% 3. total trial number:
        master_matrix_R(total_numtr,3) = total_numtr;
        %% 4. inter-subject trial number
        master_matrix_R(total_numtr,4) = trial;
        %% 5. ITI:
        if ismember (allTrials(trial), targcodes(:,1)) % any ITI1 targcode.
            master_matrix_R(total_numtr,5) = 1;
        elseif ismember (allTrials(trial), targcodes(:,2))% any ITI2 targcode.
            master_matrix_R(total_numtr,5) = 2;
        else
            master_matrix_R(total_numtr,5) = 3; % any ITI3 targcode.
        end
        %% 6. Target Side:
        if ismember(allTrials(trial),targcodes(1,:))% any left patch targcode. i.e. left target
            master_matrix_R(total_numtr,6) = 1;
            TargetSide=1;
        else
            master_matrix_R(total_numtr,6) = 2; %right target
            TargetSide=2;
        end
        %% 7. Accuracy:
        master_matrix_R(total_numtr,7) = allrespLR(trial); %1=correct 0=wrong
        %% 8. Reaction time (RT):
        master_matrix_R(total_numtr,8)=allRT(trial)*1000/fs;
        %% 9. Blink pre-targe (-500 - 0ms):
        master_matrix_R(total_numtr,9)= Blinkneg500to0(trial);
        %% 10. Blink post target (-100 to 100ms after response):
        master_matrix_R(total_numtr,10) = Blinkneg100_100PR(trial);
        %% 11. Blink post target (-100 to 450ms)
        master_matrix_R(total_numtr,11)= Blinkneg100_450(trial);
        %% 12. Left Fixation Break pre-targe (-500 - 0ms)
        master_matrix_R(total_numtr,12)=LeftFixBreakneg500to0(trial);
        %% 13. Left Fixation Break post target (-100 to 100ms after response):
        master_matrix_R(total_numtr,13)=LeftFixBreakneg100_100PR(trial);
        %% 14. Left Fixation Break post target (-100 to 450ms):
        master_matrix_R(total_numtr,14)=LeftFixBreakneg100_450(trial);
        
        %% 15. Right Fixation Break pre-targe (-500 - 0ms):
        master_matrix_R(total_numtr,15)=RightFixBreakneg500to0(trial);
        %% 16. Right Fixation Break post target (-100 to 100ms after response):
        master_matrix_R(total_numtr,16)=RightFixBreakneg100_100PR(trial);
        %% 17. Right Fixation Break post target (-100 to 450ms):
        master_matrix_R(total_numtr,17)=RightFixBreakneg100_450(trial);
        %% 18. Left AND Right Fixation Break pre-targe (-500 - 0ms):
        master_matrix_R(total_numtr,18)=BothFixBreakneg500to0(trial);
        %% 19. Left AND Right Fixation Break post target (-100 to 100ms after response):
        master_matrix_R(total_numtr,19)=BothFixBreakneg100_100PR(trial);
        %% 20. Left AND Right Fixation Break post target (-100 to 450ms):
        master_matrix_R(total_numtr,20)=BothFixBreakneg100_450(trial);
        %% 21. Artefact during pre-target window (-500 - 0ms):
        master_matrix_R(total_numtr,21)= artifact_PretargetToTarget_n(trial);
        %% 22. Artefact during post-target window (-100ms to 100ms after response):
        master_matrix_R(total_numtr,22)= artifact_BLintTo100msPostResponse_n(trial);
        %% 23. BLANK
        master_matrix_R(total_numtr,23)=0;
        %% 24. Rejected trial
        master_matrix_R(total_numtr,24)=rejected_trial_n(trial);
        %% 25. Artefact during post-target window (-100ms to 450ms):
        master_matrix_R(total_numtr,25)=artifact_BLintTo450ms_n(trial);
        
        %% 26. Pre-target Alpha Power Left Hemi:
        LH_ROI = [22,23,25,26,27];
        master_matrix_R(total_numtr,26)=squeeze(mean(mean(Alpha([LH_ROI],find(Alpha_smooth_time==-500):find(Alpha_smooth_time==0),trial),1),2));
        %% 27. Pre-target Alpha Power Right Hemi:
        RH_ROI= [59,60,62,63,64];
        master_matrix_R(total_numtr,27)=squeeze(mean(mean(Alpha([RH_ROI],find(Alpha_smooth_time==-500):find(Alpha_smooth_time==0),trial),1),2));
        
        %% 28.  Pre-target AlphaAsym:
        if master_matrix_R(total_numtr,26) && master_matrix_R(total_numtr,27)
            master_matrix_R(total_numtr,28)=(master_matrix_R(total_numtr,27)-master_matrix_R(total_numtr,26))/(master_matrix_R(total_numtr,27)+master_matrix_R(total_numtr,26)); %(RightHemiROI - LeftHemiROI)/(RightHemiROI + LeftHemiROI)
        else
            master_matrix_R(total_numtr,28)=0;
        end
        %% 29. Pre-target Pupil Diameter:
        master_matrix_R(total_numtr,29)=mean(Pupil(find(t_crop==-500):find(t_crop==0),trial));
        %% 30. N2c Amp (using GRAND AVERAGE to define N2c measurement window):
        %
        window=25; %this is the time (in samples) each side of the peak latency - so 25 is actually a 100ms window (since fs=500 and this is done each side of the peak latency)
        ch_LR = [23;60];
        ch_N2c = [60;23];
        %
        master_matrix_R(total_numtr,30)=mean(mean(erp(ch_N2c(TargetSide,:),avN2c_GrandAverage_peak_amp_index_s(TargetSide)-window:avN2c_GrandAverage_peak_amp_index_s(TargetSide)+window,trial),1));
        %% 31. N2i Amp (using GRAND AVERAGE to define N2i measurement window):
        master_matrix_R(total_numtr,31)=mean(mean(erp(ch_LR(TargetSide,:),avN2i_GrandAverage_peak_amp_index_s(TargetSide)-window:avN2i_GrandAverage_peak_amp_index_s(TargetSide)+window,trial),1));
        %% 32. Respose locked CPP slope: (just fitting a straight line, like in Kelly and O'Connel J.Neuro, but on trial-by-trial basis)
        slope_timeframe = [-400,-50];
        if validrlock(trial)
            coef = polyfit(tr(tr>slope_timeframe(1) & tr<slope_timeframe(2)),(erpr(ch_CPP,tr>slope_timeframe(1) & tr<slope_timeframe(2),trial)),1); % coef returns 2 coefficients fitting r = slope * x + intercept
            master_matrix_R(total_numtr,32) = coef(1); %slope
            %                 r = coef(1) .* tr(tr>slope_timeframe(1) & tr<slope_timeframe(2)) + coef(2); %r=slope(x)+intercept, r is a vectore representing the linear curve fitted to the erpr during slope_timeframe
            %                 figure
            %                 plot(tr,erpr(ch_CPP,:,trial),'color','k');
            %                 hold on;
            %                 plot(tr(tr>slope_timeframe(1) & tr<slope_timeframe(2)), r, ':');
            %                 line(xlim,[0,0],'Color','k');
            %                 line([0,0],ylim,'Color','k');
            %                 line([slope_timeframe(1),slope_timeframe(1)],ylim,'linestyle',':');
            %                 line([slope_timeframe(2),slope_timeframe(2)],ylim,'linestyle',':');
            %                 hold off;
        end
        %%
        %% 33. Stimulus locked CPP slope: (just fitting a straight line, like in Kelly and O'Connel J.Neuro, but on trial-by-trial basis)
        slope_timeframe = [250,450];
        coef = polyfit(t_crop(t_crop>slope_timeframe(1) & t_crop<slope_timeframe(2)),(erp(ch_CPP,t_crop>slope_timeframe(1) & t_crop<slope_timeframe(2),trial)),1); % coef returns 2 coefficients fitting r = slope * x + intercept
        master_matrix_R(total_numtr,33) = coef(1); %slope
        y = coef(1) .* t_crop(t_crop>slope_timeframe(1) & t_crop<slope_timeframe(2)) + coef(2); %y=slope(x)+intercept, y is a vectore representing the linear curve fitted to the erp during slope_timeframe
        %             figure
        %             plot(t_crop(find(t_crop>-150):find(t_crop==1000)),erp(ch_CPP,find(t_crop>-150):find(t_crop==1000),trial),'color','k');
        %             hold on;
        %             plot(t_crop(t_crop>slope_timeframe(1) & t_crop<slope_timeframe(2)), y, ':');
        %             line(xlim,[0,0],'Color','k');
        %             line([0,0],ylim,'Color','k');
        %             line([slope_timeframe(1),slope_timeframe(1)],ylim,'linestyle',':');
        %             line([slope_timeframe(2),slope_timeframe(2)],ylim,'linestyle',':');
        %             hold off;
        
        %% 34. N2c peak latency:
        % NB: this is quarter the window size in samples, each sample = 2ms and
        % it's this either side.
        window_size = 25;
        % contra and search frames encompass the entire negativity.
        contra_peak_t = [150,500]; contra_peak_ts(1) = find(t_crop==contra_peak_t(1)); contra_peak_ts(2) = find(t_crop==contra_peak_t(2));
        % SEARCHING FOR PEAK LATENCY
        clear N2c_peak_latencies
        % for each trial...
        % search your search timeframe, defined above by contra_peak ts, in sliding windows
        % NB this is done in samples, not time, it's later converted.
        clear win_mean win_mean_inds
        counter2 = 1;
        for j = contra_peak_ts(1)+window_size:contra_peak_ts(2)-window_size
            % get average amplitude of sliding window from N2pc electrode
            if master_matrix_R(total_numtr,6) == 1; %if left target, measure from right hemi (ch_LR(2,:)) electrodes
                win_mean(counter2) = squeeze(mean(mean(erp(ch_LR(2,:),j-window_size:j+window_size,trial),1),2));
            elseif master_matrix_R(total_numtr,6) == 2; %if right target, measure from left hemi (ch_LR(1,:)) electrodes
                win_mean(counter2) = squeeze(mean(mean(erp(ch_LR(1,:),j-window_size:j+window_size,trial),1),2));
            end
            % get the middle sample point of that window
            win_mean_inds(counter2) = j;
            counter2 = counter2+1;
        end
        % find the most negative amplitude in the resulting windows
        [~,ind_temp] = min(win_mean);
        % get the sample point which had that negative amplitude
        N2pc_min_ind = win_mean_inds(ind_temp);
        
        % if the peak latency is at the very start or end of the search
        % timeframe, it will probably be bogus. set to NaN.
        if ind_temp==1 | ind_temp==length(win_mean)
            master_matrix_R(total_numtr,34)= 0; %%DN: make it 0 instead of NaN, will remove these in R
        else
            % it's good! add it in.
            master_matrix_R(total_numtr,34)=t_crop(N2pc_min_ind);  %N2c_peak_latencies(trial)= t(N2pc_min_ind);
        end
        %% 35. CPP half peak latency:
        half_max_peak=max(erp(ch_CPP,find(t_crop==0):find(t_crop==1500),trial))/2;

        half_max_peak_index=find(erp(ch_CPP,find(t_crop==0):find(t_crop==1500),trial)>=half_max_peak,1,'first')+length(find(erp(t_crop<0)));
        if half_max_peak<0
            master_matrix_R(total_numtr,35)=0;
        elseif isempty(half_max_peak_index)
                master_matrix_R(total_numtr,35)=0;
        else 
        master_matrix_R(total_numtr,35)=t_crop(half_max_peak_index);
        end
        
        
        %% 36. N2c Amp (using PARTICIPANT LEVEL AVERAGE to define N2c measurement window):
        %
        window=25; %this is the time (in samples) each side of the peak latency - so 25 is actually a 100ms window (since fs=500 and this is done each side of the peak latency)
        ch_LR = [23;60];
        ch_N2c = [60;23];
        %
        master_matrix_R(total_numtr,36)=mean(mean(erp(ch_N2c(TargetSide,:),avN2c_ParticipantLevel_peak_amp_index_s(TargetSide)-window:avN2c_ParticipantLevel_peak_amp_index_s(TargetSide)+window,trial),1));
        
        %% 37. N2i Amp (using PARTICIPANT LEVEL AVERAGE to define N2i measurement window):
        master_matrix_R(total_numtr,37)=mean(mean(erp(ch_LR(TargetSide,:),avN2i_ParticipantLevel_peak_amp_index_s(TargetSide)-window:avN2i_ParticipantLevel_peak_amp_index_s(TargetSide)+window,trial),1));
    end
end
% find empty cells in ID_vector
emptyCells = cellfun(@isempty,ID_vector);
% remove empty cells
ID_vector(emptyCells) = [];

%Save the data in .csv format to be read into R for inferential stats analysis
csvwrite (['master_matrix_R.csv'],master_matrix_R)
cell2csv ('ID_vector.csv',ID_vector)


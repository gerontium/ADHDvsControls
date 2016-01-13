clear all
close all
clc

path='C:\Users\Dan\Dropbox\Monash\My Papers\ADHD vs Controls EEG QBI\Dots Data Downward\';
% path='C:\Users\newmand\Dropbox\Monash\My Papers\ADHD vs Controls EEG QBI\Dots Data Downward\';

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

% duds = []; %
duds = [12,16,17,24,26,... %ADHD: %'AD69C', 'AD59C', 'AD27C', 'AD51C', 'AD98C' % These are kicked out due to clinical cuttoff filter_CPRS_N_B
    43,45,56];  %Controls: %C194 not enough trials %('C14' and 'C259' filter_CPRS_N_B);
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

ID_vector=cell(length(subject_folder)*205*length(tr),1); %this will save the subjects ID for each single trial can be pasted into SPSS for ID column. Code at the end of the script clear the emplt cells

HPF=0; %Use high-pass filtered erp? 1=yes, 0=no
matfile='_8_to_13Hz_neg800_to_1880_64ARchans_35HzLPF_point0HzHPF_ET.mat';

current=1;
for s=1:length(allsubj)
%     disp(['Subject: ',num2str(s)])
    disp(['Subject: ',allsubj{s}])
    
    %     load([path subject_folder{s} '\' allsubj{s} '_ROIs.mat']); %load the participant's individualised Alpha ROI electrodes sensitive to Light
    if ismember(subject_folder{s},subject_folder_Control)
        load([path 'Controls\' subject_folder{s} '\' allsubj{s} matfile]);
        load([path 'Controls\' subject_folder{s} '\' 'avN2c_peak_amp_index.mat']);
        load([path 'Controls\' subject_folder{s} '\' 'avN2i_peak_amp_index.mat']);
    elseif ismember(subject_folder{s},subject_folder_ADHD)
        load([path 'ADHD\' subject_folder{s} '\' allsubj{s} matfile]);
        load([path 'ADHD\' subject_folder{s} '\' 'avN2c_peak_amp_index.mat']);
        load([path 'ADHD\' subject_folder{s} '\' 'avN2i_peak_amp_index.mat']);
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
    Pupilr = zeros(length(tr),size(Pupil,2));
    validrlock = zeros(1,length(allRT)); % length of RTs.
    for n=1:length(allRT);
        [blah,RTsamp] = min(abs(t_crop*fs/1000-allRT(n))); % get the sample point of the RT.
        if RTsamp+trs(1) >0 & RTsamp+trs(end)<=length(t_crop) & allRT(n)>0 % is the RT larger than 1st stim RT point, smaller than last RT point.
            erpr(:,:,n) = erp(:,RTsamp+trs,n);
            Pupilr(:,n) = Pupil(RTsamp+trs,n);
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
    

    %% DN: master_matrix_R columns:
    %1.Subject number 2.
 
    for trial=1:length(allTrials) % get rid of last trigger?
        total_numtr = total_numtr+1;      
        ID_vector(current:current+(length(tr)-1)) = subject_folder(s);
        %% 1. Subject number:
        master_matrix_R(current:current+(length(tr)-1),1) = s;
        %% 2. ADHD or Control (1 or 2):
        if ismember(subject_folder{s},subject_folder_ADHD)
            master_matrix_R(current:current+(length(tr)-1),2) = 1; % (1=ADHD)
        elseif ismember(subject_folder{s},subject_folder_Control)
            master_matrix_R(current:current+(length(tr)-1),2) = 2; % (2=Control)
        else keyboard
        end
        %% 3. total trial number:
        master_matrix_R(current:current+(length(tr)-1),3) = total_numtr;
        %% 4. inter-subject trial number
        master_matrix_R(current:current+(length(tr)-1),4) = trial;
        %% 5. ITI:
        if ismember (allTrials(trial), targcodes(:,1)) % any ITI1 targcode.
            master_matrix_R(current:current+(length(tr)-1),5) = 1;
        elseif ismember (allTrials(trial), targcodes(:,2))% any ITI2 targcode.
            master_matrix_R(current:current+(length(tr)-1),5) = 2;
        else
            master_matrix_R(current:current+(length(tr)-1),5) = 3; % any ITI3 targcode.
        end
        %% 6. Target Side:
        if ismember(allTrials(trial),targcodes(1,:))% any left patch targcode. i.e. left target
            master_matrix_R(current:current+(length(tr)-1),6) = 1;
            TargetSide=1;
        else
            master_matrix_R(current:current+(length(tr)-1),6) = 2; %right target
            TargetSide=2;
        end
        %% 7. Accuracy:
        master_matrix_R(current:current+(length(tr)-1),7) = allrespLR(trial); %1=correct 0=wrong
        %% 8. Reaction time (RT):
        master_matrix_R(current:current+(length(tr)-1),8)=allRT(trial)*1000/fs;
        %% 9. Blink post target (-100 to 100ms after response):
        master_matrix_R(current:current+(length(tr)-1),9) = Blinkneg100_100PR(trial);
        %% 10. Left Fixation Break post target (-100 to 100ms after response):
        master_matrix_R(current:current+(length(tr)-1),10)=LeftFixBreakneg100_100PR(trial);
        %% 11. Right Fixation Break post target (-100 to 100ms after response):
        master_matrix_R(current:current+(length(tr)-1),11)=RightFixBreakneg100_100PR(trial);
        %% 12. Left AND Right Fixation Break post target (-100 to 100ms after response):
        master_matrix_R(current:current+(length(tr)-1),12)=BothFixBreakneg100_100PR(trial);
        %% 13. Artefact during post-target window (-100ms to 100ms after response):
        master_matrix_R(current:current+(length(tr)-1),13)= artifact_BLintTo100msPostResponse_n(trial);
        %% 14. Rejected trial
        master_matrix_R(current:current+(length(tr)-1),14)=rejected_trial_n(trial);
        %% 15. Pupil Diameter:
        master_matrix_R(current:current+(length(tr)-1),15)=Pupilr(:,trial);
        %% 16. CPP:
        master_matrix_R(current:current+(length(tr)-1),16)=erpr(ch_CPP,:, trial);
        %% 17. Time:
         master_matrix_R(current:current+(length(tr)-1),17)=tr;

        current=current+length(tr);
    end
end
% find empty cells in ID_vector
emptyCells = cellfun(@isempty,ID_vector);
% remove empty cells
ID_vector(emptyCells) = [];

%Save the data in .csv format to be read into R for inferential stats analysis
csvwrite (['master_matrix_R_Resp_locked_ERP.csv'],master_matrix_R)
cell2csv ('ID_vector_Resp_locked_ERP.csv',ID_vector)


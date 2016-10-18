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
% duds = [12,16,17,24,26,... %ADHD: %'AD69C', 'AD59C', 'AD27C', 'AD51C', 'AD98C' % These are kicked out due to clinical cuttoff filter_CPRS_N_B
%     43,45,56];  %Controls: %C194 not enough trials %('C14' and 'C259' filter_CPRS_N_B);
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

% side,ITI
targcodes = zeros(2,3);
targcodes(1,:) = [101 103 105]; % left patch,
targcodes(2,:) = [102 104 106]; % right patch

master_matrix_R = []; % This saves the matrix for SPSS/R analysis.
total_numtr = 0;

t=[-750:50:1800]; %Must be the same as Alpha_smooth_time, which is loaded below

ID_vector=cell(length(subject_folder)*205*length(t),1); %this will save the subjects ID for each single trial can be pasted into SPSS for ID column. Code at the end of the script clear the emplt cells

HPF=0; %Use high-pass filtered erp? 1=yes, 0=no
matfile='_8_to_13Hz_neg800_to_1880_64ARchans_35HzLPF_point0HzHPF_ET.mat';

current=1;
for s=1:length(allsubj)
%     disp(['Subject: ',num2str(s)])
    disp(['Subject: ',allsubj{s}])
    
    %     load([path subject_folder{s} '\' allsubj{s} '_ROIs.mat']); %load the participant's individualised Alpha ROI electrodes sensitive to Light
    if ismember(subject_folder{s},subject_folder_Control)
        load([path 'Controls\' subject_folder{s} '\' allsubj{s} matfile]);
        load([path 'Controls\' subject_folder{s} '\' 'ROIs.mat']);
    elseif ismember(subject_folder{s},subject_folder_ADHD)
        load([path 'ADHD\' subject_folder{s} '\' allsubj{s} matfile]);
        load([path 'ADHD\' subject_folder{s} '\' 'ROIs.mat']);
    else
        keyboard
    end
        LH_ROI=LH_ROI_s;
        RH_ROI=RH_ROI_s;    
    t=Alpha_smooth_time;
    %if the final trial was a miss there will be no RT recorded, just need
    %to add a zero for RT in that case
    if length(allRT)<length(allrespLR)
        allRT(length(allRT):length(allrespLR))=0;
    end
    
    
    if HPF %Use high-pass filtered erp?
        erp=erp_HPF;
    end
    
    allTrials=allTrig; % just renamed this because it makes more sense to me to call it trials

    
    for trial=1:length(allTrials) % get rid of last trigger?
        total_numtr = total_numtr+1;      
        ID_vector(current:current+(length(t)-1)) = subject_folder(s);
        %% 1. Subject number:
        master_matrix_R(current:current+(length(t)-1),1) = s;
        %% 2. total trial number:
        master_matrix_R(current:current+(length(t)-1),2) = total_numtr;
        %% 3. inter-subject trial number
        master_matrix_R(current:current+(length(t)-1),3) = trial;
        %% 4. Left Hemisphere Alpha:
        master_matrix_R(current:current+(length(t)-1),4)=mean(Alpha(LH_ROI,:,trial),1);
        %% 5. Right Hemisphere Alpha: 
        master_matrix_R(current:current+(length(t)-1),5)=mean(Alpha(RH_ROI,:,trial),1);
        %% 6. Time (Alpha_smooth_time):
         master_matrix_R(current:current+(length(t)-1),6)=t;
        current=current+length(t);
    end
end
% find empty cells in ID_vector
emptyCells = cellfun(@isempty,ID_vector);
% remove empty cells
ID_vector(emptyCells) = [];

%Save the data in .csv format to be read into R for inferential stats analysis
csvwrite (['master_matrix_R_Stim_locked_AlphaPower.csv'],master_matrix_R)
cell2csv ('ID_vector_Stim_locked_AlphaPower.csv',ID_vector)


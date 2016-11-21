%%% runafew
clear all
close all
clc

% % % % % -------------------------------------ADHD-------------------------------
subject_folder = {'AD40C' 'AD11C' 'AD43C' 'AD18C' 'AD24C' 'AD52C' 'AD5C'...
    'AD54C' 'AD75C' 'AD15C' 'AD49C' 'AD69C' 'AD32C' 'AD16C'	'AD72C'...
    'AD59C'	'AD27C'	'AD46C'	'AD22C'	'AD26C'	'AD99C'	'AD48C'	'AD57C'...
    'AD51C' 'AD19C' 'AD98C' 'AD25C' 'AD23C'...
    '001_KK' 'C12' 'C21' '002_LK' 'C50' 'C131' 'C20' 'C132' 'C213'...
    'C204'	'C171' 'C13' 'C119'	'C121'	'C194'	'C168' ...
    'C14' 'C49' 'C400' 'C100' 'C117' 'C115' 'C110' 'C183' 'C144' 'C252' ...
    'C140' 'C259' 'C143' 'C89' 'C62' 'C88' 'C84' 'C87'};
allsubj = {'1_40' '1_11' '1_43' '1_18' '1_24' '1_52' '1_5'...
    '1_54' '1_75' '1_15' '1_49' '1_69' '1_32' '1_16'...
    '1_72'	'1_59'	'1_27'	'1_46'	'1_22'	'1_26'	'1_99'	'1_48'	'1_57'...
    '1_51' '1_19' '1_98' '1_25' '1_23'...
    '001'	'12'	'21'	'002'	'50'	'131'	'20'	'132'...
    '213'	'204'	'171'	'13'	'119'	'121'	'194'	'168'...
     '14' '49' '400' '100' '117' '115' '110' '183'  '144' '252' ...
     '140' '259' '143' '89' '62' '88' '84' '87'};

allblocks = {[1:10], [1:10],[1:7],[1:10],[1:10],[1:10],[1:10],[1:10],[1:11],...%for ADHD
    [1:10],[1:10],[1:10],[1:11],[1:10],[1:10],[1:10],[1:10],[1:10],[1:10],...
    [1:10],[1:9],[1:10],[1:10]...
    [1:10],[1:11],[1:10],[1:10],[1:10]...
    [2:11], [1:10],[1:10],[1:10],	[1:10],	[1:10],	[1:10],... %for controls
[1:10],	[1:10],	[1:10],	[1:10],	[1:11],	[1:11],	[1:10],	[1:10],	[1:10]...
,[1:10],[1:10],	[1:10],[1:4,6:11],[1:10],[1:10],[1:10],[1:10],[1:10],[1:10],...
[1:10],[1:10],[1:10] ,[1:10],[1:10],[1:10],[1:10],[1:10]};

duds = [];

    allbadchans = {[7,34,33,36,42,52,60,62]%'AD40C'
                   [2,5,42,34,35,7,50,15,52] %AD11C
                   [7,9,14,15,24,42,61]%AD43C
                   [51,52,62] %'AD18C'
                   [2,3,7,16,18,24,35,41,44,52,60,61]%AD24C
                   [2,19,28,35]%AD52C
                   [7,58]%AD5C
                   [50,52,55,58,62]%AD54C
                   [2,8,24,34,35,64]%AD75C
                   [31,15,34,53]%AD15C
                   [2,15,16,34,35,41,42,52] %AD49C
                   [2,7,16,28,42] %AD69C
				     [15,6] %AD32C
                   [7,28,52]%AD16C
                   [61] %AD72C
                   [] %AD59C
                   [51] %AD27C
                   [7,21,40] %AD46C
                   [24,52] %AD22C
                   [1,2,31,33,34,35] %AD26C
                   [1,2,15,33,52,57] %AD99C
                   [2,6,34] %AD48C
                   [2,24,35,57,61] %AD57C
                   [2,15,24,52] %AD51C
                   [] %AD19C
                   [7,35,57] %AD98C
                   [5,16] %AD25C 
                   [2,52] %AD23C %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                   [11,15,40,52,57] %001_KK
                   [52,2] %C12
                   [20,31]%C21
                   [2,5,35] %002_LK
                   [15,52]% C50
                   [15,57]% C131
                   [2,43]% C20
                   [5,11,48]% C132
                   [52]% C213
                   [8,16,52]% C204
                   []% C171
                   [15,16,24,51]% C13
                   [1,29]% C119
                   [1,16,25,34,52,62]% C121
                   [15,47,52,57,62]% C194
                   [15,57,60,62]% C168
                   [27,35,41,64]%C14
                   [2,24]%C49
                   [15,42,44,62]%C400
                   [30,52,62]%C100
                   [15,24,27,28,52,62,64]%C117
                   [15,16,24,41,52]%C115
                   [15,28,33,43,52,61]%C110
                   [1,29,31,57] %C183
                   [15,30,52,60] %C144
                   [15,52,60] %C252
                   [7,59,57,61]%C140
                   [15,30,57,63]%C259
                   [43] %'C143'
                   [15] % 'C89'
                   [34,52,62]%'C62'
                   [15,16,34,52] %'C88' 
                   [15,27,45,52,64,57]%'C84'
                   [8,15,61,62]}; %'C87'

% % % % -------------------------------------------------------------------------
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
% --------------------------------------------------------------------------

original_paradigm={'AD40C' 'AD11C' 'AD43C' 'AD18C' 'AD24C'}; %these guys did the paradigm that measured
%RT as the point at which both buttons became clicked regerdless of whether there may have been a few ms 
%difference between when the first and second button made contact -in this case the new paradigm
% takes the mean time between when each botton made contact.


single_participants = [];
exp_conditions = {'C','CDD'}; c = 1; %DN
file_start = 1;


if ~isempty(duds) && isempty(single_participants)
    subject_folder([duds]) = [];
    allsubj([duds]) = [];
    allblocks([duds]) = [];
    allbadchans([duds]) = [];
end

if ~isempty(single_participants)
    subject_folder = subject_folder([single_participants]);
    allsubj = allsubj([single_participants]);
    allblocks = allblocks([single_participants]);
    allbadchans = allbadchans([single_participants]);
end

h = waitbar(0,'Please wait...');
steps = length(allsubj);
step = file_start-1;
for s=file_start:length(allsubj)
%     path = 'C:\Users\newmand\Dropbox\Monash\My Papers\ADHD vs Controls EEG QBI\Dots Data Downward\'; 
    path='S:\R-MNHS-SPP\Bellgrove-data\4. Dan Newman\QBI ADHD dots data\Dots Data Downward\';
    if ismember(subject_folder{s},subject_folder_ADHD)
       path= [path 'ADHD\'];
    elseif ismember(subject_folder{s},subject_folder_Control)
       path= [path 'Controls\'];
    end
    
    disp(subject_folder{s})
    tic
    if s==file_start
        waitbar(step/steps,h)
    else
        min_time = round((end_time*(steps-step))/60);
        sec_time = round(rem(end_time*(steps-step),60));
        waitbar(step/steps,h,[num2str(min_time),' minutes remaining'])
    end
    step=step+1;
    subjID = [path subject_folder{s} '\' allsubj{s} '_' exp_conditions{c}];
    blocks = allblocks{s};
    badchans = allbadchans{s};
    if c==1
       CPP_Alpha_analysis_QBI_DownwardOnly_ET
%        convert_bdf_to_set
    elseif c==2
        Dots_Discrete;
    end
    end_time = toc;
end
close(h)
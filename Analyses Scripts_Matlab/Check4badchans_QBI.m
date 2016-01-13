clear all
close all

% datafolder = 'C:\Users\Dan\Dropbox\QBI ADHD dots data\Dots Data Downward\ADHD\'; %DN
% matfolder =  'C:\Users\Dan\Dropbox\QBI ADHD dots data\Dots Data Downward\ADHD\';

% subject_folder = {'MW3' 'NL'}; 
% sessionID = {'MW3' 'NL'}; 

% -------------------------------------ADHD-------------------------------
datafolder = 'C:\Users\newmand\Dropbox\QBI ADHD dots data\Dots Data Downward\ADHD\'; %DN
matfolder =  'C:\Users\newmand\Dropbox\QBI ADHD dots data\Dots Data Downward\ADHD\';

subject_folder = {'AD40C' 'AD11C' 'AD43C' 'AD18C' 'AD24C' 'AD52C' 'AD5C'...
    'AD54C' 'AD75C' 'AD15C' 'AD49C' 'AD69C' 'AD32C' 'AD16C'	'AD72C'...
    'AD59C'	'AD27C'	'AD46C'	'AD22C'	'AD26C'	'AD99C'	'AD48C'	'AD57C'...
    'AD51C' 'AD19C' 'AD98C' 'AD25C' 'AD23C'};
sessionID = {'1_40' '1_11' '1_43' '1_18' '1_24' '1_52' '1_5'...
    '1_54' '1_75' '1_15' '1_49' '1_69' '1_32' '1_16'...
    '1_72'	'1_59'	'1_27'	'1_46'	'1_22'	'1_26'	'1_99'	'1_48'	'1_57'...
    '1_51' '1_19' '1_98' '1_25' '1_23'};

blocks = {[1:10], [1:10],[1:7],[1:10],[1:10],[1:10],[1:10],[1:10],[1:11],...
    [1:10],[1:10],[1:10],[1:11],[1:10],[1:10],[1:10],[1:10],[1:10],[1:10],...
    [1:10],[1:9],[1:10],[1:10]...
    [1:10],[1:11],[1:10],[1:10],[1:10]};
%--------------------------------------------------------------------------

% % -------------------------------Control----------------------------------
% datafolder = 'C:\Users\newmand\Dropbox\QBI ADHD dots data\Dots Data Downward\Controls\'; 
% matfolder =  'C:\Users\newmand\Dropbox\QBI ADHD dots data\Dots Data Downward\Controls\';
% % datafolder = 'C:\Users\Dan\Dropbox\QBI ADHD dots data\Dots Data Downward\Controls\'; 
% % matfolder =  'C:\Users\Dan\Dropbox\QBI ADHD dots data\Dots Data Downward\Controls\';
% 
% subject_folder = {'001_KK' 'C12' 'C21' '002_LK' 'C50' 'C131' 'C20' 'C132' 'C213'...
%     'C204'	'C171' 'C13' 'C119'	'C121'	'C194'	'C168' ...
%     'C14' 'C49' 'C400' 'C100' 'C117' 'C115' 'C110' 'C183' 'C144' 'C252' ...
%     'C140' 'C259' 'C143' 'C89' 'C62' 'C88' 'C84' 'C87'};
% 
% sessionID = {'001'	'12'	'21'	'002'	'50'	'131'	'20'	'132'...
%     '213'	'204'	'171'	'13'	'119'	'121'	'194'	'168' ...
%     '14' '49' '400' '100' '117' '115' '110' '183' '144' '252'...
%     '140' '259' '143' '89' '62' '88' '84' '87'};
% 
% blocks = {[1:11], [1:10],[1:10],[1:10],	[1:10],	[1:10],	[1:10],... %for controls
% [1:10],	[1:10],	[1:10],	[1:10],	[1:11],	[1:11],	[1:10],	[1:10],	[1:10]...
% ,[1:10],[1:10],	[1:10], [1:4,6:11],[1:10],[1:10],[1:10],[1:10],[1:10],[1:10],...
% [1:10],[1:10],[1:10],[1:10],[1:10],[1:10],[1:10],[1:10]};
% 
% %--------------------------------------------------------------------------


exp_conditions = {'C','CDD'}; c = 1; 
file_start = 1;

% blocks = {[1:11], [1:10], [1:10], [1:10]}; %For Controls

%for s=file_start:file_start%length(sessionID)
for s=1:length(sessionID)%DN
    matfile{s} = [datafolder subject_folder{s} '\' sessionID{s} '_' exp_conditions{c} '_chanvars.mat'];
end
% 
% % CTET:
% matfolder = '/Users/skelly/Data/CTET/mats/';
% sessionID = {'1'};
% for s=1:length(sessionID)
%     matfile{s} = [matfolder 's' sessionID{s} '_chanvars.mat']; 
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for s=file_start:file_start%length(sessionID)
% for s=1:length(sessionID)
    disp(sessionID{s})
    load(matfile{s})
    chanVar = double(chanVar);
%     chanVar = double(chanVar(:,[2:7])); %DN: for if you want to kick certain blocks 
    
    badchans = []; %DN: these two lines will swap and bad channels you identify with the 'changechans' in the next line
    changechans = []; % must be in same order as badchans.
%     badchans = [1,2,33,34,35]; %DN: these two lines will swap and bad channels you identify with the 'changechans' in the next line
%     changechans = [47,47,47,47,47]; % must be in same order as badchans.
    chanVar(badchans(1:end),:) = chanVar(changechans(1:end),:);
    
    avVar = mean(chanVar,2); 
        
    % average variance for each channel across all 16 conditions
    % on a second sweep for a given subject, might want to plot topo again
    % after getting rid of a really bad one (to make it easier to see other
    % bad channels) - so do something like:
    % avVar(104) = avVar(103);  % quick hack - make a reall bad chan equal its neighbor
    
    figure;
    topoplot(avVar,chanlocs,'plotchans',[1:64],'electrodes','numbers');
    title(sessionID{s})
    
    figure; hold on
    plot(chanVar(1:64,:))
    title(sessionID{s})
    
end
% getChannelVars.m
% Computes and saves the channel variances for each block, so these
% can be plotted to look for bad channels using check4badchans.m.
% Variance calc from FFT spectrum so can avoid certain frequencies.
% list ALL data files in a study in a cell array of cell arrays such that
% files{s}{n} is the name of the nth file of session (subject) s.
% also list session IDs (subject initials or whatever) in cell array sessionID.
clear all
close all
clc

% % -------------------------------------ADHD-------------------------------
% datafolder = 'C:\Users\newmand\Dropbox\QBI ADHD dots data\Dots Data Downward\ADHD\'; %DN
% matfolder =  'C:\Users\newmand\Dropbox\QBI ADHD dots data\Dots Data Downward\ADHD\';
% 
% subject_folder = {'AD40C' 'AD11C' 'AD43C' 'AD18C' 'AD24C' 'AD52C' 'AD5C'...
%     'AD54C' 'AD75C' 'AD15C' 'AD49C' 'AD69C' 'AD32C' 'AD16C'	'AD72C'...
%     'AD59C'	'AD27C'	'AD46C'	'AD22C'	'AD26C'	'AD99C'	'AD48C'	'AD57C'...
%     'AD51C' 'AD19C' 'AD98C' 'AD25C' 'AD23C'};
% sessionID = {'1_40' '1_11' '1_43' '1_18' '1_24' '1_52' '1_5'...
%     '1_54' '1_75' '1_15' '1_49' '1_69' '1_32' '1_16'...
%     '1_72'	'1_59'	'1_27'	'1_46'	'1_22'	'1_26'	'1_99'	'1_48'	'1_57'...
%     '1_51' '1_19' '1_98' '1_25' '1_23'};
% 
% blocks = {[1:10], [1:10],[1:7],[1:10],[1:10],[1:10],[1:10],[1:10],[1:11],...
%     [1:10],[1:10],[1:10],[1:11],[1:10],[1:10],[1:10],[1:10],[1:10],[1:10],...
%     [1:10],[1:9],[1:10],[1:10]...
%     [1:10],[1:11],[1:10],[1:10],[1:10]};
% %--------------------------------------------------------------------------


% -------------------------------Control----------------------------------
datafolder = 'C:\Users\newmand\Dropbox\QBI ADHD dots data\Dots Data Downward\Controls\'; 
matfolder =  'C:\Users\newmand\Dropbox\QBI ADHD dots data\Dots Data Downward\Controls\';
% datafolder = 'C:\Users\Dan\Dropbox\QBI ADHD dots data\Dots Data Downward\Controls\'; 
% matfolder =  'C:\Users\Dan\Dropbox\QBI ADHD dots data\Dots Data Downward\Controls\';

subject_folder = {'001_KK' 'C12' 'C21' '002_LK' 'C50' 'C131' 'C20' 'C132' 'C213'...
    'C204'	'C171' 'C13' 'C119'	'C121'	'C194'	'C168' ...
    'C14' 'C49' 'C400' 'C100' 'C117' 'C115' 'C110' 'C183' 'C144' 'C252' ...
    'C140' 'C259' 'C143' 'C89' 'C62' 'C88' 'C84' 'C87'};

sessionID = {'001'	'12'	'21'	'002'	'50'	'131'	'20'	'132'...
    '213'	'204'	'171'	'13'	'119'	'121'	'194'	'168' ...
    '14' '49' '400' '100' '117' '115' '110' '183' '144' '252'...
    '140' '259' '143' '89' '62' '88' '84' '87'};

blocks = {[1:11], [1:10],[1:10],[1:10],	[1:10],	[1:10],	[1:10],... %for controls
[1:10],	[1:10],	[1:10],	[1:10],	[1:11],	[1:11],	[1:10],	[1:10],	[1:10]...
,[1:10],[1:10],	[1:10], [1:4,6:11],[1:10],[1:10],[1:10],[1:10],[1:10],[1:10],...
[1:10],[1:10],[1:10],[1:10],[1:10],[1:10],[1:10],[1:10]};

%--------------------------------------------------------------------------

exp_conditions = {'C','CDD'}; c = 1; 
file_start = 34;

clear files matfile
for s=file_start:length(subject_folder)
    f=0;
    for b=blocks{s}
        f=f+1;
        files{s}{f} = [datafolder subject_folder{s} '\' sessionID{s} '_' exp_conditions{c} num2str(b) '.bdf'];
    end
    %     matfile{s} = [matfolder subject_folder{s} '\' sessionID{s} '_' exp_conditions{c} '_chanvars.mat'];
    matfile{s} = [matfolder subject_folder{s} '\' sessionID{s} '_' exp_conditions{c} '_chanvars.mat'];
end

% This is specifically for CTET:
% sessionID = {'CB' 'DA' 'FA' 'SL' 'PF' 'FS' 'MC' 'DF' 'TH'};
% subjnum = {'1' '2' '3' '4' '5' '6' '7' '8' '9'};
% sessionID = {'AW' 'CF' 'DMC' 'EC' 'KD' 'MB' 'MB2' 'MVS' 'NB' 'NM' 'SB' 'SC' 'SE' 'SH' 'ST' 'VG' 'ZZ'};
% datafolder = '/Users/skelly/Data/CTET_ADHD/BDFs/';
% matfolder = '/Users/skelly/Data/CTET_ADHD/mats/';
% for s=1:length(sessionID)
%
% %     thisfolder = [datafolder sessionID{s} '_ADHD' subjnum{s} '/'];
%     thisfolder = [datafolder sessionID{s} '/'];
%     direc = dir(thisfolder);
%     direc(1)=[]; direc(1)=[];
%     k=0;
%     for d=1:length(direc)
%         if strfind(direc(d).name,'CTET') & strfind(direc(d).name,'.bdf')
%             k=k+1;
%             files{s}{k} = [thisfolder direc(d).name];
%         end
%     end
%
%     matfile{s} = [matfolder sessionID{s} '_CNT_chanvars.mat'];
% end

% how much of the spectrum to use?
speclims = [4 48];  % Limits in Hz

minBreakDur_s = 25;  % number of seconds defining a "break" between blocks within a data file. Was using 2 for CTET
minBlockDur_s = 60; % a block must be at least 30s, otherwise the pause btw triggers is something else.

chanlocs = readlocs('cap64.loc');
%chanlocs = readlocs('cap128.loc');
% chanlocs = readlocs ('actiCAP64_ThetaPhi.elp','filetype','besa'); %DN for actiCAP


%%%%%%%%%%%%%%%%%%%%% From here it's all standard

h = waitbar(0,'Please wait...');
steps = length(sessionID);
step = file_start-1;
for s=file_start:length(subject_folder)
    disp(s)
    tic
    % First go through the blocks and see if there are breaks (defined by time btw triggers of minBreakDur_s seconds)
    % if there are, then find the block breaks and read files in block by block:
    if s==file_start
        waitbar(step/steps,h)
    else
        min_time = round((end_time*(steps-step))/60);
        sec_time = round(rem(end_time*(steps-step),60));
        %         waitbar(step/steps,h,[num2str(min_time),' minutes, ',num2str(sec_time),' seconds remaining'])
        waitbar(step/steps,h,[num2str(min_time), ' minutes remaining'])
    end
    step=step+1;
    numb=0; clear files1 blockrange;
    
    
    for f=1:length(files{s})
        EEG = pop_biosig(files{s}{f}); % read in just one channel to get triggers
        if EEG.srate>500,
            EEG = pop_resample(EEG, 500);
        end
        % Fish out the event triggers and times
        clear trigs stimes
        for i=1:length(EEG.event)
            trigs(i)=EEG.event(i).type;
            stimes(i)=EEG.event(i).latency;
        end
        %
        % %         figure
        % %         plot(trigs)
        %
        minBreakDur = minBreakDur_s*EEG.srate;  % >2s between triggers => inter-block break
        brk = find(diff(stimes)>minBreakDur);
        if ~isempty(brk)
            breaktimes_samp = (stimes(brk)+stimes(brk+1))/2;    % break times in sample points
        else
            breaktimes_samp = [];
        end
        breaktimes_s = [0 breaktimes_samp size(EEG.data,2)]./EEG.srate;    % break times in sec
        breaktimes_s(find(diff(breaktimes_s)<minBlockDur_s)) = [];  % get rid of breaks that separate segments of data that are too short to be a block
        for b=1:length(breaktimes_s)-1
            numb=numb+1;
            files1{numb} = files{s}{f};
            blockrange{numb} = breaktimes_s(b:b+1);
        end
    end
    
    clear chanVar
    for b=1:length(files1)
        % For the purposes of looking for bad channels, it seems most sensible to leave the BDF referenced as it was recorded.
        % If we average-reference, a bad channel's badness is diluted and may spread to other channels.
        % With a single reference channel, it would be ok, as long as that channel is clean.
        EEG = pop_biosig(files1{b},'blockrange',round(blockrange{b}));
        
        if EEG.srate>500,
            EEG = pop_resample(EEG, 500);
        end
        % Fish out the event triggers and times
        clear trigs stimes
        for i=1:length(EEG.event)
            trigs(i)=EEG.event(i).type;
            stimes(i)=EEG.event(i).latency;
        end
        temp = abs(fft(EEG.data(:,stimes(1):stimes(end))'))'; % FFT amplitude spectrum
        tempF = [0:size(temp,2)-1]*EEG.srate/size(temp,2); % Frequency scale
        chanVar(:,b) = mean(temp(:,find(tempF>speclims(1) & tempF<speclims(2))),2);       % ROW of variances
        
    end
    
    save(matfile{s},'chanlocs','chanVar')
    end_time = toc;
end
close(h)


% Dan, the code is pretty much the same as the plotting code up until the
% last few lines when I calculate the CPP index. Note I've excluded PF and
% RKR for the moment, their CPPs were slightly different from the rest,
% making it a little difficult to calculate. There's code to plot each
% individual CPP there so you can have a look.
clear all
close all
clc
chanlocs = readlocs('cap64.loc');

% 
% % % %-------------------------------ADHD-------------------------------------------
% path = 'C:\Users\newmand\Dropbox\Monash\My Papers\ADHD vs Controls EEG QBI\Dots Data Downward\ADHD\'; 
path = 'C:\Users\Dan\Dropbox\Monash\My Papers\ADHD vs Controls EEG QBI\Dots Data Downward\ADHD\'; 
% path = 'C:\Users\Dan\Dropbox\QBI ADHD dots data\Dots Data Downward\ADHD\';
% path = 'S:\R-MNHS-SPP\Bellgrove-data\4. Dan Newman\QBI ADHD dots data\Dots Data Downward\ADHD\';

subject_folder = {'AD40C' 'AD11C' 'AD43C' 'AD18C' 'AD24C' 'AD52C' 'AD5C'...
    'AD54C' 'AD75C' 'AD15C' 'AD49C' 'AD69C' 'AD32C' 'AD16C'	'AD72C'...
    'AD59C'	'AD27C'	'AD46C'	'AD22C'	'AD26C'	'AD99C'	'AD48C'	'AD57C'...
    'AD51C' 'AD19C' 'AD98C' 'AD25C' 'AD23C'};
allsubj = {'1_40' '1_11' '1_43' '1_18' '1_24' '1_52' '1_5'...
    '1_54' '1_75' '1_15' '1_49' '1_69' '1_32' '1_16'...
    '1_72'	'1_59'	'1_27'	'1_46'	'1_22'	'1_26'	'1_99'	'1_48'	'1_57'...
    '1_51' '1_19' '1_98' '1_25' '1_23'};

allblocks = {[1:10], [1:10],[1:7],[1:10],[1:10],[1:10],[1:10],[1:10],[1:11],...
    [1:10],[1:10],[1:10],[1:11],[1:10],[1:10],[1:10],[1:10],[1:10],[1:10],...
    [1:10],[1:9],[1:10],[1:10]...
    [1:10],[1:11],[1:10],[1:10],[1:10]};

duds = [12,16,17,24,26]; %'AD69C', 'AD59C', 'AD27C', 'AD51C', 'AD98C'  These are kicked out due to clinical cuttoff filter_CPRS_N_B
%  duds = [];
% % % %---------------------------------------------------------------------------

% % % -------------------------------Controls--------------------------------------------
% path = 'C:\Users\newmand\Dropbox\Monash\My Papers\ADHD vs Controls EEG QBI\Dots Data Downward\Controls\'; 
% % path = 'C:\Users\newmand\Dropbox\Monash\My Papers\ADHD vs Controls EEG QBI\Dots Data Downward\Controls\'; 
% % path='S:\R-MNHS-SPP\Bellgrove-data\4. Dan Newman\QBI ADHD dots data\Dots Data Downward\Controls\';
% 
% subject_folder = {'001_KK' 'C12' 'C21' '002_LK' 'C50' 'C131' 'C20' 'C132' 'C213'...
%     'C204'	'C171' 'C13' 'C119'	'C121'	'C194'	'C168' ...
%     'C14' 'C49' 'C400' 'C100' 'C117' 'C115' 'C110' 'C183' 'C144' 'C252' ...
%     'C140' 'C259' 'C143' 'C89' 'C62' 'C88' 'C84' 'C87'};
% 
% allsubj = {'001'	'12'	'21'	'002'	'50'	'131'	'20'	'132'...
%     '213'	'204'	'171'	'13'	'119'	'121'	'194'	'168'...
%      '14' '49' '400' '100' '117' '115' '110' '183'  '144' '252' ...
%      '140' '259' '143' '89' '62' '88' '84' '87'};
% 
% allblocks = {[2:11], [1:10],[1:10],[1:10],	[1:10],	[1:10],	[1:10],... %for controls
% [1:10],	[1:10],	[1:10],	[1:10],	[1:11],	[1:11],	[1:10],	[1:10],	[1:10]...
% ,[1:10],[1:10],	[1:10],[1:4,6:11],[1:10],[1:10],[1:10],[1:10],[1:10],[1:10],...
% [1:10],[1:10],[1:10] ,[1:10],[1:10],[1:10],[1:10],[1:10]};
% 
% duds = [17,28,31]; %('C14', 'C259', filter_CPRS_N_B); 'C62'(C62 is RTasym outlier) %18(C49) was an outlier for CPP asym has extreamly leftward 
% % duds = [];
% % ---------------------------------------------------------------------------

single_participants = []; %DN: put the number of the participants you want to include in here and it will only run the analysis on them

% exp_conditions = {'CD'}; exp_c = 1;
exp_conditions = {'C'}; exp_c = 1; %DN
file_start = 1; % bear in mind duds.

exclude_chans = [24 28 33 37 47 61];
% exclude_chans = [];
plot_chans = [1:27,29:32,34:36,38:46,48:64];
total_RT_data = []; % This saves the matrix for SPSS analysis.
% Participant, block no, total trial no, intra block no, side, coherence,
% motion, button press, RT, correct/incorrect/no response.

if ~isempty(duds) && isempty(single_participants)
    subject_folder([duds]) = [];
    allsubj([duds]) = [];
    allblocks([duds]) = [];
end

if ~isempty(single_participants)
    subject_folder = subject_folder(single_participants);
    allsubj = allsubj(single_participants);
    allblocks = allblocks(single_participants);
end

% side,instance
targcodes = zeros(2,3);
targcodes(1,:) = [101 103 105]; % left patch,
targcodes(2,:) = [102 104 106]; % right patch

Fs=500;
numch=64;
rtlim=[0.2 2.2];

ch = [31]; %Channel Pz
ch_R_L = [62,25]; % right hemi channels for left target, vice versa. 25=P07 - left hemi, 62=P08 - right hemi
ch_for_ipsicon(1,:) = [62;25];
ch_for_ipsicon(2,:) = [25;62];
ch_l = [25];
ch_r = [62];
% ch = [25]; %DN: Channel Pz on the actiCAP64



% time scales:

ts = -0.350*Fs:1.880*Fs;   % in sample points, the ERP epoch
t = ts*1000/Fs;

% response-locked erps:
% trs = [-.876*Fs:Fs*.125];
% tr = trs*1000/Fs;
trs = [-.800*Fs:Fs*.100];
tr = trs*1000/Fs;


avRT=[];
avAlpha = [];
for s=file_start:length(allsubj)
    %     load([path subject_folder{s} '\' allsubj{s} '_' exp_conditions{exp_c} '_resample_Alpha'])
%     load([path subject_folder{s} '\' allsubj{s} '_' exp_conditions{exp_c} '_alpha_neg1250_to_2000ms_postTartRejOnly']) 

    
%     load([path subject_folder{s} '\' allsubj{s} '_8_to_13Hz_neg_800_to_1875ms_AR_centre_artRej500msPostTar_ET_20HzLPF']);
    load([path subject_folder{s} '\' allsubj{s} '_8_to_13Hz_neg800_to_1880_64ARchans_35HzLPF_point0HzHPF_ET_newLPF']);
%     Alpha=Alpha_CSD;

if length(allRT)<length(allrespLR)
    allRT(length(allRT)+1:length(allrespLR))=0;
end

    % stim-locked erps
    ts_alpha = Alpha_smooth_sample;
    t_alpha=Alpha_smooth_time;
    
    disp(['Subject ' allsubj{s} ' number of trials = ' num2str(size(Alpha,3))])
    
    
    validrlock = zeros(1,length(allRT)); % length of RTs.
    for n=1:length(allRT);
        [blah,RTsamp] = min(abs(t*Fs/1000-allRT(n))); % get the sample point of the RT.
        if RTsamp+trs(1) >0 & RTsamp+trs(end)<=length(t) & allRT(n)>0 % is the RT larger than 1st stim RT point, smaller than last RT point.
            validrlock(n)=1;
        end
    end
    
    clear conds
   for side = 1:2
        for i = 1:3
            % calcs the indices of the triggers for each
            % appropriate trial type.
            conds{side,i} = find(allTrig==targcodes(side,i) & allrespLR==1 & ...
                allRT>rtlim(1)*Fs & allRT<rtlim(2)*Fs & validrlock);
        end
        
        trial_temp = [conds{side,:}];
        conds2{s,side} = allRT(trial_temp)*1000/Fs;
        conds3{s,side} = trial_temp;
        clear trial_temp
    end
    
    disp(['Subject ',allsubj{s},' Total Valid Trials: ',num2str(length([conds2{s,:}])),' = ',num2str(round(100*length([conds2{s,:}])/(length(allblocks{s})*20))),'%'])
    disp(['Subject ',allsubj{s},' Total Left Trials: ',num2str(length([conds2{s,1}]))])
    disp(['Subject ',allsubj{s},' Total Right Trials: ',num2str(length([conds2{s,2}]))])
    disp(['Subject ',allsubj{s},' Left RT: ',num2str(mean([conds2{s,1}]))])
    disp(['Subject ',allsubj{s},' Right RT: ',num2str(mean([conds2{s,2}]))])
    RT_index(s) = (mean([conds2{s,:,1,:}])-mean([conds2{s,2}]))/((mean([conds2{s,1}])+mean([conds2{s,2}]))/2);
    
    for side = 1:2
        avAlpha(s,side,:,:) = mean(Alpha(1:numch,:,[conds3{s,side}]),3); %DN: avAlpha has 4 dimensions (subject,side,electrode,time)
        avRT{s,side} = mean(allRT([conds3{s,side}]),3);
        if isnan(avAlpha(s,side))
            keyboard
        end
    end
 
end


%DN: find the best LH and RH ROI electrodes for each participant
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for s=file_start:length(allsubj)  %DN: avAlpha has 4 dimensions (subject,side,electrode,time)
    for elec=1:numch
        left_minus_right_per_subject(s,elec) = squeeze(mean(avAlpha(s,1,elec,find(t_alpha==0):find(t_alpha==1800))))-squeeze(mean(avAlpha(s,2,elec,find(t_alpha==0):find(t_alpha==1800))));
    end
end

LH_elec=[20:23 25:27];
RH_elec=[57:60 62:64];
for s=file_start:length(allsubj)  %DN: For each participant this specify the 4 occipito-pariatal electrodes for each hemisphere that show the greatest desyncronisation difference between cont/ipsilateral targets
    LH_desync(s,:)= left_minus_right_per_subject(s,LH_elec);
    [temp1,temp2] = sort(LH_desync(s,:));
    LH_ROI(s,:)= LH_elec(temp2(5:7)); %DN: pick the 4 parieto-occipito that show the highest left_minus_right values (8:11)
    
    RH_desync(s,:)= left_minus_right_per_subject(s,RH_elec);
    [temp1,temp2] = sort(RH_desync(s,:));
    RH_ROI(s,:)= RH_elec(temp2(1:3)); %DN: pick the 4 parieto-occipito that show the lowest left_minus_right values (1:4)
% LH_ROI(s,:)=[25,26,27];
% RH_ROI(s,:)=[62,63,64];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%DN: combine LH_ROI = and RH_ROI electrodes together in ROIs_LH_RH, and ROIs_RH_LH for an ipsicon type thing
ROIs_LH_RH=zeros(length(allsubj),length(LH_ROI(1,:)),2);
ROIs_LH_RH(:,:,1)=LH_ROI;
ROIs_LH_RH(:,:,2)=RH_ROI;
ROIs_RH_LH=zeros(length(allsubj),length(LH_ROI(1,:)),2);
ROIs_RH_LH(:,:,2)=LH_ROI;
ROIs_RH_LH(:,:,1)=RH_ROI;

%DN: now make avAlpha_ROIs(subject,side,hemi,time) %collapse across ROI electrodes
% avAlpha_temp = squeeze(mean(mean(avAlpha,2),4)); % collapse by coherence and motion -avAlpha_temp(s,side,elec,time)
avAlpha_temp = avAlpha;
for s=file_start:length(allsubj)
    for hemi=1:2
        avAlpha_ROIs_LH_RH(s,:,hemi,:) = mean(avAlpha_temp(s,:,ROIs_LH_RH(s,:,hemi),:),3); %avAlpha_ROIs(subject,side,hemi,time) %for each hemi, collapse accross the ROI electrodes
        avAlpha_ROIs_RH_LH(s,:,hemi,:) = mean(avAlpha_temp(s,:,ROIs_RH_LH(s,:,hemi),:),3);
    end
end
%DN: and combine them together into an ipsicon struct to use for plotting
avAlpha_ROIs_ipsicon(1).avAlpha_ROIs = avAlpha_ROIs_RH_LH;
avAlpha_ROIs_ipsicon(2).avAlpha_ROIs = avAlpha_ROIs_LH_RH;


%     disp(['Subject ',allsubj{s},' Total Valid Trials: ',num2str(length([conds2{s,:}])),' = ',num2str(round(100*length([conds2{s,:}])/(length(allblocks{s})*20))),'%'])
%     disp(['Subject ',allsubj{s},' Total Left Trials: ',num2str(length([conds2{s,1}]))])
%     disp(['Subject ',allsubj{s},' Total Right Trials: ',num2str(length([conds2{s,2}]))])
%     disp(['Subject ',allsubj{s},' Left RT: ',num2str(mean([conds2{s,1}]))])
%     disp(['Subject ',allsubj{s},' Right RT: ',num2str(mean([conds2{s,2}]))])
    RT_index(s) = (mean([conds2{s,:,1,:}])-mean([conds2{s,2}]))/((mean([conds2{s,1}])+mean([conds2{s,2}]))/2);

[h2,p2,ci,stats] = ttest(RT_index);
disp(['T-test results for index: ',num2str(h2),'. p = ',num2str(p2)])

patch_side = {'Left Target','Right Target'};
patch_ipsi_contra = {'Left target/Contra Hemi','Left Target/Ipsi Hemi','Right Target/Contra Hemi','Right Target/Ipsi Hemi'};
patch_coh = {'Low','High'};
patch_coh_side = {'Low Left','Low Right','High Left','High Right'};
colors = {'b' 'r' 'g' 'm' 'c'};
line_styles = {'-' '-'};
colors2 = {'b' 'r' 'b' 'r'};
line_styles2 = {'-' '-' '--' '--'};
colors3 = {'b' 'b' 'r' 'r'};
line_styles3 = {'-' '--' '-' '--'};
[B,A]=butter(4,8*2/Fs);



%%
% ------------------------ PLOT Alpha -----------------------------


% %--------------------------------------------------------------------------
% %                              PLOT SIDES
% %--------------------------------------------------------------------------
% % Alpha = elec x time x trialcount
% % % avAlpha has 6 dimensions (subject,coh,side,motion,electrode,time)
% figure
% for side=1:2
%     avAlpha_temp = squeeze(mean(avAlpha(:,side,:,:),1));
%      avRT_temp = mean([avRT{:,side}].*(1000/Fs));
%     avAlpha_plot = squeeze(mean(avAlpha_temp(ch_for_ipsicon(1,side),:),1));
%     h(side) = plot(t_alpha,avAlpha_plot,colors{side}); hold on;
%     line([avRT_temp,avRT_temp],ylim,'Color',colors{side},'LineStyle',line_styles{side});
%     %     line(xlim,[0,0],'Color','k');
%     line([0,0],ylim,'Color','k');
%     disp([patch_side{side},' RT = ',num2str(avRT_temp)]);
% end
% legend(h,patch_side,'Location','NorthWest');
% clear h;
% title(' Alpha Power Contralateral')
% 
% 
% % avAlpha_ROIs(subject,side,hemi,time)
% 
% %Now use the ROI:
% figure
% for side=1:2
%     avRT_temp = mean([avRT{:,side}].*(1000/Fs));
%     avAlpha_plot = squeeze(mean(mean(mean(avAlpha_ROIs_RH_LH(:,side,side,:),1),2),3));
%     h(side) = plot(t_alpha,avAlpha_plot,colors{side}); hold on;
%     line([avRT_temp,avRT_temp],ylim,'Color',colors{side},'LineStyle',line_styles{side});
%     %     line(xlim,[0,0],'Color','k');
%     line([0,0],ylim,'Color','k');
%     disp([patch_side{side},' RT = ',num2str(avRT_temp)]);
% end
% legend(h,patch_side,'Location','NorthWest');
% clear h;
% title(' Alpha Power Contralateral ROI')
% 
% 
% figure
% for side=1:2
%     avAlpha_temp = squeeze(mean(avAlpha(:,side,:,:),1));
%     avRT_temp = mean([avRT{:,side}].*(1000/Fs));
%     avAlpha_plot = squeeze(mean(avAlpha_temp(ch_for_ipsicon(2,:),:),1));
%     
%     h(side) = plot(t_alpha,avAlpha_plot,colors{side}); hold on;
%     line([avRT_temp,avRT_temp],ylim,'Color',colors{side},'LineStyle',line_styles{side});
%     %     line(xlim,[0,0],'Color','k');
%     line([0,0],ylim,'Color','k');
%     disp([patch_side{side},' RT = ',num2str(avRT_temp)]);
% end
% legend(h,patch_side,'Location','NorthWest');
% clear h;
% title(' Alpha Power Ipsilateral')
% 
% %Now use the ROI:
% figure
% for side=1:2
%     avRT_temp = mean([avRT{:,side}].*(1000/Fs));
%     avAlpha_plot = squeeze(mean(mean(mean(avAlpha_ROIs_LH_RH(:,side,side,:),1),2),3)); %avAlpha_ROIs(subject,side,hemi,time)
%     
%     h(side) = plot(t_alpha,avAlpha_plot,colors{side}); hold on;
%     line([avRT_temp,avRT_temp],ylim,'Color',colors{side},'LineStyle',line_styles{side});
%     %     line(xlim,[0,0],'Color','k');
%     line([0,0],ylim,'Color','k');
%     disp([patch_side{side},' RT = ',num2str(avRT_temp)]);
% end
% legend(h,patch_side,'Location','NorthWest');
% clear h;
% title(' Alpha Power Ipsilateral ROI')
% 
% 
% 
% counter = 1;
% figure
% % xy_axes = axes('Parent',figure,'FontName','Arial','FontSize',20);
% for side=1:2
%     for channels = 1:2
%         avAlpha_temp = squeeze(mean(avAlpha(:,side,:,:),1));
%         avRT_temp = mean([avRT{:,side}].*(1000/Fs));
%         avAlpha_plot = squeeze(mean(avAlpha_temp(ch_for_ipsicon(side,channels,:),:),1));
%         h(counter) = plot(t_alpha,avAlpha_plot,'Color',colors3{counter},'LineStyle',line_styles3{counter}, ...
%             'Linewidth',1.5); hold on;
%         set(gca, 'XLim', [-1000 2000],'YLim', [2 4])
%         line([avRT_temp,avRT_temp],ylim,'Color',colors{side},'LineStyle',line_styles{side});
%         line(xlim,[0,0],'Color','k');
%         line([0,0],ylim,'Color','k');
%         counter = counter+1;
%     end
% end
% legend(h,patch_ipsi_contra,'Location','NorthWest');
% clear h;
% title(' Alpha Power by Target Side by Hemi (Ipsi vs Contra)')
% 
% %Now use the ROI:
% counter = 1;
% figure
% % xy_axes = axes('Parent',figure,'FontName','Arial','FontSize',20);
% for side=1:2
%     for channels = 1:2
%         avRT_temp = mean([avRT{:,side}].*(1000/Fs));
%         %         avAlpha_plot = squeeze(mean(avAlpha_temp(ch_for_ipsicon(side,channels,:),:),1));
%         avAlpha_plot = squeeze(mean(mean(mean(avAlpha_ROIs_ipsicon(channels).avAlpha_ROIs(:,side,side,:),1),2),3));  %avAlpha_ROIs_ipsicon.avAlpha_ROIs(subject,side,hemi,time)
%         h(counter) = plot(t_alpha,avAlpha_plot,'Color',colors3{counter},'LineStyle',line_styles3{counter}, ...
%             'Linewidth',1.5); hold on;
%         set(gca, 'XLim', [-1000 2000],'YLim', [2 4])
%         line([avRT_temp,avRT_temp],ylim,'Color',colors{side},'LineStyle',line_styles{side});
%         line(xlim,[0,0],'Color','k');
%         line([0,0],ylim,'Color','k');
%         counter = counter+1;
%     end
% end
% legend(h,patch_ipsi_contra,'Location','NorthWest');
% clear h;
% title(' Alpha Power by Target Side by Hemi ROIs (Ipsi vs Contra)')


%HERE, need to make ROI 1 of these baselined graphs:
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Baselined Alpha desynch by Target Side by Hemi (Ipsi vs Contra)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
counter = 1;
figure
for side=1:2
    for channels = 1:2
        avAlpha_temp = squeeze(mean(avAlpha(:,side,:,:),1));
        avRT_temp = mean([avRT{:,side}].*(1000/Fs));
        temp(ch_for_ipsicon(side,channels),:) = avAlpha_temp(ch_for_ipsicon(side,channels),:);
        bl_amp = mean(temp(ch_for_ipsicon(side,channels),9:16),2); % 13:20 = baseline from -400ms before onset assuming the epoch is from -750 to 1800ms
        avAlpha_plot = squeeze(mean(avAlpha_temp(ch_for_ipsicon(side,channels,:),:),1))-repmat(bl_amp,[1,size(temp(ch_for_ipsicon(1,side),:),2),size(temp(ch_for_ipsicon(side,channels,:),:),3)]);
        h(counter) = plot(t_alpha,avAlpha_plot,'Color',colors3{counter},'LineStyle',line_styles3{counter}, ...
            'Linewidth',1.5); hold on;
        set(gca, 'XLim', [-800 1800],'YLim', [-1 0.6])
        line([avRT_temp,avRT_temp],ylim,'Color',colors{side},'LineStyle',line_styles{side});
        line(xlim,[0,0],'Color','k');
        line([0,0],ylim,'Color','k');
        counter = counter+1;
    end
end
legend(h,patch_ipsi_contra,'Location','NorthWest');
clear h;
title('Baselined Alpha desynch by Target Side by Hemi (Ipsi vs Contra)')


%Alpha Asymmetry Index
figure
set(gca,'FontSize',15);
ylabel('microVolts','FontName','Arial','FontSize',20)
xlabel('Time (ms)','FontName','Arial','FontSize',20)
for target=1:2 %DN:just changed 'side' to 'target' here because thinking about target-'side' and hemi-'side' was doing my head in
    avAlpha_temp = squeeze(mean(avAlpha(:,target,:,:),1));
    avRT_temp = mean([avRT{:,:}].*(1000/Fs));
    avAlpha_plot = (squeeze(mean(avAlpha_temp(ch_l,:),1))-squeeze(mean(avAlpha_temp(ch_r,:),1)))./((squeeze(mean(avAlpha_temp(ch_r,:),1))+squeeze(mean(avAlpha_temp(ch_l,:),1)))); %Alpha Power Asymmetry 
    h(target) = plot(t_alpha,avAlpha_plot,colors{target},'LineWidth',3); hold on;
    %     line([avRT_temp,avRT_temp],ylim,'Color',colors{target},'LineStyle',line_styles{target});
    line(xlim,[0,0],'Color','k','LineWidth',1.5);
    line([0,0],ylim,'Color','k','LineWidth',1.5);
    line([avRT_temp,avRT_temp],ylim,'Color','k','LineWidth',2);
end
legend(h,patch_side,'Location','NorthWest');
clear h;
title('Alpha Asymmetry Index')

%Alpha Asymmetry Index    %Now use the ROI:
figure
set(gca,'FontSize',15);
ylabel('microVolts','FontName','Arial','FontSize',20)
xlabel('Time (ms)','FontName','Arial','FontSize',20)
for target=1:2 %DN:just changed 'side' to 'target' here because thinking about target-'side' and hemi-'side' was doing my head in
    avRT_temp = mean([avRT{:,:}].*(1000/Fs));   %avAlpha_ROIs_LH_RH(subject,side,hemi,time)
    avAlpha_plot = (squeeze(mean(mean(mean(avAlpha_ROIs_LH_RH(:,target,1,:),1),2),3))-squeeze(mean(mean(mean(avAlpha_ROIs_LH_RH(:,target,2,:),1),2),3)))./(squeeze(mean(mean(mean(avAlpha_ROIs_LH_RH(:,target,1,:),1),2),3))+squeeze(mean(mean(mean(avAlpha_ROIs_LH_RH(:,target,2,:),1),2),3))); %Alpha Power Asymmetry - Negitive values indicate greater alpha power over LH; Positive values indicate greater alpha power over right hemisphere
    h(target) = plot(t_alpha,avAlpha_plot,colors{target},'LineWidth',3); hold on;
    %     line([avRT_temp,avRT_temp],ylim,'Color',colors{target},'LineStyle',line_styles{target});
    line(xlim,[0,0],'Color','k','LineWidth',1.5);
    line([0,0],ylim,'Color','k','LineWidth',1.5);
    line([avRT_temp,avRT_temp],ylim,'Color','k','LineWidth',2);
end
legend(h,patch_side,'Location','NorthWest');
clear h;
title('Alpha Asymmetry Index - ROI')

% %Alpha Asymmetry Index  ROI:  % % % plot individual subjects
% for s = 1:size(allsubj,2)
%     figure
% set(gca,'FontSize',15);
% ylabel('microVolts','FontName','Arial','FontSize',20)
% xlabel('Time (ms)','FontName','Arial','FontSize',20)
% for target=1:2 %DN:just changed 'side' to 'target' here because thinking about target-'side' and hemi-'side' was doing my head in
%     avRT_temp = mean([avRT{s,:}].*(1000/Fs));   %avAlpha_ROIs_LH_RH(subject,side,hemi,time)
%     avAlpha_plot = (squeeze(mean(mean(mean(avAlpha_ROIs_LH_RH(s,target,1,:),1),2),3))-squeeze(mean(mean(mean(avAlpha_ROIs_LH_RH(s,target,2,:),1),2),3)))./(squeeze(mean(mean(mean(avAlpha_ROIs_LH_RH(s,target,1,:),1),2),3))+squeeze(mean(mean(mean(avAlpha_ROIs_LH_RH(s,target,2,:),1),2),3))); %Alpha Power Asymmetry - Negitive values indicate greater alpha power over LH; Positive values indicate greater alpha power over right hemisphere
%     h(target) = plot(t_alpha,avAlpha_plot,colors{target},'LineWidth',3); hold on;
%     %     line([avRT_temp,avRT_temp],ylim,'Color',colors{target},'LineStyle',line_styles{target});
%     line(xlim,[0,0],'Color','k','LineWidth',1.5);
%     line([0,0],ylim,'Color','k','LineWidth',1.5);
%     line([avRT_temp,avRT_temp],ylim,'Color','k','LineWidth',2);
% end
% legend(h,patch_side,'Location','NorthWest');
% clear h;
% title('Alpha Asymmetry Index - ROI')
% end


% %Contralateral alpha desynch baselined  %HERE, need to make ROI 1 of these baselined graphs:
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
for side=1:2
    avAlpha_temp = squeeze(mean(avAlpha(:,side,:,:),1));
    avRT_temp = mean([avRT{:,side}].*(1000/Fs));
    temp(ch_for_ipsicon(1,side),:) = avAlpha_temp(ch_for_ipsicon(1,side),:);
    bl_amp = mean(temp(ch_for_ipsicon(1,side),9:16),2); % 13:20 = baseline from -400ms before onset assuming the epoch is from -1000 to 2000ms
    avAlpha_plot = squeeze(mean(avAlpha_temp(ch_for_ipsicon(1,side),:),1))- repmat(bl_amp,[1,size(temp(ch_for_ipsicon(1,side),:),2),size(temp(ch_for_ipsicon(1,side),:),3)]);
    h(side) = plot(t_alpha,avAlpha_plot,colors{side}); hold on;
    line([avRT_temp,avRT_temp],ylim,'Color',colors{side},'LineStyle',line_styles{side});
    line(xlim,[0,0],'Color','k');
    line([0,0],ylim,'Color','k');
    disp([patch_side{side},' RT = ',num2str(avRT_temp)]);
end
legend(h,patch_side,'Location','West');
clear h;
title('Contralateral alpha desynch baselined')


avAlpha_all_temp = squeeze(mean(avAlpha,2)); % collapse by side  (subject,coh,side,motion,electrode,time)
for s = 1:size(allsubj,2)
    avAlpha_all(s,:) = squeeze(mean(avAlpha_all_temp(s,ch_R_L,:),2));
end

%Mean pre-target alpha asymmetry:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% avAlpha_all_temp(s,elec,time)
avAlpha_all_temp = squeeze(mean(avAlpha,2)); % collapse by side 
for s = 1:size(allsubj,2) LH_ROI
    PreTarget_RH(s) = mean(squeeze(avAlpha_all_temp(s,ch_r,find(t_alpha==-750):find(t_alpha==0))));
%       PreTarget_RH(s) = squeeze(mean(mean(avAlpha_all_temp(s,RH_ROI(s,:),find(t_alpha==-750):find(t_alpha==0)),3),2));
    PreTarget_LH(s) = mean(squeeze(avAlpha_all_temp(s,ch_l,find(t_alpha==-750):find(t_alpha==0))));
%       PreTarget_LH(s) = squeeze(mean(mean(avAlpha_all_temp(s,LH_ROI(s,:),find(t_alpha==-750):find(t_alpha==0)),3),2)); 
    PreTargetAlpha_Index(s) = (PreTarget_RH(s)-PreTarget_LH(s))/(PreTarget_RH(s)+PreTarget_LH(s));  %not using ROI, just using one electrode from each hemisphere
end
% % correlation between pre-target alpha index and RT index
[R,P] = corrcoef(PreTargetAlpha_Index,RT_index);
disp('correlation between mean pre-target alpha index and mean RT index');
disp(['Pearsons R']);
disp(R(1,2))
disp(['Corresponding p-value']);
disp(P(1,2))

xy_axes = axes('Parent',figure,'FontName','Arial');
hold(xy_axes,'all');
% xlim(xy_axes,[-0.12 0.04])
% ylim(xy_axes,[-60 40])
h1 = scatter(PreTargetAlpha_Index,RT_index,'o','MarkerFaceColor','b'); %[.49 1 .63]
title(['R = ',num2str(round(R(1,2)*1000)/1000),', p = ',num2str(round(P(1,2)*1000)/1000)])
hChildren = get(h1, 'Children');
set(hChildren, 'Markersize', 5)
ylabel('RT Asym','FontName','Arial','FontSize',16)
xlabel('Pre-target Alpha Asym','FontName','Arial','FontSize',16)
% set(gca,'XTick',[-0.12 -0.08 -0.04 0 0.04],'FontSize',28,'FontName','Arial','YTick',[-60 -40 -20 0 20 40],'FontSize',28);
line([xlim],[0,0],'Color','k','LineWidth', 1.4);
line([0,0],[ylim],'Color','k','LineWidth', 1.4);
h2 = lsline;
set(h2,'LineWidth',2, 'Color','r');


%Now try for ROI
avAlpha_all_temp = squeeze(mean(avAlpha,2)); % collapse by coherence, side and motion.
for s = 1:size(allsubj,2)
    PreTarget_RH_ROI(s) = squeeze(mean(mean(avAlpha_all_temp(s,RH_ROI(s,:),find(t_alpha==-750):find(t_alpha==0)))));
    PreTarget_LH_ROI(s) = squeeze(mean(mean(squeeze(avAlpha_all_temp(s,LH_ROI(s,:),find(t_alpha==-750):find(t_alpha==0))))));
    PreTargetAlpha_Index_ROI(s) = (PreTarget_RH_ROI(s)-PreTarget_LH_ROI(s))/((PreTarget_RH_ROI(s)+PreTarget_LH_ROI(s))/2);
end
% % correlation between pre-target alpha index and RT index
[R,P] = corrcoef(PreTargetAlpha_Index_ROI,RT_index);
disp('correlation between mean pre-target alpha index and mean RT index');
disp(['Pearsons R']);
disp(R(1,2))
disp(['Corresponding p-value']);
disp(P(1,2))

xy_axes = axes('Parent',figure,'FontName','Arial');
hold(xy_axes,'all');
% xlim(xy_axes,[-0.12 0.04])
% ylim(xy_axes,[-60 40])
h1 = scatter(PreTargetAlpha_Index_ROI,RT_index,'o','MarkerFaceColor','b'); %[.49 1 .63]
title(['R = ',num2str(round(R(1,2)*1000)/1000),', p = ',num2str(round(P(1,2)*1000)/1000)])
hChildren = get(h1, 'Children');
set(hChildren, 'Markersize', 5)
ylabel('RT Asym','FontName','Arial','FontSize',16)
xlabel('Pre-target Alpha Asym - ROI','FontName','Arial','FontSize',16)
% set(gca,'XTick',[-0.12 -0.08 -0.04 0 0.04],'FontSize',28,'FontName','Arial','YTick',[-60 -40 -20 0 20 40],'FontSize',28);
line([xlim],[0,0],'Color','k','LineWidth', 1.4);
line([0,0],[ylim],'Color','k','LineWidth', 1.4);
h2 = lsline;
set(h2,'LineWidth',2, 'Color','r');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% avAlpha(s,coh,side,motion,elec,time)
avAlpha_lr_temp = avAlpha; % collapse by coherence and motion. % avAlpha_lr_temp(s,side,elec,time)
for s = 1:size(allsubj,2)
    for side = 1:2
        avAlpha_contralateral(s,side,:) = squeeze(mean(avAlpha_lr_temp(s,side,ch_for_ipsicon(1,side),:),3));
    end
end


% avAlpha_lr(s,side,:)
for s = 1:size(allsubj,2)
    alpha_desync_LeftTarget_RightHemi(s) = min(avAlpha_contralateral(s,1,find(t_alpha==0):find(t_alpha==1800)))-mean(avAlpha_contralateral(s,1,find(t_alpha==-750):find(t_alpha==-50))); %DN: max contralateral alpha desync during motion minus average pre-target alpha
    alpha_desync_RightTarget_LeftHemi(s) = min(avAlpha_contralateral(s,2,find(t_alpha==0):find(t_alpha==1800)))-mean(avAlpha_contralateral(s,2,find(t_alpha==-750):find(t_alpha==-50)));
    
    %   calculate index, fairly self explanatory.
    alpha_desync_index1(s) = (abs(alpha_desync_RightTarget_LeftHemi(s))-abs(alpha_desync_LeftTarget_RightHemi(s)))/((abs(alpha_desync_LeftTarget_RightHemi(s))+abs(alpha_desync_RightTarget_LeftHemi(s)))); %DN: Negative numbers indicate greater contralateral desynchronisation after left targets than after right targets. I added the 'abs' in here to save thinking about negitive numbers when interpreting the index
    %       alpha_desync_index1(s) = (abs(alpha_desync_LeftTarget_RightHemi(s))-abs(alpha_desync_RightTarget_LeftHemi(s)))/((abs(alpha_desync_LeftTarget_RightHemi(s))+abs(alpha_desync_RightTarget_LeftHemi(s)))/2);
end


% this plots the differenct between contralateral alpha desync from left vs right targets for each participant to check for outliers.
figure
plot(alpha_desync_LeftTarget_RightHemi)
hold on
plot(alpha_desync_RightTarget_LeftHemi,'r')


% 1 sample t-test for contralateral alpha desync index
[h3,p3,ci3,stats3] = ttest(alpha_desync_index1);
disp(['Avg alpha desync index: ',num2str(mean(alpha_desync_index1))])
disp(['T-test results for contralateral alpha desync index: t = ',num2str(stats3.tstat),'. p = ',num2str(p3)])


% % 1 sample t-test for CPP index
% [h2,p2,ci2,stats2] = ttest(half_peak_index);
% disp(['Avg CPP index: ',num2str(mean(half_peak_index))])
% disp(['T-test results for CPP index: t = ',num2str(stats2.tstat),'. p = ',num2str(p2)])

% CORRELATIONS
% correlation between post target alpha desync index and RT index
[R,P] = corrcoef(alpha_desync_index1,RT_index);
disp('Correlation mean post target alpha desync index and mean RT index:');
disp(['Pearsons R']);
disp(R(1,2))
disp(['Corresponding p-value']);
disp(P(1,2))
xy_axes = axes('Parent',figure,'FontName','Arial');
hold(xy_axes,'all');
% xlim(xy_axes,[-0.12 0.04])
% ylim(xy_axes,[-60 40])
h1 = scatter(alpha_desync_index1,RT_index,'o','MarkerFaceColor','b'); %[.49 1 .63]
title(['R = ',num2str(round(R(1,2)*1000)/1000),', p = ',num2str(round(P(1,2)*1000)/1000)])
hChildren = get(h1, 'Children');
set(hChildren, 'Markersize', 5)
ylabel('RT Asym','FontName','Arial','FontSize',16)
xlabel('Alpha desynchronisation Asym','FontName','Arial','FontSize',16)
% set(gca,'XTick',[-0.12 -0.08 -0.04 0 0.04],'FontSize',28,'FontName','Arial','YTick',[-60 -40 -20 0 20 40],'FontSize',28);
line([xlim],[0,0],'Color','k','LineWidth', 1.4);
line([0,0],[ylim],'Color','k','LineWidth', 1.4);
h2 = lsline;
set(h2,'LineWidth',2, 'Color','r');


% % % correlation between and pre-target alpha index post target alpha desync index
[R,P] = corrcoef(PreTargetAlpha_Index,alpha_desync_index1);
disp('between and pre-target alpha index post target alpha desync index');
disp(['Pearsons R']);
disp(R(1,2))
disp(['Corresponding p-value']);
disp(P(1,2))
xy_axes = axes('Parent',figure,'FontName','Arial');
hold(xy_axes,'all');
% xlim(xy_axes,[-0.12 0.04])
% ylim(xy_axes,[-60 40])
h1 = scatter(PreTargetAlpha_Index,alpha_desync_index1,'o','MarkerFaceColor','b'); %[.49 1 .63]
title(['R = ',num2str(round(R(1,2)*1000)/1000),', p = ',num2str(round(P(1,2)*1000)/1000)])
hChildren = get(h1, 'Children');
set(hChildren, 'Markersize', 5)
ylabel('Post target alpha desync asym','FontName','Arial','FontSize',16)
xlabel('Pre-target Alpha Asym','FontName','Arial','FontSize',16)
% set(gca,'XTick',[-0.12 -0.08 -0.04 0 0.04],'FontSize',28,'FontName','Arial','YTick',[-60 -40 -20 0 20 40],'FontSize',28);
line([xlim],[0,0],'Color','k','LineWidth', 1.4);
line([0,0],[ylim],'Color','k','LineWidth', 1.4);
h2 = lsline;
set(h2,'LineWidth',2, 'Color','r');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% % plot individual subjects
% for s = 1:size(allsubj,2)
%     figure
%     for side=1:2
%         avAlpha_temp = squeeze(mean(mean(avAlpha(s,:,side,:,:,:),2),4));
%         avRT_temp = mean([avRT{s,:,side,:}].*(1000/Fs));
%         avAlpha_plot = squeeze(mean(avAlpha_temp(ch_R_L(side),:),1));
%
%         h(side) = plot(t_alpha,avAlpha_plot,colors{side}); hold on;
% %         h(side) = plot(avAlpha_plot,colors{side}); hold on;
%         line(xlim,[0,0],'Color','k');
%         line([0,0],ylim,'Color','k');
% %         disp([patch_side{side},' RT = ',num2str(avRT_temp)]);
%     end
%     legend(h,patch_side,'Location','NorthWest');
%     clear h;
%     title([num2str(s),':  Alpha Power for Sides ',allsubj{s},', RT index = ',num2str(RT_index(s)),', Alpha desync index = ',num2str(alpha_desync_index1(s))])
% end
%
%
% % % plot individual subjects  %%USING ROI
% for s = 1:size(allsubj,2)
%     figure
%     for side=1:2
%         avAlpha_temp = squeeze(mean(mean(avAlpha(s,:,side,:,:,:),2),4));
%         avRT_temp = mean([avRT{s,:,side,:}].*(1000/Fs));
%         avAlpha_plot = squeeze(mean(avAlpha_temp(ROIs_RH_LH(s,:,side),:),1));
%
%         h(side) = plot(t_alpha,avAlpha_plot,colors{side}); hold on;
% %         h(side) = plot(avAlpha_plot,colors{side}); hold on;
%         line(xlim,[0,0],'Color','k');
%         line([0,0],ylim,'Color','k');
% %         disp([patch_side{side},' RT = ',num2str(avRT_temp)]);
%     end
%     legend(h,patch_side,'Location','NorthWest');
%     clear h;
%     title([num2str(s),': ROI - Alpha Power for Sides ',allsubj{s},', RT index = ',num2str(RT_index(s)),', Alpha desync index = '])
% end




%DN get mean left and right RT for each participant
for s = 1:size(allsubj,2)
    RTs_left(s) = mean([conds2{s,1}]);
end

for s = 1:size(allsubj,2)
    RTs_right(s) = mean([conds2{s,2}]);
end


for side = 1:2 %DN this does the scalp plots
    avAlpha_temp = squeeze(mean(avAlpha(:,side,:,:),1));
    %for chan = 1:72
    for chan = 1:numch %DN
        temp(chan,:,side) = avAlpha_temp(chan,:);
    end
    bl_amp = mean(temp(:,9:16,side),2); % 13:20 = baseline from -400ms before onset assuming the epoch is from -1000 to 2000ms
    temp(:,:,side) = temp(:,:,side) - repmat(bl_amp,[1,size(temp(:,:,side),2),size(temp(:,:,side),3)]);
    
    figure;
    plottopo(temp(1:64,:,side),'chanlocs',chanlocs,'limits',[t_alpha(1) t_alpha(end) min(min(temp(:,:,side)))  max(max(temp(:,:,side)))], ...
        'title',[patch_side{side},' Topography'],'ydir',1,'chans',plot_chans);
    % %     OPTIONAL CODE TO PLOT TOPOGRAPHIES
    counter = 1;
    axis tight
    set(gca,'NextPlot','replaceChildren');
    for i = find(t_alpha==0):1:find(t_alpha==1950)
        figure;
        topoplot (temp(:,i,side),chanlocs,'maplimits',[min(min(temp(1:64,find(t_alpha==0):find(t_alpha==1950),side)))  max(max(temp(1:64,find(t_alpha==0):find(t_alpha==1950),side)))],'electrodes','numbers','plotchans',plot_chans);
        title([patch_side{side},' Target topography. Time = ' num2str(t_alpha(i)) ' ms']);
        frame(counter:counter+2) = getframe(gca);
        counter = counter+3;
    end
    %     figure;
    %     movie(frame(1:size(frame,2)));
    keyboard
    %     close all
    %     frame = [];
end

%--------------------------------------------------------------------------

%DN: scalp plots for left minus right target alpha
avAlpha_left_minus_right = squeeze(mean(avAlpha(:,1,:,:),1))-squeeze(mean(avAlpha(:,2,:,:),1)); %DN: left target minus right target
temp = avAlpha_left_minus_right;
bl_amp = mean(temp(:,9:16),2); % 13:20 = baseline from -400ms before onset assuming the epoch is from -1000 to 2000ms
temp(:,:) = temp(:,:) - repmat(bl_amp,[1,size(temp(:,:),2),1]);
figure;
plottopo(temp(1:64,:),'chanlocs',chanlocs,'limits',[t_alpha(1) t_alpha(end) min(min(temp(:,:)))  max(max(temp(:,:)))], ...
    'title',[' Topography'],'ydir',1,'chans',plot_chans);
% %     OPTIONAL CODE TO PLOT TOPOGRAPHIES
axis tight
set(gca,'NextPlot','replaceChildren');
for i = find(t_alpha==0):1:find(t_alpha==1800)
    figure;
    topoplot (temp(:,i),chanlocs,'maplimits',[min(min(temp(1:64,find(t_alpha==0):find(t_alpha==1800))))  max(max(temp(1:64,find(t_alpha==0):find(t_alpha==1800))))],'electrodes','numbers','plotchans',1:64);
    title(['Left minus Right Target topography. Time = ' num2str(t_alpha(i)) ' ms']);
    frame(counter:counter+2) = getframe(gca);
    counter = counter+3;
end



%         plot grand average left minus right desync using mean alpha during the time period for left minus right targets

%DN: avAlpha has 4 dimensions (subject,side,electrode,time)
avAlpha_left_minus_right = squeeze(mean(avAlpha(:,1,:,:),1))-squeeze(mean(avAlpha(:,2,:,:),1)); %DN: left target minus right target
temp = avAlpha_left_minus_right;
bl_amp = mean(temp(:,9:16),2); % 13:20 = baseline from -400ms before onset assuming the epoch is from -1000 to 2000ms
temp(:,:) = temp(:,:) - repmat(bl_amp,[1,size(temp(:,:),2),1]);
for elec=1:numch
    avAlpha_left_minus_right_postTarger(elec) = squeeze(mean(avAlpha_left_minus_right(elec,find(t_alpha==0):find(t_alpha==1800))));
end
figure;
topoplot (avAlpha_left_minus_right_postTarger, chanlocs,'electrodes','numbers','plotchans',1:64);
title(['left minus right post target in Cont Dots']);
figure;
bar(avAlpha_left_minus_right_postTarger([16:23 25:27 53:60 62:64]))
%         bar(left_minus_right_desync(s,:))
xlim([0 23])
my_labels = ['16';'17';'18';'19';'20';'21';'22';'23';'25';'26';'27';'53';'54';'55';'56';'57';'58';'59';'60';'62';'63';'64'];
set(gca,'XTick',[1:22.5]);
set(gca,'XTickLabel',my_labels);
title(['Chans for left minus right post target in Cont Dots ']);


keyboard

%         plot left minus right desync for individual participants using mean alpha during the time period for left minus right targets


for s=file_start:length(allsubj)
    figure;
    topoplot (left_minus_right_per_subject(s,:),chanlocs,'electrodes','numbers','plotchans',plot_chans);
    title([num2str(s),': Post cue alpha desync ',allsubj{s}]);
    figure;
    bar(left_minus_right_per_subject(s,[16:23 25:27 53:60 62:64]))
    %         bar(left_minus_right_desync(s,:))
    xlim([0 23])
    my_labels = ['16';'17';'18';'19';'20';'21';'22';'23';'25';'26';'27';'53';'54';'55';'56';'57';'58';'59';'60';'62';'63';'64'];
    set(gca,'XTick',[1:22.5]);
    set(gca,'XTickLabel',my_labels);
    title([num2str(s),': Chans for Post cue alpha desync ',allsubj{s}]);
end

subject_folder=subject_folder';
open subject_folder
PreTarget_RH_ROI=PreTarget_RH_ROI'; PreTarget_LH_ROI=PreTarget_LH_ROI';PreTargetAlpha_Index_ROI=PreTargetAlpha_Index_ROI';
open PreTarget_LH_ROI
open PreTarget_RH_ROI
open PreTargetAlpha_Index_ROI



alpha_desync_LeftTarget_RightHemi=alpha_desync_LeftTarget_RightHemi'; alpha_desync_RightTarget_LeftHemi=alpha_desync_RightTarget_LeftHemi';alpha_desync_index1=alpha_desync_index1';
open alpha_desync_LeftTarget_RightHemi
open alpha_desync_RightTarget_LeftHemi
open alpha_desync_index1


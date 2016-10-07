function juice_RMS
clear all; close all;
tic;
%%%%%%%%%%%%%%%%%%%%       �˲�������    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Fs = 250;  % Sampling Frequency    
%%% filter_design(Fs,Fstop1,Fpass1,Fpass2,Fstop2)    % �˲���ϵ���ļ��㣬���洢ϵ�� B
load('B.mat'); 
%%%%%%%%%%%%%%%%%%%%        ����       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
unit_num = 50;    %���ٸ�����һ��rms

global data_length;
data_length=[];
N2_dir_path = 'D:\spindle\RMS\Data';  % ��N2_dir_path�����б��Ե������ļ��е�·����
N2_dir = dir(N2_dir_path); %�� N2_dir��N2�����ļ��е���Ϣ�Ľṹ�壩
m = length(N2_dir); % m-2 Ϊ���Ը���

%%%%%%%%%%%%%%%%%%%   rms, threshold   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for subj_i = 17 % �Ա��Ե�ѭ�� 
    subj_name = N2_dir(subj_i).name; % ��subj_name����ǰ���Ե����֣�
    subj_dir_path = [N2_dir_path,'\',subj_name]; % ��subj_dir_path����ǰ�����ļ��е�·���� 
    subj_dir_s = dir(subj_dir_path); % (subj_dir_N23: ��ǰ���Ե��ļ��е���Ϣ�Ľṹ)
    m1 =  length(subj_dir_s); % m1-2 ��ǰ�����ļ����µ�mat���������ж��ٶε����ݣ�
    if isempty(data_length)
        data_length=zeros(m-2,m1-2);%��һ��������ÿ������ÿ��mat�ļ������ݳ���
    else
    end
    cd(subj_dir_path);   % 
    mkdir('results');    % �ڱ����ļ����½��ļ��� results�����ڴ洢���
    subj_results_path = [subj_dir_path,'\','results'];
    
    all_mat_rms2 = [];
    
    for subj_s = 3:m1
        N_subj_mat=subj_s-2;
        subj_s_name = subj_dir_s(subj_s).name; %�ļ��е�mat�ļ���Ϣ
        cd(subj_results_path);%����results�ļ�
%         mkdir(subj_s_name);  % ��results�ļ����½��ļ���
        %cd('D:\MATLAB\matlab2012a\mywork\mywork\sunjb\RMS-A\chun_mat');%�ص����Ŀ¼��������Ҳ�������Ҫ�õ��ĺ���   
        subj_results_s_path = subj_results_path;
        subj_s_path = subj_dir_path; % ��subj_dir_path����ǰ�����ļ��е�·���� 
        subj_mat = dir([subj_dir_path '\' '*.mat']);
        num_subj_mat = length(subj_mat); % ��num_subj_mat����ǰ���Ե�mat������
        all_mat_rms = [];
        all_mat_time = zeros(1,num_subj_mat);
        all_mat_time_num = zeros(1,num_subj_mat);
        %%%%%%%%%%%%%%%%%%%%%           rms          %%%%%%%%%%%%%%%%%%%%%%%
        
        subj_mat_path = [subj_s_path '\' subj_s_name]; % ��subj_mat_dir����ǰ���Եĵ�N_subj_mat ��mat�ļ�·����
        %%%%  ���� .mat   %%%%
        load(subj_mat_path); 
        data_length(subj_i-2,subj_s-2)=length(b(3,:));
        mat_orgn_data= b([1:8,13:17],:); % ��mat_orgn_data:load����ԭʼ�����ݣ�
        mat_orgn_length = size(mat_orgn_data,2);   % ��mat_length��mat_orgn_data�ĳ��ȣ�
        each_mat_rms = mat_rms(mat_orgn_data,unit_num,B,N_subj_mat,subj_results_s_path);
        mat_time = size(each_mat_rms,1)*0.25;   % ����ÿ��mat��ʱ��,s
        all_mat_time(N_subj_mat) = mat_time;     % ����ÿ��mat��ʱ����һ��������    
        all_mat_rms = [all_mat_rms;each_mat_rms];  % ����ÿ��mat��rms��һ��������
        all_mat_time_num(N_subj_mat) = mat_orgn_length;
        all_mat_rms2 = [all_mat_rms2;all_mat_rms];
        path_2 = strcat(subj_results_s_path,'\','all_mat_time.mat');
        save(path_2,'all_mat_time');   % ����ÿ��stage��time������ all_mat_time �� all_mat_time.mat
        save(path_2,'all_mat_time_num');
        thres= prctile(all_mat_rms2,95);  %��ֵ
%         clear all_mat_rms2;
        cd(subj_results_path);
        save(['thres_' subj_s_name],'thres');  % ���� thres �� thres.mat
        if ~exist('spindle_a0.mat')
            spd_detection_a0=zeros(data_length(subj_i-2,subj_s-2),1,m1-2,15);
        else
        end
        filter_mat_name = dir(['.\','filter_data_*.mat']);% ����ͨ��� 'rms_data_*.mat'
        load('all_mat_time');
        s_time = sum(all_mat_time)/60; % �ý׶ε�ʱ�䣬min
        Spindle_general = [];
        for pole=1:11
            Spd_amplitude = [];  %����ÿ���缫��amplitude
            Spd_frequency = [];   % ����ÿ���缫�� frequency
            Spd_duration = [];   %  ����ÿ���缫�� duration
            cd(subj_results_s_path);
            filter_data_path = [filter_mat_name(N_subj_mat).name]; % 
            load(filter_data_path);  % �����˲�����
            each_mat_rms_pole=each_mat_rms(:,pole);%ȡһ���缫������
            rms_data_1 = (each_mat_rms_pole>thres(pole)) ;  % ��rms�д���thres�ı��Ϊ1   
            res = lianxu_1(rms_data_1,unit_num,Fs);    % ��������1��λ�ú͸���                     
            eval(['Sres_',num2str(N_subj_mat),'mat_',num2str(pole),'pole','=','res',';']);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%   singular spindle    %%%%%%%%%%%%%%%%%%%%%%
            cd(subj_results_s_path);   % �漰�����ݱ���
            if isempty(res)
                continue;
            else
                [spd_num,unuseful] = size(res);
                for spd_i = 1:spd_num
                    st = res(spd_i,1);  % ����rms�Ĵ��������index
                    ed =res(spd_i,1)+res(spd_i,2)-1;  % ����rms�Ĵ����Ľ���index
                    st = (st-1)*unit_num+1;   % ����Ĵ��������index
                    ed = ed*unit_num;     % ����Ĵ����Ľ���index
                %%%%%%%%%����Ĵ�������ֹ�㣬���ڻ�ͼ%%%%%%%%%%%%%%%%%
                    spd_detection_a0(st:ed,1,N_subj_mat,pole)=1;
                    if ~exist('spindle_a0.mat')
                        spd_a0_position=zeros(spd_num,2,m1-2,15);                          
                        spd_a0_position(spd_i,:,N_subj_mat,pole)=[st ed];
                    else
                        spd_a0_position(spd_i,:,N_subj_mat,pole)=[st ed];
                    end
                        save('spindle_a0','spd_a0_position','spd_detection_a0');
                        spd_data = mat_data_3(st:ed);  %�õ��Ĵ������� 
                        [pks_p,locs_p] = findpeaks(spd_data);  % �õ�����ֵ
                        [pks_n,locs_n] = findpeaks(-spd_data);  %�õ���Сֵ
                        locs_p = st-1+locs_p;  %�õ�����ֵ��mat_data_3 �ľ���index
                        locs_n = st-1+locs_n;  %�õ���Сֵ��mat_data_3 �ľ���index


           %%%%%%%%%%%%%%%     �����ֵ   %%%%%%%%%%%%%%%%%%%%%%%%%       

                        length_p = length(locs_p);
                        length_n = length(locs_n);
                        length_union = length_p+length_n;
                        pks_union = zeros(1,length_union);

                        if (locs_p(1)<locs_n(1))  % ����ֵ��ǰ��
                            pks_union(1:2:end) = pks_p;   
                            pks_union(2:2:end) = pks_n;    % ���з�ֵ�Ĳ��ƴ�ӣ����ڼ���pks-to-pks                       
                            pks_union_1 = [pks_union(2:end),0];   % �ӵڶ�����ʼȡ
                            pks_union_2 = pks_union+pks_union_1;  %  ���� pks-to-pks
                            pks_union = pks_union_2(1:end-1);   % ȡ��ʵ�ʵ�pks-to-pks
                            [amplitude,index_1] = max(pks_union);  % �õ�����peak-to-peak


                        else
                            pks_union(1:2:end) = pks_n;   
                            pks_union(2:2:end) = pks_p;
                            pks_union_1 = [pks_union(2:end),0]; 
                            pks_union_2 = pks_union+pks_union_1;  %  ���� pks-to-pks
                            pks_union = pks_union_2(1:end-1); 
                            [amplitude,index_1] = max(pks_union);  % �õ�����peak-to-peak

                        end                       
                        Spd_amplitude = [Spd_amplitude,amplitude];

            %%%%%%%%%%%%%%%%%%  ����Ƶ��  %%%%%%%%%%%%%%%%%
%                         pks_p_diff = diff(locs_p);
%                         pks_n_diff = diff(locs_n);
%                         pks_diff = [pks_p_diff pks_n_diff];
%                         frequency = Fs/mean(pks_diff);
                        N=512;
                        FFT_data=abs(fft(spd_data,N));
                        [pks,locs]=findpeaks(FFT_data(1:length(FFT_data)/2));
                        freqs=(1:N/2)*Fs/N;
                        locs_n=[];
                        freqs_n=[];
                        for i_pks=1:length(pks)
                            i_freqs=freqs(locs(i_pks));%��ֵ���Ӧ��Ƶ��
                            if i_freqs>=12&&i_freqs<=16.5%�ҳ�����Ƶ��Ϊ12-16hz��Ƶ��
                                locs_n=[locs_n locs(i_pks)];%����Ƶ�ʷ�Χ��λ��
                                freqs_n=[freqs_n i_freqs];
                            else
                            end
                        end     
                        if ~isempty(freqs_n)
                            frequency=max(freqs_n);%12-16hz��Χ�ڵ����Ƶ��
                            freq_floor=floor(frequency);
                            diff_freq=abs(frequency-freq_floor);
                            if(0<=diff_freq&&diff_freq<0.125)
                                frequency=freq_floor;
                            elseif(0.125<=diff_freq&&diff_freq<0.375)
                                frequency=freq_floor+0.25;
                            elseif(0.375<=diff_freq&&diff_freq<0.625)
                                frequency=freq_floor+0.5;
                            elseif(0.625<=diff_freq&&diff_freq<0.875)
                                frequency=freq_floor+0.75;
                            elseif(diff_freq>=0.875)
                                frequency=freq_floor+1;
                            end
                        else
                            for i_pks=1:length(pks)
                                i_freqs=freqs(locs(i_pks));%��ֵ���Ӧ��Ƶ��
                                if i_freqs>=11&&i_freqs<=17%�ҳ�����Ƶ��Ϊ12-16hz��Ƶ��
                                    locs_n=[locs_n locs(i_pks)];%����Ƶ�ʷ�Χ��λ��
                                    freqs_n=[freqs_n i_freqs];
                                else
                                end
                            end
                            frequency=max(freqs_n);%11-17hz��Χ�ڵ����Ƶ��
                            freq_floor=floor(frequency);
                            diff_freq=abs(frequency-freq_floor);
                            if(0<=diff_freq&&diff_freq<0.125)
                                frequency=freq_floor;
                            elseif(0.125<=diff_freq&&diff_freq<0.375)
                                frequency=freq_floor+0.25;
                            elseif(0.375<=diff_freq&&diff_freq<0.625)
                                frequency=freq_floor+0.5;
                            elseif(0.625<=diff_freq&&diff_freq<0.875)
                                frequency=freq_floor+0.75;
                            elseif(diff_freq>=0.875)
                                frequency=freq_floor+1;
                            end
                        end
                        Spd_frequency = [Spd_frequency,frequency];
                        
            %%%%%%%%%%%%%%%%%  �������ʱ��   %%%%%%%%%%%%%%%%%%%%%%%%%
                        duration = res(spd_i,2)*(unit_num/Fs);   %  
                        Spd_duration = [Spd_duration,duration];

                end

            end

            
%             save(['Spindle_',num2str(pole),'pole'],'spd_a0_position','spd_detection_a0');           
            Spd_num = numel(Spd_duration);
            Spd_destiny= Spd_num/s_time; % ����density=spindles/min
            mean_amplitude = mean(Spd_amplitude);
            mean_frequency = mean(Spd_frequency);
            mean_duration = mean(Spd_duration);
            general.num=Spd_num;
            general.destiny=Spd_destiny;
            general.amplitude=Spd_amplitude;
            general.frequency=Spd_frequency;
            general.duration=Spd_duration;
            general.mean_amplitude=mean_amplitude;
            general.mean_frequency=mean_frequency;
            general.mean_duration=mean_duration;
            general.data_duration=s_time;
            clear Spd_*pole;
            clear Spd_destiny;   
            clear Spd_amplitude;
            clear Spd_frequency;
            clear Spd_duration;               
            save(['Spindle_detail',subj_s_name(1:end-4),'_',num2str(pole),'pole'] ,'general');
            clear general;
        end
%         save('res_all','Sres_*');    %����������'Sres_'��ͷ�ı����� res_all.mat����ʵ����res
        clear Sres_*;
        
%         delete('filter*.mat');    
        delete('rms_data*.mat');
            
    end
            
    
end
toc;

end



%%%%%%%%%%%%%%%%%%%%    filter_design    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function  filter_design(Fs,Fstop1,Fpass1,Fpass2,Fstop2)

% Fs = 500;  % Sampling Frequency    
% 
% Fstop1 = 10;               % First Stopband Frequency
% Fpass1 = 10.2;             % First Passband Frequency
% Fpass2 = 16.8;            % Second Passband Frequency
% Fstop2 = 17;              % Second Stopband Frequency
Dstop1 = 0.001;           % First Stopband Attenuation   %%% ������������Գɼȶ�����
Dpass  = 0.057501127785;  % Passband Ripple
Dstop2 = 0.001;           % Second Stopband Attenuation
dens   = 20;              % Density Factor

% Calculate the order from the parameters using FIRPMORD.
[N, Fo, Ao, W] = firpmord([Fstop1 Fpass1 Fpass2 Fstop2]/(Fs/2), [0 1 ...
                          0], [Dstop1 Dpass Dstop2]);

% Calculate the coefficients using the FIRPM function.
B  = firpm(N, Fo, Ao, W, {dens});
save('B.mat','B')
end



%%%%%%%%%%%%%%%%%%%%%%%%%%   each_mat_rms   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function each_mat_rms = mat_rms(mat_orgn_data,unit_num,B,N_subj_mat,subj_results_s_path)
mat_orgn_length = size(mat_orgn_data,2);   % ��mat_length��mat_orgn_data�ĳ��ȣ�
mat_length = mat_orgn_length-mod(mat_orgn_length,unit_num); % (mat_length:�������ݳ������ܱ�unit_num�����Ĳ���)
mat_data_1 = mat_orgn_data(:,1:mat_length); % ����ǰ���ݲ��ܱ�unit_num�����Ĳ��ִ����ȥ�� 
mat_data_2 = zeros(11,mat_length); % Ĭ��ΪC3�缫���ݲ�����˫������  ��mat_data_2: ��ȥ�ο���ѹ������ ��
mat_data_2(1,:) = mat_data_1(1,:) - mat_data_1(13,:);  %%FP1�����A2���źţ�
mat_data_2(2,:) = mat_data_1(2,:) - mat_data_1(12,:);  %%FP2�����A1���źţ�
mat_data_2(3,:) = mat_data_1(3,:) - mat_data_1(13,:);  %%F3�����A2���źţ�
mat_data_2(4,:) = mat_data_1(4,:) - mat_data_1(12,:);  %%F4�����A1���źţ�
mat_data_2(5,:) = mat_data_1(5,:) - mat_data_1(13,:);  %%C3�����A2���źţ�2
mat_data_2(6,:) = mat_data_1(6,:) - mat_data_1(12,:);  %%C4�����A1���źţ�
mat_data_2(7,:) = mat_data_1(7,:) - mat_data_1(13,:);  %%P3�����A2���źţ�
mat_data_2(8,:) = mat_data_1(8,:) - mat_data_1(12,:);  %%P4�����A1���źţ�
mat_data_2(9,:) = mat_data_1(9,:) - (mat_data_1(12,:)+mat_data_1(13,:))/2;  %%Fz�����(A1+A2)/2���źţ�
mat_data_2(10,:) = mat_data_1(10,:) - (mat_data_1(12,:)+mat_data_1(13,:))/2;  %%Cz�����(A1+A2)/2���źţ�
mat_data_2(11,:) = mat_data_1(11,:) - (mat_data_1(12,:)+mat_data_1(13,:))/2;  %%Pz�����(A1+A2)/2���źţ�
clear mat_orgn_data;
clear mat_data_1;

%%%%%%%%%%%%%%%%%%%%  �˲�   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mat_data_2 = mat_data_2';
mat_data_3 = filtfilt(B,1,mat_data_2); % ��mat_data_2�����˲����õ�10�����ݣ���Ҫ�ϳ�ʱ�䣬����save  mat_data_3��

name_1 = strcat('filter_data_',num2str(N_subj_mat,'%02d'),'.mat');
path =strcat(subj_results_s_path,'\',name_1);
save(path,'mat_data_3');           % �����˲�������� mat_data_3 �� filter_data_...mat
mat_data_4 = reshape( mat_data_3,unit_num,[],11); % �����ݽ���ά��ת��������һ����rms���㡣
clear mat_data_2;
clear mat_data_3;

%%%%%%%%%%%%%%%%%%%%  ����rms   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
each_mat_rms= rms(mat_data_4);  %%��rms (1*10 | 1*10 | 1*10 ...)
each_mat_rms = reshape(each_mat_rms,[],11);
%each_mat_rms = each_mat_rms';
name_2 = strcat('rms_data_',num2str(N_subj_mat,'%02d'),'.mat');  % num2str(N_subj_mat,'%02d')
path =strcat(subj_results_s_path,'\',name_2);
save(path,'each_mat_rms');   % ����each_mat_rms ��  rms_data_...mat
%%%%%%%%%%%%%%%%%%   �洢��ǰ���Ե�rms  %%%%%%%%%%%%%%%%%%%%%%%%%

end


%%%%%%%%%%%%%%%%%%%%%%%     lianxu_1    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function res = lianxu_1(a,Num,Fs)
%a = [0 ones(1,5)  0 0 1 0 ones(1,10) 0] ;
b = find(a) ; %�ҳ�rms�������д�����ֵ����ֵΪ1��λ��
res = [] ;
n = 1 ; 
i = 1 ;
while i < length(b)
    j = i+1 ;
    while j <= length(b) &&  b(j)==b(j-1)+1 %�����������Ϊ1
        n = n + 1 ;%����Ϊ1�ĸ���
        j = j + 1 ;
    end
    if n >= ((0.4*Fs)/Num) && n <= ((2*Fs)/Num)    % ����Ϊ1�ĸ�����Χ�ڴ�֮�ڣ�������Ĵ����ĳ���ʱ�䣬�ͽ����ֵ��¼����
        res = [res ; b(i),n] ;
   
    end
    n = 1 ;
    i = j ;
end
end
 

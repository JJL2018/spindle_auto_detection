function AR_model_500
close all;
clear all;
prefile = spm_select(1, 'dir', 'Select the position of EEG file','' ...
            ,pwd,'.*');
N2_dir_path = prefile;  % ��N2_dir_path�����б��Ե������ļ��е�·����
N2_dir = dir(N2_dir_path); %�� N2_dir��N2�����ļ��е���Ϣ�Ľṹ�壩
m = length(N2_dir); % m-2 Ϊ���Ը���  
fs=500;
Ra = 0.9;%��һ����ֵ
Rb = 0.95;%�ڶ�����ֵ
p=8;%ARģ�͵Ľ���
Hd = kasier_filter;
B = Hd.Numerator;
h=waitbar(0,'Please waiting...');
number_segment = zeros(1,m-2);
for subj_i = 3:m
    subj_name = N2_dir(subj_i).name; % ��subj_name����ǰ���Ե����֣�
    subj_dir_path = [N2_dir_path,subj_name]; % ��subj_dir_path����ǰ�����ļ��е�·����
    subj_dir = dir(subj_dir_path);
    number_segment(subj_i-2) = length(subj_dir)-2;
end
total_step = sum(number_segment)*10;
step = 0;
for subj_i = 3:m;
    subj_name = N2_dir(subj_i).name; % ��subj_name����ǰ���Ե����֣�
    subj_dir_path = [N2_dir_path,subj_name]; % ��subj_dir_path����ǰ�����ļ��е�·����
    subj_dir = dir(subj_dir_path);
    number_segment(subj_i-2) = length(subj_dir)-2;
    for segment = 3:length(subj_dir)
        subj_dir_name = subj_dir(segment).name;
        load([subj_dir_path,'\',subj_dir_name]);
        data = b;
        left_data = data(1:2:9,:);
        right_data = data(2:2:10,:);
        left_data = left_data-ones(size(left_data,1),1)*data(30,:);
        right_data = right_data-ones(size(right_data,1),1)*data(29,:);
        data_all = [left_data;right_data];
        data_all_medi = zeros(size(data_all,1),size(data_all,2));
        data_all_medi(1:2:9,:) = left_data(1:5,:);
        data_all_medi(2:2:10,:) = right_data(1:5,:);
        num_mod = mod(size(data_all_medi,2),fs);
        data_all_medi(:,end-num_mod+1:end) = [];
        each_mat_2 = filtfilt(B,1,data_all_medi); % ��mat_data_2�����˲����õ�10�����ݣ���Ҫ�ϳ�ʱ�䣬����save  mat_data_3��
        each_mat_3 = each_mat_2';
        clear data_all_medi;  
        time = size(each_mat_3,2)/fs;
        detection_1 = zeros(size(each_mat_3,1),time*50);
        detection = zeros(size(each_mat_3,1),size(each_mat_3,2));
        for channel = 1:size(each_mat_3,1);
            step = step + 1;
            for k = 1:time;
                x_input1s = each_mat_3(channel,(k-1)*fs+1:k*fs);%1s����
                ar_coeffs = arburg(x_input1s,p);%ʹ��burg������ARģ�Ͳ������й��ƣ�
                ZK = roots(ar_coeffs);%�󼫵�
                RK = abs(ZK);%�����ģ
                angleK = angle(ZK);%�������λ��
                [RK_all index]= max(abs(RK));
                if RK_all>=Ra;
                    if k == 1
                        frequency = angleK(index)*fs/(2*pi);
                        while (frequency == 0)
                            RK(index) = [];
                            angleK(index) = [];
                            [RK_all index]= max(abs(RK));
                            frequency = angleK(index)*fs/(2*pi);
                        end
                        if RK_all >= Rb && frequency>=10 && frequency <=16;
                            detection_1(channel,(k-1)*50+1:k*50) = 1;
                        end
                    else
                        n = 0;
                        for i = 1/50:1/50:1
                            n = n+1;
                            x_input1s = each_mat_3(channel,ceil((k-2)*fs+i*fs)+1:ceil((k-2)*fs+i*fs)+fs);
                            ar_coeffs2 = arburg(x_input1s,p);%ʹ��burg������ARģ�Ͳ������й��ƣ�
                            ZK2 = roots(ar_coeffs2);%�󼫵�
                            RK2 = abs(ZK2);%�����ģ
                            angleK2 = angle(ZK2);%�������λ��
                            [RK_all_2 index_2]= max(abs(RK2));
                            frequency_2 = angleK2(index_2)*fs/(2*pi);
                            while (frequency_2 == 0)
                                RK2(index_2) = [];
                                angleK2(index_2) = [];
                                [RK_all_2 index_2]= max(abs(RK2));
                                frequency_2 = angleK2(index_2)*fs/(2*pi);
                            end
                            if RK_all_2 >= Rb && frequency_2>=10 && frequency_2 <=16
                                detection_1(channel,(k-2)*50+n+1) = 1;                           
                            end
                        end
                    end   
                end             
            end 
            [start_position end_position] = start_end(detection_1(channel,:));
            if ~isempty(start_position)            
                for spindle_i = 1:length(start_position)
                    duration = (end_position(spindle_i) - start_position(spindle_i) + 1)/50;
                    if duration >= 0.5 && duration <= 2
                        detection(channel,(start_position(spindle_i)-1)*fs/50+1:(end_position(spindle_i)-1)*fs/50+1)=1;
                    else
                        detection_1(channel,start_position(spindle_i):end_position(spindle_i)) = 0;
                    end
                end
            end
            num_step = step/total_step;
            waitbar(num_step,h,['�����' num2str(num_step*100) '%']);
        end
         detection_all(subj_i-2,segment-2) = struct('detection',detection,'detection_media',detection_1);
    end
end
index = find(prefile,'\');
psd_path = prefile(1:index(end));
mkdir([psd_path,'AR_model_results_500']);
str_path = [psd_path,'AR_model_results_500\'];
save([str_path,'AR_model_result.mat'],'detection_all');
close(h);
end


function Hd = kasier_filter
%UNTITLED Returns a discrete-time filter object.

%
% MATLAB Code
% Generated by MATLAB(R) 7.14 and the Signal Processing Toolbox 6.17.
%
% Generated on: 05-Nov-2015 10:21:02
%

% FIR Window Bandpass filter designed using the FIR1 function.

% All frequency values are in Hz.
Fs = 500;  % Sampling Frequency

N    = 1665;     % Order
Fc1  = 0.3;      % First Cutoff Frequency
Fc2  = 35;       % Second Cutoff Frequency
flag = 'scale';  % Sampling Flag
Beta = 5;        % Window Parameter
% Create the window vector for the design algorithm.
win = kaiser(N+1, Beta);

% Calculate the coefficients using the FIR1 function.
b  = fir1(N, [Fc1 Fc2]/(Fs/2), 'bandpass', win, flag);
Hd = dfilt.dffir(b);
% [EOF]
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%�ҵ��Ĵ����Ŀ�ʼʱ��ͽ���ʱ��
function [start_position end_position] = start_end(each_subject)
[Row,column] = size(each_subject);
if Row > column
    each_subject = each_subject';%��������ת��Ϊ������
end
length_subject = length(each_subject);
each_diff = diff(each_subject);
start_position = find(each_diff == 1) + 1;
end_position = find(each_diff == -1);
if each_subject(1) == 1  
   %��each_subject��һ������1����ô��һ���Ĵ����Ŀ�ʼ����Ϊ1
    start_position = [1,start_position];
end
if each_subject(end) == 1 
    %��each_subjec�����һ������1����ô���һ���Ĵ����Ľ�������Ϊlength_subject
    end_position = [end_position,length_subject];  
end
end
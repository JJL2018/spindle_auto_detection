function spindle_detection_MP
warning off all
%%  ������ȡ
% num_subj = 30;                                                 %% ��ȡ����������
fs = 500;                         %% ����Ƶ�ʣ�
ds = 4;                              %% �²���������Ĭ��4����
d_fs = fs/ds;                                                               %% �����²�����Ĳ����ʣ�
N = 1024;                               %% ��ȡÿ�ηֽ���źŵ�����Ĭ��
load('GaborAtom_1024.mat');                    %% ��ȡԭ�ӿ⣻                                                                %% �ͷŲ���ʹ�õĴ洢�ռ䣻
ep = 0.05;                                                                  %% �ź��ع��в��ֹ��ֵ��
H_psd = 16;                            %% ��ȡ����spindle�����Ƶ�ʣ�
L_psd = 9;                             %% ��ȡ����spindle�����Ƶ�ʣ�
TH1 = 7.5;                                 %% ��ȡ�����spindle������ֵ������7.5����
S_duration = 0.5;                           %% ��ȡ����spindle����̳���ʱ�䣻
L_duration = 2;                           %% ��ȡ����spindle�������ʱ�䣻
bbb = [-3.98923231507507e-05,-3.46161293505339e-05,0.00109113359144369,-0.000817126039535110,-0.00743905493062784,0.0106040711249938,0.0246986155741091,...
    -0.0577878721767207,-0.0483106137321757,0.298035851567139,0.559999006947751,0.298035851567139,-0.0483106137321757,-0.0577878721767207,0.0246986155741091,...
    0.0106040711249938,-0.00743905493062784,-0.000817126039535110,0.00109113359144369,-3.46161293505339e-05,-3.98923231507507e-05];
%%  ���ݶ�ȡ�ͼ���
total_len = 0;
data_path='D:\spindle\MP\data\N2';
data_dir=dir(data_path);
num_subj=length(data_dir);%N2�ļ�����mat�ļ�����
detection=zeros(num_subj-2,300000);
for sub_matj = 4  %%��mat�ļ���ѭ��
    spindle_num = zeros(1,10);
    data_len = 0;
    spindle_para = zeros(1,6,10);
    spindle_data = zeros(1,N,10);
    spindle_atom = zeros(1,N,10);
    spindle_marker = zeros(1,N,10);
    spindle_density = zeros(4,10);
    mat_path=fullfile(data_path,data_dir(sub_matj).name);
    load(mat_path);%����mat�ļ�
    data_matrix =b([1:10 29:32],:);  %% ��ȡ��ǰ���ݶε���Ч���ݣ�
    data_matrix = downsample(data_matrix',ds)';
    SigLen = size(data_matrix,2)-mod(size(data_matrix,2),N);  %% �������ݳ������ܱ����ݵ�Ԫ�����Ĳ��֣�
    data_matrix = data_matrix(:,1:SigLen);  %% ����ǰ���ݲ��ܱ����㵥Ԫ�����Ĳ��ִ����ȥ����
    data_10channels = zeros(10,SigLen);  %% �������ڷ��������ݴ洢�ռ䣻
    data_10channels(1,:) = data_matrix(1,:) - data_matrix(12,:);  %% FP1�����A2���źţ�
    data_10channels(2,:) = data_matrix(2,:) - data_matrix(11,:);  %% FP2�����A1���źţ�
    data_10channels(3,:) = data_matrix(3,:) - data_matrix(12,:);  %% F3�����A2���źţ�
    data_10channels(4,:) = data_matrix(4,:) - data_matrix(11,:);  %% F4�����A1���źţ�
    data_10channels(5,:) = data_matrix(5,:) - data_matrix(12,:);  %% C3�����A2���źţ�
    data_10channels(6,:) = data_matrix(6,:) - data_matrix(11,:);  %% C4�����A1���źţ�
    data_10channels(7,:) = data_matrix(7,:) - data_matrix(12,:);  %% P3�����A2���źţ�
    data_10channels(8,:) = data_matrix(8,:) - data_matrix(11,:);  %% P4�����A1���źţ�
    data_10channels(9,:) = data_matrix(9,:) - data_matrix(12,:);  %% O1�����A2���źţ�
    data_10channels(10,:) = data_matrix(10,:) - data_matrix(11,:);      %% O2�����A1���źţ�
    clear data_matrix;                                                  %% �ͷŲ���ʹ�õĴ洢�ռ䣻
    num_cc = SigLen/N;
    cc = clock;
%     disp(['���ڼ����',num2str(sub_matj),'�����ԣ���',num2str(num_subj),'�����ԣ��ĵ�',num2str(ll),...
%         '�����ݣ���',num2str(num_yuanqiang),'�����ݣ��������ݳ���',num2str(num_cc*N/d_fs),'�롪����ǰʱ�䣺',...
%         num2str(cc(2)),'��',num2str(cc(3)),'�ա�',num2str(cc(4)),'ʱ',num2str(cc(5)),'��',num2str(round(cc(6))),'��']); %%��MATLAB������ʵʱ��ʾ���㵽���ĸ����Ե��Ķ����ݣ�
    data_len = data_len + num_cc;           %% ��ʼ��Ϊ��data_len = zeros(1,num_subj)��
    data_filter = filtfilt(bbb,1,data_10channels');                       %% �����ݽ���35Hz�ĵ�ͨ�˲���
    clear data_10channels;
    data_tran = reshape(data_filter,N,num_cc,[]);                  %% ������ת��Ϊ��ά��N��*num_cc��*10��
    clear data_filter;
%     spm_progress_bar('Init',num_cc*10,'Inner');                         %% ��spmС���ڵĽ��������ֱ���Ϊ��1/����*�缫������
    guan = 0;
    for chs = 5
        for len = 1:num_cc
            guan = guan+1;
            x_xdata = data_tran(:,len,chs)';
%             TH1= prctile(x_xdata,95);
            [g_atomCoe_totle,g_atom,a,x_error] = matchPursuit(x_xdata,g,ep);
            [N1,M1] = size(g_atom);                                     %% N����ֽ��ѡ��ԭ�ӵĸ�����M��ʾÿ��ԭ�ӵĳ���
              for i = 1:N1
                 g_atom(i,:) = g_atom(i,:)*g_atomCoe_totle(i);
                 [atom_peak,index_atom] = findpeaks(g_atom(i,:));
                 if numel(atom_peak) < 2
                     continue;
                 end
                 yu = abs(fftshift(fft(g_atom(i,:)))).^2;               %% ����ͼ����ԭ�������ף����������N/2���㣩��
                 yu1 = yu(N/2+1:end);                                   %% ֻҪ�������N/2���㣬��ӦƵ�ʣ�0Hz �� (N/2-1)/(N/d_fs) Hz;
                 [yu1_peak,index1] = findpeaks(yu1);                    %% ���������׵ķ�ֵ
                 if isempty(index1)                                     %% ����Ƿ��з�ֵ����û�з�ֵ��������һ��ԭ�ӣ�
                     continue;
                 end
                 [yu1_max,index2] = max(yu1_peak);                      %% ���������׵�����ֵ
                 index = index1(index2);
                 index_tran0 = ((0:N-1)-N/2)*(d_fs/N);
                 index_tran = index_tran0(N/2+1:end);
                 if (index_tran(index) >= L_psd) && (index_tran(index) <= H_psd)   %% ��������׵�����ֵ�Ƿ���spindleƵ����Χ��
                     B = find(g_atom(i,:) >= TH1);
                     if isempty(B)
                         continue;
                     end
                     duration = (B(end) - B(1))/d_fs;                         
                     if duration >= S_duration && duration <= L_duration
                         marker_s = zeros(1,N);
                         spindle_num(chs) = spindle_num(chs) +1;        %% ��ʼ��Ϊ��spindle_num = zeros(10,num_subj);
                         spindle_para(spindle_num(chs),1,chs) = index_tran(index);
                         spindle_para(spindle_num(chs),2,chs) = max(atom_peak);
                         spindle_para(spindle_num(chs),3,chs) = duration;                             
                         marker_s(B(1):B(end)) = 1;
                         spd_st=(B(1)+N*(len-1)-1)*ds;
                         spd_ed=(B(end)+N*(len-1)-1)*ds;
                         detection(sub_matj-2,spd_st:spd_ed)=1;
                         spindle_data(spindle_num(chs),:,chs) = x_xdata;
                         spindle_atom(spindle_num(chs),:,chs) = g_atom(i,:);
                         spindle_marker(spindle_num(chs),:,chs) = marker_s;
                         zzz = sum(reshape(spindle_atom(spindle_num(chs),:,chs).^2,8,[]))./sum(reshape((spindle_data(spindle_num(chs),:,chs)-mean(spindle_data(spindle_num(chs),:,chs))).^2,8,[]));
                         yyy = reshape(repmat(zzz,8,1),1,[]).*spindle_marker(spindle_num(chs),:,chs);
                         duration1 = sum(yyy > 0.4)/d_fs;
                         duration2 = sum(yyy > 0.2)/d_fs;
                         spindle_para(spindle_num(chs),4,chs) = duration2; 
                         spindle_para(spindle_num(chs),5,chs) = duration1; 
                         if duration1 >= 0.3
                             spindle_para(spindle_num(chs),6,chs) = 100;
                         elseif duration1 < 0.3 && duration2 >= 0.5
                             spindle_para(spindle_num(chs),6,chs) = 50;
                         else
                             spindle_para(spindle_num(chs),6,chs) = 25;
                         end
                     end
                 end
             end              
%             spm_progress_bar('Set',guan);                               %% ��spmС���ڵĽ�������1��
        end
    end
    spindle_density(1,:) = spindle_num./(data_len*N/d_fs/60);
    spindle_density(2,:) = sum(spindle_para(:,6,:) == 25)./(data_len*N/d_fs/60);
    spindle_density(3,:) = sum(spindle_para(:,6,:) == 50)./(data_len*N/d_fs/60);
    spindle_density(4,:) = sum(spindle_para(:,6,:) == 100)./(data_len*N/d_fs/60);
    save(['Sub',num2str(sub_matj-2),'_spindle_all.mat'],'spindle_num','data_len','spindle_density','spindle_para','spindle_data','spindle_atom','spindle_marker');
    total_len = total_len + data_len;
end
save('MP_detection','detection');
disp('o(��_��)o');
disp('o(��_��)o');
disp('o(��_��)o');
disp('o(��_��)o');
disp('o(��_��)o');
disp(['���ڼ�������ˣ��ۼƼ������ݣ�',num2str(total_len*N/d_fs),'�롪����ǰʱ�䣺',...
    num2str(cc(2)),'��',num2str(cc(3)),'�ա�',num2str(cc(4)),'ʱ',num2str(cc(5)),'��',num2str(round(cc(6))),'��']);
% spm_progress_bar('Clear');  %% �ر�spmС���ڵĽ�������







%% -----------------------------------------------------
function [g_atomCoe_totle,g_atom,a,x_error] = matchPursuit(x,g,ep)
%% ����ƥ��׷��
% num = size(g,1);
num = 1000;
[row,colomn] = size(x);
if row > colomn
    x = x';
end
x_error = x;
g_atom = zeros(num,colomn);
g_atomCoe_totle = zeros(1,num);
a = zeros(1,num);
for m = 1:num
    inner_product = g*x_error';%�����ݺ�ԭ�����ڻ���ȡ��ֵ���
    [inner_max_abs,index] = max(abs(inner_product));
    g_atom(m,:) = g(index,:);%ÿ�ε�����õ���ԭ��
    g_atomCoe_totle(m) = inner_product(index);%ÿ�ε������ڻ�ϵ��
    x_error = x_error - inner_product(index).*g(index,:);%�в�
    a(m) = (norm(x_error)^2)/(norm(x)^2);
    if a(m) < ep %
        break;
    end
end
g_atom = g_atom(1:m,:);
g_atomCoe_totle = g_atomCoe_totle(1:m);
a = a(1:m);


function Get_FI(file_name, total_log, Exp) 
% Hyper parameter
conf_ct = 1 ; 
bin_nb = 2 ; 

disp("데이터 정리...") ; 
% distance
excel = xlsread(file_name, "Sheet1") ; 

if Exp == 1
    color_d = excel(:, 3) ;
    ori_d = excel(:, 4) ;
    
    % probe log record
    c_log = total_log.log_list1c ;
    o_log = total_log.log_list1o ;
    rt_log = total_log.log_time1 ;
    
    % confidence
    cof_c = excel(:, 5) ;
    cof_o = excel(:, 6) ;
    
elseif Exp == 2 
    color_d = excel(:, 4) ;
    ori_d = excel(:, 5) ;
        
    % probe log record
    c_log = total_log.log_c ;
    o_log = total_log.log_o ;
    rt_log = total_log.log_time ;
    
    % confidence
    cof_c = excel(:, 6) ;
    cof_o = excel(:, 7) ;
    
end

%% Estimate Color and Ori Precision 
auc_fig = figure ; 
Cauc = mok_cdf(color_d) ; hold on ; 
Oauc = mok_cdf(ori_d) ; 
mok_cdf(-180 : 180) ; 

%% log organization %% 
diff_c = zeros([size(c_log, 1)+1, size(c_log, 2)]) ; 
diff_c(2:end, :) = c_log ;  
changed_c = c_log - diff_c(1:end-1, :) ;   
changed_c(changed_c == 0) = nan ;  changed_c(isnan(changed_c) == 0) = 1 ;  

diff_o = zeros([size(o_log, 1)+1, size(o_log, 2)]) ; 
diff_o(2:end, :) = o_log ;  
changed_o = o_log - diff_o(1:end-1, :) ; 
changed_o(changed_o == 0) = nan ;  changed_o(isnan(changed_o) == 0) = 1 ;  

%___ revised logs ________________________________
c_log_re = c_log .* changed_c ; 
o_log_re = o_log .* changed_o ; 
% ________________________________________________

% ___ Select Tags _____
choice_list = zeros([1, size(c_log_re, 2)]) ;
crt_list = zeros([1, size(c_log_re, 2)]) ;
ort_list = zeros([1, size(c_log_re, 2)]) ;

conf_tags = [] ; 
for tt = 1 : size(c_log_re, 2)
    c_list = c_log_re(2:end, tt) ; 
    o_list = o_log_re(2:end, tt) ; 
    
    c_index = find(isnan(c_list) ~= 1) ;
    o_index = find(isnan(o_list) ~= 1) ;
    
    if isempty(c_index) ~= 1 & isempty(o_index) ~= 1
        start_c = c_index(1) ; end_c = c_index(end) ;
        start_o = o_index(1) ; end_o = o_index(end) ;
        c_range = [start_c : end_c] ;
        o_range = [start_o : end_o] ;
        co_range = [c_range, o_range] ;
        norep_size = size(unique(co_range)) ; norep_size = norep_size(2) ;
        rep_size = size(co_range) ; rep_size = rep_size(2) ;
        
        c_interval = rt_log(start_c : end_c , tt) ;
        o_interval = rt_log(start_o : end_o, tt) ; 
        
        c_rt = sum(c_interval) ; 
        o_rt = sum(o_interval) ; 
        
        if norep_size == rep_size
            choice_method = 0 ; % 순차
        elseif norep_size ~= rep_size
            choice_method = 1 ; % 조율
        end
    elseif isempty(c_index) | isempty(o_index) 
        choice_method = 0 ;
        c_rt = 0 ; 
        o_rt = 0 ; 
    end
    
    choice_list(tt) = choice_method ; 
    crt_list(tt) = c_rt ; 
    ort_list(tt) = o_rt ; 
    
    clist_index = find(isnan(c_list) ~= 1) ;
    clist_ind = rt_interval(clist_index, rt_log, tt) ; 
    clist_index1 = vertcat([0], clist_ind) ; 
    clist_index2 = vertcat(clist_ind, [0]) ;
    clist_interval = clist_index2 - clist_index1 ;
    clist_interval = clist_interval(2 : end-1) ;
    max_cinterval = max(clist_interval) ; 
    cmax_pos = find(clist_interval == max_cinterval) ; 
    
    olist_index = find(isnan(o_list) ~= 1) ;
    olist_ind = rt_interval(olist_index, rt_log, tt) ;
    olist_index1 = vertcat([0], olist_ind) ; 
    olist_index2 = vertcat(olist_ind, [0]) ;
    olist_interval = olist_index2 - olist_index1 ;
    olist_interval = olist_interval(2 : end-1) ; 
    max_ointerval = max(olist_interval) ; 
    omax_pos = find(olist_interval == max_ointerval) ;
    
    conf_list = [max_cinterval, max_ointerval] ; 
    % 조율 여부 : 0 - 모두 x, 1 - color만 조율, 2 - ori만 조율, 3 - 모두 조율
    conf_logic = conf_list >= 1.5 ; % 1.5 초 이상의 간격은 조율로 판단. 
    if choice_method
        if sum(conf_logic) == 0 
            conf_judg = 0 ; 
        elseif sum(conf_logic) == 2
            conf_judg = 3 ; 
        elseif sum(conf_logic) == 1
            if conf_logic(1)
                conf_judg = 1 ; 
            elseif conf_logic(2)
                conf_judg = 2 ; 
            end
        end
    else
        conf_judg = 0 ; 
    end
    conf_tags(tt) = conf_judg ; 
    
end

%%%________ VFI_Exp1 Main Results _______________%%%
disp("* 주요 결과 정리") ;
trial_nb = length(color_d) ;  
pdir = pwd ; 
if Exp == 2 
    cd(strcat(pdir, '\Results2')) ;
    newfolder = file_name(17:end-5) ;
elseif Exp == 1
    cd(strcat(pdir, '\Results')) ; 
    newfolder = file_name(16:end-5) ;
end
 
pdir = pwd ; 
new_dic = [pdir + "\" + newfolder] ; 
mkdir(new_dic) ; addpath(new_dic) ; 
cd(strcat(new_dic)) ;

% Show d distribution  
disp("(1) Show d distribution") ; 
f = figure ; 
subplot(1,2,1);
hist(color_d, 180) ; 
title("d distribution of color recall")

subplot(1,2,2); 
hist(ori_d, 180) ; 
title("d distribution of orientation recall")

%%% Qualitative Results
%% Configuration rate : Conf_Rate
Conf_Rate = length(conf_tags(conf_tags > 0)) / trial_nb ; 
disp("(2) Configuration rate : " + Conf_Rate) ; 

%% Confidence SI : Conf_SI 
% confidence 0, 1 : recall failure 
% confidence 2, 3 : recall success
cof_data = [cof_c, cof_o] ; 
failed_ind = find(cof_c <= 1) ; 
cof_failed_data = cof_data(failed_ind, :) ; 

% numerator : cof_succ = ori success rate from color failed trials 
% denominator : cof_succ_all = ori success rate from all trials  
cof_succ_all = length(cof_o(cof_o > conf_ct)) / trial_nb ; 
cof_succ = length(cof_failed_data(cof_failed_data(:, 2) > conf_ct)) / length(failed_ind) ; 

Conf_SI = cof_succ / cof_succ_all ; 
disp("(3) Confidence SI : " + Conf_SI) ;

% AUC of features 
disp("(4) AUC of Color : " + Cauc) ;
disp("(4) AUC of Ori : " + Oauc) ; 

%%% Save Results 
eval([newfolder + "_results.name = newfolder ;"]) ;
eval([newfolder + "_results.Configuration_Rate = Conf_Rate ;"]) ;
eval([newfolder + "_results.Confidence_SI = Conf_SI ;"]) ;
eval([newfolder + "_results.AUC = [Cauc, Oauc] ; "]) ;
saveas(auc_fig, "AUC of features") ; 
saveas(f, "Distribution of d") ; 
mat_name = [newfolder + "_results"] ; 
save(mat_name, mat_name) ; 

disp("분석 완료. 결과 데이터 저장됨") ; 
end
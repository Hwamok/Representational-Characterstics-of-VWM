%%%========   VFI All Results Analysis   ========%%%
clear all ; clc ; 
global start_dir result_dir sub_list filtered_sublist trial_nb lag_time

start_dir = which("SubjectList.txt") ;      
start_dir = start_dir(1:end-16) ; 
result_dir = [start_dir + "\Results_collection"] ;
cd(start_dir) ;

sub_list = readtable('SubjectList.txt') ; 
sub_list = transpose(sub_list.SubID) ; 
filtered_sublist = sub_list ;  

%% Step0. Hyper Parameter
global bin_nb Pm_crit model
bin_nb = 2 ; 
Pm_crit = 1 ; % If confidence > 1, Probe was memorized
trial_nb = 192 ; 
model = StandardMixtureModel ; 
lag_time = 2 ; 

E1 = 1 ; 
E2_1 = 1 ; 
E2_2 = 1 ; 
E3 = 1; 
E4 = 1 ;  

%% Step1. Subject filtering & General Statistics
disp("Step1. Subject filtering & General Statistics") ; 
GeneralStatistics = step1_Analysis(E1) ; 

%% Step2. Feature Independence 
% Crit_feature = "Color" or "Ori"
disp("Step2. Feature Independence") ;
global SIstat
SIstat = step2_Analysis(E2_1, "Color") ;
load(which('SIstat.mat')) ; 
SIstat = step2_Analysis(E2_2, "Ori") ;

%% Step3. Response Pattern
disp("Step3. Response Pattern") ;
RPstat = step3_Analysis(E3) ; 

%% Step4. Combine All of d & conf data from subjects
disp("Step4. All data of d & confidence for subjects") ;
alldata = step4_Analysis(E4) ; 

function GeneralStatistics = step1_Analysis(Execute)
global start_dir result_dir sub_list filtered_sublist trial_nb model Pm_crit

if Execute
    SubjectsStatistics_index = {"SubID", "Color AUC", "Ori AUC", "Color2 AUC", "Ori2 AUC", "Color Pm", "Color Pb", "Color sd", "Ori Pm", "Ori Pb", "Ori sd", ...
        "Color2 Pm", "Color2 Pb", "Color2 sd", "Ori2 Pm", "Ori2 Pb", "Ori2 sd"} ;
    SubjectsStatistics = cell([length(sub_list)+1, length(SubjectsStatistics_index)]) ;
    SubjectsStatistics(1, :) = SubjectsStatistics_index ; SubjectsStatistics(2 : end, 1) = transpose(sub_list) ;
    
    ConfStatistics_index = { "SubID", "Cauc C0",  "Cauc C1", "Cauc C2", "Cauc C3", "Oauc C0", "Oauc C1", "Oauc C2", "Oauc C3", ...
        "Cpm C0", "Cpm C1", "Cpm C2", "Cpm C3", "Cpb C0", "Cpb C1", "Cpb C2", "Cpb C3", "Csd C0" "Csd C1" "Csd C2" "Csd C3", ...
        "Opm C0", "Opm C1", "Opm C2", "Opm C3", "Opb C0", "Opb C1", "Opb C2", "Opb C3", "Osd C0", "Osd C1", "Osd C2", "Osd C3" } ;
    ConfStatistics = cell([length(sub_list)+1, length(ConfStatistics_index)]) ;
    ConfStatistics(1, :) = ConfStatistics_index ; ConfStatistics(2 : end, 1) = transpose(sub_list) ;
    
    Confsummary_index = {"SubID", "Color #C0", "Color #C1", "Color #C2", "Color #C3", ...
        "Ori #C0", "Ori #C1", "Ori #C2", "Ori #C3", "Color Memory Rate", "Ori Memory Rate"} ;
    Confsummary = cell([length(sub_list)+1, length(Confsummary_index)]) ; 
    Confsummary(1, :) = Confsummary_index ; Confsummary(2 : end, 1) = transpose(sub_list) ; 
    
    for ss = 1 : length(sub_list)
        
        subid = sub_list{ss} ;
        disp( num2str(ss) + ". " + subid + " 계산") ;
        mid_dir = [start_dir + "\" + subid] ;
        
        cd(mid_dir) ;
        
        file_name = [subid + ".xlsx"] ;
        excel = xlsread(file_name, "Sheet1") ;
        color_d = excel(:, 3) ;
        ori_d = excel(:, 4) ;
        cof_c = excel(:, 5) ;
        cof_o = excel(:, 6) ;
        nt_c1 = excel(:, 11) ; nt_c2 = excel(:, 12) ;
        nt_o1 = excel(:, 13) ; nt_o2 = excel(:, 14) ;
        color2_d = excel(:, 7) ; 
        ori2_d = excel(:, 8) ; 
        dist_c1 = excel(:, 15) ; dist_c2 = excel(:, 16) ; 
        dist_o1 = excel(:, 17) ; dist_o2 = excel(:, 18) ; 
        
        color_confset = [cof_c, color_d, nt_c1, nt_c2] ;
        ori_confset = [cof_o, ori_d, nt_o1, nt_o2] ;
        
        % # of each Confidence
        Cmemory_rate = sum(cof_c > Pm_crit) / 192 ; 
        Omemory_rate = sum(cof_o > Pm_crit) / 192 ; 
        Confsummary(ss+1, 2:5) = {sum(cof_c==0), sum(cof_c==1), sum(cof_c==2), sum(cof_c==3)} ; 
        Confsummary(ss+1, 6:9) = {sum(cof_o==0), sum(cof_o==1), sum(cof_o==2), sum(cof_o==3)} ;  
        Confsummary(ss+1, 10:11) = {Cmemory_rate, Omemory_rate} ;
        
        % AUC
        auc_c = mok_cdf(color_d) ;
        auc_o = mok_cdf(ori_d) ;
        close ;
        SubjectsStatistics(ss+1, 2:3) = {auc_c, auc_o} ;
        
        auc_c2 = mok_cdf(color2_d) ; 
        auc_o2 = mok_cdf(ori2_d) ; 
        close ; 
        SubjectsStatistics(ss+1, 4:5) = {auc_c2, auc_o2} ;
        
%         if (auc_c >= 0.5014) * (auc_o >= 0.5014) == 0
%             filtered_sublist(ss) = [] ;
%             disp(["** " + subid + " was filtered! "]) ;
%         end
        
        % Pm, Pb, sd
        C_data.errors = transpose(color_d) ;
        C_data.distractors = transpose([nt_c1, nt_c2]) ;
        O_data.errors = transpose(ori_d) ;
        O_data.distractors = transpose([nt_o1, nt_o2]) ;
        Color_fit = MLE(C_data, model) ;
        Ori_fit = MLE(O_data, model) ;
        
        C2_data.errors = transpose(color2_d) ; 
        C2_data.distractors = transpose([dist_c1, dist_c2]) ;
        O2_data.errors = transpose(ori2_d) ; 
        O2_data.distractors = transpose([dist_o1, dist_o2]) ;
        Color2_fit = MLE(C2_data, model) ; 
        Ori2_fit = MLE(O2_data, model) ; 
        
        Cauc4conf = {} ; Oauc4conf = {} ;
        for tt = 1 : 4
            C_inconf = color_confset(color_confset(:, 1) == tt-1, 2 : end) ;
            O_inconf = ori_confset(ori_confset(:, 1) == tt-1, 2 : end) ;
            
            % AUC
            Cauc_inconf = mok_cdf(C_inconf(:, 1)) ;
            Oauc_inconf = mok_cdf(O_inconf(:, 1)) ;
            Cauc4conf{tt} = Cauc_inconf ;
            Oauc4conf{tt} = Oauc_inconf ;
            close ;
            
            % Pm, Pg, sd
            Cconf.errors = transpose(C_inconf(:, 1)) ;
            Cconf.distractors = transpose(C_inconf(:, 2:3)) ;
            Oconf.errors = transpose(O_inconf(:, 1)) ;
            Oconf.distractors = transpose(O_inconf(:, 2:3)) ;
            
            if ~isempty(C_inconf)
                Cfit4conf = MLE(Cconf, model) ;
            else
                Cfit4conf = [nan nan nan] ;
            end
            if ~isempty(O_inconf)
                Ofit4conf = MLE(Oconf, model) ;
            else
                Ofit4conf = [nan nan nan] ;
            end
            
            if size(model.paramNames, 2) == 2
                ConfStatistics(ss+1, [10 14 18] + (tt-1)) = {1-Cfit4conf(1), nan, Cfit4conf(2) } ;
                ConfStatistics(ss+1, [22 26 30] + (tt-1)) = {1-Ofit4conf(1), nan, Ofit4conf(2) } ;
            else
                ConfStatistics(ss+1, [10 14 18] + (tt-1)) = {1-Cfit4conf(1), Cfit4conf(2), Cfit4conf(3) } ;
                ConfStatistics(ss+1, [22 26 30] + (tt-1)) = {1-Ofit4conf(1), Ofit4conf(2), Ofit4conf(3) } ;
            end
        end
        
        if size(model.paramNames, 2) == 2
            SubjectsStatistics(ss+1, 6:8) = {1-Color_fit(1), nan, Color_fit(2)} ;
            SubjectsStatistics(ss+1, 9:11) = {1-Ori_fit(1), nan, Ori_fit(2)} ;
            SubjectsStatistics(ss+1, 12:14) = {1-Color2_fit(1), nan, Color2_fit(2)} ; 
            SubjectsStatistics(ss+1, 15:17) = {1-Ori2_fit(1), nan, Ori2_fit(2)} ;
        else
            SubjectsStatistics(ss+1, 6:8) = {1-Color_fit(1), Color_fit(2), Color_fit(3)} ;
            SubjectsStatistics(ss+1, 9:11) = {1-Ori_fit(1), Ori_fit(2), Ori_fit(3)} ;
            SubjectsStatistics(ss+1, 12:14) = {1-Color2_fit(1), Color2_fit(2), Color2_fit(3)} ; 
            SubjectsStatistics(ss+1, 15:17) = {1-Ori2_fit(1), Ori2_fit(2), Ori2_fit(3)} ;
        end
        ConfStatistics(ss+1, 2:5) = Cauc4conf ;
        ConfStatistics(ss+1, 6:9) = Oauc4conf ;
        
    end
    
    cd(result_dir) ;
    GeneralStatistics.SubjectsStat = SubjectsStatistics ;
    GeneralStatistics.ConfStat = ConfStatistics ;
    GeneralStatistics.ConfSummary = Confsummary ; 
    save("Filtering_result\GeneralStatistics", "GeneralStatistics") ;
    
    xlsx_name = "Filtering_result\GeneralStatistics.xlsx" ;
    writecell(SubjectsStatistics, xlsx_name, 'Sheet', 'SubjectsStat', 'Range', 'A1') ;
    writecell(ConfStatistics, xlsx_name, 'Sheet', 'ConfStat', 'Range', 'A1') ;
    writecell(Confsummary, xlsx_name, 'Sheet', '#Conf', 'Range', 'A1') ; 
    disp("** Step1 저장 완료.") ;
    
    %txt_sublist = transpose([{'SubID'}, filtered_sublist]) ;
    %writecell(txt_sublist, "Filtering_result\Filtered_sublist.txt") ;
    
    cd(start_dir) ;
else
    GeneralStatistics = false ; 
end

end

function SIstat = step2_Analysis(Execute, crit_feature)
global start_dir result_dir sub_list filtered_sublist bin_nb Pm_crit trial_nb model SIstat
% crit_feature : 'Color - 1' or 'Ori - 2'
if strcmp(crit_feature, "Color") 
    crit_f = 1 ; 
elseif strcmp(crit_feature, "Ori") 
    crit_f = 2 ; 
end
disp( "feature 기준 : " + crit_feature ) ;

if Execute

    filtered_sublist = readtable('Filtered_sublist.txt') ;
    filtered_sublist = transpose(filtered_sublist.SubID) ;
    sub_nb = length(filtered_sublist) ;
    
    % (1) Subjects binnedAUC
    BinnedAUCs = cell([sub_nb, bin_nb]) ;
    % (2) Subjects binned_model Fits
    binned_fits = cell([sub_nb, bin_nb * 3]) ;
    % (3) Confidence SI
    ConfSIs = cell([sub_nb, 1]) ;
    ConfSIs_div = cell([sub_nb, 1]) ; 
    ConfAUCs = cell([sub_nb, 2]) ;
    
    for ss = 1 : length(filtered_sublist)
        
        subid = filtered_sublist{ss} ;
        disp( num2str(ss) + ". " + subid + " 계산") ;
        mid_dir = [start_dir + "\" + subid] ;
        
        cd(mid_dir) ;
        
        file_name = [subid + ".xlsx"] ;
        excel = xlsread(file_name, "Sheet1") ;
        color_d = excel(:, 3) ;
        ori_d = excel(:, 4) ;
        cof_c = excel(:, 5) ;
        cof_o = excel(:, 6) ;
        nt_c1 = excel(:, 11) ; nt_c2 = excel(:, 12) ;
        nt_o1 = excel(:, 13) ; nt_o2 = excel(:, 14) ;
        
        if crit_f == 1 % Color 기준으로 정렬
            dataset = [cof_c, abs(color_d), nt_c1, nt_c2, cof_o, ori_d, nt_o1, nt_o2] ; 
        elseif crit_f == 2 % Orientation 기준으로 정렬
            dataset = [cof_o, abs(ori_d), nt_o1, nt_o2, cof_c, color_d, nt_c1, nt_c2] ;
        end
        sortdata = sortrows(dataset, 2) ;
            
        binned_data = {} ;
        binlen = trial_nb / bin_nb ;
        start_pnt = 1 ;
        % Set Color binned data
        for bb = 1 : bin_nb
            binned_data{bb} = sortdata(start_pnt : start_pnt+binlen - 1, :) ;
            start_pnt = start_pnt + binlen ;
        end
        
        binned_AUC = [] ;
        % Calculate Results
        for bb = 1 : bin_nb
            % AUC
            binned_AUC(bb) = mok_cdf(binned_data{bb}(:, 6)) ;
            BinnedAUCs{ss, bb} = binned_AUC(bb) ; 
            close ;
            % model fitting
            binned_data4Swap.errors = transpose(binned_data{bb}(:, 6)) ;
            binned_data4Swap.distractors = transpose(binned_data{bb}(:, 7 : 8)) ;
            binned_fit = MLE(binned_data4Swap, model) ;
            if size(model.paramNames, 2) == 2
                binned_fits(ss, [1, 1+bin_nb, 1+2*bin_nb] + bb -1) = {1-binned_fit(1), nan, binned_fit(2)} ;
            else
                binned_fits(ss, [1, 1+bin_nb, 1+2*bin_nb] + bb -1) = {1-binned_fit(1), binned_fit(2), binned_fit(3)} ;
            end
        end
                
        % Confidence SI
        if crit_f == 1 
            cof_data = [cof_c, cof_o] ;
        elseif crit_f == 2 
            cof_data = [cof_o, cof_c] ; 
        end
        which_failed = find(cof_data(:, 1) <= Pm_crit) ;
        failed_data = cof_data(which_failed, :) ;
        % numerator : Pm_inFailed = ori's conf Pm at color failed trials
        % denominator : Pm_inAll = ori's conf Pm at all trials
        Pm_inFailed = length(failed_data(failed_data(:, 2) > Pm_crit)) / length(which_failed) ;
        Pm_inAll = length(cof_data(cof_data(:, 2) > Pm_crit)) / trial_nb ;
        ConfSIs_div{ss, 1} = Pm_inFailed / Pm_inAll ;
        ConfSIs{ss, 1} = Pm_inFailed ;

        % Confidence SI - AUC 
        which_nf = find(dataset(:, 1) > Pm_crit) ;
        which_f = find(dataset(:, 1) <= Pm_crit) ; 
        
        nf_data = dataset(which_nf, 6) ; 
        f_data = dataset(which_f, 6) ; 
        
        fAUC = mok_cdf(f_data) ; 
        nfAUC = mok_cdf(nf_data) ; 
        close ; 
        ConfAUCs(ss, :) = {nfAUC, fAUC} ; 
        

    end
    
    % Write Results in EXCEL files.
    BinnedAUCs_Index = {"SubID"} ;
    for ii = 1 : bin_nb 
        BinnedAUCs_Index(1+ii) = {["Bin" + num2str(ii)+ " AUC"]} ; 
    end
    BinnedAUCs = [transpose(filtered_sublist), BinnedAUCs] ;
    BinnedAUCs = vertcat(BinnedAUCs_Index, BinnedAUCs) ;
    eval(["SIstat." + crit_feature + "BinnedAUCs = BinnedAUCs ;"]) ; 
    
    binned_fits_Index = {"SubID"} ; 
    for ii = 1 : bin_nb
        binned_fits_Index(1+ii) = {["Bin" + num2str(ii)+ " Pm"]} ;
    end
    len = length(binned_fits_Index) ; 
    for ii = 1 : bin_nb
        binned_fits_Index(len+ii) = {["Bin" + num2str(ii)+ " Pb"]} ;
    end
    len = length(binned_fits_Index) ; 
    for ii = 1 : bin_nb
        binned_fits_Index(len+ii) = {["Bin" + num2str(ii)+ " sd"]} ;
    end
    binned_fits = [transpose(filtered_sublist), binned_fits] ;
    binned_fits = vertcat(binned_fits_Index, binned_fits) ;
    eval(["SIstat." + crit_feature + "BinnedFits = binned_fits ;"]) ; 
    
    ConfSIs_Index = {"SubID", "Confidence SI_Nodiv", "Confidence SI_div", "Conf_기억 AUC", "Conf_망각 AUC"} ;
    ConfSIs = [transpose(filtered_sublist), ConfSIs, ConfSIs_div, ConfAUCs] ;
    ConfSIs = vertcat(ConfSIs_Index, ConfSIs) ;
    eval(["SIstat." + crit_feature + "Confidence_SI = ConfSIs ; "]) ; 
    
    cd(result_dir) ;
    SIstat.Hyperparam = ["S" + num2str(sub_nb) + "B" + num2str(bin_nb) + "C" + num2str(Pm_crit)] ;
    save("Quantity_result\SIstat", "SIstat") ;
    model_name = string(model.name(1:4)) ; 
    xlsx_name = ["Quantity_result\SIstat.S" + num2str(sub_nb) + "B" + num2str(bin_nb) + "C" + num2str(Pm_crit) + ".xlsx"] ;
    writecell(BinnedAUCs, xlsx_name, 'Sheet', ["BinnedAUCs."+ crit_feature], 'Range', 'A1') ;
    writecell(binned_fits, xlsx_name, 'Sheet', ["Binned_fits." + crit_feature], 'Range', 'A1') ;
    writecell(ConfSIs, xlsx_name, 'Sheet', ["ConfSIs." + crit_feature], 'Range', 'A1') ;
    disp("** Step2 저장 완료.") ;
    
    cd(start_dir) ; 
else
    SIstat = false ; 
end

end

function RPstat = step3_Analysis(Execute)
global start_dir result_dir sub_list filtered_sublist bin_nb Pm_crit trial_nb model lag_time

if Execute
    filtered_sublist = readtable('Filtered_sublist.txt') ;
    filtered_sublist = transpose(filtered_sublist.SubID) ;
    sub_nb = length(filtered_sublist) ;
    
    RP_Results = cell([sub_nb, 2]) ;
    RP_Results_Index = {"SubID", "조율확률", "동시조작률"} ;
    
    CT_Results_Index = {"SubID", "#색상조율", "#방위조율", "#둘다조율",...
        "#색상조율 평균 색상cof", "#방위조율 평균 색상cof", "#둘다조율 평균 색상cof", ...
        "#색상조율 평균 방위cof", "#방위조율 평균 방위cof", "#둘다조율 평균 방위cof", ...
        "#색상조율 평균 색상d", "#방위조율 평균 색상d", "#둘다조율 평균 색상d", ...
        "#색상조율 평균 방위d", "#방위조율 평균 방위d", "#둘다조율 평균 방위d"} ;
    
    CT_Results_all_Index = {"SubID", "#모든조율", "모든조율 평균 색상cof", "모든조율 평균 방위cof", "모든조율 색상 AUC", "모든조율 방위 AUC"} ;
    
    conf_tags_sums = cell([sub_nb, 1]) ;
    conf_tags_nbs = cell([sub_nb, 3]) ;
    conf_tags_allcofcs = cell([sub_nb, 1]) ;
    conf_tags_cofcs = cell([sub_nb, 3]) ;
    conf_tags_allcofos = cell([sub_nb, 1]) ;
    conf_tags_cofos = cell([sub_nb, 3]) ;
    conf_tags_allcds = cell([sub_nb, 1]) ;
    conf_tags_cds = cell([sub_nb, 3]) ;
    conf_tags_allods = cell([sub_nb, 1]) ;
    conf_tags_ods = cell([sub_nb, 3]) ;
    
    for ss = 1 : length(filtered_sublist)
        
        subid = filtered_sublist{ss} ;
        disp( num2str(ss) + ". " + subid + " 계산") ;
        mid_dir = [start_dir + "\" + subid] ;
        
        cd(mid_dir) ;
        
        file_name = [subid + ".xlsx"] ;
        excel = xlsread(file_name, "Sheet1") ;
        color_d = excel(:, 3) ;
        ori_d = excel(:, 4) ;
        cof_c = excel(:, 5) ;
        cof_o = excel(:, 6) ;
        nt_c1 = excel(:, 11) ; nt_c2 = excel(:, 12) ;
        nt_o1 = excel(:, 13) ; nt_o2 = excel(:, 14) ;
        cof_data = [cof_c, cof_o] ;
        
        excel2 = xlsread(file_name, "Sheet2") ;
        color_ans = excel2(:, 2) ;
        ori_ans = excel2(:, 3) ;
        
        % distractor degree
        excel3 = xlsread(file_name, "Sheet3") ;
        dp1_c = excel3(:, 4) ;
        dp1_o = excel3(:, 5) ;
        dp2_c = excel3(:, 6) ;
        dp2_o = excel3(:, 7) ;
        
        % probe log record
        load([subid + "_log.mat"]) ;
        c_log = total_log.log_list1c ;
        o_log = total_log.log_list1o ;
        rt_log = total_log.log_time1 ;
        
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
            conf_logic = conf_list >= lag_time ; % 1.5 초 이상의 간격은 조율로 판단.
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
        confcof = [transpose(conf_tags), cof_data, color_d, ori_d] ;
        conf_data = confcof(find(confcof(:, 1) > 0), :) ;
        % data when configurated
        conf_tags_nb = cell([1, 3]) ;
        conf_tags_cofc = cell([1, 3]) ; conf_tags_cofo = cell([1, 3]) ;
        conf_tags_cd = cell([1, 3]) ; conf_tags_od = cell([1, 3]) ;
        for cc = 1 : 3
            target_conf = conf_data((conf_data(:, 1) == cc), :) ;
            conf_tags_nb(cc) = {numel(target_conf(:, 1))} ;
            conf_tags_cofc(cc) = {mean(target_conf(:, 2))} ;
            conf_tags_cofo(cc) = {mean(target_conf(:, 3))} ;
            conf_tags_cd(cc) = {mean(abs(target_conf(:, 4)))} ;
            conf_tags_od(cc) = {mean(abs(target_conf(:, 5)))} ;
        end
        
        conf_tags_nbs(ss, :) = conf_tags_nb ;
        conf_tags_cofcs(ss, :) = conf_tags_cofc ;
        conf_tags_cofos(ss, :) = conf_tags_cofo ;
        conf_tags_cds(ss, :) = conf_tags_cd ;
        conf_tags_ods(ss, :) = conf_tags_od ;
        
        conf_tags_sums(ss, :) = {length(conf_tags(conf_tags > 0))} ;
        conf_tags_allcofcs(ss, :) = {mean(conf_data(:, 2))} ;
        conf_tags_allcofos(ss, :) = {mean(conf_data(:, 3))} ;
        conf_tags_allcds(ss, :) = {mok_cdf(conf_data(:, 4))} ;
        conf_tags_allods(ss, :) = {mok_cdf(conf_data(:, 5))} ; close ; 
        
        % Configuration rate : Conf_Rate
        Conf_Rate = length(conf_tags(conf_tags > 0)) / trial_nb ;
        
        % Simultaneously recall rate : Sr_Rate
        Sr_Rate = mean((choice_list)) ;
        
        RP_Results(ss, :) = {Conf_Rate, Sr_Rate} ;
        
    end
    
    CT_Results = horzcat(transpose(filtered_sublist), conf_tags_nbs, conf_tags_cofcs, conf_tags_cofos, conf_tags_cds, conf_tags_ods) ;
    CT_Results_all = horzcat(transpose(filtered_sublist), conf_tags_sums, conf_tags_allcofcs, conf_tags_allcofos, conf_tags_allcds, conf_tags_allods) ;
    CT_Results = vertcat(CT_Results_Index, CT_Results) ;
    CT_Results_all = vertcat(CT_Results_all_Index, CT_Results_all) ;
    
    RP_Results = [transpose(filtered_sublist), RP_Results] ;
    RP_Results = vertcat(RP_Results_Index, RP_Results) ;
    
    RPstat.CTresults.all = CT_Results_all ; RPstat.CTresults.single = CT_Results ;
    RPstat.RPresults = RP_Results ;
    
    cd(result_dir) ;
    save("Log_result\RPstat", "RPstat") ;
    xlsx_name = ["Log_result\RPstatS" + num2str(sub_nb) + "B" + num2str(bin_nb) + "C" + num2str(Pm_crit) + ".xlsx"] ;
    writecell(RP_Results, xlsx_name, 'Sheet', 'RP_Results', 'Range', 'A1') ;
    writecell(CT_Results_all, xlsx_name, 'Sheet', 'CTresults.all', 'Range', 'A1') ;
    writecell(CT_Results, xlsx_name, 'Sheet', 'CTresults.single', 'Range', 'A1') ;
    disp("** Step3 저장 완료.") ;
    
    cd(start_dir) ;
else
    RPstat = false ; 
end
    
end

function alldata = step4_Analysis(Execute)
global start_dir result_dir sub_list filtered_sublist bin_nb Pm_crit trial_nb

if Execute
    filtered_sublist = readtable('Filtered_sublist.txt') ;
    filtered_sublist = transpose(filtered_sublist.SubID) ;
    sub_nb = length(filtered_sublist) ;
    
    alldata_Index = {"SubID", "Color d", "Ori d", "Conf C", "Conf O", "N-T C1", "N-T C2", "N-T O1", "N-T O2", "Color2_d", "Ori2_d"} ;
    alldata = cell([(sub_nb * trial_nb +1), length(alldata_Index)]) ;
    alldata(1, :) = alldata_Index ;
    start_pnt = 2 ;
    for ss = 1 : length(filtered_sublist)
        
        subid = filtered_sublist{ss} ;
        disp( num2str(ss) + ". " + subid + " 계산") ;
        mid_dir = [start_dir + "\" + subid] ;
        
        cd(mid_dir) ;
        
        file_name = [subid + ".xlsx"] ;
        excel = xlsread(file_name, "Sheet1") ;
        color_d = excel(:, 3) ;
        ori_d = excel(:, 4) ;
        cof_c = excel(:, 5) ;
        cof_o = excel(:, 6) ;
        nt_c1 = excel(:, 11) ; nt_c2 = excel(:, 12) ;
        nt_o1 = excel(:, 13) ; nt_o2 = excel(:, 14) ;
        Cnt_d = excel(:, 7) ; Ont_d = excel(:, 8) ; 
        trial_nb = length(color_d) ;
        
        data4scatterplot = [color_d, ori_d, cof_c, cof_o, nt_c1, nt_c2, nt_o1, nt_o2, Cnt_d, Ont_d] ;
        data4scatterplot = mat2cell_HM(data4scatterplot) ;
        sub_cell = cell([trial_nb,1]) ; sub_cell(:, :) = {subid} ;
        data4scatterplot = horzcat(sub_cell, data4scatterplot) ;
        alldata(start_pnt : start_pnt + trial_nb-1, : ) = data4scatterplot ;
        start_pnt = start_pnt + trial_nb ;
    end
    cd(result_dir) ;
    xlsx_name = ["D&C_alldata.xlsx"] ;
    writecell(alldata, xlsx_name, 'Sheet', 'AllData', 'Range', 'A1') ;
else
    alldata = false ; 
    
end

end

function cell_conv = mat2cell_HM(list)
    cell_conv = cell(size(list)) ; 
    for tt = 1 : size(list, 1)
        for ss = 1 : size(list, 2)
            cell_conv{tt, ss} = list(tt, ss) ; 
        end
    end
end
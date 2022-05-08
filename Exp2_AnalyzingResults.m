%%%========   VFI All Results Analysis   ========%%%
clear all ; clc ; 
global start_dir result_dir sub_list filtered_sublist trial_nb lag_time

start_dir = which("SubjectList2.txt") ;      
start_dir = start_dir(1:end-17) ; 
result_dir = [start_dir + "\Results_collection"] ;
cd(start_dir) ;

sub_list = readtable('SubjectList2.txt') ; 
sub_list = transpose(sub_list.SubID) ; 
filtered_sublist = sub_list ;  

%% Step0. Hyper Parameter
global bin_nb Pm_crit model
bin_nb = 2 ; 
Pm_crit = 1 ; % If confidence > 1, Probe was memorized
trial_nb = 240 ; 
model = StandardMixtureModel ; 
lag_time = 2 ; 

E1 = 1 ; 
E2_1 = 1 ; 
E2_2 = 1 ; 
E3 = 1 ; 
E4 = 1 ;  
E5 = 1 ; 

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

%% Step5. Confidence sd 
disp("Step5. Confidence sd") ;
Csd = step5_Analysis(E5) ; 

function GeneralStatistics = step1_Analysis(Execute)
global start_dir result_dir sub_list filtered_sublist trial_nb model Pm_crit

if Execute
    SubjectsStatistics_index = {"SubID", "Color AUC", "Ori AUC", "Color SS3AUC", "Ori SS3AUC", "Color SS5AUC", "Ori SS5AUC", ...
        "Color Pm", "Color Pb", "Color sd", "Ori Pm", "Ori Pb", "Ori sd", ...
        "Color SS3Pm", "Color SS3Pb", "Color SS3sd", "Ori SS3Pm", "Ori SS3Pb", "Ori SS3sd", ...
        "Color SS5Pm", "Color SS5Pb", "Color SS5sd", "Ori SS5Pm", "Ori SS5Pb", "Ori SS5sd"} ;
    SubjectsStatistics = cell([length(sub_list)+1, length(SubjectsStatistics_index)]) ;
    SubjectsStatistics(1, :) = SubjectsStatistics_index ; SubjectsStatistics(2 : end, 1) = transpose(sub_list) ;
    
    ConfStatistics_index = { "SubID", "Cauc C0",  "Cauc C1", "Cauc C2", "Cauc C3", "Oauc C0", "Oauc C1", "Oauc C2", "Oauc C3", ...
        "C3auc C0", "C3auc C1", "C3auc C2", "C3auc C3", "O3auc C0", "O3auc C1", "O3auc C2", "O3auc C3", ... 
        "C5auc C0", "C5auc C1", "C5auc C2", "C5auc C3", "O5auc C0", "O5auc C1", "O5auc C2", "O5auc C3" } ;
    ConfStatistics = cell([length(sub_list)+1, length(ConfStatistics_index)]) ;
    ConfStatistics(1, :) = ConfStatistics_index ; ConfStatistics(2 : end, 1) = transpose(sub_list) ;
    
    ConfStatistics3_index = { "SubID", "Cauc C0",  "Cauc C1", "Cauc C2", "Cauc C3", "Oauc C0", "Oauc C1", "Oauc C2", "Oauc C3", ...
        "Cpm C0", "Cpm C1", "Cpm C2", "Cpm C3", "Cpb C0", "Cpb C1", "Cpb C2", "Cpb C3", "Csd C0" "Csd C1" "Csd C2" "Csd C3", ...
        "Opm C0", "Opm C1", "Opm C2", "Opm C3", "Opb C0", "Opb C1", "Opb C2", "Opb C3", "Osd C0", "Osd C1", "Osd C2", "Osd C3" } ;
    ConfStatistics3 = cell([length(sub_list)+1, length(ConfStatistics3_index)]) ;
    ConfStatistics3(1, :) = ConfStatistics3_index ; ConfStatistics3(2 : end, 1) = transpose(sub_list) ;
    
    ConfStatistics5_index = { "SubID", "Cauc C0",  "Cauc C1", "Cauc C2", "Cauc C3", "Oauc C0", "Oauc C1", "Oauc C2", "Oauc C3", ...
        "Cpm C0", "Cpm C1", "Cpm C2", "Cpm C3", "Cpb C0", "Cpb C1", "Cpb C2", "Cpb C3", "Csd C0" "Csd C1" "Csd C2" "Csd C3", ...
        "Opm C0", "Opm C1", "Opm C2", "Opm C3", "Opb C0", "Opb C1", "Opb C2", "Opb C3", "Osd C0", "Osd C1", "Osd C2", "Osd C3" } ;
    ConfStatistics5 = cell([length(sub_list)+1, length(ConfStatistics5_index)]) ;
    ConfStatistics5(1, :) = ConfStatistics5_index ; ConfStatistics5(2 : end, 1) = transpose(sub_list) ;
    
    Confsummary_index = {"SubID", "Color #C0", "Color #C1", "Color #C2", "Color #C3", ...
        "Ori #C0", "Ori #C1", "Ori #C2", "Ori #C3", "Color Memory Rate", "Ori Memory Rate"} ;
    Confsummary = cell([length(sub_list)+1, length(Confsummary_index)]) ; 
    Confsummary(1, :) = Confsummary_index ; Confsummary(2 : end, 1) = transpose(sub_list) ; 
    
    Confsummary3_index = {"SubID", "Color #C0", "Color #C1", "Color #C2", "Color #C3", ...
        "Ori #C0", "Ori #C1", "Ori #C2", "Ori #C3", "Color Memory Rate", "Ori Memory Rate"} ;
    Confsummary3 = cell([length(sub_list)+1, length(Confsummary3_index)]) ; 
    Confsummary3(1, :) = Confsummary3_index ; Confsummary3(2 : end, 1) = transpose(sub_list) ; 
    
    Confsummary5_index = {"SubID", "Color #C0", "Color #C1", "Color #C2", "Color #C3", ...
        "Ori #C0", "Ori #C1", "Ori #C2", "Ori #C3", "Color Memory Rate", "Ori Memory Rate"} ;
    Confsummary5 = cell([length(sub_list)+1, length(Confsummary5_index)]) ; 
    Confsummary5(1, :) = Confsummary_index ; Confsummary5(2 : end, 1) = transpose(sub_list) ; 
    
    for ss = 1 : length(sub_list)
        
        subid = sub_list{ss} ;
        disp( num2str(ss) + ". " + subid + " 계산") ;
        mid_dir = [start_dir + "\" + subid] ;
        
        cd(mid_dir) ;
        
        file_name = [subid + ".xlsx"] ;
        excel = xlsread(file_name, "Sheet1") ;
        setsize = excel(:, 3) ; 
        color_d = excel(:, 4) ;
        ori_d = excel(:, 5) ;
        cof_c = excel(:, 6) ;
        cof_o = excel(:, 7) ;
        nt_c = excel(:, 9 : 12) ; 
        nt_o = excel(:, 13 : 16) ; 
        
        color_confset = [cof_c, color_d, nt_c] ;
        ori_confset = [cof_o, ori_d, nt_o] ;
        
        ind3 = setsize == 3 ;
        ind5 = setsize == 5 ; 
        
        % # of each Confidence
        Cmemory_rate = sum(cof_c > Pm_crit) / 240 ; 
        Omemory_rate = sum(cof_o > Pm_crit) / 240 ;
        for ll = 1 : 4
            Confsummary(ss+1, ll+1) = {sum(cof_c == ll-1)} ;
            Confsummary(ss+1, ll+5) = {sum(cof_o == ll-1)} ;
        end
        Confsummary(ss+1, 10:11) = {Cmemory_rate, Omemory_rate} ;
        
        Cmemory_rate3 = sum(cof_c(ind3) > Pm_crit) / 120 ; 
        Omemory_rate3 = sum(cof_o(ind3) > Pm_crit) / 120 ;
        for ll = 1 : 4
            Confsummary3(ss+1, ll+1) = {sum(cof_c(ind3) == ll-1)} ;
            Confsummary3(ss+1, ll+5) = {sum(cof_o(ind3) == ll-1)} ;
        end
        Confsummary3(ss+1, 10:11) = {Cmemory_rate3, Omemory_rate3} ;
        
        Cmemory_rate5 = sum(cof_c(ind5) > Pm_crit) / 120 ; 
        Omemory_rate5 = sum(cof_o(ind5) > Pm_crit) / 120 ;
        for ll = 1 : 4
            Confsummary5(ss+1, ll+1) = {sum(cof_c(ind5) == ll-1)} ;
            Confsummary5(ss+1, ll+5) = {sum(cof_o(ind5) == ll-1)} ;
        end
        Confsummary5(ss+1, 10:11) = {Cmemory_rate5, Omemory_rate5} ;
        
        % AUC
        auc_c = mok_cdf(color_d) ;
        auc_o = mok_cdf(ori_d) ;
        close ;
        SubjectsStatistics(ss+1, 2:3) = {auc_c, auc_o} ;
        
        auc_c3 = mok_cdf(color_d(ind3)) ; 
        auc_o3 = mok_cdf(ori_d(ind3)) ; 
        close ; 
        SubjectsStatistics(ss+1, 4:5) = {auc_c3, auc_o3} ;
        
        auc_c5 = mok_cdf(color_d(ind5)) ; 
        auc_o5 = mok_cdf(ori_d(ind5)) ; 
        close ; 
        SubjectsStatistics(ss+1, 6:7) = {auc_c5, auc_o5} ;
        
        % Pm, Pb, sd
        C_data.errors = transpose(color_d) ;
        C_data.distractors = transpose(nt_c) ;
        O_data.errors = transpose(ori_d) ;
        O_data.distractors = transpose(nt_o) ;
        
        C3_data.errors = transpose(color_d(ind3)) ;
        C3_data.distractors = transpose(nt_c(ind3)) ;
        O3_data.errors = transpose(ori_d(ind3)) ;
        O3_data.distractors = transpose(nt_o(ind3)) ;
        
        C5_data.errors = transpose(color_d(ind5)) ;
        C5_data.distractors = transpose(nt_c(ind5)) ;
        O5_data.errors = transpose(ori_d(ind5)) ;
        O5_data.distractors = transpose(nt_o(ind5)) ;
        
        Color_fit = MLE(C_data, model) ;
        Ori_fit = MLE(O_data, model) ;
        
        Color_fit3 = MLE(C3_data, model) ; 
        Ori_fit3 = MLE(O3_data, model) ; 
        
        Color_fit5 = MLE(C5_data, model) ; 
        Ori_fit5 = MLE(O5_data, model) ; 
        
        Cauc4conf = {} ; Oauc4conf = {} ; C3auc4conf = {} ; O3auc4conf = {} ; C5auc4conf = {} ; O5auc4conf = {} ; 
        c3_confset = color_confset(ind3, :) ; c5_confset = color_confset(ind5, :) ;
        o3_confset = ori_confset(ind3, :) ; o5_confset = ori_confset(ind5, :) ;
        for tt = 1 : 4
            C_inconf = color_confset(color_confset(:, 1) == tt-1, 2 : end) ;
            O_inconf = ori_confset(ori_confset(:, 1) == tt-1, 2 : end) ;
            
            C3_inconf = c3_confset(c3_confset(:, 1) == tt-1, 2 : end) ;
            O3_inconf = o3_confset(o3_confset(:, 1) == tt-1, 2 : end) ;
            
            C5_inconf = c5_confset(c5_confset(:, 1) == tt-1, 2 : end) ;
            O5_inconf = o5_confset(o5_confset(:, 1) == tt-1, 2 : end) ;
            
            % AUC
            Cauc_inconf = mok_cdf(C_inconf(:, 1)) ;
            Oauc_inconf = mok_cdf(O_inconf(:, 1)) ;
            Cauc4conf{tt} = Cauc_inconf ;
            Oauc4conf{tt} = Oauc_inconf ;
            close ;
            
            C3auc_inconf = mok_cdf(C3_inconf(:, 1)) ;
            O3auc_inconf = mok_cdf(O3_inconf(:, 1)) ;
            C3auc4conf{tt} = C3auc_inconf ;
            O3auc4conf{tt} = O3auc_inconf ;
            close ;
            
            C5auc_inconf = mok_cdf(C5_inconf(:, 1)) ;
            O5auc_inconf = mok_cdf(O5_inconf(:, 1)) ;
            C5auc4conf{tt} = C5auc_inconf ;
            O5auc4conf{tt} = O5auc_inconf ;
            close ;
            
        end
        
        if size(model.paramNames, 2) == 2
            SubjectsStatistics(ss+1, 8:10) = {1-Color_fit(1), nan, Color_fit(2)} ;
            SubjectsStatistics(ss+1, 11:13) = {1-Ori_fit(1), nan, Ori_fit(2)} ;
            SubjectsStatistics(ss+1, 14:16) = {1-Color_fit3(1), nan, Color_fit3(2)} ; 
            SubjectsStatistics(ss+1, 17:19) = {1-Ori_fit3(1), nan, Ori_fit3(2)} ;
            SubjectsStatistics(ss+1, 20:22) = {1-Color_fit5(1), nan, Color_fit5(2)} ;
            SubjectsStatistics(ss+1, 23:25) = {1-Ori_fit5(1), nan, Ori_fit5(2)} ;
        else
            SubjectsStatistics(ss+1, 8:10) = {1-Color_fit(1), Color_fit(2), Color_fit(3)} ;
            SubjectsStatistics(ss+1, 11:13) = {1-Ori_fit(1), Ori_fit(2), Ori_fit(3)} ;
            SubjectsStatistics(ss+1, 14:16) = {1-Color_fit3(1), Color_fit3(2), Color_fit3(3)} ; 
            SubjectsStatistics(ss+1, 17:19) = {1-Ori_fit3(1), Ori_fit3(2), Ori_fit3(3)} ;
            SubjectsStatistics(ss+1, 20:22) = {1-Color_fit5(1), Color_fit5(2), Color_fit5(3)} ;
            SubjectsStatistics(ss+1, 23:25) = {1-Ori_fit5(1), Ori_fit5(2), Ori_fit5(3)} ;
        end
        ConfStatistics(ss+1, 2:5) = Cauc4conf ;
        ConfStatistics(ss+1, 6:9) = Oauc4conf ;
        ConfStatistics(ss+1, 10:13) = C3auc4conf ;
        ConfStatistics(ss+1, 14:17) = O3auc4conf ;
        ConfStatistics(ss+1, 18:21) = C5auc4conf ;
        ConfStatistics(ss+1, 22:25) = O5auc4conf ;
        
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

    filtered_sublist = readtable('Filtered_sublist2.txt') ;
    filtered_sublist = transpose(filtered_sublist.SubID) ;
    sub_nb = length(filtered_sublist) ;
    
    % (1) Subjects binnedAUC
    BinnedAUCs = cell([sub_nb, bin_nb]) ;
    BinnedAUCs3 = cell([sub_nb, bin_nb]) ;
    BinnedAUCs5 = cell([sub_nb, bin_nb]) ;
    % (2) Subjects binned_model Fits
    binned_fits = cell([sub_nb, bin_nb * 3]) ;
    binned_fits3 = cell([sub_nb, bin_nb * 3]) ;
    binned_fits5 = cell([sub_nb, bin_nb * 3]) ;
    % (3) Confidence SI
    ConfSIs = cell([sub_nb, 1]) ;
    ConfSIs_div = cell([sub_nb, 1]) ;
    ConfSIs3 = cell([sub_nb, 1]) ;
    ConfSIs_div3 = cell([sub_nb, 1]) ;
    ConfSIs5 = cell([sub_nb, 1]) ;
    ConfSIs_div5 = cell([sub_nb, 1]) ;
    % (4) Confidence SI - AUC
    ConfAUCs = cell([sub_nb, 2]) ;
    ConfAUCs3 = cell([sub_nb, 2]) ;
    ConfAUCs5 = cell([sub_nb, 2]) ;
    
    for ss = 1 : length(filtered_sublist)
        
        subid = filtered_sublist{ss} ;
        disp( num2str(ss) + ". " + subid + " 계산") ;
        mid_dir = [start_dir + "\" + subid] ;
        
        cd(mid_dir) ;
        
        file_name = [subid + ".xlsx"] ;
        excel = xlsread(file_name, "Sheet1") ;
        color_d = excel(:, 4) ;
        ori_d = excel(:, 5) ;
        cof_c = excel(:, 6) ;
        cof_o = excel(:, 7) ;
        nt_c = excel(:, 9:12) ; nt_o = excel(:, 13:16) ; 
        setsize = excel(:, 3) ; 
        ind3 = setsize == 3 ; ind5 = setsize == 5 ; 
        
        if crit_f == 1 % Color 기준으로 정렬
            dataset = [cof_c, abs(color_d), nt_c, cof_o, ori_d, nt_o] ; 
        elseif crit_f == 2 % Orientation 기준으로 정렬
            dataset = [cof_o, abs(ori_d), nt_o, cof_c, color_d, nt_c] ;
        end
        data3 = dataset(ind3, :) ; data5 = dataset(ind5, :) ; 
        sortdata = sortrows(dataset, 2) ;
        sortdata3 = sortrows(data3, 2) ; sortdata5 = sortrows(data5, 2) ; 
            
        binned_data = {} ;
        binlen = trial_nb / bin_nb ;
        start_pnt = 1 ;
        % Set Color binned data
        for bb = 1 : bin_nb
            binned_data{bb} = sortdata(start_pnt : start_pnt+binlen - 1, :) ;
            start_pnt = start_pnt + binlen ;
        end
        
        binned_data3 = {} ;
        binlen = (trial_nb / 2) / bin_nb ;
        start_pnt = 1 ;
        % Set Color binned data
        for bb = 1 : bin_nb
            binned_data3{bb} = sortdata3(start_pnt : start_pnt+binlen - 1, :) ;
            start_pnt = start_pnt + binlen ;
        end
        
        binned_data5 = {} ;
        binlen = (trial_nb / 2) / bin_nb ;
        start_pnt = 1 ;
        % Set Color binned data
        for bb = 1 : bin_nb
            binned_data5{bb} = sortdata5(start_pnt : start_pnt+binlen - 1, :) ;
            start_pnt = start_pnt + binlen ;
        end
        
        binned_AUC = [] ; 
        binned_AUC3 = [] ; binned_AUC5 = [] ; 
        % Calculate Results
        for bb = 1 : bin_nb
            % AUC
            binned_AUC(bb) = mok_cdf(binned_data{bb}(:, 8)) ;
            BinnedAUCs{ss, bb} = binned_AUC(bb) ; 
            binned_AUC3(bb) = mok_cdf(binned_data3{bb}(:, 8)) ;
            BinnedAUCs3{ss, bb} = binned_AUC3(bb) ; 
            binned_AUC5(bb) = mok_cdf(binned_data5{bb}(:, 8)) ;
            BinnedAUCs5{ss, bb} = binned_AUC5(bb) ; 
            close ;
            
            % model fitting
            binned_data4Swap.errors = transpose(binned_data{bb}(:, 8)) ;
            binned_data4Swap.distractors = transpose(binned_data{bb}(:, 9 : 12)) ;
            binned_fit = MLE(binned_data4Swap, model) ;
            if size(model.paramNames, 2) == 2
                binned_fits(ss, [1, 1+bin_nb, 1+2*bin_nb] + bb -1) = {1-binned_fit(1), nan, binned_fit(2)} ;
            else
                binned_fits(ss, [1, 1+bin_nb, 1+2*bin_nb] + bb -1) = {1-binned_fit(1), binned_fit(2), binned_fit(3)} ;
            end
            
            binned_data4Swap.errors = transpose(binned_data3{bb}(:, 8)) ;
            binned_data4Swap.distractors = transpose(binned_data3{bb}(:, 9 : 12)) ;
            binned_fit = MLE(binned_data4Swap, model) ;
            if size(model.paramNames, 2) == 2
                binned_fits3(ss, [1, 1+bin_nb, 1+2*bin_nb] + bb -1) = {1-binned_fit(1), nan, binned_fit(2)} ;
            else
                binned_fits3(ss, [1, 1+bin_nb, 1+2*bin_nb] + bb -1) = {1-binned_fit(1), binned_fit(2), binned_fit(3)} ;
            end
            
            binned_data4Swap.errors = transpose(binned_data5{bb}(:, 8)) ;
            binned_data4Swap.distractors = transpose(binned_data5{bb}(:, 9 : 12)) ;
            binned_fit = MLE(binned_data4Swap, model) ;
            if size(model.paramNames, 2) == 2
                binned_fits5(ss, [1, 1+bin_nb, 1+2*bin_nb] + bb -1) = {1-binned_fit(1), nan, binned_fit(2)} ;
            else
                binned_fits5(ss, [1, 1+bin_nb, 1+2*bin_nb] + bb -1) = {1-binned_fit(1), binned_fit(2), binned_fit(3)} ;
            end
            
        end
                
        % Confidence SI
        if crit_f == 1 
            cof_data = [cof_c, cof_o] ;
        elseif crit_f == 2 
            cof_data = [cof_o, cof_c] ; 
        end
        cof_data3 = cof_data(ind3, :) ;
        cof_data5 = cof_data(ind5, :) ;
        
        which_failed = find(cof_data(:, 1) <= Pm_crit) ;
        failed_data = cof_data(which_failed, :) ;
        % numerator : Pm_inFailed = ori's conf Pm at color failed trials
        % denominator : Pm_inAll = ori's conf Pm at all trials
        Pm_inFailed = length(failed_data(failed_data(:, 2) > Pm_crit)) / length(which_failed) ;
        Pm_inAll = length(cof_data(cof_data(:, 2) > Pm_crit)) / trial_nb ;
        ConfSIs_div{ss, 1} = Pm_inFailed / Pm_inAll ;
        ConfSIs{ss, 1} = Pm_inFailed ;
        
        which_failed = find(cof_data3(:, 1) <= Pm_crit) ;
        failed_data = cof_data3(which_failed, :) ;
        % numerator : Pm_inFailed = ori's conf Pm at color failed trials
        % denominator : Pm_inAll = ori's conf Pm at all trials
        Pm_inFailed = length(failed_data(failed_data(:, 2) > Pm_crit)) / length(which_failed) ;
        Pm_inAll = length(cof_data3(cof_data3(:, 2) > Pm_crit)) / (trial_nb / 2) ;
        ConfSIs_div3{ss, 1} = Pm_inFailed / Pm_inAll ;
        ConfSIs3{ss, 1} = Pm_inFailed ;
        
        which_failed = find(cof_data5(:, 1) <= Pm_crit) ;
        failed_data = cof_data5(which_failed, :) ;
        % numerator : Pm_inFailed = ori's conf Pm at color failed trials
        % denominator : Pm_inAll = ori's conf Pm at all trials
        Pm_inFailed = length(failed_data(failed_data(:, 2) > Pm_crit)) / length(which_failed) ;
        Pm_inAll = length(cof_data5(cof_data5(:, 2) > Pm_crit)) / (trial_nb / 2) ;
        ConfSIs_div5{ss, 1} = Pm_inFailed / Pm_inAll ;
        ConfSIs5{ss, 1} = Pm_inFailed ;
        
        which_nf = find(dataset(:, 1) > Pm_crit) ;
        which_f = find(dataset(:, 1) <= Pm_crit) ; 
        
        nf_data = dataset(which_nf, 8) ; 
        f_data = dataset(which_f, 8) ; 
        
        fAUC = mok_cdf(f_data) ; 
        nfAUC = mok_cdf(nf_data) ; 
        close ; 
        ConfAUCs(ss, :) = {nfAUC, fAUC} ; 
        
        which_nf = find(data3(:, 1) > Pm_crit) ;
        which_f = find(data3(:, 1) <= Pm_crit) ; 
        
        nf_data = data3(which_nf, 8) ; 
        f_data = data3(which_f, 8) ; 
        
        fAUC = mok_cdf(f_data) ; 
        nfAUC = mok_cdf(nf_data) ; 
        close ; 
        ConfAUCs3(ss, :) = {nfAUC, fAUC} ; 
        
        
        which_nf = find(data5(:, 1) > Pm_crit) ;
        which_f = find(data5(:, 1) <= Pm_crit) ; 
        
        nf_data = data5(which_nf, 8) ; 
        f_data = data5(which_f, 8) ; 
        
        fAUC = mok_cdf(f_data) ; 
        nfAUC = mok_cdf(nf_data) ; 
        close ; 
        ConfAUCs5(ss, :) = {nfAUC, fAUC} ; 
        
    end
    
    % Write Results in EXCEL files.
    BinnedAUCs_Index = {"SubID"} ;
    for ii = 1 : bin_nb 
        BinnedAUCs_Index(1+ii) = {["Bin" + num2str(ii)+ " AUC"]} ; 
    end
    len = length(BinnedAUCs_Index) ; 
    for ii = 1 : bin_nb
        BinnedAUCs_Index(len+ii) = {["Bin" + num2str(ii)+ " AUC3"]} ;
    end
    len = length(BinnedAUCs_Index) ; 
    for ii = 1 : bin_nb
        BinnedAUCs_Index(len+ii) = {["Bin" + num2str(ii)+ " AUC5"]} ;
    end
    BinnedAUCs = [transpose(filtered_sublist), BinnedAUCs, BinnedAUCs3, BinnedAUCs5] ;
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
    len = length(binned_fits_Index) ;
    for ii = 1 : bin_nb
        binned_fits_Index(len+ii) = {["Bin" + num2str(ii)+ " Pm3"]} ;
    end
    len = length(binned_fits_Index) ; 
    for ii = 1 : bin_nb
        binned_fits_Index(len+ii) = {["Bin" + num2str(ii)+ " Pb3"]} ;
    end
    len = length(binned_fits_Index) ; 
    for ii = 1 : bin_nb
        binned_fits_Index(len+ii) = {["Bin" + num2str(ii)+ " sd3"]} ;
    end
    len = length(binned_fits_Index) ;
    for ii = 1 : bin_nb
        binned_fits_Index(len+ii) = {["Bin" + num2str(ii)+ " Pm5"]} ;
    end
    len = length(binned_fits_Index) ; 
    for ii = 1 : bin_nb
        binned_fits_Index(len+ii) = {["Bin" + num2str(ii)+ " Pb5"]} ;
    end
    len = length(binned_fits_Index) ; 
    for ii = 1 : bin_nb
        binned_fits_Index(len+ii) = {["Bin" + num2str(ii)+ " sd5"]} ;
    end
    
    binned_fits = [binned_fits, binned_fits3, binned_fits5] ;
    binned_fits = [transpose(filtered_sublist), binned_fits] ;
    binned_fits = vertcat(binned_fits_Index, binned_fits) ;
    eval(["SIstat." + crit_feature + "BinnedFits = binned_fits ;"]) ; 
    
    ConfSIs_Index = {"SubID", "Conf_SI_Nodiv", "Conf_SI_div", "Conf_SI_Nodiv3", "Conf_SI_div3", "Conf_SI_Nodiv5", "Conf_SI_div5", ...
        "Conf 기억AUC", "Conf 망각AUC", "Conf 기억AUC3", "Conf 망각AUC3", "Conf 기억AUC5", "Conf 망각AUC5"} ;
    ConfSIs = [transpose(filtered_sublist), ConfSIs, ConfSIs_div, ConfSIs3, ConfSIs_div3, ConfSIs5, ConfSIs_div5, ConfAUCs, ConfAUCs3, ConfAUCs5] ;
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
    filtered_sublist = readtable('Filtered_sublist2.txt') ;
    filtered_sublist = transpose(filtered_sublist.SubID) ;
    sub_nb = length(filtered_sublist) ;
    
    RP_Results_Index = {"SubID", "조율확률", "동시조작률", "조율확률ss3", "동시조작률ss3", "조율확률ss5", "동시조작률ss5"} ;
    RP_Results = cell([sub_nb, length(RP_Results_Index)-1]) ; 
    
    CT_Results_Index = {"SubID", "#색상조율", "#방위조율", "#둘다조율",...
        "#색상조율 평균 색상cof", "#방위조율 평균 색상cof", "#둘다조율 평균 색상cof", ...
        "#색상조율 평균 방위cof", "#방위조율 평균 방위cof", "#둘다조율 평균 방위cof", ...
        "#색상조율 평균 색상d", "#방위조율 평균 색상d", "#둘다조율 평균 색상d", ...
        "#색상조율 평균 방위d", "#방위조율 평균 방위d", "#둘다조율 평균 방위d"} ;
   
    CT_Results3_Index = {"SubID", "#색상조율", "#방위조율", "#둘다조율",...
        "#색상조율 평균 색상cof", "#방위조율 평균 색상cof", "#둘다조율 평균 색상cof", ...
        "#색상조율 평균 방위cof", "#방위조율 평균 방위cof", "#둘다조율 평균 방위cof", ...
        "#색상조율 평균 색상d", "#방위조율 평균 색상d", "#둘다조율 평균 색상d", ...
        "#색상조율 평균 방위d", "#방위조율 평균 방위d", "#둘다조율 평균 방위d"} ;
   
    CT_Results5_Index = {"SubID", "#색상조율", "#방위조율", "#둘다조율",...
        "#색상조율 평균 색상cof", "#방위조율 평균 색상cof", "#둘다조율 평균 색상cof", ...
        "#색상조율 평균 방위cof", "#방위조율 평균 방위cof", "#둘다조율 평균 방위cof", ...
        "#색상조율 평균 색상d", "#방위조율 평균 색상d", "#둘다조율 평균 색상d", ...
        "#색상조율 평균 방위d", "#방위조율 평균 방위d", "#둘다조율 평균 방위d"} ;
   
    CT_Results_all_Index = {"SubID", "#모든조율", "모든조율 평균 색상cof", "모든조율 평균 방위cof", "모든조율 색상 AUC", "모든조율 방위 AUC"} ;
    CT_Results_all3_Index = {"SubID", "#모든조율", "모든조율 평균 색상cof", "모든조율 평균 방위cof", "모든조율 색상 AUC", "모든조율 방위 AUC"} ;
    CT_Results_all5_Index = {"SubID", "#모든조율", "모든조율 평균 색상cof", "모든조율 평균 방위cof", "모든조율 색상 AUC", "모든조율 방위 AUC"} ;
    
    conf_tags_sums = cell([sub_nb, 1]) ; conf_tags_sums3 = cell([sub_nb, 1]) ; conf_tags_sums5 = cell([sub_nb, 1]) ;
    conf_tags_nbs = cell([sub_nb, 3]) ; conf_tags_nbs3 = cell([sub_nb, 3]) ; conf_tags_nbs5 = cell([sub_nb, 3]) ;
    conf_tags_allcofcs = cell([sub_nb, 1]) ; conf_tags_allcofcs3 = cell([sub_nb, 1]) ; conf_tags_allcofcs5 = cell([sub_nb, 1]) ;
    conf_tags_cofcs = cell([sub_nb, 3]) ; conf_tags_cofcs3 = cell([sub_nb, 3]) ; conf_tags_cofcs5 = cell([sub_nb, 3]) ;
    conf_tags_allcofos = cell([sub_nb, 1]) ; conf_tags_allcofos3 = cell([sub_nb, 1]) ; conf_tags_allcofos5 = cell([sub_nb, 1]) ;
    conf_tags_cofos = cell([sub_nb, 3]) ; conf_tags_cofos3 = cell([sub_nb, 3]) ; conf_tags_cofos5 = cell([sub_nb, 3]) ;
    conf_tags_allcds = cell([sub_nb, 1]) ; conf_tags_allcds3 = cell([sub_nb, 1]) ; conf_tags_allcds5 = cell([sub_nb, 1]) ;
    conf_tags_cds = cell([sub_nb, 3]) ; conf_tags_cds3 = cell([sub_nb, 3]) ; conf_tags_cds5 = cell([sub_nb, 3]) ;
    conf_tags_allods = cell([sub_nb, 1]) ; conf_tags_allods3 = cell([sub_nb, 1]) ; conf_tags_allods5 = cell([sub_nb, 1]) ;
    conf_tags_ods = cell([sub_nb, 3]) ; conf_tags_ods3 = cell([sub_nb, 3]) ; conf_tags_ods5 = cell([sub_nb, 3]) ;
    
    for ss = 1 : length(filtered_sublist)
        
        log_out = log_operation(ss, 0) ; 
        conf_tags_nbs(ss, :) = log_out.conf_tags_nb ;
        conf_tags_cofcs(ss, :) = log_out.conf_tags_cofc ;
        conf_tags_cofos(ss, :) = log_out.conf_tags_cofo ;
        conf_tags_cds(ss, :) = log_out.conf_tags_cd ;
        conf_tags_ods(ss, :) = log_out.conf_tags_od ;
        
        conf_tags_sums(ss, :) = {length(log_out.conf_tags(log_out.conf_tags > 0))} ;
        conf_tags_allcofcs(ss, :) = {mean(log_out.conf_data(:, 2))} ;
        conf_tags_allcofos(ss, :) = {mean(log_out.conf_data(:, 3))} ;
        conf_tags_allcds(ss, :) = {mok_cdf(log_out.conf_data(:, 4))} ;
        conf_tags_allods(ss, :) = {mok_cdf(log_out.conf_data(:, 5))} ; close ; 
        
        % Configuration rate : Conf_Rate
        Conf_Rate = length(log_out.conf_tags(log_out.conf_tags > 0)) / trial_nb ;
        
        % Simultaneously recall rate : Sr_Rate
        Sr_Rate = mean((log_out.choice_list)) ;
        
        RP_Results(ss, 1 : 2 ) = {Conf_Rate, Sr_Rate} ;
        
        % ss3 
        log_out = log_operation(ss, 3) ;
        conf_tags_nbs3(ss, :) = log_out.conf_tags_nb ;
        conf_tags_cofcs3(ss, :) = log_out.conf_tags_cofc ;
        conf_tags_cofos3(ss, :) = log_out.conf_tags_cofo ;
        conf_tags_cds3(ss, :) = log_out.conf_tags_cd ;
        conf_tags_ods3(ss, :) = log_out.conf_tags_od ;
        
        conf_tags_sums3(ss, :) = {length(log_out.conf_tags(log_out.conf_tags > 0))} ;
        conf_tags_allcofcs3(ss, :) = {mean(log_out.conf_data(:, 2))} ;
        conf_tags_allcofos3(ss, :) = {mean(log_out.conf_data(:, 3))} ;
        conf_tags_allcds3(ss, :) = {mok_cdf(log_out.conf_data(:, 4))} ;
        conf_tags_allods3(ss, :) = {mok_cdf(log_out.conf_data(:, 5))} ; close ;
        
        % Configuration rate : Conf_Rate
        Conf_Rate3 = length(log_out.conf_tags(log_out.conf_tags > 0)) / (trial_nb / 2) ;
        
        % Simultaneously recall rate : Sr_Rate
        Sr_Rate3 = mean((log_out.choice_list)) ;
        
        RP_Results(ss, 3 : 4) = {Conf_Rate3, Sr_Rate3} ;
        
        % ss5
        log_out = log_operation(ss, 5) ;
        conf_tags_nbs5(ss, :) = log_out.conf_tags_nb ;
        conf_tags_cofcs5(ss, :) = log_out.conf_tags_cofc ;
        conf_tags_cofos5(ss, :) = log_out.conf_tags_cofo ;
        conf_tags_cds5(ss, :) = log_out.conf_tags_cd ;
        conf_tags_ods5(ss, :) = log_out.conf_tags_od ;
        
        conf_tags_sums5(ss, :) = {length(log_out.conf_tags(log_out.conf_tags > 0))} ;
        conf_tags_allcofcs5(ss, :) = {mean(log_out.conf_data(:, 2))} ;
        conf_tags_allcofos5(ss, :) = {mean(log_out.conf_data(:, 3))} ;
        conf_tags_allcds5(ss, :) = {mok_cdf(log_out.conf_data(:, 4))} ;
        conf_tags_allods5(ss, :) = {mok_cdf(log_out.conf_data(:, 5))} ; close ;
        
        % Configuration rate : Conf_Rate
        Conf_Rate5 = length(log_out.conf_tags(log_out.conf_tags > 0)) / (trial_nb / 2) ;
        
        % Simultaneously recall rate : Sr_Rate
        Sr_Rate5 = mean((log_out.choice_list)) ;
        
        RP_Results(ss, 5 : 6) = {Conf_Rate5, Sr_Rate5} ;
        
    end
    
    CT_Results = horzcat(transpose(filtered_sublist), conf_tags_nbs, conf_tags_cofcs, conf_tags_cofos, conf_tags_cds, conf_tags_ods) ;
    CT_Results_all = horzcat(transpose(filtered_sublist), conf_tags_sums, conf_tags_allcofcs, conf_tags_allcofos, conf_tags_allcds, conf_tags_allods) ;
    CT_Results = vertcat(CT_Results_Index, CT_Results) ;
    CT_Results_all = vertcat(CT_Results_all_Index, CT_Results_all) ;
    
    CT_Results3 = horzcat(transpose(filtered_sublist), conf_tags_nbs3, conf_tags_cofcs3, conf_tags_cofos3, conf_tags_cds3, conf_tags_ods3) ;
    CT_Results_all3 = horzcat(transpose(filtered_sublist), conf_tags_sums3, conf_tags_allcofcs3, conf_tags_allcofos3, conf_tags_allcds3, conf_tags_allods3) ;
    CT_Results3 = vertcat(CT_Results3_Index, CT_Results3) ;
    CT_Results_all3 = vertcat(CT_Results_all3_Index, CT_Results_all3) ;
    
    CT_Results5 = horzcat(transpose(filtered_sublist), conf_tags_nbs5, conf_tags_cofcs5, conf_tags_cofos5, conf_tags_cds5, conf_tags_ods5) ;
    CT_Results_all5 = horzcat(transpose(filtered_sublist), conf_tags_sums5, conf_tags_allcofcs5, conf_tags_allcofos5, conf_tags_allcds5, conf_tags_allods5) ;
    CT_Results5 = vertcat(CT_Results5_Index, CT_Results5) ;
    CT_Results_all5 = vertcat(CT_Results_all5_Index, CT_Results_all5) ;
    
    RP_Results = [transpose(filtered_sublist), RP_Results] ;
    RP_Results = vertcat(RP_Results_Index, RP_Results) ;
    
    RPstat.CTresults.all = CT_Results_all ; RPstat.CTresults.single = CT_Results ;
    RPstat.CTresults3.all = CT_Results_all3 ; RPstat.CTresults3.single = CT_Results3 ;
    RPstat.CTresults5.all = CT_Results_all5 ; RPstat.CTresults5.single = CT_Results5 ;
    RPstat.RPresults = RP_Results ;
    
    cd(result_dir) ;
    save("Log_result\RPstat", "RPstat") ;
    xlsx_name = ["Log_result\RPstatS" + num2str(sub_nb) + "B" + num2str(bin_nb) + "C" + num2str(Pm_crit) + ".xlsx"] ;
    writecell(RP_Results, xlsx_name, 'Sheet', 'RP_Results', 'Range', 'A1') ;
    writecell(CT_Results_all, xlsx_name, 'Sheet', 'CTresults.all', 'Range', 'A1') ;
    writecell(CT_Results, xlsx_name, 'Sheet', 'CTresults.single', 'Range', 'A1') ;
    writecell(CT_Results_all3, xlsx_name, 'Sheet', 'CTresults3.all', 'Range', 'A1') ;
    writecell(CT_Results3, xlsx_name, 'Sheet', 'CTresults3.single', 'Range', 'A1') ;
    writecell(CT_Results_all5, xlsx_name, 'Sheet', 'CTresults5.all', 'Range', 'A1') ;
    writecell(CT_Results5, xlsx_name, 'Sheet', 'CTresults5.single', 'Range', 'A1') ;
    
    disp("** Step3 저장 완료.") ;
    
    cd(start_dir) ;
else
    RPstat = false ; 
end
    
end

function alldata = step4_Analysis(Execute)
global start_dir result_dir sub_list filtered_sublist bin_nb Pm_crit trial_nb

if Execute
    filtered_sublist = readtable('Filtered_sublist2.txt') ;
    filtered_sublist = transpose(filtered_sublist.SubID) ;
    sub_nb = length(filtered_sublist) ;
    
    alldata_Index = {"SubID", "setsize", "Color d", "Ori d", "Conf C", "Conf O", "N-T C1", "N-T C2", "N-T C3", "N-T C4", ...
        "N-T O1", "N-T O2", "N-T O3", "N-T O4"} ;
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
        color_d = excel(:, 4) ;
        ori_d = excel(:, 5) ;
        cof_c = excel(:, 6) ;
        cof_o = excel(:, 7) ;
        nt_c = excel(:, 9:12) ; nt_o = excel(:, 13:16) ; 
        setsize = excel(:, 3) ; 
        
        trial_nb = length(color_d) ;
        
        data4scatterplot = [setsize, color_d, ori_d, cof_c, cof_o, nt_c, nt_o] ;
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

function log_out = log_operation(ss, sscond)
global start_dir filtered_sublist lag_time

subid = filtered_sublist{ss} ;
disp( num2str(ss) + ". " + subid + " 계산") ;
mid_dir = [start_dir + "\" + subid] ;

cd(mid_dir) ;

file_name = [subid + ".xlsx"] ;
excel = xlsread(file_name, "Sheet1") ;
color_d = excel(:, 4) ;
ori_d = excel(:, 5) ;
cof_c = excel(:, 6) ;
cof_o = excel(:, 7) ;
nt_c = excel(:, 9 : 12) ;
nt_o = excel(:, 13 : 16) ;
cof_data = [cof_c, cof_o] ;
setsize = excel(:, 3) ; 
if sscond == 3 | sscond == 5
    ind = setsize == sscond ; 
else
    ind = logical(ones([240, 1])) ; 
end

excel2 = xlsread(file_name, "Sheet2") ;
color_ans = excel2(:, 2) ;
ori_ans = excel2(:, 3) ;

% distractor degree
excel3 = xlsread(file_name, "Sheet3") ;
dp_c = excel3(:, 4 : 7) ;
dp_o = excel3(:, 8 : 11) ;

% probe log record
load([subid + "_log.mat"]) ;
c_log = total_log.log_c(:, transpose(ind)) ;
o_log = total_log.log_o(:, transpose(ind)) ;
rt_log = total_log.log_time(:, transpose(ind)) ;

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
confcof = [transpose(conf_tags), cof_data(ind, :), color_d(ind, :), ori_d(ind, :)] ;
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

log_out.conf_tags = conf_tags ; 
log_out.conf_tags_nb = conf_tags_nb ;
log_out.conf_tags_cofc = conf_tags_cofc ; 
log_out.conf_tags_cofo = conf_tags_cofo ; 
log_out.conf_tags_cd = conf_tags_cd ; 
log_out.conf_tags_od = conf_tags_od ; 
log_out.conf_data = conf_data ; 
log_out.choice_list = choice_list ; 

end

function CSDstat = step5_Analysis(Execute)
global start_dir result_dir sub_list filtered_sublist bin_nb Pm_crit trial_nb

if Execute 
    
    filtered_sublist = readtable('Filtered_sublist2.txt') ;
    filtered_sublist = transpose(filtered_sublist.SubID) ;
    sub_nb = length(filtered_sublist) ;
    
    CSD_results = cell([sub_nb, 12]) ;
    for ss = 1 : length(filtered_sublist)
        
        subid = filtered_sublist{ss} ; 
        disp( num2str(ss) + ". " + subid + " 계산") ;
        mid_dir = [start_dir + "\" + subid] ;
        
        cd(mid_dir) ;
        file_name = [subid + ".xlsx"] ;
        excel = xlsread(file_name, "Sheet1") ;
        color_d = excel(:, 4) ; 
        ori_d = excel(:, 5) ; 
        cof_c = excel(:, 6) ;
        cof_o = excel(:, 7) ; 
        setsize = excel(:, 3) ; 
        
        c_data = [cof_c, color_d] ;
        o_data = [cof_o, ori_d] ; 
        
        Caucs = cell([1, 2]) ; 
        Oaucs = cell([1, 2]) ;
        Csds = cell([1, 2]) ;
        Osds = cell([1, 2]) ;
        Cpms = cell([1, 2]) ;
        Opms = cell([1, 2]) ;
        
        size_l = [3 5] ; 
        for ii = 1 : 2 
            size = size_l(ii) ; 
            ind = setsize == size ; 
            c_set = c_data(ind, :) ; 
            o_set = o_data(ind, :) ; 
            
            ind_Cpm = c_set(:, 1) > Pm_crit ; 
            ind_Opm = o_set(:, 1) > Pm_crit ; 
            Cpm = mean(ind_Cpm) ; 
            Opm = mean(ind_Opm) ; 
            
            CM_set = c_set(ind_Cpm, :) ; 
            OM_set = o_set(ind_Opm, :) ; 
            
            CM_auc = mok_cdf(CM_set(:, 2)) ;
            OM_auc = mok_cdf(OM_set(:, 2)) ;
            close ; 
%             CM_sd = std(CM_set(:, 2)) ; 
%             OM_sd = std(OM_set(:, 2)) ;
            
            CM_sd = std(abs(CM_set(:, 2))) ;
            OM_sd = std(abs(OM_set(:, 2))) ;

            Cpms{ii} = Cpm ; 
            Opms{ii} = Opm ; 
            Caucs{ii} = CM_auc ; 
            Oaucs{ii} = OM_auc ; 
            Csds{ii} = CM_sd ; 
            Osds{ii} = OM_sd ;     
        end
        CSD_results(ss, :) = [Cpms, Opms, Caucs, Oaucs, Csds, Osds] ; 
    end
    CSD_index = {"Subid", "C3pm", "C5pm", "O3pm", "O5pm",...
        "C3auc", "C5auc", "O3auc", "O5auc", ...
        "C3sd", "C5sd", "O3sd", "O5sd"} ;
    CSD_results = horzcat(transpose(sub_list), CSD_results) ; 
    CSD_results = vertcat(CSD_index, CSD_results) ; 
    CSDstat.CSD_results = CSD_results ; 
    
    cd(result_dir) ; 
    save("Quantity_result\CSDstat", "CSDstat") ; 
    xlsx_name = ["Quantity_result\CSDstat.S" + num2str(sub_nb) + "B" + num2str(bin_nb) + "C" + num2str(Pm_crit) + ".xlsx"] ;
    writecell(CSD_results, xlsx_name, 'Sheet', "CofSD", 'Range', 'A1') ;
    disp("** Step5 저장 완료.") ; 
    
    cd(start_dir) ; 
else
    CSDstat = false ; 
end
end
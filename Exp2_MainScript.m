%%% Hwamok's VFI research Experiment 2
  
clear all ; clc ;   
    
exp_folder = which('VFI_EXP2.m') ;       
exp_folder = exp_folder(1:end-11 ) ;        
cd(exp_folder) ;      
Screen('Preference', 'SkipSyncTests', 0) ;         
 
global dist probe_dur mask_dur blank_dur trial_nb  
global log_c log_o log_time   
 
% Main parameter of details  
probe_dur = 0.5 ; % origin was 1.2sec   
mask_dur = 0.2 ;  
blank_dur = 0.8 ; % 0.8 
trial_nb = 240 ;  

dist = 150 ; % distance from base_posX / base_posY origin 120
 
%% _________________________________________________________________________
try
    %% Step 1 : Screen & other basic setting 
    [exp_info, window] = prepare_psych_screen ; % Basic Setting
    window.mask = imread('poly_mask_small.png') ; 
    load('cbar_collection.mat') ; 
    window.cbar_collection = cbar_collection ; 
    
     %% writing excel
    if strcmp(exp_info.exp_type, 'practice')
        file_name = strcat('subject_backup2\prac_', exp_info.subject_name, '.xlsx') ;
        mat_name = ['subject_backup2\prac_', exp_info.subject_name] ;
    elseif strcmp(exp_info.exp_type, 'experiment')
        file_name = strcat('subject_backup2\', exp_info.subject_name, '.xlsx') ;
        mat_name = ['subject_backup2\', exp_info.subject_name] ;
    end
    %% 비정상 종료 후 불러오기 
    mat_file = [mat_name, '.mat'] ; 
    try
        load_history = importdata(file_name).data.Sheet1 ;
        load(mat_file) ;
        load([mat_name, '_log.mat']) ;
        ispaused = 1 ; 
        log_c = total_log.log_c ; 
        log_o = total_log.log_o ; 
        log_time = total_log.log_time ; 
        
    catch 
        load_history = NaN ;
        ispaused = 0 ; 
    end
    if ispaused ~= 1
        %% Step 2 : Total Exp conditions setting
        [total_cond, total_log] = cond_setting(exp_info, window) ;
    end
    
    save(mat_name, 'total_cond') ;
    save([mat_name + "_log"], 'total_log') ; 
    
    % 결과 출력물 sheet 1 총 10열
    excel_index1 = {"block", "시행", "SS", "color d", "ori d", "confidence_c", "confidence_o", "   rt1   ", ...
        "nt_c1 d", "nt_c2 d", "nt_c3 d", "nt_c4 d", "nt_o1 d", "nt_o2 d", "nt_o3 d", "nt_o4 d"} ;
    
    % 결과 출력물 sheet 2 총 9열
    excel_index2 = {"시행", "color ans", "ori ans", "color 선택", "ori 선택", ...
        "cbar_start(top)1", "ori_start1"} ;
    %  결과 출력물 sheet 3 총 7열
    excel_index3 = {'시행', 'probe_color', 'probe_ori', '2_color', '3_color', ...
        '4_color', '5_color', '2_ori', '3_ori', '4_ori', '5_ori'} ;
    
    writecell(excel_index1, file_name, 'Sheet', 1, 'Range', 'A1') ;
    writecell(excel_index2, file_name, 'Sheet', 2, 'Range', 'A1') ;
    writecell(excel_index3, file_name, 'Sheet', 3, 'Range', 'A1') ;
    
    
    %% Step 3 : Exp start.
    % Instruction 
    inst_img = imread('inst.jpg') ; 
    inst_texture = Screen('MakeTexture', window.onScreen, inst_img) ;
    img_rect = [480, 242, 1440, 838] ; 
    
    HideCursor ; 
    while true % until spacebar
        Screen('DrawTexture', window.onScreen, inst_texture, [], img_rect) ; 
        Screen('Flip', window.onScreen) ; 
        
        outforpress = pressforskip(exp_info) ; 
        if outforpress
            break 
        end
        
    end
    
    block_criterion = ( [0 1 2 3] * total_cond.trials_nb/4) + 1 ;
    mid_break_criterion = ( [1 3 5 7] * total_cond.trials_nb/8) +1 ;
    
    % start trials
    if ispaused == 1
        start_t = load_history(end, 2) +1 ;
        block = floor((start_t-1)/60) + 1
        disp("!! 시행 " + start_t + "에서 다시 시작 !!" ) ;
    elseif ispaused == 0
        start_t = 1 ;
        block = 0 ;
    end
    
    for trial = start_t : total_cond.trials_nb % trial start
        
        if strcmp(exp_info.exp_type, "experiment")
            if block_criterion(block_criterion == trial)
                block = block + 1 ;
                if block > 1
                    show_break('60', img_rect, window, exp_info) ;
                end
                show_Basic('ready', 1, window, total_cond, trial) ;
            end
            if mid_break_criterion(mid_break_criterion == trial)
                show_break('30', img_rect, window, exp_info) ;
                show_Basic('ready', 1, window, total_cond, trial) ;
            end
            
        elseif strcmp(exp_info.exp_type, "practice")
            if trial == 1
                show_Basic('ready', 1, window, total_cond, trial) ;
            end
        end
        
        % Assigning trial condition variable __________________
        p_color = total_cond.color_cond(trial, 1) ;
        p_ori = total_cond.ori_cond(trial, 1) ;
        p_rgb = total_cond.rgb_cond{trial, 1} ;
        p_pos = total_cond.pos_cond{trial, 1} ;

        total_cond.debug_stim{trial} = {[p_rgb, p_ori]} ;
        
        %_____________________________________________
        % Start showing stims
        SoundDemo(.15, 440) ; 
        show_Basic('fixation', 0.5, window, total_cond, trial) ;
        show_Basic('blank', 0.5, window, total_cond, trial) ; 
        
        % Show memory items 
        for i = 1 : total_cond.setsize(trial)
             making_stim(total_cond.rgb_cond{trial, i}, total_cond.ori_cond(trial, i), ...
                total_cond.pos_cond{trial, i}, window) ;
        end
        Screen('Flip', window.onScreen) ;
        WaitSecs(probe_dur) ;
        
        % =>> Masking
        show_noise_masking(mask_dur, trial, total_cond, window) ;
        show_Basic("blank", blank_dur, window, total_cond, trial) ;
         
        % Recall Task
        SoundDemo(.15, 300) ;
        [trial_resp1, nt_out_d1] = execute_task(1, trial, total_cond, window, exp_info) ;
        
         % organize task responses
        %_______________________________________________________________________
        d_color1 = trial_resp1{1}{1} ; d_ori1 = trial_resp1{1}{2} ;  
        total_cond.d_index{trial} = {d_color1, d_ori1} ; 
        rt1 = trial_resp1{2} ;
        
        choiced_color1 = trial_resp1{3}{1} ; choiced_ori1 = trial_resp1{3}{2} ;
        %________________________________________________________________________
        show_Basic('blank', 0.5, window, total_cond, trial) ; 
        
        % confidence rating 
        total_cond.confidence_c(trial) = confidence_rate(window, 1, exp_info) ;  
        total_cond.confidence_o(trial) = confidence_rate(window, 2, exp_info) ;  
        WaitSecs(0.3) ; 
        
        % feedback 
        choiced_value = [choiced_color1, choiced_ori1] ; 
        show_feedback(window, total_cond.debug_stim{trial}, choiced_value, exp_info, total_cond, trial) ; 
        
        % 결과 출력물 sheet 1 총 305행 20열
        if length(nt_out_d1) == 4
            nt_out_d1 = {nt_out_d1{1}, nt_out_d1{2}, nan, nan, nt_out_d1{3}, nt_out_d1{4}} ;
        end
        result_collection1 = [ {block, trial, total_cond.setsize(trial), ...
            d_color1, d_ori1, total_cond.confidence_c(trial), total_cond.confidence_o(trial), rt1}, ...
            nt_out_d1 ] ;
        
        % 결과 출력물 sheet 2 총 305행 11열
        result_collection2 = {trial, ...
            p_color, p_ori, ...
            choiced_color1, choiced_ori1, total_cond.top_color{trial}, ...
            total_cond.top_ori{trial}} ;
        
        % 결과 출력물 sheet3 총 305행 12열
        indexC = {} ; indexO = {} ; 
        for ii = 2 : total_cond.setsize(trial)
            indexC{ii-1} = total_cond.color_cond(trial, ii) ;
            indexO{ii-1} = total_cond.ori_cond(trial, ii) ;
        end
        indexCO = [indexC, indexO] ;
        if total_cond.setsize(trial) == 3
            indexCO = [indexC, nan, nan, indexO] ;
        end
        result_collection3 = [{trial, p_color, p_ori}, ...
            indexCO] ;
        
        writecell(result_collection1, file_name, 'Sheet', 1, 'Range', strcat('A', num2str(trial+1))) ;
        writecell(result_collection2, file_name, 'Sheet', 2, 'Range', strcat('A', num2str(trial+1))) ;
        writecell(result_collection3, file_name, 'Sheet', 3, 'Range', strcat('A', num2str(trial+1))) ;
        
    end
    total_log.log_c = log_c ; 
    total_log.log_o = log_o ; 
    total_log.log_time = log_time ; 
    save([mat_name, '_log'], 'total_log') ;
    save(mat_name, 'total_cond') ;
    
catch
    total_log.log_c = log_c ;
    total_log.log_o = log_o ;
    total_log.log_time = log_time ;
    save([mat_name, '_log'], 'total_log') ;
    save(mat_name, 'total_cond') ;
    
    Screen('CloseAll') ;
    disp("비정상 종료") ; 
    psychrethrow(psychlasterror) ;
    
    
end
Screen('CloseAll') ; 
disp('정상 종료') ;

%%______실험 종료 후 결과 데이터 처리____________%% 
if ~strcmp(file_name(17:20 ), 'prac')
    
    disp("실험 종료.  결과 데이터 처리 중....") ;
    Get_FI(file_name, total_log, 2) ; 

end
disp("%%%_______모두 종료________%%%") ; 

function [exp_info, window] = prepare_psych_screen
%commandwindow ; % Select the command window to avoid typing in open scripts

% Seed the random number generator.
RandStream.setGlobalStream(RandStream('mt19937ar', 'seed', sum(100*clock))) ;
exp_info = Input_info ; 

%______________ open Window ____________________________________________
window.screenNumber = max(Screen('Screens')) ;
%window_rect = [0 0 1920 1080] ; 
window_rect = [] ;
window.onScreen = Screen('OpenWindow', window.screenNumber, [128 128 128], window_rect) ;
Screen('BlendFunction', window.onScreen, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA') ;
[window.screenX, window.screenY] = Screen('WindowSize', window.onScreen) ; % check resolution
window.screenRect  = [0, 0, window.screenX, window.screenY] ; % screen rect
window.centerX = window.screenX * 0.5 ; % center of screen in X direction
window.centerY = window.screenY * 0.5; % center of screen in Y direction
window.centerXL = floor(mean([0, window.centerX])) ; % center of left half of screen in X direction
window.centerXR = floor(mean([window.centerX, window.screenX])) ; % center of right half of screen in X direction
window.ifi = Screen('GetFlipInterval', window.onScreen) ;
window.vbl = Screen('Flip', window.onScreen);
window.waitframes = 1;

% Basic drawing and screen variables.
window.black    = BlackIndex(window.onScreen) ;
window.white    = WhiteIndex(window.onScreen) ;
window.gray     = mean([window.black window.white]) ;
window.bcolor   = window.gray ;

% Others 
KbName('UnifyKeyNames') ; % key setting

% Prepare func 
GetSecs ;
WaitSecs(.01) ;
SoundDemo(1,0) ;

Screen('TextStyle', window.onScreen, 1) ;
Screen('TextSize', window.onScreen, 30) ;
Screen('TextFont', window.onScreen, 'Helvetica') ;

end

function exp_info = Input_info
% output : (1) subject_name (2) exp_type

prompt_str = {'Subject ID', 'Order', 'Screen Width(cm)', 'Viewing Distance(cm)' } ;
init_str={'test','1 : AB, 2 : BA', '52.1', '60'} ;
exp_title = "Foretting_colorwheel" ;
NumLines = 1 ;
init_result = inputdlg( prompt_str, exp_title, NumLines, init_str ) ;

exp_info.subject_name = init_result{1,1} ;
exp_info.B_order = str2num(init_result{2,1}) ; 
screen_width = str2num(init_result{3,1}) ;
viewDistance = str2num(init_result{4,1}) ;

% Define task condition by dialog pop-up
exp_info.exp_type = questdlg('실험시작', 'exp_type', 'practice', 'experiment', 'experiment') ;

end


% Show Basic
function show_Basic(basic_type, dur, window, total_cond, t) 

if strcmp(basic_type, "fixation") 
    verbal_suppression_text = total_cond.verbal_suppression{t} ; 
    Screen('DrawText', window.onScreen, [verbal_suppression_text], window.centerX - 50, window.centerY - 50) ;
    Screen('DrawDots', window.onScreen, [window.centerX, window.centerY], 30, [0 0 0], [], 2) ;

elseif strcmp(basic_type, 'ready')
    
    Screen('DrawText', window.onScreen, ['Ready'], window.centerX-50, window.centerY-50) ;
    Screen('DrawDots', window.onScreen, [window.centerX, window.centerY], 20, [0 0 0], [], 2) ;
    SoundDemo(.5, 330) ;
    Screen('Flip', window.onScreen) ; WaitSecs(1) ; 
    
    Screen('Flip', window.onScreen) ; WaitSecs(0.1) ; 
    
    Screen('DrawText', window.onScreen, ['Set'], window.centerX-50, window.centerY-50) ;
    Screen('DrawDots', window.onScreen, [window.centerX, window.centerY], 20, [0 0 0], [], 2) ;
    SoundDemo(.5, 330) ;
    Screen('Flip', window.onScreen) ; WaitSecs(1) ; 
    
    Screen('Flip', window.onScreen) ; WaitSecs(0.1) ;
    
    Screen('DrawText', window.onScreen, ['Go !'], window.centerX-50, window.centerY-50) ;
    Screen('DrawDots', window.onScreen, [window.centerX, window.centerY], 20, [0 0 0], [], 2) ;
    SoundDemo(.5, 659) ;
    Screen('Flip', window.onScreen) ; WaitSecs(1) ; 
    
end

Screen('Flip', window.onScreen) ;
WaitSecs(dur) ;
    
end

% 시행별 조건 정리. 동일한 조건으로 구성된 구획이 총 4 Blocks 60*4 = 240시행. 
% 1 구획 : 60시행, setsize, Position, 
function [total_cond, total_log] = cond_setting(exp_info, window) 
global trial_nb 

if strcmp(exp_info.exp_type, 'practice')
    total_cond.trials_nb = 32 ;
elseif strcmp(exp_info.exp_type, 'experiment')
    total_cond.trials_nb = trial_nb ;
end

minDegree = 60 ; % 60
set3s = repmat(3, [1,total_cond.trials_nb/2]) ; set5s = repmat(5, [1, total_cond.trials_nb/2]) ; 
if exp_info.B_order == 1
    total_cond.setsize = [set3s, set5s] ;
elseif exp_info.B_order == 2
    total_cond.setsize = [set5s, set3s] ; 
end

total_cond.color_cond = ones([total_cond.trials_nb, 5]) * nan ; % 전체 color angle collection
total_cond.ori_cond = ones([total_cond.trials_nb, 5]) * nan ;  % 전체 orientation angle collection
total_cond.rgb_cond = {} ;  % 전체 rgb값
total_cond.pos_cond = {} ; % 전체 stims pos
total_cond.confidence_c = [] ;
total_cond.confidence_o = [] ;

log4cell = ones([3000, total_cond.trials_nb]) * nan ;
log_var = {"c", "o", "time"} ; 
for i = 1 : length(log_var)
    var_str = ["total_log.log_" + log_var{i} + " = log4cell ;"] ; 
    eval(var_str) ; 
end

global log_c log_o log_time
log4cell = ones([3000, total_cond.trials_nb]) * nan ;
log_c = log4cell ; log_o = log4cell ; log_time = log4cell ; 

for t = 1 : total_cond.trials_nb % specific conditions for total exp 
    setsize = total_cond.setsize(t) ; 
    color_list = rand_deg(setsize, minDegree) ;
    ori_list = rand_deg(setsize, minDegree) ;
    for j = 1 : setsize
        total_cond.color_cond(t, j) = color_list(j) ; 
        total_cond.ori_cond(t, j) = ori_list(j) ;
    end

    % 76 rgb value setting
    hue_list = color_list/360 ;
     
    for k = 1 : setsize
        hsv_value = [ hue_list(k) 1 1 ] ; 
        total_cond.rgb_cond{t, k} = hsv2rgb(hsv_value) * 255 ; 
    end
    
    % cbar start point setting
    top_color = mod( rand_top(color_list) - 179, 360 ) ;
    top_color(top_color ==0) = 360 ; 
    top_ori = rand_top(ori_list) ; 
    
    total_cond.top_color{t} = top_color ;
    total_cond.top_ori{t} = top_ori ;
    
    global dist 
    for p = 1 : 5
        pos_rad = (-1 * (72 * (p-1)) + 180) * (pi / 180) ;
        pos_x = round(window.centerX + (sin(pos_rad) * dist )) ;
        pos_y = round(window.centerY + (cos(pos_rad) * dist )) ;
        pos_code{p} = [pos_x, pos_y] ;
    end
   
    % item position setting 
    pos_list = Shuffle(pos_code) ; 
    for n = 1 : setsize
        total_cond.pos_cond{t, n} = pos_list{n} ; 
    end
    
    verbal_inhibit = {['1 2 3 4'], ['a b c d']} ;
    total_cond.verbal_suppression = datasample(verbal_inhibit, total_cond.trials_nb) ; 
end

end

% making randomized degree list  
function deg_list = rand_deg(setsize, min_distance) 

maxAngle = 360 ;
while true
    deg_list = randi(maxAngle, [1, setsize]) ;
    diff = [] ;
    s = 0 ;
    for i = 1 : setsize
        for j = flip([i+1 : setsize])
            s = s + 1 ;
            single_d = abs(deg_list(j) - deg_list(i)) ;
            if single_d > 180
                single_d = 360 - single_d ;
            end
            diff(s) = single_d ;
        end
    end
    
    error = diff(diff < min_distance) ;
    if length(error) == 0
        break
    end
    
end
        
end

function deg = rand_top(cond_list)  
trial = 0 ;     
while true
    trial = trial + 1 ; 
    if trial > 20000 
        Screen("CloseAll") ;
        disp("조건 생성 실패") ;
        break 
    end
    deg = randi(360, 1) ;
    diff = abs(cond_list - deg) ;
    diff(diff > 180) = 360 - diff(diff > 180) ; 
    
    disc_diff = diff > 60 ;
    if isempty(disc_diff(disc_diff == 0))
        break
    end
end

end


% drawing non-colored isosceles triangle 
function making_stim(rgb, ori, pos, window) 

sides_nb = 3 ; % 삼각형
angles_in_deg = [0 150 210 360] - 90 + ori ;
angles_in_rad = angles_in_deg * (pi / 180) ;
stim_radius = 35 ; %50

xPosVector = cos(angles_in_rad) .* stim_radius + pos(1) ;
yPosVector = sin(angles_in_rad) .* stim_radius + pos(2) ;

isConvex = 1 ; % Convex 형태 (볼록)
 
% Draw the rect to the screen 
Screen('FillPoly', window.onScreen, rgb, [xPosVector; yPosVector]', isConvex) ;

end

% Masking_noise
function show_noise_masking(dur, t, total_cond, window)
setsize = total_cond.setsize(t) ; 
mask = window.mask ;
mask_size = size(mask) ;

mask(mask ~= 128) = datasample([1:255], length(mask(mask ~= 128))) ;
noise_texture = Screen('MakeTexture', window.onScreen, mask) ;

patch_pos = total_cond.pos_cond{t, 1} ;
patch_rect = CenterRectOnPointd([0 0 mask_size(1) mask_size(2)], patch_pos(1), patch_pos(2) ) ;

noise_texture = Screen('MakeTexture', window.onScreen, mask) ;
patch_rect = CenterRectOnPointd([0 0 mask_size(1) mask_size(2)], patch_pos(1), patch_pos(2) ) ;

Screen('DrawTexture', window.onScreen, noise_texture, [], patch_rect) ;

for i = 1 : setsize
    mask(mask == 0) = datasample([1:255], length(mask(mask == 0))) ;
    noise_texture = Screen('MakeTexture', window.onScreen, mask) ;
    
    patch_pos = total_cond.pos_cond{t,i} ;
    noise_texture = Screen('MakeTexture', window.onScreen, mask) ;
    patch_rect = CenterRectOnPointd([0 0 mask_size(1) mask_size(2)], patch_pos(1), patch_pos(2) ) ;
    
    Screen('DrawTexture', window.onScreen, noise_texture, [], patch_rect) ;
    

end
Screen('Flip', window.onScreen) ; WaitSecs(dur) ;

end

% Task execute function
function [trial_resp, nt_out_d] = execute_task(task_order, t, total_cond, window, exp_info) 
global log_c log_o log_time
setsize = total_cond.setsize(t) ; 
%____ KeySetting ______________________________
escapeKey = KbName('ESCAPE') ;

upperKey = KbName('9') ; 
underKey = KbName('6') ;
tenupKey = KbName('*') ; 
tenunKey = KbName('3') ; 

unclocKey = KbName('W') ; 
clocKey = KbName('E') ;
tenunclocKey = KbName('Q') ; 
tenclocKey = KbName('R') ; 

keyset = [upperKey, underKey, tenupKey, tenunKey, unclocKey, clocKey, tenunclocKey, tenclocKey] ;

SpaceKey = KbName('space') ; 
% ______________________________________________

outer_radius = 425 ;  %425 ; 
inner_diameter = 700 ;  %700 ; 

center_pos = total_cond.pos_cond{t, 1} ; 

Nemo_size = 60 ; 
Nemo = CenterRectOnPointd([0 0 Nemo_size Nemo_size], center_pos(1), center_pos(2)) ;
center_Nemo = CenterRectOnPointd([0 0 Nemo_size Nemo_size], window.centerX, window.centerY) ;
nonp_Nemo = {} ; 
for j = 2 : setsize
    nonp_Rect = CenterRectOnPointd([0 0 Nemo_size Nemo_size], total_cond.pos_cond{t, j}(1), total_cond.pos_cond{t, j}(2)) ;  
    nonp_Nemo{j-1} = nonp_Rect ; 
end

wheel_Nemo = CenterRectOnPointd([0, 0, outer_radius*2, outer_radius*2], center_pos(1), center_pos(2)) ;
cbar_Nemo = CenterRectOnPointd([0 0 20 389], center_pos(1)+70, center_pos(2)) ;

% Draw wheel
top_color = total_cond.top_color{t} ; 
top_ori = total_cond.top_ori{t} ; 

start_time = GetSecs ;

log_t = 0 ;  
debug2_break = datasample(1:200, 1) ; 

key_process = 3 ; 
keylock = key_process ; 
while true
     
    log_t = log_t + 1 ;
    start_log_time = GetSecs ;
    cbar = window.cbar_collection{top_color} ;
    cbar_Texture = Screen('MakeTexture', window.onScreen, cbar) ; %After making texture in the window
    Screen('DrawTexture', window.onScreen, cbar_Texture, [], cbar_Nemo); %Drawing the texture

    
    %___ esc 누르면 종료
    %_________________________________________________________________________________________________
    [keyIsDown,secs, keyCode] = KbCheck ;
    
    if keyCode(escapeKey)
        Screen('CloseAll') ;
    end
    
    keyfunc = ["top_color-1 ;", "top_color+1 ;", "top_color-10 ;", "top_color+10 ;", "top_ori-1 ;", "top_ori+1 ;", "top_ori-10 ;", "top_ori+10 ;"] ; 
    keyvar = ["top_color = ", "top_ori = "] ; 
    
    if keylock == key_process 
        inters = intersect(keyset, find(keyCode)) ; 
        for ii = 1 : size(inters, 2)
            findN = find(keyset == inters(ii)) ;
            eval(keyvar(ceil(findN/4)) + keyfunc(findN)) ;
        end
        if size(inters, 2) ~= 0
            keylock = 0 ;
        end
    elseif keylock ~= key_process
        keylock = keylock+1 ; 
        if keylock > key_process
            keylock = key_process ; 
        end
    end
    
    % debug2일 때, Random operation
    if strcmp(exp_info.subject_name, "debug2") 
        top_color = top_color + datasample([-10, -1, 0, 1, 10], 1) ; 
        top_ori = top_ori + datasample([-10, -1, 0, 1, 10], 1) ; 
        % debug2 시행 종료 .     
        if log_t > debug2_break
            keyCode(32) = 1 ; 
        end
    end
    
    top_color = correct_degree(top_color) ;
    top_ori = correct_degree(top_ori) ;
    
    %_________________________________________________________________________________________________
    % bifeature task
    global choiced_probe choiced_distractor
    [current_value, difference, current_angle, nt_difference] = compute_current_angle(task_order, t, top_ori, cbar, total_cond, center_pos) ;
    if task_order == 1 % probe test
        making_stim(current_value{1}, current_value{2}, total_cond.pos_cond{t, 1}, window)
        choiced_probe = current_value ; 
    elseif task_order == 2 % distractor test
        making_stim(current_value{1}, current_value{2}, total_cond.pos_cond{t, 2}, window) ;
        choiced_distractor = current_value ; 
    end
    
    % bin_square at non-target pos
    showing_non_probe_text = ["Screen('FrameRect', window.onScreen, [255 255 255], center_Nemo, [2]) ;", ...
        "Screen('FrameRect', window.onScreen, [255 255 255], nonp_Nemo{2}, [2]) ;", ...
        "Screen('FrameRect', window.onScreen, [255 255 255], nonp_Nemo{3}, [2]) ;", ...
        "Screen('FrameRect', window.onScreen, [255 255 255], nonp_Nemo{4}, [2]) ;", ...
        "Screen('FrameRect', window.onScreen, [255 255 255], nonp_Nemo{1}, [2]) ;"] ;
    
    if setsize == 3
        eval_nb = 2 ;
    elseif setsize == 5
        eval_nb = 4 ;
    end
    
    for j = 1 : eval_nb
        if j == 1 & task_order == 1
            continue
        end
        eval(showing_non_probe_text(j)) ;
    end
    
    if task_order == 1 
        eval(showing_non_probe_text(5)) ;
    end
        
    % Debug 모드일 떄에는 색상환에 정답 표시 
    if strcmp(exp_info.subject_name, "debug")
        stim_cont = total_cond.debug_stim{t} ; 
        making_stim(stim_cont{1}(1:3), stim_cont{1}(4), [200, 200], window) ;
    end
    
    vbl = Screen('Flip', window.onScreen, window.vbl + (window.waitframes - 0.5) * window.ifi) ;  
    
    log_c(log_t, t) = current_angle{1} ; 
    log_o(log_t, t) = current_angle{2} ; 
            
    %___ Spacebar was pressed !! ____
    if keyCode(SpaceKey)
        end_time = GetSecs ;
        out_d =  compute_d(difference) ;
        nt_out_d = compute_d(nt_difference) ; 
        
        end_log_time = GetSecs ; 
        eval(['log_time(log_t, t) = end_log_time - start_log_time ; ']) ;
        log_t = 0 ;
        keylock = key_process ; 
        break ;
    end
    
    %_________________________
    end_log_time = GetSecs ;
    eval(['log_time(log_t, t) = end_log_time - start_log_time ; ']) ;
    
end

rt = end_time - start_time ; 
trial_resp = {out_d, rt, current_angle} ;

end

% drawing oriwheel texture
function wheel_Texture = making_wheel(out_radius, inner_diameter, window) 

[grid_x, grid_y] = meshgrid(-1*out_radius : out_radius) ;
wheel = zeros(out_radius*2+1,out_radius*2+1, 3) ; % S-layer of HSV dimension: its value should be 1

wheel = hsv2rgb(wheel) ; % change HSV to RGB 
donuts = circle(out_radius*2+1).*(1-circle(out_radius*2+1, inner_diameter)) ;
wheel(:, :, 4) = donuts ; %When you make a texture using a matrix, the fourth layer of the matrix represents transparency.
% The inner part of the donut that we made cosists of 0, therefore, the innercircle which consists of value 0 become transparent.
wheel = wheel *255 ; 
wheel_Texture = Screen('MakeTexture', window.onScreen, wheel) ; %After making texture in the window

end

% compute current_color 
function [current_value, difference, current_angle, nt_difference] = compute_current_angle(task_order, t, top_ori, cbar, total_cond, center_pos)
% color
current_rgb = cbar(195, 1, :) / 255 ;
current_rgb = [current_rgb(:, :, 1), current_rgb(:, :, 2), current_rgb(:, :, 3)] ; 
current_hsv = rgb2hsv(current_rgb) ;
current_color = [cbar(195, 1, 1), cbar(195, 1, 2), cbar(195, 1, 3)]  ; 
choiced_angleC = current_hsv(1) * 360 ;
target_angleC = total_cond.color_cond(t, task_order) ;
C_difference = choiced_angleC - target_angleC ;

% ori
current_ori = top_ori ;
choiced_angleO = top_ori ;
target_angleO = total_cond.ori_cond(t, task_order) ;
O_difference = choiced_angleO - target_angleO ;     % diffrence angle

% two feature data 
current_value = {current_color, current_ori} ; 
difference = {round(C_difference), round(O_difference)} ; 
current_angle = {choiced_angleC, current_ori} ; 
 
% non-target distance for swap error model 
for tt = 2 : total_cond.setsize(t)
    targetC = total_cond.color_cond(t, tt) ;
    nt_cd = round(choiced_angleC - targetC) ; 
    targetO = total_cond.ori_cond(t, tt) ; 
    nt_od = round(choiced_angleO - targetO) ;
    nt_cds{tt-1} = nt_cd ; 
    nt_ods{tt-1} = nt_od ; 
end
nt_difference = [nt_cds, nt_ods] ;  

end

% compute 'd'
function out_d =  compute_d(difference)

for dd = 1: length(difference)
    if abs(difference{dd}) > 180
        tempD = 360-abs(difference{dd}) ;
        if difference{dd} > 0
            difference{dd} = -1*tempD ;
        elseif difference{dd} < 0
            difference{dd} = tempD ;
        end
    end
end

out_d = difference ;

end

function corrected_degree = correct_degree(origin_degree) 

    corrected_degree = mod(origin_degree, 360) ;
    if corrected_degree == 0
        corrected_degree = 360 ;
    end
    
end
% feedback
function show_feedback(window, target_index, choiced_value, exp_info, total_cond, t)
% target_index = {[p_rgb, p_ori], [dp_rgb, dp_ori]} ;
% choiced_value = [choiced_color1, choiced_ori1, choiced_color2, choiced_ori2] ; 
global choiced_probe choiced_distractor

skip = 0 ; 
while skip == 0 
    Screen('DrawText', window.onScreen, ['Target'], window.centerX-230, window.centerY-100) ;
    Screen('DrawText', window.onScreen, ['Your Response'], window.centerX+100, window.centerY-100) ;

    % probe Target
    making_stim(target_index{1}(1:3), target_index{1}(4), [window.centerX-170, window.centerY], window) ;
    % probe Response 
    making_stim(choiced_probe{1}, choiced_probe{2}, [window.centerX+200, window.centerY], window) ; 
    
    Screen('Flip', window.onScreen) ; 
    
    outforpress = pressforskip(exp_info) ;
    if outforpress
        break
    end
end

end

% Break time
function show_break(break_type, img_rect, window, exp_info) 
escapeKey = KbName('ESCAPE') ;

if break_type == '60'
    img_name = "break60" ;
    dur = 60 ; 
elseif break_type == '30'
    img_name = "break30" ;
    dur = 30 ; 
end

break_img = imread( strcat(img_name, ".jpg")) ; 
break_texture = Screen('MakeTexture', window.onScreen, break_img) ;

break_fin_img = imread( strcat(img_name, "_fin.jpg")) ; 
break_fin_texture = Screen('MakeTexture', window.onScreen, break_fin_img) ;

Screen('DrawTexture', window.onScreen, break_texture, [], img_rect) ;
Screen('Flip', window.onScreen) ;
WaitSecs(dur) ; 

while true 
    
    Screen('DrawTexture', window.onScreen, break_fin_texture, [], img_rect) ;
    Screen('Flip', window.onScreen) ;
    outforpress = pressforskip(exp_info) ;
    if outforpress
        break
    end
    
end

end

function outforpress = pressforskip(exp_info)

escapeKey = KbName('ESCAPE') ;
SpaceKey = KbName('space') ; 

[keyIsDown,secs, keyCode] = KbCheck ;
outforpress = 0 ; 
if strcmp(exp_info.subject_name, "debug2")
    outforpress = 1 ; 
elseif keyCode(SpaceKey)
    outforpress = 1 ; 
elseif keyCode(escapeKey)
    Screen('CloseAll') ;
end

end

function confidence = confidence_rate(window, order, exp_info)

%KbName('UnifyKeyNames') ; 
escapeKey = KbName('ESCAPE') ;
SpaceKey = KbName('space') ; 
num0key = KbName('0') ; 
num1key = KbName('1') ; 
num2key = KbName('2') ; 
num3key = KbName('3') ; 

keylist = [num0key, num1key, num2key, num3key] ; 
confidence = nan ; 

while true
    if order == 1
        Screen('DrawText', window.onScreen, ['Rating Confidence for Color Recall : 0 ~ 3'], window.centerX-270, window.centerY-50) ;
    elseif order == 2
        Screen('DrawText', window.onScreen, ['Rating Confidence for Orientation Recall : 0 ~ 3'], window.centerX-270, window.centerY-50) ;
    end
    rating_text = strcat('Your Rating is :  ', num2str(confidence)) ; 
    Screen('DrawText', window.onScreen, [rating_text], window.centerX-270, window.centerY+50) ;
    Screen('Flip', window.onScreen) ; 
    
    [keyIsDown,secs, keyCode] = KbCheck ;
    
    if keyCode(escapeKey)
        Screen('CloseAll') ;
    end
    
    inters = intersect(keylist, find(keyCode)) ;
    for ii = 1 : size(inters, 2)
        findN = find(keylist == inters(ii)) ;      
        if ~isempty(findN)
            confidence = findN-1 ;
        end
    end
    
    if keyCode(SpaceKey) & ~isnan(confidence)
        break
    end
    
    if strcmp(exp_info.subject_name, "debug2")
        confidence = datasample(0:3, 1) ; 
        break ; 
    end 

end

end

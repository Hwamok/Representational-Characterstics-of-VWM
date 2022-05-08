function target_cell = finding_files(target_dir, fmt)

cd(target_dir) ; 
file_list = dir ; 
file_nb = length(dir) ; 
target_nb = 0 ; 
target_cell = {} ; 

for t = 1 : file_nb
    finding_name = struct2cell(file_list(t)) ;
    file_name = finding_name{1} ;
    is_target = strfind(file_name, fmt) ;
    if is_target ~= 0
        target_nb = target_nb + 1 ;
        target_cell{target_nb} = file_name ;
    end
end

end
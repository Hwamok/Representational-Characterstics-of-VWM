function out_cell = mat2cell_HM(mat_t)
out_cell = cell([size(mat_t)]) ; 

for i = 1 : size(mat_t, 1)
    for j = 1 : size(mat_t, 2)
        out_cell{i, j} = mat_t(i, j) ;
    end
end

end
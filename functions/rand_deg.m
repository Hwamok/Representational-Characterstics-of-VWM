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

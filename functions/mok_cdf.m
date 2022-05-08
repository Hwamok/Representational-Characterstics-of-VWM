function [AUC, calc_process] = mok_cdf(list)

% 정수형 배열에서 누적분포함수 계산하기. 
% list는 n*1 double
list(isnan(list) == 1) = [] ; 
list = round(abs(list)) ; 
size_row = size(list, 1) ; 
size_col = size(list, 2) ; 

nb_degree = 181 ; % 0 ~ 180 degree 

freq_list = zeros([nb_degree, 1]) ;
for ii = 1 : size_row
    for jj = 1 : size_col
        d = list(ii, jj) ;
        freq_list(d+1) = freq_list(d+1) + 1 ;
    end
end
nb = sum(freq_list) ; 
prob_list = freq_list/nb ; 

cumu_f = [] ; 
cumu_prob = 0 ; 
for kk = 1 : size(freq_list, 1)
    cumu_prob = cumu_prob + prob_list(kk) ;
    cumu_f(kk) = cumu_prob ; 
end

x = (0 : nb_degree-1) ./ (nb_degree-1) ;
y = cumu_f ;
trapezoid = [] ; 
for ll = 1 : nb_degree - 1 
    trapezoid(ll) = (cumu_f(ll+1) + cumu_f(ll))/2 * (x(ll+1) - x(ll)) ;
end
AUC = sum(trapezoid) ; 

trapezoid = [trapezoid, nan] ; 
calc_process = [transpose(x), transpose(y), transpose(trapezoid) ] ; 

hold on ; 
plot(0:nb_degree-1, y) ;

title('CDF of vector') ; 
xlabel('distance (d)') ; 
ylabel('cumulative probability') ; 
ylim(0:1) ; 

end
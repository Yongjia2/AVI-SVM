function ecc = get_ecc(dataset, x)
num_initial = size(dataset,1);
mean_initial = mean(dataset,1);  
var_initial = 0;
for i= 1:num_initial
    var_initial = var_initial + (norm(dataset(i,:)- mean_initial)^2)/num_initial;
end
%求点x的ecc值
s_k = num_initial + 1;
mean_s_k = (num_initial - 1)/s_k * mean_initial + x / s_k;
var_s_k = (num_initial - 1)/s_k * var_initial + norm(x - mean_s_k)^2/s_k;
ecc = (1 / s_k + norm(mean_s_k - x)^2/(s_k * var_s_k))/2;

    





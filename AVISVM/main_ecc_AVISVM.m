function Data = main_ecc_AVISVM
Data.dim = 3;
Data.xlow = [0, 0.1 , 0.1] ;
Data.xup = [3, 1000000, 1000000];
Data.objfunction = @(x)myfun(x);
end

function f = myfun(x) 
[~,~, train_data_with_label,positive_select_index] = get_data;
par_ecc_limit = x(1);
u = x(2);
v = x(3);
fvalue_valid_average = kfold_AVISVM(train_data_with_label,positive_select_index,par_ecc_limit,u,v);
f = - fvalue_valid_average;
end

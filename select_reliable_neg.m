function [reliable_neg,remain_data] = select_reliable_neg(positive_data, unlabeled_data,num_select,par_ecc_limit)
ecc = zeros(size(positive_data, 1),1);
index = [];
n = 0;
for i=1:length(unlabeled_data)
    ecc(i) = get_ecc(positive_data(:,1:end -1),unlabeled_data(i,1:end-1));
    outlier = is_outlier(ecc(i), size(positive_data, 1), par_ecc_limit);
    if outlier
        n = n +1;
        index(n) = i;
    end
end
if length(index) <= num_select
    reliable_neg = unlabeled_data(index,:);
    remain_data_index = setdiff((1:size(unlabeled_data, 1)),index);
    remain_data = unlabeled_data(remain_data_index,:); 
else
    [~,ecc_index] = sort(ecc(index),'descend');
    ecc_select_index = index(ecc_index(1:num_select));
    reliable_neg = unlabeled_data(ecc_select_index,:);
    remain_data_index = setdiff((1:size(unlabeled_data, 1)),ecc_select_index);
    remain_data = unlabeled_data(remain_data_index,:);
end


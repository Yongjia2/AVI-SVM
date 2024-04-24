function fvalue_valid_average = kfold_AVISVM(train_data_with_label,positive_select_index,par_ecc_limit,u,v)
indices=crossvalind('Kfold',train_data_with_label(:,end),5);
fvalue_valid = zeros(5,1);
for i=1:5
    valid_index = (indices == i);
    valid_index_new = find(valid_index == 1);%得到验证集的下标
    positive_index_in_valid = intersect(valid_index_new,positive_select_index);    %在验证集中的正类点在整个数据集上的下标
    positive_data_in_valid = train_data_with_label(positive_index_in_valid,:); % 在验证集中的正类点
    train_index = ~valid_index;
    train_index_new = find(train_index == 1);%得到训练集在整个数据集上的下标
    positive_index_in_train = intersect(train_index_new,positive_select_index);    %在训练集中的正类点在整个数据集的下标
    valid_data = train_data_with_label(valid_index_new,:);%验证集数据
    %train_data = train_data_with_label(train_index_new,:);%训练集数据
    positive_data_in_train = train_data_with_label(positive_index_in_train,:);  %在训练集中的正类点
    unlabeled_data_in_train = train_data_with_label(setdiff(train_index_new,positive_index_in_train),:);
    num_select = length(positive_index_in_train);
    [reliable_neg,remain_data] = select_reliable_neg(positive_data_in_train, unlabeled_data_in_train,num_select,par_ecc_limit);
    [w,b] = AVI_SVM(positive_data_in_train, reliable_neg,remain_data,u,v);
   fvalue_valid(i) = get_fvalue_validAVISVM(w,b,positive_data_in_valid,valid_data);
end
fvalue_valid_average = mean(fvalue_valid);
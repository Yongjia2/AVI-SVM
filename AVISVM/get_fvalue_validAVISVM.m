function f_valid = get_fvalue_validAVISVM(w,b,positive_data_in_valid,valid_dataset)
label_new = zeros(size(valid_dataset,1),1);
dataset_no_label = valid_dataset(:,1:end-1);
dataset_no_label_positive = positive_data_in_valid(:,1:end-1);
for i = 1:size(valid_dataset,1)
    if dataset_no_label(i,:)*w - b > 0
        label_new(i) = 1;
    else
        label_new(i) = 0;
    end
end
label_new_valid = zeros(size(positive_data_in_valid,1),1);
for i = 1:size(positive_data_in_valid,1)
    if dataset_no_label_positive(i,:)*w - b > 0
        label_new_valid(i) = 1;
    else
        label_new_valid(i) = 0;
    end
end
p_label_1 = length(find(label_new == 1))/ size(valid_dataset,1);
TP = length(find(label_new_valid == 1));
recall = TP/size(positive_data_in_valid,1);
f_valid = recall^2/p_label_1;
  
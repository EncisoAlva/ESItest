function label_new = hx_label2number(label_old,filename)
% filename gives us a file wich contains the mapping between current labels
% and the corresponding numbers.

a = textread(filename,'%s');
num = a(1:2:end);
label = a(2:2:end);
label_new = {};

for i = 1 : length(label_old)
    curr = label_old{i};
    for j = 1 : length(label)
        if strcmp(label{j},curr)
            label_new(end+1) = num(j);
        end
    end
end
label_new = label_new';
end
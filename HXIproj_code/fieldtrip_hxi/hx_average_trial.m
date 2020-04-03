function cfg_new = hx_average_trial(cfg_old, windowlength)


cfg_new = cfg_old;

trials = cfg_old.trial;
trials_new = {};
for i = 1 : length(trials)
    curr = trials{i};
    new = curr;
    ncols = size(curr,2);
    for j = 1 : ncols
        if j+windowlength > ncols
            indices = j : ncols;
        else
            indices = j : j+windowlength;
        end
        new(:,j) = mean(curr(:,indices),2);
    end
    trials_new = [trials_new, new];
end

cfg_new.trial = trials_new;
end
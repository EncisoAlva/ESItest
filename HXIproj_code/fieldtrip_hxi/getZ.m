function Z = getZ(beta)

M = (length(beta)+1) / 2;
Z = [];
for i = 1 : M
    Z = [Z; beta(i:i+M-1)];
end
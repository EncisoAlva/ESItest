function ind = hx_find_indices_in_sphere(pnt,center,radius)


m = size(pnt,1);
center_mat = repmat(center,m,1);
diff = pnt - center_mat;
diff_sq = diff.^2;
diff_sum = sum(diff_sq,2);
rad_sq = radius^2;

ind = find(diff_sum <= rad_sq);


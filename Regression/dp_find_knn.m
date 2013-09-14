function [D_close distances] = dp_find_knn(X_a, x_b, k, num_id_cols)

    % strip out the response column
    D_a = X_a(:,num_id_cols+1:end-1);
    d_b = x_b(:,num_id_cols+1:end-1);

    % compute our 'difference' vector
    diff = zeros(size(D_a));
    for j=1:size(diff,1),
        dist      = D_a(j,:) - d_b;
        diff(j,:) = dist;
    end
    d = sqrt(sum(diff.^2,2));
    
    % put the response column back in
    D_full  = [d X_a(:,1:num_id_cols) D_a X_a(:,end)];
    
    % now return the k 'closest'
    D_s       = sortrows(D_full);
    D_c       = D_s(1:k,:);
    D_close   = D_c(:,2:end);
    distances = D_c(:,1);
function d = dp_euclidean_distance(X_a, x_b, num_id_cols)

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
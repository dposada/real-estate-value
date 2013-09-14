function [y weights] = dp_weighted_ave(D_train, x_test, lambda)

    % separate the predictors from the response
    X_train = D_train(:,1:end-1);
    y_train = D_train(:,end);
    
    % calculate weights using the Epanechnikov kernel
    weights = dp_kernel_ep(X_train, x_test, lambda);

    % sum everything up
    s    = sum(weights .* y_train);
    norm = sum(weights);
    if norm==0, disp('Sum of weights is zero - try a bigger lambda!'); end
    
    % return the Nadaraya-Watson kernel-weighted average
    y = s / norm;
    
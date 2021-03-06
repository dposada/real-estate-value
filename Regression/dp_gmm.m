function [mix options errlog prob] = dp_gmm(X_raw, num_id_cols, num_centers, num_iters)

    % create the gmm object
    X       = X_raw(:,num_id_cols+1:end);
    dim     = size(X,2);
    mix     = gmm(dim,num_centers,'diag');

    % initialize our data
    % Just use 5 iterations of k-means in initialization
    options     = foptions;
    options(14) = 5;
    mix         = gmminit(mix,X,options);

    % set up the options vector
    options     = zeros(1, 18);
    options(1)  = 1;         % Prints out error values.
    options(14) = num_iters; % Number of iterations.
    
    % run EM
    [mix options errlog] = gmmem(mix,X,options);
    
    % get the "responsibility" of each distribution
    [prob] = gmmpost(mix,X);
    
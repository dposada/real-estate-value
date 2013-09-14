function [y_model weights neighbors comp] = dp_lwr(D_train, d_test, lambda)

    % separate the predictors from the response
    X_train = D_train(:,1:end-1);
    y_train = D_train(:,end);
    x_test  = d_test(:,1:end-1);
    
    % calculate weights
    n       = size(X_train,1);
    W       = zeros(n,n);
    weights = zeros(n,1);
    dist    = zeros(n,1);
    for k=1:n,
        d          = dp_euclidean_distance(D_train(k,:),d_test,0);
        w          = exp(-d^2 / (2 * lambda^2));
        weights(k) = w;
        W(k,k)     = weights(k);
        dist(k)    = d;
    end
    neighbors = sum(weights>=0.001);
    comp      = find(weights==max(weights));

    % set up our data
    M      = [ones(n,1) X_train];
    y      = y_train;
    m_test = [1 x_test];

    % now do locally weighted regression
%    theta   = pinv(M'*W*M) * M' * W * y;
    theta   = lscov(M,y,weights);
%    theta   = glmfit(X_train,y,'normal','weights',weights);
    y_model = m_test * theta;

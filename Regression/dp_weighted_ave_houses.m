function [Y_model E W N] = dp_weighted_ave_houses(data_file, results_file, num_id_cols, lambda, D_test)

    % load the data and determine how much should be used for training
    D_raw         = load(data_file);
    D             = D_raw(:,num_id_cols+1:end);
    
    %%%
    train_percent = 0.75;
    rows          = size(D, 1);
    train_size    = ceil(rows*train_percent);

    % set up our training matrix
    T = D(1:train_size,:);
    
    % set up our test matrix
    if nargin < 5
        S_raw = D_raw(train_size+1:end,:);
    else
        S_raw = D_test;
    end
    S         = S_raw(:,num_id_cols+1:end);
    test_size = size(S,1);

    % run our test data through the model
    X_test  = S(:,1:end-1);
    Y_test  = S(:,end);
    Y_model = zeros(test_size,1);
    W       = zeros(test_size,train_size);
    for k=1:size(Y_model),
        x_t         = X_test(k,:);
        [y weights] = dp_weighted_ave(T, x_t, lambda);
        Y_model(k)  = y;
        W(k,:)      = weights';
    end
    
    % who were the neighbors that we used?
    N = [];
    if size(S,1)==1,
        N = [W(W~=0)' D_raw(W~=0,:)];
        save('neighbors.txt', 'N', '-ASCII', '-DOUBLE', '-tabs');
    end
    
    % see how we did
    E_1 = Y_test-Y_model;
    E_2 = E_1./Y_test;
    E_3 = abs(E_2);
    E   = [E_1 E_2 E_3];
    R   = [S_raw(:,1:num_id_cols) Y_test Y_model E];
    save(results_file, 'R', '-ASCII', '-DOUBLE', '-tabs');
    
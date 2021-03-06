function [Y_model E e_mean e_median e_max e_20 e_10 e_5] = dp_localregtree_houses(data_file, results_file, num_id_cols, lambda, dist_thresh, verbose, D_test)

    % load the data and determine how much should be used for training
    D_raw = load(data_file);
    D     = D_raw(:,num_id_cols+1:end);
    
    %%%
    train_percent = 0.75;
    rows          = size(D, 1);
    train_size    = ceil(rows*train_percent);

    % set up our training matrix
    T = D(1:train_size,:);
    
    % set up our test matrix
    if nargin < 7
        S_raw = D_raw(train_size+1:end,:);
    else
        S_raw = D_test;
    end
    S         = S_raw(:,num_id_cols+1:end);
    test_size = size(S,1);

    %%%
    X_test  = S(:,1:end-1);
    Y_test  = S(:,end);
    Y_model = zeros(test_size,1);
    for k=1:test_size,
        %%
        x_t     = X_test(k,:);
        T_close = dp_find_closest(T, x_t, dist_thresh, lambda, verbose);
        
        % build a regression tree (leave out lat,lon)
        pred_start = 1;
        X          = T_close(:,pred_start:end-1);
        y          = T_close(:,end);
        t          = classregtree(X,y);
        
        % do some cross-validation
%         [c,s,n,best] = test(t,'cross',X,y);
%         tmin         = prune(t,'level',best);
        tmin = t;

        % run our test data through the model
        Y_model(k) = eval(tmin, x_t(:,pred_start:end));
    end
    
    % see how we did
    mul      = 100000;
    Y_test   = Y_test * mul;
    Y_model  = Y_model * mul;
    E_1      = Y_test-Y_model;
    E_2      = E_1./Y_test;
    E_3      = abs(E_2);
    E        = [E_1 E_2 E_3];
    R        = [S_raw(:,1:num_id_cols) Y_test Y_model E];
    e_mean   = mean(E_3)*100;
    e_median = median(E_3)*100;
    e_max    = max(E_3)*100;
    e_20     = sum(E_3<0.2)/test_size*100;
    e_10     = sum(E_3<0.1)/test_size*100;
    e_5      = sum(E_3<0.05)/test_size*100;
    msg      = strcat(...
        'Mean:   %5.2f\n', ...
        'Median: %5.2f\n', ...
        'Max:    %5.2f\n', ...
        '< 20:   %5.2f\n', ...
        '< 10:   %5.2f\n', ...
        '< 5:    %5.2f\n');
    msg = sprintf(msg, e_mean, e_median, e_max, e_20, e_10, e_5);
    disp(msg);
    save(results_file, 'R', '-ASCII', '-DOUBLE', '-tabs');
    
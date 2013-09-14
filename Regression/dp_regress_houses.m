function [Y_model E B] = dp_regress_houses(data_file, results_file, num_id_cols)

    % load and scale the data
    D_raw = load(data_file);
    D_raw = [D_raw(:,1:num_id_cols) dp_normalize(D_raw(:,num_id_cols+1:end-1)) D_raw(:,end)];

    % determine how much should be used for training
    D             = D_raw(:,num_id_cols+1:end);
    rows          = size(D, 1);
    train_percent = 0.90;
    train_size    = ceil(rows*train_percent);
    
    % set up our training matrix
    T = D(1:train_size,:);
    X = [ones(train_size,1) T(:,1:end-1)];
    Y = T(:,end);

    % do the regression
    B = regress(Y, X);
    
    % run our test data through the model
    S_raw   = D_raw(train_size+1:end,:);
    S       = S_raw(:,num_id_cols+1:end);
    X_test  = [ones(size(S,1),1) S(:,1:end-1)];
    Y_test  = S(:,end);
    Y_model = X_test * B;
    
    % see how we did
    E_1 = Y_test-Y_model;
    E_2 = E_1./Y_test;
    E_3 = abs(E_2);
    E   = [E_1 E_2 E_3];
    R   = [S_raw(:,1:num_id_cols) Y_test Y_model E];
    save(results_file, 'R', '-ASCII', '-tabs');
    test_size= size(S,1);
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

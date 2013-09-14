function [Y_model E W N] = dp_lwr_houses(data_file, num_id_cols, lambda, D_test)

    results_file = 'results.txt';

    % load the data
    D_raw = load(data_file);
    D_raw = [D_raw(:,1:num_id_cols) dp_normalize(D_raw(:,num_id_cols+1:end-1)) D_raw(:,end)];
    D     = D_raw(:,num_id_cols+1:end);
    
    % determine how much should be used for training
    train_percent = 0.90;
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
    Y_model = zeros(test_size,1);
    W       = zeros(test_size,train_size);
    Q       = zeros(test_size,1);
    C       = zeros(test_size,1);
    for k=1:test_size,
        if (mod(k,10)==0)
            disp(sprintf('%d/%d',k,test_size));
        end
        property_id                = S_raw(k,1);
        x_t                        = S(k,:);
        [y weights neighbors comp] = dp_lwr(T, x_t, lambda);
        Y_model(k)                 = y;
        W(k,:)                     = weights';
        Q(k)                       = neighbors;
        C(k)                       = D_raw(comp(1),1);
        if (neighbors==0),
            msg = 'Home w/virtually no neighbors: %d';
            msg = sprintf(msg, property_id);
            disp(msg);
        end
    end
    
    % who were the neighbors that we used?
    N      = [];
    thresh = 0.75;
    if size(S,1)==1,
        N = [
            -1            S_raw;
            W(W>=thresh)' D_raw(W>=thresh,:)];
        save('neighbors.txt', 'N', '-ASCII', '-DOUBLE', '-tabs');
    end
    
    % see how we did
    Y_test  = S(:,end);
    E_1     = Y_test-Y_model;
    E_2     = E_1./Y_test;
    E_3     = abs(E_2);
    E       = [E_1 E_2 E_3];
    R       = [S_raw(:,1:num_id_cols) Y_test Y_model E Q C];
    save(results_file, 'R', '-ASCII', '-DOUBLE', '-tabs');
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
    
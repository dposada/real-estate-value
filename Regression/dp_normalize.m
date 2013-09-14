function data = dp_normalize(original, num_id_cols)

    if nargin < 2
        num_id_cols = 0;
    end

    %%%
    rows = size(original,1);
    
    % normalize to a standard gaussian
    muo   = mean( original( :, num_id_cols+1:end) );
    stdo  = std( original( :, num_id_cols+1:end) );
    stdo2 = 1 ./ stdo;
    data  = [original(:,1:num_id_cols) (original(:,num_id_cols+1:end) - ones(rows,1)*muo)*diag(stdo2)];
    
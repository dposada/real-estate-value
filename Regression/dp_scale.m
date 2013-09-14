function data = dp_scale(original, num_id_cols)

    if nargin < 2
        num_id_cols = 0;
    end
    
    %%%
    rows = size(original,1);
    orig = original(:,num_id_cols+1:end);
    orig = orig - ones(rows,1)*min(orig);
    orig = orig ./ (ones(rows,1)*max(orig));
    
    %%%
    orig = orig * 10;
    
    %%%
    data = [original(:,1:num_id_cols) orig];
    
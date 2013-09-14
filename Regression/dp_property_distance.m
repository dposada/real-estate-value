function d = dp_property_distance(X_a, x_b, dist_thresh)

    % get the coordinates (latitude, longitude)
    coords      = [1 2];
    Coord_a     = X_a(:,coords);
    coord_b     = x_b(coords);

    % get the rest of the predictors
    C_a = X_a(:,3:end);
    c_b = x_b(3:end);
    
    % compute our 'difference' vector
    diff = zeros(size(C_a));
    for k=1:size(diff,1),
        dist = abs(Coord_a(k,:) - coord_b);
        if (dist <= dist_thresh)
            diff(k,:) = C_a(k,:) - c_b;
        else
            diff(k,:) = Inf;
        end
    end
    d = sqrt(sum(diff.^2,2));
    
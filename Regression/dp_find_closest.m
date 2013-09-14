function D_close = dp_find_closest(D_a, x_b, max_dist, min_matches, verbose)

    % get the coordinates (latitude, longitude)
    coords  = [1 2];
    Coord_a = D_a(:,coords);
    coord_b = x_b(coords);

    % compute our 'difference' vector
    diff = zeros(size(Coord_a));
    for k=1:size(diff,1),
        dist      = Coord_a(k,:) - coord_b;
        diff(k,:) = dist;
    end
    d = sqrt(sum(diff.^2,2));
    
    %%%
    close = find(d<=max_dist);
    if(size(close,1) < min_matches),
        D_full  = [d D_a];
        D_s     = sortrows(D_full);
        D_c     = D_s(1:min_matches,:);
        D_close = D_c(:,2:end);
        if (verbose),
            msg = 'Unable to find %d observations within %f - max distance: %f';
            msg = sprintf(msg, min_matches, max_dist, D_c(end,1));
            disp(msg);
        end
    else
        D_close = D_a(close,:);
    end
    
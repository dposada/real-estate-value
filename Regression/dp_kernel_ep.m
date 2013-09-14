function k = dp_kernel_ep(X_train, x_test, lambda)

    if nargin < 3, lambda = 1; end

    dist   = dp_property_distance(X_train, x_test);
    d      = abs(dist) / lambda;
    t      = abs(d);
    t(t>1) = 1;
    k      = .75 * (1 - t.^2);

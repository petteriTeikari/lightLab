function yhat = sigmoid_4param(params,x1)

    % SIGMOID Function to fit data to a four parameter dose response curve
    % requires the nlinfit function of the statistics toolbox and a set of 
    % initial parameters such as the one generated by init_coeffs.m.

    min     = params(1);
    max     = params(2);
    ec      = params(3);
    hillc   = params(4);

    yhat = (max + ((min-max) ./ ( 1 + ((x1/ec).^hillc))));

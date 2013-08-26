function yhat = sigmoid_Hill(params,x)   

    % Used for example by Mure et al. (2009)

    Pmax    = params(1);    
    B       = params(2);
    C       = params(3);

    yhat =  Pmax * ( x .^ B ./ ( (x .^ B)  + (C .^ B) ) );

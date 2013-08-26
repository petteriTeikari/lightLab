function init_params = sigmoid_initCoeffs(x,y)

    % INIT_COEFFS Function to generate the initial parameters for the 4
    % parameter dose response curve.

    parms    = ones(1,4);
    parms(1) = min(y);
    parms(2) = max(y);
    parms(3) = (min(x)+max(x))/2;
    
    % get input sizes
    sizey    = size(y);
    sizex    = size(x);
    
    % further fixing
    %{
    if (y(1)-y(sizey)) ./ (x(2)-x(sizex))>0
        parms(4)=(y(1)-y(sizey))./(x(2)-x(sizex));
    else
        parms(4)=1;
    end    
    %}
    parms(4) = 1;
    
    init_params=parms;
function paramOut = MAIN_sigmoidFunctions(x, y, err, sigmoidType, options)

    % For 4-parameter SIGMOID
    if strcmpi(sigmoidType, '4param') == 1  
        
        % used for example by Brainard et al. (2001) for the melatonin
        % suppression IRCs
        init0 = sigmoid_initCoeffs(x,y);
        paramOut = nlinfit(x, y, 'sigmoid_4param', init0, options);                                 
    
    % For 3-parameter HILL-function
    elseif strcmpi(sigmoidType, 'Hill') == 1   
        
        % used for example by Mure et al. (2009)
        init0 = [1.0 0.2 12]; % [Pmax B C] initial guesses
        paramOut = nlinfit(x, y, 'sigmoid_Hill', init0, options);                             
        
    end
        

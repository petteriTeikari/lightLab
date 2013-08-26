function yOut = poolingModel_function(x, lambda, y, err, mode, statParam, output, actSpectra, options, path)

    % INPUTS
    % x       - x(1): k1
    %         - x(2): k2
    %         - x(3): m
    %         - x(4): c
    %         - x(5): r
    %         - x(6): fMe
    %         - ...
    %         - x(i): more parameters
        
    % OUTPUT
    % yOut    - result of some cost function, this could be the
    %           least-squares error between the input and the fit for
    %           example    
   
    debugOn = 0;
    cd(path.Code)
    
    %% DEFINE PHOTORECEPTOR TERMS
    
        % You could use string matching from the actSpectra{i}.header field
        % but now lazy programmer was lazy and hard-coded things, so the
        % index inside {i} could be obtained automatically
    
        % Melanopsin
        OPN4 = (x(1) .* actSpectra{1}.spectrum) .^ x(5);
        
        % Bistable Melanopsin
            if strcmp(options.modeNomogram, 'static') == 1
                
                ONE = ones(length(actSpectra{1}.spectrum),1);
                equiSpec = ONE ./ (ONE + (actSpectra{3}.spectrum ./ (options.biPhi * actSpectra{1}.spectrum)));
                OPN4bi = (x(1) .* equiSpec) .^ x(5);

            elseif strcmp(options.modeNomogram, 'dynamic') == 1
                
                % correct later
                options.Rpeak = 482;
                options.Mpeak = 587;

            end
        
        % Cones
        C = (x(2) .* actSpectra{7}.spectrum) .^ x(4); % v(lambda)
                             % correct if you want to use MWS/LWS
        
        % Rods
        R = (x(3) .* actSpectra{2}.spectrum) .^ x(4);

        % S-Cones
        Cs = (x(7) .* actSpectra{4}.spectrum) .^ x(4);

        % Opponent term
        Opp = (x(8) .* abs(actSpectra{6}.spectrum - (x(9) .* actSpectra{5}.spectrum))) .^ x(4);
        
       
    %% CORRECT TERMS if the experimental data is as discrete data points
    % which is most likely to be the case for photoreception studies
    
        if strcmp(output, 'spectrum') == 1
            % if your input is truely spectral
            % this is typically only the case for the "final call"           
            
        elseif strcmp(output, 'optim') == 1
            lambdaInd = extractIndices(lambda, actSpectra{1}.lambda);
        
            OPN4      = OPN4(lambdaInd);
            OPN4bi    = OPN4bi(lambdaInd); 
            C         = C(lambdaInd);
            R         = R(lambdaInd);
            Cs        = Cs(lambdaInd);
            Opp       = Opp(lambdaInd);            
        end
        
   
    %% COMBINATION MODELS
    
        if strcmp(mode, 'simple') == 1
            % Combine the 3 above defined terms - ORIGINAL VERSION
            Sfit = ( OPN4 + ( (C + R).^(1/x(4)) ).^x(5)  ) .^(1/x(5));                         
            
        elseif strcmp(mode, 'opponent') == 1 % from Kurtenbach et al. (1999)   
            % add spectral opponency and S-cone contribution
            Sfit = ( OPN4 + ( (C + R + Cs + Opp).^(1/x(4)) ).^x(5)  ) .^(1/x(5));
            
        elseif strcmp(mode, 'simpleBi') == 1
            % Combine the 3 above defined terms - MODIFIED VERSION to include bistability
            Sfit = ( OPN4bi .^ (1/x(4)) + ( (C + R).^(1/x(4)) ).^x(5)  ) .^(1/x(5));
            
        elseif strcmp(mode, 'opponentBi') == 1 % from Kurtenbach et al. (1999)   
            % add spectral opponency and S-cone contribution
            Sfit = ( OPN4bi + ( (C + R + Cs + Opp).^(1/x(4)) ).^x(5)  ) .^(1/x(5));
            
        else                
            errordlg('String mismatch? Define variable "mode" better')            
        end
        
        if debugOn == 1
            %% DEBUG
            subplot(3,1,3)
            plot(lambda,Sfit)
            xlim([380 650]); ylim([0 1.2])
            pause(0.2)
        end
        
        
    %% CALCULATE the COST FUNCTION
    
        % So if Matlab is a bit novel to you, what has happened here is
        % that the poolingModel_main() calls this whole function many times
        % during the optimization routine and tries to change the input
        % values (in variable "x") on every call and then your goodness of
        % fit is quantified finally with this single scalar cost function
        % which is minimized here        
        
        if strcmp(output, 'optim') == 1
            cd(path.common)
            yOut = calc_fitStats(y, Sfit, err, statParam.K, output);
            cd(path.Code)
        else
            yOut = Sfit;
        end

function [spec, points, stats, actSpectra] = poolingModel_main(lambda,y,err,mode,linLog,comb_k,contr,p,densit,fMe,oppon,bound,costF,options,path)

    spec   = [];
    points = [];
    stats  = [];

    % INPUTS (see useDefaultOptionsForMixedModels.m for further details)
    
        % x      - experimental x vector (e.g. wavelengths)
        % y      - experimental y vector (e.g. sensitivity)
        % err    - errors associated     (e.g. SD)
        
        % mode   - what model of the submodels to be used
        %          'simple'
        %          'opponent'
        %          'simpleBi'
        %          'opponentBi'
        
        % linLog - linear or logarithmic fitting
        
        % comb_k - 2 column vector,                        [k1 k2]
        % contr  - initial guesses for contributions,      [m0 c0 r0]
        % p      - LWS/MWS ratio,                           e.g  0.62
        % densit - densities for the photopigments         [dens_M dens_C dens_R dens_CS]
        % fMe    - initial value for metaMelanop fraction   e.g. 0.5
        % oppon  - opponent model parameters (x0)          [fB0 fD0 fE0]
    
        % bound  - structure for the model bounds, names same as for initial parameters
        %
        %           * if the structure does not exist then that parameter
        %             is not going to be optimized at all
        %
        %           * if it is [] or NaN then the default values are used
        %
        %             .comb_k
        %             .contr
        %             .p
        %             .densit
        %             .fMe
        %             .oppon
        
        % costF  - if you want to define an other cost function rather than
        %          least-squares, this should be a string and then you do
        %          custom if-else-end switch
        %          default is ......   
        
        % options - structure containing general options for the model
        %             .    
    
    %% OPTIMIZE the weights for the contribution model
    % -----------------------------------------------             
        
        % Define the rod, cone, melanopsin contributions corresponding to the
        % experimentally acquired action spectrum      
        
            % redefine the variables for easier reading of this code
            
                % initial values
                m0      = contr(1);
                c0      = contr(2);
                r0      = contr(3);
                k1      = comb_k(1);
                k2      = comb_k(2);
                fMe0    = fMe;
                fB0     = oppon(1);
                fD0     = oppon(2);
                fE0     = oppon(3);                
                dens_M  = densit(1);
                dens_C  = densit(2);
                dens_CS = densit(3);
                dens_R  = densit(4); 
           
                
        % define the action spectra used in the optimization procedure
            callFrom = 'poolingModel';            
            [peak, templates] = poolingModel_defineNeededSpectra(mode, linLog, options);
            actSpectra = define_actionSpectra(lambda, peak, templates, path, callFrom);
            
            %             for ji = 1 : length(actSpectra)
            %                 hold on
            %                 plot(actSpectra{1}.lambda, actSpectra{ji}.spectrum)
            %                 title(actSpectra{ji}.header)
            %                 pause
            %             end
            
         % Parameter that can be changed during optimization
            x0 = [m0; c0; r0; k1; k2; fMe0; fB0; fD0; fE0; dens_R; dens_C; dens_CS; dens_M];
                
        % MANIPULATE THESE if you want to CONSTRAIN some variables
            lb = [0.0; 0.03; 0.1; 1.0; 10.0; 0.10; 0.0; 0.0; 0.00; 0.40; 0.38; 0.30; dens_M]; % lower bounds for x0 variables
            ub = [1.5; 1.12; 1.5; 1.0; 10.0; 1.4; 1.5; 1.5; 1.25; 0.40; 0.38; 0.30; dens_M]; % upper bounds for x0 variables                          
            
        % Define the contents statParam
        
            % Calculate the total sum of square of the experimental data
            % SS_diff = y - mean(y);           
            % SS_tot  = SS_diff' * SS_diff; 
            
            % Number of input data points
            statParam.N = length(~isnan(y));
            
            % Number of free parameters
            statParam.K = defineNoFreeParameters(x0, ub, lb, mode);             
                                    
        % Inequality estimation parameters, 'doc fmincon' for more info
        % when defined as empty ([]) these have no significance to anything
            A = [];
            b = [];
            Aeq = [];
            beq = [];            
            nonlcon = [];                     
         
         % Define the minimization function   
            output = 'optim';
            % options.modeNomogram = 'dynamic'; % updated on each iteration if 'dynamic', useful for fMe
            options.modeNomogram = 'static'; % for 'simple' mode to initialize the shapes only once
            options.biPhi = 0.70; % relative quantum efficiency
            f = @(x) poolingModel_function(x, lambda, y, err, mode, statParam, output, actSpectra, options, path);      

        % Define options for minimization function
            optimOpt = optimset('LargeScale','off', 'Display', 'on');
            optimOpt = optimset(optimOpt, 'Algorithm', 'interior-point');
            optimOpt = optimset(optimOpt, 'UseParallel', 'always');                
            
        %% Optimize using fmincon           
            [x, fval, exitflag, output] = fmincon(f,x0,A,b,Aeq,beq,lb,ub,nonlcon,optimOpt);
           
        % After optimization, obtain the spectrum and statistical
        % parameters with the optimized values
            output = 'spectrum';            
            spec = poolingModel_function(x, lambda, y, err, mode, statParam, output, actSpectra, options, path);
        
        %% Display information on plot window  
           % displayResults(x, lb, ub, fval, t, K, N, outSpectrum, handles, mode)              
        
           
        %% TEST
        %         close all
        %         figure('Color','w')     
        %         hold on
        %         e(1) = errorbar(lambda, y, err, 'ko');
        %         e(2) = plot(actSpectra{1}.lambda, spec, '-r');
        %         xlim([380 700]); ylim([0 1.2])
        %         hold off
       
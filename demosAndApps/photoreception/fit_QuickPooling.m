% Quick Pooling Model as used by McDougal and Gamlin
function fit_QuickPooling()        

    % Petteri Teikari, 2011, petteri.teikari@gmail.com

    % ORIGINAL:
    
        % Quick RF. 1974. 
        % A vector-magnitude model of contrast detection. 
        % Biological Cybernetics 16:65–67. 
        % http://dx.doi.org/10.1007/BF00271628.
    
    % McDougal and Gamlin:
    
        % McDougal DH, Gamlin PD. 2010. 
        % The Influence of Intrinsically Photosensitive Retinal Ganglion Cells on the Spectral Sensitivity and Response Dynamics of the Human Pupillary Light Reflex. 
        % Vision Res 50:72–87. 
        % http://dx.doi.org/10.1016/j.visres.2009.10.012.
    
    % NOTE!
    
        % No SWS cones in the model (original)
        % no dynamic optical densities
        % check the validity of the opponent model
        % mainly the original implemention works, and the opponent is
        % slightly unfinished
        

    %% General settings
    % ----------------    
    
        close all
        handles.scrsz = get(0,'ScreenSize'); % get screen size for plotting

    
        % Define pathnames   
        fileName = mfilename; fullPath = mfilename('fullpath');
        path.Code = strrep(fullPath, fileName, '');
        cd ..; cd ..;  path.lightLab = pwd; 
        path.common = fullfile(path.lightLab, 'lib', 'common');
        cd(path.common)
        path = setDefaultFolders(path); % set other folders using a subfunction  
        
        % modelType = 'equilibriumPupil';
        modelType = 'melatonin';

        if strcmp(modelType, 'melatonin') == 1
            handles.fitFromPoints = 1; % if 1, the data are the raw data points
        else
            handles.fitFromPoints = 0; 
        end
        
        % set default styling
        style = setDefaultFigureStyling(path);
        cd(path.Code)

    %% Model parameters
    % ----------------
    
        % LWS/MWS-ratio
        p = 0.62; % Ratio 1.625, ratio of standard observer, Pokorny, Jin & Smith 1993, http://dx.doi.org/10.1364/JOSAA.10.001304 (?)

        % Combination rule parameters
        k1 = 1; % fixed to 1 in the original paper (McDougal and Gamlin 2010)
        k2 = 10; % fixed to 10 in the original paper (McDougal and Gamlin 2010)

        % Cone/Rod/Melanopsin contribution parameters, initial values
        m = 1;
        c = 1;
        r = 1;
        
        % Bistable MELANOPSIN term
        b = 0.9; 
        
        % additional opponent cone parameters, from Kurtenbach et al.
        % (1999), http://dx.doi.org/10.1364/JOSAA.16.001541
        fB = 0.2; 
        fD = 0.2;       
        fE = 1.25; % constant at the paper
        
        % self-screening for photopigments
            
            % hard-coded in import_RetinalSensitivities, write another
            % wrapper if you want to change them parametrically


     %% IMPORT THE Spectral Sensitivities of Photoreceptors        
    
        % Corneal Sensitivities
        cd(path.photoreception)
        S_cornea = import_CornealSensitivities(path.templates);
        cd(path.Code)
        
        % Retinal Sensitivities
        cd(path.photoreception)
        S_retina = import_RetinalSensitivities(path.nomogram);
        cd(path.Code)

            S.opn4 = S_retina.Melanop.data; % assign to other variable name to ensure backward compatibility with old code
            S.rods = S_retina.Rhodop.data;
            S.SWS = S_retina.SWS.data;
            S.MWS = S_retina.MWS.data;
            S.LWS = S_retina.LWS.data;            
            S.cones = S_cornea.Vl;
            S.wavelength = S_retina.wavelength;
            
    % Initialize the figure
        cd(path.plotFunc)
        [figureHandle, handles] = initQuickPoolFigure(handles, style, S);
        cd(path.Code)
    
    %% OPTIMIZE the weights for the contribution model
    % -----------------------------------------------             
        
        % Define the rod, cone, melanopsin contributions corresponding to the
        % experimentally acquired action spectrum        
            
            % POSSIBLE MODELS
            % ---------------
           
            mode = 'original';
            % mode = 'opponent_wo_bistability';
            
            output = 'optim'; % 'optim' or 'spectrum'
                              % output in 'optim' when optimizing the parameters
                              % 'spectrum' when you want S_total out with
                              % statistic parameters        
           
            
        %% Define experimental spectrum (original data set)
        
            if strcmp(modelType, 'equilibriumPupil') == 1
               
                %{
                N = 11; % number of data points in the experimental data (for AIC)
                S_exp = S.opn4_bistable;                        
                %}
        
            elseif strcmp(modelType, 'melatonin') == 1
                    
                %% Import the data
    
                fileName = fullfile(path.templates, 'brainardThapan_melatoninSuppression_LIN_Rea2011.txt');
                tmp = importdata(fileName, '\t', 1);
                    x = tmp.data(:,1);
                    y = tmp.data(:,2);
                    err = zeros(length(x),1); % no SDs
                    
                hold on
                figureHandle.points = plot(x, y,'o'); set(figureHandle.points, 'Color', [.4 .4 .4])                
                hold off
                
                N = length(y); % number of data points in the experimental data (for AIC)
                S_exp(:,1) = x;
                S_exp(:,2) = y / max(y); % normalize
                
                set(figureHandle.p_dynamic, 'XData', S_exp(:,1))
                
            else
                
                % nothing
                
            end
            
            % Calculate the total sum of square of the experimental data
            SS_diff = S_exp(:,2) - mean(S_exp(:,2));           
            SS_tot = SS_diff' * SS_diff;
            
            
        %% Define the minimization function 
        
            tic; % start timing
            
            % self-screening for photopigments, no effect for fitting atm
            
                d_m = 0.00050;    % 0.50 in Tsujimura et al. (2010), http://dx.doi.org/10.1098/rspb.2010.0330
                                  % 0.00050 or very small, Do et al. (2009), http://dx.doi.org/10.1038/nature07682
                d_c = 0.38;    % 0.27 in Lamb (1995), http://dx.doi.org/10.1016/0042-6989(95)00114-F (diff. for S-cones!)
                               % 0.38 for M/L-cones, Stockman et al. (1999), http://dx.doi.org/10.1016/S0042-6989(98)00225-9
                d_cS = 0.30;   % 0.30 for S-cones, Stockman et al. (1999), http://dx.doi.org/10.1016/S0042-6989(98)00225-9
                d_r = 0.40;    % 0.4 in Lamb (1995), http://dx.doi.org/10.1016/0042-6989(95)00114-F

             % Parameter to be changed for minimization
                x0 = [m; c; r; k1; k2; b; fB; fD; fE; d_r; d_c; d_cS; d_m];
                
                % MANIPULATE THESE if you want to CONSTRAIN some variables
                lb = [0.0; 0.03; 0.1; 1.0; 10.0; 0.10; 0.0; 0.0; 0.00; 0.40; 0.38; 0.30; 0.00050]; % lower bounds for x0 variables
                ub = [1.5; 1.12; 0.2; 1.0; 10.0; 1.4; 1.5; 1.5; 1.25; 0.40; 0.38; 0.30; 0.00050]; % upper bounds for x0 variables
                
                % number of free parameters
                
                    K = 0; % initial value
                    if strcmp(mode, 'original') == 1 % || strcmp(mode, 'original w lens') == 1
                        for iK = 1 : 5; if ub(iK) ~= lb(iK); K = K + 1; end; end     
                        for iK = length(x0)-3 : length(x0); if ub(iK) ~= lb(iK); K = K + 1; end; end     
                    %{
                    elseif strcmp(mode, 'bistable') == 1 || strcmp(mode, 'bistable_lensCorr') == 1
                        for iK = 2 : 6; if ub(iK) ~= lb(iK); K = K + 1; end; end        
                        for iK = length(x0)-3 : length(x0); if ub(iK) ~= lb(iK); K = K + 1; end; end     
                    elseif strcmp(mode, 'opponent_wo_bistability') == 1
                        for iK = 1 : 5; if ub(iK) ~= lb(iK); K = K + 1; end; end  
                        for iK = 7 : length(x0); if ub(iK) ~= lb(iK); K = K + 1; end; end  
                    elseif strcmp(mode, 'opponent_w_bistability') == 1 || strcmp(mode, 'opponent_w_bistability_woLens') == 1
                        for iK = 2 : length(x0); if ub(iK) ~= lb(iK); K = K + 1; end; end  
                    %}
                    end
                                    
                % Inequality estimation parameters, 'doc fmincon' for more info
                A = [];
                b = [];
                Aeq = [];
                beq = [];            
                nonlcon = [];                     
            
            % f = @(x) compositeActionSpectrum(S_prefiltered.opn4_bistable, S_prefiltered, mode, x, figureHandle, N); % prefiltered            
            f = @(x) compositeActionSpectrum(S_exp, S, mode, x, figureHandle, N, K, SS_tot, output, style, handles);      

            % Define options for minimization function
                options = optimset('LargeScale','off', 'Display', 'off');
                
            
        %% Optimize
        
            % [x, fval] = fminsearch(f, x0, options); % unconstrained optimization            
            cd(path.library_fit)
            [x, fval] = fmincon(f,x0,A,b,Aeq,beq,lb,ub,nonlcon,options);
            
            % After optimization, obtain the spectrum and statistical
            % parameters with the optimized values
                output = 'spectrum';
                outSpectrum = compositeActionSpectrum(S_exp, S, mode, x, figureHandle, N, K, SS_tot, output, style, handles);
                outSpectrum.wavelength = S.wavelength;
                

            t.optimization = toc; % stop timing            
        
        %% Display information on plot window  
        cd(path.plotFunc)
        QuickPlotDisplayResults(x, lb, ub, fval, t, K, N, outSpectrum, handles, style, mode)              
        cd(path.Code)
        
        % autosave the figure      
        if style.imgOutautoSavePlot == 1            
            fileNameOut = ['fitQuickPooling_melatoninSuppression_', mode, '.png'];
            cd(path.figuresOut)
            saveToDisk(figureHandle, fileNameOut, style)
            cd(path.Code)
        end
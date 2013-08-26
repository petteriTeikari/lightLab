function out = compositeActionSpectrum(S_exp, S_sen, mode, x, figureHandle, N, K, SS_tot, output, style, handles)

    % S_exp                - experimentally acquired composite spectra that
    %                        can contain arbitrary weights of different photoreceptors
    % S_sen                - structure containing the spectral
    %                        sensitivities of different
    %                        photoreceptors / photoreceptor systems
    % x(0-5/6)
    % k1, k2, m, c, r      - model parameters from the original paper
    % b                    - bistable term added 
    % N                    - number of data points used to fit the
    %                        experimental curve
    % K                    - number of free parameters     
    
    % Original
        % x(1) - m
        % x(2) - c
        % x(3) - r
        % x(4) - k1
        % x(5) - k2

    % Added parameters
        % x(6) - b  , bistable term
        % x(7) - fB , S-cone term
        % x(8) - fD , opponent term 1
        % x(9) - fE , opponent term 2

    % Self-screening of the pigment
        % x(10)  - d_r, rods
        % x(11) - d_c, M/L-cones
        % x(12) - d_cS, S-cones
        % x(13) - d_m, melanopsin

    % for fB,fD,fE see the publication by Kurtenbach et al. (1999)
        % http://dx.doi.org/10.1364/JOSAA.16.001541

    % For the clarity of reading the code, the different terms can be
    % separated to individual variables (McDougal and Gamlin, original)
        
        %% McDougal, David H, and Paul D Gamlin. 
        % "The Influence of Intrinsically Photosensitive Retinal Ganglion Cells on the Spectral Sensitivity and Response Dynamics of the Human Pupillary Light Reflex." '
        % Vision Research (October 19, 2009. http://dx.doi.org/10.1016/j.visres.2009.10.012.
        
        % Equation (8)        
        
            lambda_full = (380:1:780)';
            
            % CORRECT THE SENSITIVITIES FOR SELF-SCREENING
            
                % melanopsin
                    % S_sen.opn4 = correctForDensity(S_sen.opn4, x(12));                

                % cones
                    % S_sen.cones % no correction                
                    if strcmp(mode, 'opponent_wo_bistability') == 1 || strcmp(mode, 'opponent_w_bistability') == 1 || strcmp(mode, 'opponent_w_bistability_woLens') 
                        %S_sen.SWS = correctForDensity(S_sen.SWS, x(11));
                        %S_sen.MWS = correctForDensity(S_sen.MWS, x(10));
                        %S_sen.LWS = correctForDensity(S_sen.LWS, x(10));
                    end

                % rods
                    % S_sen.rods % no correction
            
            % DEFINE THE TERMS 
            
                melanopsinTerm = (x(1) .* S_sen.opn4) .^ x(5);
                
                %{
                S_sen.opn4_wLens = uncorrectLinearSensitivityForPrefiltering(S_sen.opn4, handles.path.Code, handles.path.Sensitivity);
                    S_sen.opn4_wLens = S_sen.opn4_wLens ./ max(S_sen.opn4_wLens);                    
                melanopsinTerm_wLens = (x(1) .* S_sen.opn4_wLens) .^ x(5);
                
                % melanopsinBistableTerm = ((x(6) .* S_sen.opn4) .^ x(5)) + (((1- x(6)) .* S_sen.opn4meta) .^ x(5)); 
                melanopsinBistableTerm = ((x(6) .* S_sen.opn4_bistable) .^ x(5));
                melanopsinBistableTerm_wLens = ((x(6) .* S_sen.opn4_bistable_wLens) .^ x(5));
                %}
                
                coneTerm = (x(2) .* S_sen.cones) .^ x(4);
                rodTerm = (x(3) .* S_sen.rods) .^ x(4); 

                % OPPONENCY term with S-CONE term
                % modified from Kurtenbach et al. (1999)
                % http://dx.doi.org/10.1364/JOSAA.16.001541
                sConeTerm = (x(7) .* S_sen.SWS) .^ x(4); 
                opponencyTerm = (x(8) .* abs(S_sen.LWS - (x(9) .* S_sen.MWS))) .^ x(4); 
                
                    
            %% RE-DEFINE the terms if fit for data points are used only at
            %% the input data points
            if handles.fitFromPoints == 1 && strcmp(output, 'optim') == 1                    
                
                S_total(:,1) = S_exp(:,1); % the same x-vector (wavelength)          
                
                lambda_indices = extractIndices(S_total, lambda_full); % extract the indices matching the experimental data wavelengths to full lambda       

                % All the defined terms have the same wavelength range from
                % 380 nm to 780 nm in 1 nm steps so the same indices can be
                % used for all the terms.
                melanopsinTerm = melanopsinTerm(lambda_indices);
                %melanopsinTerm_wLens = melanopsinTerm_wLens(lambda_indices);
                %melanopsinBistableTerm = melanopsinBistableTerm(lambda_indices);
                %melanopsinBistableTerm_wLens = melanopsinBistableTerm_wLens(lambda_indices);
                coneTerm = coneTerm(lambda_indices);
                rodTerm = rodTerm(lambda_indices);
                sConeTerm = sConeTerm(lambda_indices);
                opponencyTerm = opponencyTerm(lambda_indices);
                
            elseif strcmp(output, 'spectrum') == 1                
                S_total(:,1) = lambda_full;
                
            else                               
                S_total(:,1) = S_exp(:,1); % the same x-vector (wavelength)
                
            end
        
        %% Different linear combination models defined
        
            if strcmp(mode, 'original') == 1
                % Combine the 3 above defined terms - ORIGINAL VERSION
                S_total = ( melanopsinTerm + ( (coneTerm + rodTerm).^(1/x(4)) ).^x(5)  ).^(1/x(5));
                
            elseif strcmp(mode, 'original w lens') == 1
                % Combine the 3 above defined terms - ORIGINAL VERSION
                S_total = ( melanopsinTerm_wLens + ( (coneTerm + rodTerm).^(1/x(4)) ).^x(5)  ).^(1/x(5));

            elseif strcmp(mode, 'bistable') == 1
                % Combine the 3 above defined terms - MODIFIED VERSION to include bistability
                S_total = ( melanopsinBistableTerm .^ (1/x(4)) + ( (coneTerm + rodTerm).^(1/x(4)) ).^x(5)  ).^(1/x(5));

            elseif strcmp(mode, 'bistable_lensCorr') == 1
                % Combine the 3 above defined terms - MODIFIED VERSION to
                % include bistability + uncorrect the lens density with
                % Stockmann template as done by Mure et al. (2009)             
                S_total = ( melanopsinBistableTerm_wLens .^ (1/x(4)) + ( (coneTerm + rodTerm).^(1/x(4)) ).^x(5)  ).^(1/x(5));

            elseif strcmp(mode, 'opponent_wo_bistability') == 1 % from Kurtenbach et al. (1999)   
                % add spectral opponency and S-cone contribution
                S_total = ( melanopsinTerm + ( (coneTerm + rodTerm + sConeTerm + opponencyTerm).^(1/x(4)) ).^x(5)  ).^(1/x(5));

            elseif strcmp(mode, 'opponent_w_bistability') == 1 % from Kurtenbach et al. (1999)   
                % add spectral opponency and S-cone contribution
                S_total = ( melanopsinBistableTerm + ( (coneTerm + rodTerm + sConeTerm + opponencyTerm).^(1/x(4)) ).^x(5)  ).^(1/x(5));

            elseif strcmp(mode, 'opponent_w_bistability_woLens') == 1 % from Kurtenbach et al. (1999)   
                % add spectral opponency and S-cone contribution
                S_total = ( melanopsinBistableTerm_wLens + ( (coneTerm + rodTerm + sConeTerm + opponencyTerm).^(1/x(4)) ).^x(5)  ).^(1/x(5));

            else
                disp('String mismatch?')
                disp('Define variable "mode" better')

            end
        
        % For the very final output when optimization is finished
        if strcmp(output, 'spectrum')
            whos
            S_total = S_total / max(S_total);  % scale output so that the maximum is one 
            lambda_indices = extractIndices(S_exp, lambda_full);
            out = compute_fittingStats(S_total(lambda_indices), S_exp, N, K, SS_tot, output); % Compute the STATS like R^2, AICc, etc.
            out.spectrum = S_total;
            set(figureHandle.p_dynamic, 'XData', lambda_full)
            set(figureHandle.total, 'XData', lambda_full, 'YData', S_total)
            
        else
            out = compute_fittingStats(S_total, S_exp, N, K, SS_tot, output); % Compute the STATS like R^2, AICc, etc.
            % whos
            set(figureHandle.total, 'XData', S_exp(:,1), 'YData', S_total)
            set(figureHandle.exp, 'XData', S_exp(:,1), 'YData', S_exp(:,2))     
        end
        
           
                
        
            
        %% individual photoreceptors responses
        
            % rods
            set(figureHandle.p_dynamic(1), 'YData', rodTerm)

            % cones
            set(figureHandle.p_dynamic(2), 'YData', coneTerm)
            
            % MELANOPSIN
            
                % melanopsin nomogram
                if strcmp(mode, 'original') == 1 || strcmp(mode, 'opponent_wo_bistability') == 1 % melanopsin, retinal
                    set(figureHandle.p_dynamic(3), 'YData', melanopsinTerm)                

                elseif strcmp(mode, 'original w lens') == 1 % melanopsin, corneal
                    set(figureHandle.p_dynamic(3), 'YData', melanopsinTerm_wLens)
                
                elseif strcmp(mode, 'bistable') == 1 || strcmp(mode, 'opponent_w_bistability') == 1 % melanopsin equilibrium, retinal
                    set(figureHandle.p_dynamic(3), 'YData', melanopsinBistableTerm)                
                
                elseif strcmp(mode, 'bistable_lensCorr') == 1 || strcmp(mode, 'opponent_w_bistability_woLens') == 1 % melanopsin equilibrium, corneal
                    set(figureHandle.p_dynamic(3), 'YData', melanopsinBistableTerm_wLens)
                    
                end

            drawnow 
        
            if strcmp(output, 'spectrum') && (strcmp(mode, 'original') == 1 || strcmp(mode, 'opponent_wo_bistability') == 1 || strcmp(mode, 'original w lens') == 1)
                axes(handles.sp(3)) %#ok<MAXES>
                leg = legend(['Rods, ', 'no density corr.'], ['Cones, ', 'no density corr.'], ['Melanopsin, density = ', num2str(x(13))], 3); 
                    legend('boxoff')
                set(leg, 'Location', 'NorthEast', 'EdgeColor', [.4 .4 .4])
                set(leg, 'FontName', style.fontName, 'FontSize', style.fontBaseSize-1)
                axes(handles.sp(1)) %#ok<MAXES>
                
            end
        
        
        %% SUBFUNCTION to get indices if data points are used for the model       
        function lambda_indices = extractIndices(S_total, lambda_full)
            lambda_indices = zeros(length(S_total(:,1)),1);

            for jk = 1 : length(S_total(:,1))
                lambda_indices(jk) = find(S_total(jk,1) == lambda_full);
            end                
            
            
        %% SUBFUNCTION to correct for axial peak density self-screening    
        function sensitivityOut = correctForDensity(sensitivityIn, density)

             % for the correction equation, see Lamb (1995) for example            
             % Lamb (1995) used 0.27 for cones and 0.40 for rods,             

             % input in LINEAR units, output also on LINEAR units
             one = ones(length(sensitivityIn),1); % unit vector             
             sensitivityOut = log10(one - (sensitivityIn .* (one  - (10 .^ (-1 * density))))) ./ (-1 * density);
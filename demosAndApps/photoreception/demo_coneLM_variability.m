% Quantifies the effect of L:M cone variability to theoretical visual sensitity V(lambda)
function demo_coneLM_variability()
    
    % Petteri Teikari, 2013
    close all    
    scrsz = get(0,'ScreenSize'); % get screen size for plotting
        
    
    %% SETTINGS
    
        % Define pathnames   
        fileName = mfilename; fullPath = mfilename('fullpath');
        path.Code = strrep(fullPath, fileName, '');
        cd ..; cd ..;  path.lightLab = pwd; 
        path.common = fullfile(path.lightLab, 'lib', 'common');
        cd(path.common)
        path = setDefaultFolders(path); % set other folders using a subfunction        
      
        % set default styling
        style = setDefaultFigureStyling(path);
        cd(path.Code)
        
    %% PARAMETERS
    
        % range of the variability (as vector)
        variabilityVector = 0.01 : 0.5 : 12; % multiplies the L-cone fundamental               
        
    
     %% GENERATE THE RETINAL SENSITIVITIES (Govardovskii 2000 nomogram)
                
        cd(path.nomogram)

        % common settings
        bands = 'both';
        linLog = 'lin';
        quantaE = {'Q'; 'E'};
        xRes = 1;
        xLims = [380 780];

        wavelength = (xLims(1):xRes:xLims(2))';                

        for i = 1 : length(quantaE)
        
            % MWS
            k = 1;
            peak_nm(k) = 530; % http://www.ncbi.nlm.nih.gov/pubmed/6140680
            density(k) = 0.38; % http://dx.doi.org/10.1016/S0042-6989(98)00225-9
            S{i}(:,k) = nomog_Govardovskii2000(peak_nm(k), bands, linLog, quantaE{i}, density(k), xRes, xLims);

            % LWS
            k = 2;
            peak_nm(k) = 560; % http://www.ncbi.nlm.nih.gov/pubmed/6140680
            density(k) = 0.38; % http://dx.doi.org/10.1016/S0042-6989(98)00225-9
            S{i}(:,k) = nomog_Govardovskii2000(peak_nm(k), bands, linLog, quantaE{i}, density(k), xRes, xLims);
        
        end            
        cd(path.Code)
        
    %% Generate ocular media filter
    
        offset = 0.111;
        age = 25;
        cd(path.ocularMedia)        
        lensFilter = agedLensFilter(age, wavelength, offset);
        cd(path.Code)
        
    %% GENERATE THE POSSIBLE V(LAMBDA) CURVES
    
        % preallocate
        vLambdaMatrix{1} = zeros(length(wavelength), length(variabilityVector));
        vLambdaMatrix{2} = zeros(length(wavelength), length(variabilityVector));
    
            % The standard observer weights for the L-cone fundamental is
            % 1.891 for the quantal sensitivity and
            % 1.98065 for the energy-based sensitivity, and the
            % corresponding divider for the equations are:        
            stdWeights = [1.891 1.98065]; % for Q and E
            divider = [2.80361 2.87091]; % for Q and E
            
                % See for details (pg. 95)
                % Stockman, A., and L.T. Sharpe. “Spectral Sensitivity.” 
                % In The Senses: A Comprehensive Reference, 87–100. New York: Academic Press, 2008. 
                % http://dx.doi.org/10.1016/B978-012370880-9.00300-5.
                %
                % or
                % Stockman, Andrew, and Lindsay T. Sharpe. 
                % “The Spectral Sensitivities of the Middle- and Long-wavelength-sensitive Cones 
                % Derived from Measurements in Observers of Known Genotype.” 
                % Vision Research 40, no. 13 (June 16, 2000): 1711–1737. 
                % http://dx.doi.org/10.1016/S0042-6989(00)00021-3            
                
                % Mismatch between tabulated values results actually now as
                % I generated synthetically the fundamentals rather than
                % using the tabulated fundamentals for example from 
                % http://www.cvrl.org/

        peakNm = zeros(length(quantaE),1);
        parfor i = 1  : length(quantaE)
            for ij = 1 : length(variabilityVector)
                
                % values
                vLambdaMatrix{i}(:,ij) = ((variabilityVector(ij) * S{i}(:,2)) + S{i}(:,1)) / divider(i);                
                vLambdaMatrix{i}(:,ij) = vLambdaMatrix{i}(:,ij) .* lensFilter; % correct for lens
                vLambdaMatrix{i}(:,ij) = vLambdaMatrix{i}(:,ij) / max(vLambdaMatrix{i}(:,ij)); % normalize
                
                % legend
                [~,index] = max(vLambdaMatrix{i}(:,ij));
                peakNm(i) = wavelength(index);                
                legendString{i}{ij} = ['w = ', num2str(variabilityVector(ij)), ', peak = ' num2str(peakNm(i),'%3.0f'), ' nm'];
                
            end            
        end
    
    %% PLOT THE VARIABILITY
    
        fig = figure('Color', 'w');
            set(fig, 'Position', [0.01*scrsz(3) 0.11*scrsz(4) 0.91*scrsz(3) 0.47*scrsz(4)])
        
            rows = 1;
            cols = 2;
            
            j = 1;
            sp(j) = subplot(rows,cols,j);
                p{j} = plot(wavelength, vLambdaMatrix{j});
                tit(j) = title('Quantal Sensitivity');
                lab(j,1) = xlabel('Wavelength [nm]');
                lab(j,2) = ylabel('Relative sensitivity');
                leg(j) = legend(legendString{j});
                    legend('boxoff')
                
            j = 2;
            sp(j) = subplot(rows,cols,j);
                p{j} = plot(wavelength, vLambdaMatrix{j});
                tit(j) = title('Energy-based Sensitivity');
                lab(j,1) = xlabel('Wavelength [nm]');
                lab(j,2) = ylabel('Relative sensitivity');
                leg(j) = legend(legendString{j});
                    legend('boxoff')

            set(sp, 'XLim', [400 780])
                set(sp, 'FontName', style.fontName, 'FontSize', style.fontBaseSize)  
                set(lab, 'FontName', style.fontName, 'FontSize', style.fontBaseSize, 'FontWeight', 'bold')    
                set(tit, 'FontName', style.fontName, 'FontSize', style.fontBaseSize+1, 'FontWeight', 'bold')            
                set(leg, 'FontSize', style.fontBaseSize-1, 'FontName', style.fontName)
                
                
        % autosave the figure      
        if style.imgOutautoSavePlot == 1            
            fileNameOut = ['variability_LMcones_', linLog, '.png'];
            cd(path.figuresOut)
            saveToDisk(fig, fileNameOut, style)
            cd(path.Code)
        end
            
            
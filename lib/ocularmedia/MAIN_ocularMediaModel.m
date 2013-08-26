function [templates, handles] = MAIN_ocularMediaModel(handles)    
    
    if  nargin == 0 % if no input is provided, use default age        
        disp('--'); disp('Generating Ocular Media Density'); disp('--'); 
        close all % close all open figures    
        handles.scrsz = get(0,'ScreenSize'); % get screen size for plotting

        handles.path.code = mfilename('fullpath');
        handles.path.code = strrep(handles.path.code,'MAIN_ocularMediaModel','');
        handles.path.templates = handles.path.code; %fullfile(handles.path.code, 'templates');        
        
        handles.age = 25;
        handles.templateWavelengths = [300 800]; % nm
        handles.templateSpectralResolution = 0.1; % nm      
        handles.smallPupilCorrection = 0;
        
        % templates.lens.vanDeKraats2007.neutralOffset = 0.111;
        templates.lens.vanDeKraats2007.neutralOffset = 0;
        
        plotOn = 1;
        
    else        
        handles.templateWavelengths = handles.spectrumTruncationLimits; % nm
        handles.templateSpectralResolution = handles.spectralResolution; % nm          
        plotOn = 0;        
        templates.lens.vanDeKraats2007.neutralOffset = handles.vanDeKraats2007_neutralOffset;
        
    end        

    %% General settings               
        handles.input_headerRows = 1; % number of header rows
        handles.input_delimiter = '\t'; % tab-delimited 
        A = handles.age; % use another variable
        templates.lambda = (linspace(handles.templateWavelengths(1),...
                                     handles.templateWavelengths(2),...
                                     (((handles.templateWavelengths(2)-handles.templateWavelengths(1)) / handles.templateSpectralResolution) + 1)) )';    
        tic;  
        
    %% RAYLEIGH SCATTER      
    
        % van de Kraats and van Norren (2007) - RAYLEIGH SCATTER
        % http://dx.doi.org/10.1364/JOSAA.24.001842
        % + http://dx.doi.org/10.1016/j.exer.2005.09.007
        templates.scatter = calc_rayleighScatter(A, templates.lambda);                
        
    %% CORNEA     
    
        % Van Den Berg, T.J.T.P., and K.E.W.P. Tan. 
        % "Light transmittance of the human cornea from 320 to 700 nm for different ages." 
        % Vision Research 34, no. 11 (June 1994): 1453-1456. 
        % http://dx.doi.org/10.1016/0042-6989(94)90146-5.
        templates.cornea_vanDenBergTan1994 = calc_corneaVanDenBerg1994(templates.lambda);            
                
    %% HUMORS (~WATER)  
    
        % Smith, Raymond C., and Karen S. Baker. 
        % "Optical properties of the clearest natural waters (200-800 nm)."
        % Applied Optics 20, no. 2 (January 15, 1981): 177-184. 
        % http://dx.doi.org/10.1364/AO.20.000177.
        templates.humors = calc_humorTransmittance(templates.lambda);
        
    %% MACULAR PIGMENT
    
        % CIE. CIE 170-1:2006 Fundamental Chromaticity Diagram with Physiological Axes, n.d. 
        % http://div1.cie.co.at/?i_ca_id=551&pubid=48.   
        [templates.macularPigment.Walraven2003, templates.macularPigment.Walraven2003_norm] = ...
            calc_macularPigment_walraven2003(handles.templateWavelengths, handles.templateSpectralResolution);    
        
    %% LENS DENSITY               
        
        % TEMPLATES

            %% van Norren, Dirk, and Johannes J. Vos. 
            % "Spectral transmission of the human ocular media." 
            % Vision Research 14, no. 11 (November 1974): 1237-1244. 
            % http://dx.doi.org/10.1016/0042-6989(74)90222-3.
            templates.lens.vanNorren1974 = import_vanNorren1974_template(templates.lambda);
            
            %% Stockman, Andrew, and Lindsay T. Sharpe. 
            % "The spectral sensitivities of the middle- and long-wavelength-sensitive cones derived from measurements in observers of known genotype." 
            % Vision Research 40, no. 13 (June 16, 2000): 1711-1737. 
            % http://dx.doi.org/10.1016/S0042-6989(00)00021-3.
            templates.lens.StockmanSharpe2000 = import_stockmanSharpe2000_template(templates.lambda);                 
                
        % MODELS                            
                
            %% Pokorny, Joel, Vivianne C. Smith, and Margaret Lutze. 
            % "Aging of the human lens." 
            % Applied Optics 26, no. 8 (1987): 1437. 
            % http://dx.doi.org/10.1364/AO.26.001437       
            templates.lens.Pokorny1986 = lensModel_pokorny1986(templates.lambda, A, handles.smallPupilCorrection);            

            %% Savage, G L, G Haegerstrom-Portnoy, A J Adams, and S E Hewlett. 
            % "Age changes in the optical density of human ocular media." 
            % Clinical vision sciences 8, no. 1 (1993): 97-108. 
            % http://cat.inist.fr/?aModele=afficheN&cpsidt=4660634.
            templates.lens.savage1993.total = zeros(length(templates.lambda),1); % NOT IMPLEMENTED YET
        
            %% Zagers, Niels P. A., and Dirk van Norren. 
            % "Absorption of the eye lens and macular pigment derived from the reflectance of cone photoreceptors.” 
            % Journal of the Optical Society of America A 21, no. 12 (December 1, 2004): 2257-2268. 
            % http://dx.doi.org/10.1364/JOSAA.21.002257.
            templates.lens.Zagers2004 = lensModel_zagersNorren2004(A, templates.lambda);
                                        
            %% van de Kraats, Jan, and Dirk van Norren. 
            % “Optical density of the aging human ocular media in the visible and the UV"
            % Journal of the Optical Society of America. A, Optics, Image Science, and Vision 24, no. 7 (July 2007): 1842-57. 
            % http://dx.doi.org/10.1364/JOSAA.24.001842.
            templates.lens.vanDeKraats2007 = lensModel_vanDeKraats2007(A, templates.lambda, templates.lens.vanDeKraats2007.neutralOffset);         
                    
        
    %% PLOT the results if wanted        
        handles.time.templateImportAndCreation = toc;                
        cd(handles.path.code)
        
        if plotOn == 1
            tic;
            plotTheData(handles, templates)
            handles.time.plotting = toc;
        end
        
        
        
    % subfunction to plot the data
    function plotTheData(handles, templates)        
        
        A = handles.age;
        
        
        %{
        figure('Color', [1 1 1], 'Position', ...
            [0.04*handles.scrsz(3) 0.21*handles.scrsz(4) 0.90*handles.scrsz(3) 0.70*handles.scrsz(4)])
        
            p(1:5) = plot(templates.lambda, 10 .^ (-1 * templates.scatter.rayleighKraatsNorren2007_largeFields),...
            templates.lambda, 10 .^ (-1 * templates.lens.vanDeKraats2007.TP),...
            templates.lambda, 10 .^ (-1 * templates.lens.vanDeKraats2007.LY),...   
            templates.lambda, 10 .^ (-1 * templates.lens.vanDeKraats2007.LOUV),...   
            templates.lambda, 10 .^ (-1 * templates.lens.vanDeKraats2007.LO));
            
            leg(1) = legend(['Rayleigh Scatter, a=', num2str(handles.age)], 'Tryptophan', 'Young Lens (LY, van de Kraats)', 'Old Lens UV (LOUV, van de Kraats)', 'Old Lens (LO, van de Kraats)', 5);
            xlim([handles.templateWavelengths(1) handles.templateWavelengths(2)])
        %}
        
        
        %{
        figure('Color', [1 1 1], 'Position', ...
            [0.04*handles.scrsz(3) 0.21*handles.scrsz(4) 0.90*handles.scrsz(3) 0.70*handles.scrsz(4)])
        
            p(1:2) = plot(templates.lambda, 10 .^ (-1 * templates.lens.Zagers2004.youngLens),...
            templates.lambda, 10 .^ (-1 * templates.lens.Zagers2004.oldLens));
            
            leg(1) = legend('Young Lens (LY)', 'Old Lens (LO)', 2);
            xlim([handles.templateWavelengths(1) 600])
        %}

        
        figure('Name', 'van de Kraats and van Norren (2007', 'Color', [1 1 1], 'Position', ...
            [0.04*handles.scrsz(3) 0.21*handles.scrsz(4) 0.90*handles.scrsz(3) 0.70*handles.scrsz(4)])        
            p(1:5) = plot(templates.lambda, 10 .^ (-1 * templates.scatter.rayleighKraatsNorren2007_largeFields),...
                 templates.lambda, 10 .^ (-1 * templates.lens.vanDeKraats2007.TP),...                       
                 templates.lambda, 10 .^ (-1 * templates.lens.vanDeKraats2007.LY),...   
                 templates.lambda, 10 .^ (-1 * templates.lens.vanDeKraats2007.LOUV),...   
                 templates.lambda, 10 .^ (-1 * templates.lens.vanDeKraats2007.LO));
             
            leg(2) = legend(['Rayleigh Scatter, a=', num2str(handles.age)], 'Tryptophan', 'Young Lens (LY, van de Kraats)', 'Old Lens UV (LOUV, van de Kraats)', 'Old Lens (LO, van de Kraats)', 5);
            xlim([handles.templateWavelengths(1) handles.templateWavelengths(2)])
            title('Transmittance (LINEAR)')
            set(leg(2), 'Location', 'SouthEast')
            set(p([1 2 3]), 'LineStyle', '-')
        
            return
            
        figure('Color', [1 1 1], 'Position', ...
            [0.05*handles.scrsz(3) 0.20*handles.scrsz(4) 0.90*handles.scrsz(3) 0.70*handles.scrsz(4)])
        
            subplot(2,2,1)
            p([1:9]) = plot(templates.lambda, templates.scatter.rayleighKraatsNorren2007_largeFields,...
                 templates.lambda, templates.lens.vanDeKraats2007.TP,...
                 templates.lambda, templates.humors.density,...
                 templates.lambda, templates.lens.Zagers2004.youngLens,...
                 templates.lambda, templates.lens.Zagers2004.oldLens,...             
                 templates.lambda, templates.lens.vanDeKraats2007.LY,...   
                 templates.lambda, templates.lens.vanDeKraats2007.LOUV,...   
                 templates.lambda, templates.lens.vanDeKraats2007.LO,...   
                 templates.lambda, templates.macularPigment.Walraven2003);
            leg(1) = legend(['Rayleigh Scatter, a=', num2str(handles.age)], 'Tryptophan', ['Humors, ', num2str(templates.humors.water_l*1000, 2), ' mm of water'], 'Young Lens (Zagers)', 'Old Lens (Zagers)', 'Young Lens (LY, van de Kraats)', 'Old Lens UV (LOUV, van de Kraats)', 'Old Lens (LO, van de Kraats)', 'Macular Pigment', 9);
            xlim([300 800])
            ylim([0 6]) 
            title('Optical Density (LOGARITHMIC)')
            set(p([1 2 3]), 'LineStyle', '--')
        
        subplot(2,2,2)        

            p([1:9]) = plot(templates.lambda, 10 .^ (-1 * templates.scatter.rayleighKraatsNorren2007_largeFields),...
                 templates.lambda, 10 .^ (-1 * templates.lens.vanDeKraats2007.TP),...         
                 templates.lambda, 10 .^ (-1 * templates.humors.density),...
                 templates.lambda, 10 .^ (-1 * templates.lens.Zagers2004.youngLens),...
                 templates.lambda, 10 .^ (-1 * templates.lens.Zagers2004.oldLens),...                 
                 templates.lambda, 10 .^ (-1 * templates.lens.vanDeKraats2007.LY),...   
                 templates.lambda, 10 .^ (-1 * templates.lens.vanDeKraats2007.LOUV),...   
                 templates.lambda, 10 .^ (-1 * templates.lens.vanDeKraats2007.LO),...   
                 templates.lambda, 10 .^ (-1 * templates.macularPigment.Walraven2003_norm));
            leg(2) = legend(['Rayleigh Scatter, a=', num2str(handles.age)], 'Tryptophan', ['Humors, ', num2str(templates.humors.water_l*1000, 2), ' mm of water'], 'Young Lens (Zagers)', 'Old Lens (Zagers)', 'Young Lens (LY, van de Kraats)', 'Old Lens UV (LOUV, van de Kraats)', 'Old Lens (LO, van de Kraats)', 'Macular Pigment', 9);
            xlim([300 800])
            title('Transmittance (LINEAR)')
            set(p([1 2 3]), 'LineStyle', '--')
            
        subplot(2,2,3)
                    
            plot(templates.lambda, templates.lens.Pokorny1986.totalLensAgeEstimation,...
                 templates.lambda, templates.lens.savage1993.total,...
                 templates.lambda, templates.lens.StockmanSharpe2000,...
                 templates.lambda, templates.lens.Zagers2004.totalLens,...
                 templates.lambda, templates.lens.vanDeKraats2007.totalMedia)
            leg(3) = legend('Pokorny et al. (1986)', 'Savage et al. (1993)', 'Stockman and Sharpe STD (2000)', 'Zagers and van Norren (2004)', 'van de Kraats and van Norren (2007)', 5);
            xlim([handles.templateWavelengths(1)+20 handles.templateWavelengths(2)-80])
            title(['Optical Density (LOGARITHMIC), age = ', num2str(A), ' years'])               
            
        
        subplot(2,2,4)
        
            plot(templates.lambda, 10 .^ (-1 * templates.lens.Pokorny1986.totalLensAgeEstimation),...    
                 templates.lambda, 10 .^ (-1 * templates.lens.savage1993.total),...
                 templates.lambda, 10 .^ (-1 * templates.lens.StockmanSharpe2000),...
                 templates.lambda, 10 .^ (-1 * templates.lens.Zagers2004.totalLens), ...
                 templates.lambda, 10 .^ (-1 * templates.lens.vanDeKraats2007.totalMedia))
            leg(4) = legend('Pokorny et al. (1986)', 'Savage et al. (1993)', 'Stockman and Sharpe STD (2000)', 'Zagers and van Norren (2004)', 'van de Kraats and van Norren (2007)', 5);
            xlim([handles.templateWavelengths(1)+20 handles.templateWavelengths(2)-80])
            %xlim([400 420])
            %ylim([0.01 0.11])
            title(['Transmittance (LINEAR)), age = ', num2str(A), ' years'])
            
        set(leg([1 3]), 'Location', 'NorthEast')
        set(leg([2 4]), 'Location', 'SouthEast')
        set(leg, 'FontSize',6)
        
        %{
        figure('Color', [1 1 1])
        
        subplot(2,1,1)
                plot(templates.lambda, templates.cornea.vanDenBergTan1994.transmittance.Direct,...
                    templates.lambda, templates.cornea.vanDenBergTan1994.transmittance.Total)
                title('transmittance LOG')
                xlim([380 780])
        subplot(2,1,2)                
                plot(templates.lambda, (10 .^ templates.cornea.vanDenBergTan1994.transmittance.Direct) / max(10 .^ templates.cornea.vanDenBergTan1994.transmittance.Direct),...
                    templates.lambda, 10 .^ templates.cornea.vanDenBergTan1994.transmittance.Total / max(10 .^ templates.cornea.vanDenBergTan1994.transmittance.Total))
                title('transmittance LIN')
                xlim([380 780])
        %}
        
        
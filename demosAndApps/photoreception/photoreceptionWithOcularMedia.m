% Simulate how peak spectral efficicency changes due to ocular media filtration
function photoreceptionWithOcularMedia()

    close all    
    scrsz = get(0,'ScreenSize'); % get screen size for plotting
    
    disp(' ')
    disp('  Photoreception Demo')
    disp('  Petteri Teikari')
    disp('  petteri.teikari@gmail.com')
    disp(' ')
    
    
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
        
    %% PARAMETER
        
        % Ocular Media parameters
            age = [25 65];
            offset = 0.111;
            lambda_ocMedia = (380:1:780)'; % have to be the same as for light sources
            
        % Melanopsin parameters
        
           % common settings
            bands = 'both';
            linLog = 'lin';
            quantaE = 'Q';
            xRes = 1;
            xLims = [380 780];            
            wavelength = (xLims(1):xRes:xLims(2))';
    
            % Pigment properties
            peak_nm = 479 + 5; % nm, 5 nm of Kundt's shift from 479 nm e.g.
                               % Bowmaker(1972) http://dx.doi.org/10.1016/0042-6989(72)90149-6
            peak_nm = 479; % for human melanopsin (OPN4) by Bailes and Lucas 2013
                           % http://dx.doi.org/10.1098/rspb.2012.2987
            density = 0.0001; % OD, Do et al. http://dx.doi.org/10.1038/nature07682
        
            % create nomograms
            cd(path.nomogram)
            sensitivity{1} = nomog_Govardovskii2000(peak_nm, bands, linLog, quantaE, density, xRes, xLims);            
                sensitivity{1} = sensitivity{1} / max(sensitivity{1});
            cd(path.Code)
            
            % accessory variables, for rate constant calculation
            alpha_multip = 1;
            sigma = 1;
            nm_spacing = 10^-9;            

    
    %% Calculations
    
        % Correct for ocular media        
            
            cd(path.ocularMedia)
            lensFilter{1} = agedLensFilter(age(1), lambda_ocMedia, offset);
            lensFilter{2} = agedLensFilter(age(2), lambda_ocMedia, offset);
            cd(path.Code)
            
            sensitivity{2} = sensitivity{1} .* lensFilter{1};
            sensitivity{3} = sensitivity{1} .* lensFilter{2};            
           
            % calculate the peak wavelengths
            [c,i] = max(sensitivity{1});
                peakNm(1) = wavelength(i);
            [c,i] = max(sensitivity{2});
                peakNm(2) = wavelength(i);
            [c,i] = max(sensitivity{3});
                peakNm(3) = wavelength(i);
            
    %% PLOT
        
        fig = figure('Color', 'w');
            set(fig, 'Position', [0.2*scrsz(3) 0.1*scrsz(4) 0.72*scrsz(3) 0.8*scrsz(4)])

            rows = 2;
            cols = 2;

            % legend
           legendStr{1} = sprintf('%s%s%s', 'Retina, \lambda_m_a_x = ', num2str(peakNm(1)), ' nm');
           legendStr{2} = sprintf('%s%s%s%s', num2str(age(1)), 'yr old cornea, \lambda_m_a_x = ',  num2str(peakNm(2)), ' nm');
           legendStr{3} = sprintf('%s%s%s%s', num2str(age(2)), 'yr old cornea, \lambda_m_a_x = ',  num2str(peakNm(3)), ' nm');               

            i = 1;
            sp(i) = subplot(rows,cols,i);
            p(i,:) = plot(wavelength, sensitivity{1}, wavelength, sensitivity{2}, wavelength, sensitivity{3});

                leg(i) = legend(legendStr{1}, legendStr{2}, legendStr{3}, 3);
                legend('boxoff')  
                tit(i) = title('Absolute');

            i = 2;
            sp(i) = subplot(rows,cols,i);
            p(i,:) = plot(wavelength, sensitivity{1}/max(sensitivity{1}), wavelength, sensitivity{2}/max(sensitivity{2}), wavelength, sensitivity{3}/max(sensitivity{3}));

                leg(i) = legend(legendStr{1}, legendStr{2}, legendStr{3}, 3);
                legend('boxoff')  
                tit(i) = title('Normalized');

            i = 3;
            sp(i) = subplot(rows,cols,i);
            p(i,:) = semilogy(wavelength, sensitivity{1}, wavelength, sensitivity{2}, wavelength, sensitivity{3});

                leg(i) = legend(legendStr{1}, legendStr{2}, legendStr{3}, 3);
                legend('boxoff')  
                tit(i) = title('Absolute');

            i = 4;
            sp(i) = subplot(rows,cols,i);
            p(i,:) = semilogy(wavelength, sensitivity{1}/max(sensitivity{1}), wavelength, sensitivity{2}/max(sensitivity{2}), wavelength, sensitivity{3}/max(sensitivity{3}));

                leg(i) = legend(legendStr{1}, legendStr{2}, legendStr{3}, 3);
                legend('boxoff')  
                tit(i) = title('Normalized');

        % style

            % subplots (gca)
            set(sp, 'FontName', style.fontName, 'FontSize', style.fontBaseSize)
            set(tit, 'FontName', style.fontName, 'FontSize', style.fontBaseSize+2, 'FontWeight', 'bold')
            set(sp, 'XColor', style.colorGray, 'YColor', style.colorGray, 'XLim', [400 650])
                set(sp(3:4),  'YLim', [10^-4 1])

            % line plots            
            set(p(:,1), 'Color', style.colorPlot(1,:))
            set(p(:,2), 'Color', style.colorPlot(2,:))
            set(p(:,3), 'Color', style.colorPlot(3,:))

            % legend % text
            set(leg, 'Location', 'NorthEast', 'FontName', style.fontName, 'FontSize', style.fontBaseSize)
            set(leg(3:4), 'Location', 'SouthWest')


                
                
        %% EXPORT TO DISK

           % autosave the figure      
            if style.imgOutautoSavePlot == 1            
                fileNameOut = ['photoreceptionWithOcularMedia.png'];
                cd(path.figuresOut)
                saveToDisk(fig, fileNameOut, style)
                cd(path.Code)
            end
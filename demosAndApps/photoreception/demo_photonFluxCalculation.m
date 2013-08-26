% Quantifies the error between different ways to compute photon flux
function demo_photonFluxCalculation()

    close all    
    scrsz = get(0,'ScreenSize'); % get screen size for plotting
    
    % typically in vision research / chronobiological photoreception papers
    % the conversion is done using the peak wavelength of the stimulus
    % rather than using all of the wavelengths (around peak as well)
    
    disp(' ')
    disp('  PHOTON Flux Calculation DEMO')
    disp('  Petteri Teikari, 2011, INSERM, Lyon, France')
    disp('  petteri.teikari@gmail.com')
    disp(' ')
    
    %% Settings
    
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
    
    %% Constants
    
        h = 6.62606896 * 10^-34; % Planck's constant [J*s]
        c = 299792458; % Speed of light [m/s]  

    %% Parameters
    
        % photon densitities to be tested
        phFluxes = (linspace(10^10, 10^18, 256))';
        phFLux_cnst = 10^12;
        
        % hbws to be simulated
        hbws = (linspace(0.1, 100, 256))';
        hbws_cnst = 10; % when this is not varied
        
        % peak wavelengths to be tested
        xRes = 1; % the same for lambda and peak for simplicity
        peakNm = (380:xRes:780)';
        peakNm_cnst = 480; % when this is not varied
        
        % lambda vector for the light SPD
        lambda = (380:xRes:780)';
        
        % photon energy per lambda
        photonEnergies = (h * c) ./ (lambda * 10^-9); % [J]
        
        % FIGURE autosave options
        res = '-r300';
        antiAlias = '-a1';
    
    %% Calculations
    
        % we can compare the relative error between calculating the photon
        % flux from TOTAL irradiance (measured for example with IL-1700) 
        % either using only the peak wavelength or the whole spectrum as a
        % function of the variables defined above
        
        % Now as we have 3 variables and 1 output variable (4 dimensions of
        % data it is hard to visualize them all in one plot so we create
        % three different matrices
        
        %% CREATE LIGHT SPDs (defined in PHOTON FLUX)
        
            % preallocate memory for light SPD matrices
            SPD_peakHbw = zeros(length(lambda), length(peakNm), length(hbws));
            SPD_peakIrr = zeros(length(lambda), length(peakNm), length(phFluxes));
            SPD_HbwIrr  = zeros(length(lambda), length(hbws), length(phFluxes));

            tic
            disp('  ... 1st Light SPDs')
            % as a function of PEAK WAVELENGTH and HBW
            for i = 1 : length(peakNm)
                for j = 1 : length(hbws)                     
                    SPD_peakHbw(:,i,j) = lightScaleToPhotons(photonEnergies, ...
                                         monochromaticLightAsGaussian(peakNm(i), hbws(j), lambda), ...
                                         phFLux_cnst);                    
                end            
            end

            disp('  .... 2nd Light SPDs')
            % as a function of PEAK WAVELENGTH and PHOTON FLUX
            for i = 1 : length(peakNm)
                for j = 1 : length(phFluxes)
                    SPD_peakIrr(:,i,j) = lightScaleToPhotons(photonEnergies, ...
                                         monochromaticLightAsGaussian(peakNm(i), hbws_cnst, lambda), ...
                                         phFluxes(j));
                end            
            end

            disp('  ..... 3rd Light SPDs')
            % as a function of HBWs and PHOTON FLUX
            for i = 1 : length(hbws)            
                for j = 1 : length(phFluxes)           
                    SPD_HbwIrr(:,i,j) = lightScaleToPhotons(photonEnergies, ...
                                        monochromaticLightAsGaussian(peakNm_cnst, hbws(i), lambda), ...
                                        phFluxes(j));
                end            
            end
            time.lightSPD_creation = toc;
            
        
        %% Convert the LIGHT SPDs to IRRADIANCE
        
            % length of 1st dimension is now the length of lambda, so this
            % could have been vectorized also but is probably slightly more
            % intuitive to read like this for novice programmers?
            
            % preallocate memory for light SPD matrices
            SPD_peakHbw_irr = zeros(length(lambda), length(peakNm), length(hbws));
            SPD_peakIrr_irr = zeros(length(lambda), length(peakNm), length(phFluxes));
            SPD_HbwIrr_irr  = zeros(length(lambda), length(hbws), length(phFluxes));
        
            tic
            disp(' ')
            disp('  ... 1st Light SPDs: Irrad Conversion')
            % as a function of HBW and PEAK WAVLENGTH
            for i = 1 : length(peakNm)            
                for j = 1 : length(hbws)           
                    SPD_peakHbw_irr(:,i,j) = SPD_peakHbw(:,i,j) ./ photonEnergies;                    
                end            
            end

            disp('  .... 2nd Light SPDs: Irrad Conversion')
            % as a function of PEAK WAVELENGTH and PHOTON FLUX
            for i = 1 : length(peakNm)            
                for j = 1 : length(phFluxes)           
                    SPD_peakIrr_irr(:,i,j) = SPD_peakIrr(:,i,j) ./ photonEnergies; 
                end            
            end

            disp('  ..... 3rd Light SPDs: Irrad Conversion')
            % as a function of HBWs and PHOTON FLUX
            for i = 1 : length(hbws)            
                for j = 1 : length(phFluxes)           
                    SPD_HbwIrr_irr(:,i,j) = SPD_HbwIrr(:,i,j) ./ photonEnergies;
                end            
            end
            time.irradianceConversion = toc;
        
         
        %% Calculate now the photon densities from the converted irradiances
            
            % The idea now is that the initial light SPDs defined in photon
            % flux represents the "ground truth" and now we compare the
            % difference resulting from using only the PEAK WAVELENGTHS in
            % the following calculations
            
                        
            % preallocate memory for light SPD matrices
            SPD_peakHbw_onlyPeak = zeros(length(lambda), length(peakNm), length(hbws));
            SPD_peakIrr_onlyPeak = zeros(length(lambda), length(peakNm), length(phFluxes));
            SPD_HbwIrr_onlyPeak  = zeros(length(lambda), length(hbws), length(phFluxes));
        
            tic
            disp(' ')
            disp('  ... 1st Light SPDs: Only Peak')
            % as a function of HBW and PEAK WAVELENGTH
            for i = 1 : length(peakNm)            
                for j = 1 : length(hbws)                        
                    ind = find(lambda == peakNm(i), 1);
                    photonEnergyAtThePeak = photonEnergies(ind);
                    SPD_peakHbw_onlyPeak(:,i,j) = SPD_peakHbw_irr(:,i,j) .* photonEnergyAtThePeak;                    
                end            
            end

            disp('  .... 2nd Light SPDs: Only Peak')
            % as a function of PEAK WAVELENGTH and PHOTON FLUX
            for i = 1 : length(peakNm)            
                for j = 1 : length(phFluxes)                     
                    ind = find(lambda == peakNm(i), 1);
                    photonEnergyAtThePeak = photonEnergies(ind);
                    SPD_peakIrr_onlyPeak(:,i,j) = SPD_peakIrr_irr(:,i,j) .* photonEnergyAtThePeak; 
                end            
            end

            disp('  ..... 3rd Light SPDs: Only Peak')
            % as a function of HBWs and PHOTON FLUX            
            ind = find(lambda == peakNm_cnst, 1);
            photonEnergyAtThePeak = photonEnergies(ind);
            for i = 1 : length(hbws)            
                for j = 1 : length(phFluxes)
                    SPD_HbwIrr_onlyPeak(:,i,j) = SPD_HbwIrr_irr(:,i,j) .* photonEnergyAtThePeak;
                end            
            end
            time.photonDensityBackConversion = toc;
            
        %% We can reduce the dimensionality of now 3D-matrices
        % by integrating the wavelengths so that you have a total photon
        % flux instead of photon flux per wavelength                   
            
            tic
            phFlux_total_peakHbw = totalFluxFromSpectralFlux(SPD_peakHbw);
            phFlux_total_peakIrr = totalFluxFromSpectralFlux(SPD_peakIrr);
            phFlux_total_HbwIrr  = totalFluxFromSpectralFlux(SPD_HbwIrr);
            
            phFlux_total_peakHbw_onlyPeak = totalFluxFromSpectralFlux(SPD_peakHbw_onlyPeak);
            phFlux_total_peakIrr_onlyPeak = totalFluxFromSpectralFlux(SPD_peakIrr_onlyPeak);
            phFlux_total_HbwIrr_onlyPeak  = totalFluxFromSpectralFlux(SPD_HbwIrr_onlyPeak);
            time.dimensionReduction = toc;
            
        %% PLOT THE RESULTS
        tic

        
            % GROUND TRUTH Photon Densities
            i = 1;
            flux1a     = phFlux_total_peakHbw';
            flux2a     = phFlux_total_peakIrr';
            flux3a     = phFlux_total_HbwIrr';
            titleStr = 'Ground Truth';
            labelStr = 'Photon Density';
            fig = plot_3_matrices(peakNm, hbws, phFluxes, flux1a, flux2a, flux3a, titleStr, style, labelStr, i, scrsz);
            % autosave the figure      
            if style.imgOutautoSavePlot == 1            
                fileNameOut = ['photonFlux_plot1.png'];
                cd(path.figuresOut)
                %saveToDisk(fig, fileNameOut, style)
                cd(path.Code)
            end
            
            % "BACK-CONVERTED" Photon Densities
            i = 2;
            flux1b     = phFlux_total_peakHbw_onlyPeak';
            flux2b     = phFlux_total_peakIrr_onlyPeak';
            flux3b     = phFlux_total_HbwIrr_onlyPeak';
            titleStr = 'Back Converted';
            labelStr = 'Photon Density';
            fig = plot_3_matrices(peakNm, hbws, phFluxes, flux1b, flux2b, flux3b, titleStr, style, labelStr, i, scrsz);
            % autosave the figure      
            if style.imgOutautoSavePlot == 1            
                fileNameOut = ['photonFlux_plot1.png'];
                cd(path.figuresOut)
                %saveToDisk(fig, fileNameOut, style)
                cd(path.Code)
            end
            
            % DIFFERENCE between these two
            i = 3;
            flux1     = log10(flux1a ./ flux1b);
            flux2     = log10(flux2a ./ flux2b);
            flux3     = log10(flux3a ./ flux3b);
            titleStr = 'Error Plot';
            labelStr = 'Difference LOG';            
            fig = plot_3_matrices(peakNm, hbws, phFluxes, flux1, flux2, flux3, titleStr, style, labelStr, i, scrsz);
            % autosave the figure      
            if style.imgOutautoSavePlot == 1            
                fileNameOut = ['photonFlux_plot1.png'];
                cd(path.figuresOut)
                %saveToDisk(fig, fileNameOut, style)
                cd(path.Code)
            end
        
        time.plotting = toc;
            
    % display the timing
    time
            
        
    %% SUBFUNCTIONS
    
        % plotting subfunction    
        function fig = plot_3_matrices(peakNm, hbws, phFluxes, flux1, flux2, flux3, titleStr, style, labelStr, i, scrsz)
            
            fig = figure('Color', 'w', 'Name', titleStr);
            ySize = 0.22;
            set(fig, 'Position', [0.05*scrsz(3) (1 - (i*(ySize+0.091)))*scrsz(4) 0.9*scrsz(3) ySize*scrsz(4)])
            
            rows = 1;
            cols = 3;
            az = 0; el = 90;
            colorMAP = 'jet';
            
                % 1st subplot
                j = 1;
                sp(j) = subplot(rows, cols, j);
                
                    [X,Y] = meshgrid(peakNm, hbws);                   
                    s(j) = surf(X,Y,flux1);
                    view(az,el)
                    colorbar
                    colormap(colorMAP)
                    
                    lab(j,1) = xlabel('Peak \lambda');
                    lab(j,2) = ylabel('Hbw');
                    
                    xlim([min(peakNm) max(peakNm)])
                    ylim([min(hbws) max(hbws)])
            
                % 2nd subplot
                j = 2;
                sp(j) = subplot(rows, cols, j);
                
                    [X,Y] = meshgrid(peakNm, phFluxes);
                    s(j) = surf(X,Y,flux2);
                    view(az,el)
                    colorbar
                    colormap(colorMAP)
                    
                    lab(j,1) = xlabel('Peak \lambda');
                    lab(j,2) = ylabel('Photon flux');
                    
                    xlim([min(peakNm) max(peakNm)])
                    ylim([min(phFluxes) max(phFluxes)])
                    
                % 3rd subplot
                j = 3;
                sp(j) = subplot(rows, cols, j);
                
                    [X,Y] = meshgrid(hbws, phFluxes);
                    s(j) = surf(X,Y,flux3);
                    view(az,el)
                    colorbar
                    colormap(colorMAP)
                    
                    lab(j,1) = xlabel('Hbw');
                    lab(j,2) = ylabel('Photon flux');
                                        
                    xlim([min(hbws) max(hbws)])
                    ylim([min(phFluxes) max(phFluxes)])
                    
            
            set(sp, 'XColor', [.2 .2 .2], 'YColor', [.2 .2 .2])
            set(sp, 'FontName', style.fontName, 'FontSize', style.fontBaseSize)
        
            set(s, 'EdgeColor', 'none')
    
        % subfunction to create light SPD as taking the shape as a Gaussian
        % which is rather valid for interference filtered light as well as for
        % lasers and for LEDs
        function SPD = monochromaticLightAsGaussian(peak, FWHM, lambda)

            % sigma / deviation of the gaussian is defined as a function of FWHM
            % e.g., http://cp.literature.agilent.com/litweb/pdf/5980-0746E.pdf
            sigma = (FWHM*2) / 2.355; 

            f = gauss_distribution(lambda, peak, sigma);
            SPD = f / max(f); % normalize      


        % subfunction for Gaussian distribution
        function f = gauss_distribution(x, mu, s)

            % x         x vector (i.e. wavelength)
            % mu        mean / peak nm
            % sigma     standard deviation        
            p1 = -.5 * ((x - mu)/s) .^ 2;
            p2 = (s * sqrt(2*pi));
            f = exp(p1) ./ p2;  

        % SUBFUNCTION TO SCALE the light to photon flux
        function SPD = lightScaleToPhotons(photonEnergies, SPD, phFlux)
                
            % convert first the energy to photons
            SPD = SPD .* photonEnergies;

            % arbitrary "photon flux" of the unity normalized Gaussian
            arbFlux = trapz(SPD);

            % multiply the arbitrary photon flux with the ratio between the
            % arbitrary flux and the desired phFlux
            SPD = SPD .* (phFlux / arbFlux);

        % CALCULATE TOTAL PHOTON FLUX to get 2D-matrix from 3D-matrix
        function phFlux = totalFluxFromSpectralFlux(SPD_3D)
        
            spacing = 10 ^ -9;
        
            [y,x,z] = size(SPD_3D);
            phFlux = zeros(x,z);
            
            for i = 1 : x
                for j = 1 : z
                    phFlux(i,j) = spacing * trapz(SPD_3D(:,i,j));
                end
            end
            
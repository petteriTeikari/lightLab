% Demo for pupil behavior as a function of light intensity
function demo_staticPupilSize()
    
    % Petteri Teikari, 2013, petteri.teikari@gmail.com

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
    
        % luminance vector
        n = 100000;
        luminance.blondel   = logspace(-5,5,n); % blondels 
        luminance.cdm2      = 0.318309886 * luminance.blondel; % 1 blondel = 0.318309886 candela/meter²    
        luminance.L_fL      = luminance.cdm2 / 3.43; % foot-Lamberts
        
            % Ones -vector
            one = ones(length(n),1);
        
    %% Calculate
    
        % Pupil Diameter
        % ----
        % Moon and Spencer (1944): http://dx.doi.org/10.1364/JOSA.34.000319
        % Pamplona et al. (2009): http://dx.doi.org/10.1145/1559755.1559763
        pupil.D = 4.9 * one - (3*one * tanh(0.4 * (log10(luminance.blondel) - 0.5)));

        % Pupil Area
        % ----
        pupil.r = pupil.D / 2; % radius
        pupil.area = pi * (pupil.r) .^ 2;
        
        % Photopic Trolands
        % ----
        trolands.photopic = luminance.cdm2 .* pupil.area;
        %trolands.scotopic = 

        % Pupil Latency
        % ----
        % Link and Stark 1988: http://dx.doi.org/10.1109/10.1365
        % Pamplona et al. (2009): http://dx.doi.org/10.1145/1559755.1559763
        R = 1; % R is the light frequency measured in Hz
        pupil.tau = 253*one - (14 * log(luminance.L_fL)) + 70*R*one - (29 * R * log(luminance.L_fL));
        
            % t is the latency in milliseconds, LfL is the luminance measured
            % in foot-Lamberts (fL; mostly obsolete non-SI US unit, 1 fL = 
            % 3.43 cd/m²), and R is the light frequency measured in Hz.

        
            
    %% Plot
    
        fig = figure('Color','w','Name','Pupil Behavior');
            set(fig, 'Position', [0.05*scrsz(3) 0.15*scrsz(4) 0.5*scrsz(3) 0.50*scrsz(4)])
            
            rows = 2;
            cols = 2;
            
            xTicks = [10^-4 10^-2 1 10^2 10^4];
            
            %% DIAMETER
            i = 1;
            s(i) = subplot(rows,cols,i);
                p(i) = semilogx(luminance.cdm2, pupil.D);
                tit(i) = title('Pupil Diameter');
                lab(i,1) = xlabel('Luminance [cd/m^2]');
                lab(i,2) = ylabel('Pupil diameter [mm]');                
            
            %% AREA
            i = 2;
            s(i) = subplot(rows,cols,i);
                p(i) = semilogx(luminance.cdm2, pupil.area);
                tit(i) = title('Pupil Area');
                lab(i,1) = xlabel('Luminance [cd/m^2]');
                lab(i,2) = ylabel('Pupil area [mm^2]');
                
            
            %% TROLANDS
            i = 3;
            s(i) = subplot(rows,cols,i);
                p(i) = loglog(luminance.cdm2, trolands.photopic);
                tit(i) = title('Retinal Illuminance');
                lab(i,1) = xlabel('Luminance [cd/m^2]');
                lab(i,2) = ylabel('Photopic trolands [td]');
            
            %% LATENCY
            i = 4;
            s(i) = subplot(rows,cols,i);
                p(i) = semilogx(luminance.cdm2, pupil.tau);
                tit(i) = title(['Pupil Latency, R=', num2str(R), ' Hz']);
                lab(i,1) = xlabel('Luminance [cd/m^2]');
                lab(i,2) = ylabel('latency [ms]');
                ylim([0 1000])
                
        %% Common styling

            set(s, 'FontName', style.fontName, 'FontSize', style.fontBaseSize-1)
            set(s, 'XLim', [min(luminance.cdm2) max(luminance.cdm2)])
            set(s, 'XTick', xTicks)
            set(s, 'XGrid', 'on', 'YGrid', 'on')

            set(p, 'LineWidth',2, 'Color',[0.83 0.16 0.44])

            set(lab, 'FontName', style.fontName, 'FontSize', style.fontBaseSize, 'FontWeight', 'bold')
            set(tit, 'FontName', style.fontName, 'FontSize', style.fontBaseSize+2, 'FontWeight', 'bold')
                
        % autosave the figure      
        if style.imgOutautoSavePlot == 1            
            fileNameOut = ['Pupil_staticSize.png'];
            cd(path.figuresOut)
            saveToDisk(fig, fileNameOut, style)
            cd(path.Code)
        end
        
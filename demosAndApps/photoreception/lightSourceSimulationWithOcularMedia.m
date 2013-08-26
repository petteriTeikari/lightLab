% Simulates the effect of ocular media filtering to "perceived CCT"
function lightSourceSimulationWithOcularMedia()

    close all    
    scrsz = get(0,'ScreenSize'); % get screen size for plotting
    
    disp(' ')
    disp('  LIGHT SOURCE DEMO')
    disp('  Petteri Teikari, 2012, INSERM, Lyon, France')
    disp('  petteri.teikari@gmail.com')
    disp(' ')
    
    % Lighting companies such as Philips and Osram like to market their
    % high color temperature (Osram Skywhite 8000 K, and Philips' Activiva
    % 17000 K) as effective "circadian lights", whereas in reality the
    % peaks at short wavelength range increasing the "physical CCT" are
    % filtered in the eye before reaching retina
    
    
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
            
        % LIGHTS
            lightFile{1} = 'Fluorescent_840_Typical_Office_380nm_to_780nm_1nm.txt';
            lightFile{2} = 'Osram_Skywhite_380nm_to_780nm_1nm.txt';
            lightFile{3} = 'Fluorescent_Philips_Activiva_17000K_average_380nm_to_780nm_1nm.txt';            
            lightFile{4} = 'Bulabopsin_Lamp_380nm_to_780nm_1nm.txt';
            headerRows = 8;
            delimiter = '\t';
            
            lightCaption{1} = '4 000 K';
            lightCaption{2} = '8 000 K';
            lightCaption{3} = '17 000 K';
            lightCaption{4} = 'Synthetic';
            
        % Ocular Media parameters
            age = [25 65];
            offset = 0.111;
            lambda_ocMedia = (380:1:780)'; % have to be the same as for light sources
            
        % Melanopsin parameters
        
            % Isoform shape    
            Rpeak   = 482;
            Mpeak   = 587;            
        
            % create nomograms
            cd(path.nomogram)
                alphaR_rel = nomog_Govardovskii2000(Rpeak);
                alphaM_rel = nomog_Govardovskii2000(Mpeak);            
            cd(path.Code)
            
            % accessory variables, for rate constant calculation
            alpha_multip = 1;
            sigma = 1;
            nm_spacing = 10^-9;            
            
    
    %% Calculations
    
        tic;
        % Import the light sources            
            for i = 1 : length(lightFile)
               
               tmp = importdata(fullfile(path.lightSources, lightFile{i}), delimiter, headerRows);
                              
               SPD{1}{i} = tmp.data(:,2);              
               lambda{i} =  tmp.data(:,1);                          
               
               %remove NaNs
               SPD{1}{i}(isnan(SPD{1}{i})) = 0;               
               
               % normalize photon density to one, the SPD is still in
               % energy
               cd(path.common)
               SPD{1}{i} = norm_unityPhotonDensity(lambda{i}, SPD{1}{i});
               
            end
            cd(path.Code)
            
        % Correct for ocular media
        
            % 25yr old
            j = 1;
            cd(path.ocularMedia)
            lensFilter{j} = agedLensFilter(age(j), lambda_ocMedia, offset);
            cd(path.Code)
            
                % go through the lights
                for i = 1 : length(lightFile) 
                    SPD{j+1}{i} = filterLight(SPD{1}{i}, lensFilter{j});
                end
            
            % 65yr old
            j = 2;
            cd(path.ocularMedia)
            lensFilter{j} = agedLensFilter(age(j), lambda_ocMedia, offset);
            cd(path.Code)
            
                % go through the lights
                for i = 1 : length(lightFile) 
                    SPD{j+1}{i} = filterLight(SPD{1}{i}, lensFilter{j});
                end     
            
        % Compute the colorimetric parameters        
            cd(path.colorimetry)
            for i = 1 : 3 % no of ocular media models                
                for j = 1 : length(lightFile) % no of files 
                    colorimValues{i}{j} = MAIN_colorimetry(lambda_ocMedia, SPD{i}{j}, path);
                end                
            end
            cd(path.Code)                    
            
        % Compute f_Me
            cd(path.bistability)
            for i = 1 : 3 % no of ocular media models                
                for j = 1 : length(lightFile) % no of files                     
                    kR = calc_arrestinRateRMtransition(alphaR_rel, alpha_multip, sigma, SPD{i}{j}, nm_spacing);
                    kM = calc_arrestinRateRMtransition(alphaM_rel, alpha_multip, sigma, SPD{i}{j}, nm_spacing);                   
                    fMe{i}{j} = calc_fMe(kR, kM);                    
                end                
            end
            cd(path.Code)  
        
        
        % Compute NIF-response            
            for i = 1 : 3 % no of ocular media models                
                for j = 1 : length(lightFile) % no of files
                    cd(path.common)
                    nomoR_energy = convert_fromQuantaToEnergy(alphaR_rel, lambda_ocMedia);
                    NIF{i}{j} = (trapz(SPD{i}{j} .* nomoR_energy)) * 10^-34;
                end                
            end            
            
        timing.calculations = toc;
            
    %% PLOT
    
        % Fluorescent simulation
        
            fig = figure('Color', 'w');

                rows = length(lightFile); 
                cols = 1;
                set(fig, 'Position', [0.1*scrsz(3) 0.1*scrsz(4) 0.52*scrsz(3) 0.8*scrsz(4)])

            for i = 1 : length(lightFile)            

               % subplot 
               sp(i) = subplot(rows,cols,i);

               % get norm. for visualization
               norm = max(SPD{1}{i});

               % plot
               p(i,1:3)  = plot(lambda{i}, SPD{1}{i} / norm, ...
                                lambda{i}, SPD{2}{i} / norm, ...
                                lambda{i}, SPD{3}{i} / norm);

               % set axis limits
               xlim([lambda{i}(1) lambda{i}(end)])
               ylim([0 1])
               box off

               % legend
               legendStr{1} = sprintf('%s%s%s%s%s', '"', lightCaption{i}, '": CCT = ', num2str(colorimValues{1}{i}.CCT, '%4.0f'), ' K');
               legendStr{2} = sprintf('%s%s%s%s%s', num2str(age(1)), ' yr. lens, ', ': CCT = ', num2str(colorimValues{2}{i}.CCT, '%4.0f'), ' K');
               legendStr{3} = sprintf('%s%s%s%s%s', num2str(age(2)), ' yr. lens, ', ': CCT = ', num2str(colorimValues{3}{i}.CCT, '%4.0f'), ' K');
               leg(i) = legend(legendStr{1}, legendStr{2}, legendStr{3}, 3);
               legend('boxoff')       

               if i == 3 % length(lightFile) 
                   lab = xlabel('Wavelength [nm]');
               end

               % add additional metrics
               tHandles(i, 1:7) = addText(sp(i), p(i), fMe, NIF, i);

            end

            % style

                % subplots (gca)
                set(sp, 'FontName', style.fontName, 'FontSize', style.fontBaseSize)
                set(sp, 'XColor', style.colorGray, 'YColor', style.colorGray)

                % line plots            
                set(p(:,1), 'Color', style.colorPlot(1,:))
                set(p(:,2), 'Color', style.colorPlot(2,:))
                set(p(:,3), 'Color', style.colorPlot(3,:))

                % legend % text
                set(leg, 'Location', 'NorthEast', 'FontName', style.fontName, 'FontSize', style.fontBaseSize-1)
                set(lab, 'FontName', style.fontName, 'FontSize', style.fontBaseSize+1, 'FontWeight', 'bold')
                set(tHandles, 'FontName', style.fontName, 'FontSize', style.fontBaseSize-1, 'HorizontalAlignment', 'right')
                
                %% EXPORT TO DISK

                    if style.imgOutautoSavePlot == 1
                    cd(path.Code) 
                        fileNameOut = 'lightingSimulation.png';
                        export_fig(fileNameOut, style.imgOutRes, style.imgOutAntiAlias)
                    end
                    cd(path.Code)
            
            
        % CCT Simulation
            %{
        
            CCT_ind = [3 4];            
        
            fig = figure('Color', 'w');

                rows = 2; 
                cols = 1;
                set(fig, 'Position', [0.1*scrsz(3) 0.1*scrsz(4) 0.52*scrsz(3) 0.53*scrsz(4)])

            for i = 1 : 2 % length(lightFile)            

               % subplot 
               sp(i) = subplot(rows,cols,i);

               % get norm. for visualization
               norm = max(SPD{1}{CCT_ind(i)});

               % plot
               p(i,1:3)  = plot(lambda{i}, SPD{1}{CCT_ind(i)} / norm, ...
                                lambda{i}, SPD{2}{CCT_ind(i)} / norm, ...
                                lambda{i}, SPD{3}{CCT_ind(i)} / norm);


               % set axis limits
               xlim([lambda{i}(1) lambda{i}(end)])
               ylim([0 1])
               box off

               % legend
               legendStr{1} = sprintf('%s%s%s%s%s', '"', lightCaption{CCT_ind(i)}, '": CCT = ', num2str(colorimValues{1}{CCT_ind(i)}.CCT, '%4.0f'), ' K');
               legendStr{2} = sprintf('%s%s%s%s%s', num2str(age(1)), ' yr. lens, ', ': CCT = ', num2str(colorimValues{2}{CCT_ind(i)}.CCT, '%4.0f'), ' K');
               legendStr{3} = sprintf('%s%s%s%s%s', num2str(age(2)), ' yr. lens, ', ': CCT = ', num2str(colorimValues{3}{CCT_ind(i)}.CCT, '%4.0f'), ' K');
               leg(i) = legend(legendStr{1}, legendStr{2}, legendStr{3}, 3);
               legend('boxoff')       

               if i == 2 %length(lightFile) 
                   lab = xlabel('Wavelength [nm]');
               end

               % add additional metrics
               tHandles(i, 1:7) = addText(sp(i), p(i), fMe, NIF, CCT_ind(i));

            end
            %}

            % style

                % subplots (gca)
                set(sp, 'FontName', style.fontName, 'FontSize', style.fontBaseSize)
                set(sp, 'XColor', style.colorGray, 'YColor', style.colorGray)

                % line plots            
                set(p(:,1), 'Color', style.colorPlot(1,:))
                set(p(:,2), 'Color', style.colorPlot(2,:))
                set(p(:,3), 'Color', style.colorPlot(3,:))

                % legend % text
                set(leg, 'Location', 'NorthEast', 'FontName', style.fontName, 'FontSize', style.fontBaseSize-1)
                set(lab, 'FontName', style.fontName, 'FontSize', style.fontBaseSize+1, 'FontWeight', 'bold')
                set(tHandles, 'FontName', style.fontName, 'FontSize', style.fontBaseSize-1, 'HorizontalAlignment', 'right')
        
        %% EXPORT TO DISK

            % autosave the figure      
            if style.imgOutautoSavePlot == 1            
                fileNameOut = ['lightSourceOcularMediaSimulation.png'];
                cd(path.figuresOut)
                saveToDisk(fig, fileNameOut, style)
                cd(path.Code)
            end


    
            
    %% SUBFUNCTIONS

        function SPD_filt = filterLight(SPD, filter)        
            SPD_filt = SPD .* filter;
            
        function tHandles = addText(sp, p, fMe, NIF, ind);
            
            xPos = 771;
            y0   = 0.55;
            yInt = 0.07;
            
            % get max of NIF-response for normalization
            for i = 1 : length(NIF)
                for j = 1 : length(NIF{1})
                    NIF_values(i,j) = NIF{i}{j};
                end
            end
            norm = max(max(NIF_values));
            
            j = 1;
            tHandles(j) = text(xPos, y0 -((j-1)*yInt), ['f_M_e = ', num2str(fMe{1}{ind},2)]);
            
            j = 2;
            tHandles(j) = text(xPos, y0 -((j-1)*yInt), ['f_M_e = ', num2str(fMe{2}{ind},2)]);
            
            j = 3;
            tHandles(j) = text(xPos, y0 -((j-1)*yInt), ['f_M_e = ', num2str(fMe{3}{ind},2)]);
            
            j = 4;
            tHandles(j) = text(xPos, y0 -((j-1)*yInt), ' ');
            
            j = 5;
            tHandles(j) = text(xPos, y0 -((j-1)*yInt), ['NIF = ', num2str(NIF{1}{ind}/norm, '%1.2f')]);
            
            j = 6;
            tHandles(j) = text(xPos, y0 -((j-1)*yInt), ['NIF = ', num2str(NIF{2}{ind}/norm, '%1.2f')]);
            
            j = 7;
            tHandles(j) = text(xPos, y0 -((j-1)*yInt), ['NIF = ', num2str(NIF{3}{ind}/norm, '%1.2f')]);
            
            %{
             j = 1;
            tHandles(j) = text(xPos, y0 -((j-1)*yInt), ['f_M_e = ', num2str(fMe{1}{ind},2), ' (LIGHT)']);
            
            j = 2;
            tHandles(j) = text(xPos, y0 -((j-1)*yInt), ['f_M_e = ', num2str(fMe{2}{ind},2), ' (25 yr.)']);
            
            j = 3;
            tHandles(j) = text(xPos, y0 -((j-1)*yInt), ['f_M_e = ', num2str(fMe{3}{ind},2), ' (65 yr.)']);
            
            j = 4;
            tHandles(j) = text(xPos, y0 -((j-1)*yInt), ' ');
            
            j = 5;
            tHandles(j) = text(xPos, y0 -((j-1)*yInt), ['NIF = ', num2str(NIF{1}{ind}/norm, '%1.2f'), ' (LIGHT)']);
            
            j = 6;
            tHandles(j) = text(xPos, y0 -((j-1)*yInt), ['NIF = ', num2str(NIF{2}{ind}/norm, '%1.2f'), ' (25 yr.)']);
            
            j = 7;
            tHandles(j) = text(xPos, y0 -((j-1)*yInt), ['NIF = ', num2str(NIF{3}{ind}/norm, '%1.2f'), ' (65 yr.)']);
            %}
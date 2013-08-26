% Demo for van de Kraats and van Norren 2007 ocular media model
function demo_compare_Van2007components()
    
    % Van de Kraats J, van Norren D. 2007. 
    % Optical density of the aging human ocular media in the visible and the UV. 
    % J Opt Soc Am A Opt Image Sci Vis 24:1842–57. 
    % http://dx.doi.org/10.1364/JOSAA.24.001842.

    close all
    scrsz = get(0,'ScreenSize'); % get screen size for plotting

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
    
        l = (300:1:800)';
        offset = 0;

        ageY = 25;
        ageO = 65;

        cd(path.ocularMedia)
        lensY = lensModel_vanDeKraats2007(ageY, l, offset);
        lensO = lensModel_vanDeKraats2007(ageO, l, offset);
        cd(path.Code)
    
    fig = figure('Color', 'w', 'Position', [0.05*scrsz(3) 0.1*scrsz(4) 0.45*scrsz(3) 0.8*scrsz(4)]);
    
        % note now the lens density is in DENSITY and in LOG
    
        % plot YOUNG
        sp(1) = subplot(3,1,1);
            p(1,1:5) = plot(l, lensY.TP,...
                            l, lensY.LY,...
                            l, lensY.LO,...
                            l, lensY.LOUV,...
                            l, lensY.rayleighScatter);

            leg = legend('TP', 'LY', 'LO', 'LOUV', 'Rayl.', 5);
            legend('boxoff'); set(leg, 'Location', 'NorthEast', 'FontSize', 8)
            tx(1) = title(['YOUNG, age = ', num2str(ageY), ' years']);

        % plot OLD
        sp(2) = subplot(3,1,2);
            p(2,1:5) = plot(l, lensO.TP,...
                            l, lensO.LY,...
                            l, lensO.LO,...
                            l, lensO.LOUV,...
                            l, lensO.rayleighScatter);
            tx(2) = title(['OLD, age = ', num2str(ageO), ' years']);
        
        % calculate the difference
            lensDiff.TP = lensY.TP - lensO.TP;
            lensDiff.LY = lensY.LY - lensO.LY;
            lensDiff.LO = lensY.LO - lensO.LO;
            lensDiff.LOUV = lensY.LOUV - lensO.LOUV;
            lensDiff.rayleighScatter = lensY.rayleighScatter - lensO.rayleighScatter;
        
        % plot the DIFFERENCE
        sp(3) = subplot(3,1,3);
            p(3,1:5) = plot(l, lensDiff.TP,...
                            l, lensDiff.LY,...
                            l, lensDiff.LO,...
                            l, lensDiff.LOUV,...
                            l, lensDiff.rayleighScatter);
            tx(3) = title('DIFFERENCE (Young - Old), negative values are attenutated more with age');
                        
        % style now the plot
        set(sp, 'XLim', [380 650])
        set(sp(1:2), 'YLim', [0 2])
        set(sp(3),   'YLim', [-1 1])
        set(sp, 'FontName', style.fontName, 'FontSize', style.fontBaseSize, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3])
        set(p, 'LineWidth', 2)
        
     %% EXPORT TO DISK

       % autosave the figure      
        if style.imgOutautoSavePlot == 1            
            fileNameOut = ['vanKraatsVanNorren2007_ocularMediaModel.png'];
            cd(path.figuresOut)
            saveToDisk(fig, fileNameOut, style)
            cd(path.Code)
        end

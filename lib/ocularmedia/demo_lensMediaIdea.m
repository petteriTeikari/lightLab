%% DOCUMENTATION
% All the lines starting with %DOC% in similar sense as Java's javadoc

    %DOC%<desc>Demo for the principle of using two wavelengths around rhodopsin peak<desc/>

    %DOC%<h2>Description</h2>
    %DOC%cmdLine_sessionAnalysis() runs the session-by session analysis of lens density analysis input files

%% CODE
function demo_lensMediaIdea()

    close all
    scrsz = get(0,'ScreenSize'); % get screen size for plotting
               
    %% define other path names        
    mFilename = 'demo_lensMediaIdea'; pathF = mfilename('fullpath');
    path.mainCode = strrep(pathF, mFilename, '');
    cd(path.mainCode); cd ..;
    path.oneDirBack = pwd;
    path.nomogram = fullfile(path.oneDirBack, 'nomogram');
    
    %% Parameters
    l = (380:1:780)';
    offset = 0.111;
    ageY = 25;
    ageO = 65;
    xlimits = [380 650]; ylimits = log10([0.001 1.0]);
    blueColor  = [0.0431 0.517 0.78];
    greenColor = [0 1 0.2];
    
    autoSaveOn = 0;
        expRes = '-r300'; expAntiAlias = '-a2'; expFormat = 'png';
    
    %% Create the DATA
    
        % create lens templates
        cd(path.mainCode)
        lensY = lensModel_vanDeKraats2007(ageY, l, offset);
        lensY_sum = lensY.totalMedia;
        lensO = lensModel_vanDeKraats2007(ageO, l, offset);
        lensO_sum = lensO.totalMedia;

        % import system lights
        load monochromaticLightsSpectra.mat

        % create rhodopsin template
        peak = 495;
        cd(path.nomogram)
        rhodopsin = nomog_Govardovskii2000(peak);
        cd(path.mainCode)
        
            % filter with lens templates
            rhodopsinY = rhodopsin .* (10.^(-1*lensY_sum));
            % norm = max(rhodopsinY);
            % rhodopsinY = rhodopsinY / norm; % normalize
            rhodopsinO = rhodopsin  .* (10.^(-1*lensO_sum));
            % rhodopsinO = rhodopsinO / norm; % normalize
            
    %% CONVERT EVERYTHING to LOG
    
        lensY_sum = log10(lensY_sum);
        lensO_sum = log10(lensO_sum);
        
        rhodopsin = log10(rhodopsin);
        rhodopsinY = log10(rhodopsinY);
        rhodopsinO = log10(rhodopsinO);
        
        nm410_log = log10(nm410);
        nm560_log = log10(nm560);
            
    %% DO SOME DATA CONDITIONING
    
        % scale the spectra so that their peak match the corresponding
        % nomogram position
        [~,ind410] = max(nm410); 
        peak410 = l(ind410);
        nomogramAtPeak410 = rhodopsin(ind410);
        nomogramAtPeak410y = rhodopsinY(ind410);
        nomogramAtPeak410o = rhodopsinO(ind410);
        nm410 = nm410 * nomogramAtPeak410;
        
        [~,ind560] = max(nm560); 
        peak560 = l(ind560);
        nomogramAtPeak560 = rhodopsin(ind560);
        nomogramAtPeak560y = rhodopsinY(ind560);
        nomogramAtPeak560o = rhodopsinO(ind560);
        nm560 = nm560 * nomogramAtPeak560;
    
    %% Now plot then all these
        figure('Color', 'w', 'Position', [0.05*scrsz(3) 0.5*scrsz(4) 0.9*scrsz(3) 0.46*scrsz(4)])    
        hold on        
        % p(6) = plot(l, 10.^(-1*lensY_sum));
        % p(7) = plot(l, 10.^(-1*lensO_sum));
        p(1) = plot(l, rhodopsin);
        p(2) = plot(l, rhodopsinY);
        p(3) = plot(l, rhodopsinO);        
        p(4) = area(l, nm410); 
        p(5) = area(l, nm560);
        hold off
        
    %% Add the markers explaining the method
    
        offs = 4; % [nm]
        hold on
        mar(1) = plot(peak410, nomogramAtPeak410y, 'o'); % 410 young
        mar(2) = plot(peak410, nomogramAtPeak410o, 'o'); % 410 old
        mar(3) = plot(peak560, nomogramAtPeak560y, 'o'); % 560 young
        mar(4) = plot(peak560, nomogramAtPeak560o, 'o'); % 560 old
        mar(5) = plot(xlimits(1), nomogramAtPeak410y, 'o'); % 410 young at origin
        mar(6) = plot(xlimits(1)+offs, nomogramAtPeak410o, 'o'); % 410 old at origin
        mar(7) = plot(xlimits(1), nomogramAtPeak560y, 'o'); % 560 young at origin
        mar(8) = plot(xlimits(1)+offs, nomogramAtPeak560o, 'o'); % 560 old at origin
        
        mar(9) = plot(peak410, nomogramAtPeak410, 'o'); % 410 at unfiltered
        
        hold off
    
        % style
        set(mar([1 2 5 6]), 'MarkerFaceColor', [0 0 1])
        set(mar([3 4 7 8]), 'MarkerFaceColor', [0 1 0])
        set(mar(9), 'MarkerFaceColor', [1 0 0])
        set(mar, 'MarkerEdgeColor', [.05 .05 .05], 'MarkerSize', 7)
        
    %% Add then the lines
    
        % 4 horizontals, i.e. y-values do not change
        lin(1) = line([xlimits(1) peak410], [nomogramAtPeak410y nomogramAtPeak410y]);
        lin(2) = line([xlimits(1)+offs peak410], [nomogramAtPeak410o nomogramAtPeak410o]);
        lin(3) = line([xlimits(1) peak560], [nomogramAtPeak560y nomogramAtPeak560y]);
        lin(4) = line([xlimits(1)+offs peak560], [nomogramAtPeak560o nomogramAtPeak560o]);
        
        % 4 verticals, i.e. x-values do not change
        lin(5) = line([xlimits(1) xlimits(1)], [nomogramAtPeak410y nomogramAtPeak560y]);
        lin(6) = line([xlimits(1)+offs xlimits(1)+offs], [nomogramAtPeak410o nomogramAtPeak560o]);
        lin(7) = line([peak410 peak410], [nomogramAtPeak410y nomogramAtPeak410o]);
        lin(8) = line([peak560 peak560], [nomogramAtPeak560y nomogramAtPeak560o]);
        
        % scale factor
        lin(9) = line([peak410 peak410], [nomogramAtPeak410 nomogramAtPeak410y]);
        
        % style
        set(lin([1 3 5 7]), 'Color', [.4 .4 .4])
        set(lin([2 4 6 8]), 'Color', [.3 .3 .3], 'LineStyle', '--')
        set(lin(9), 'Color', [1 0 0], 'LineStyle', '--')
        
    %% style plots
        set(p, 'LineWidth', 1)
        % set(p(6), 'Color', [1 0.20 0]) % lens YOUNG
        % set(p(7), 'Color', [0.68 0.47 0]) % lens OLD        
        set(p(1), 'Color', [0 0 1])
        set(p(2), 'Color', [0 0 0])
        set(p(3), 'Color', [1 0.47 0])
        set(p(4), 'FaceColor', blueColor)
        set(p(5), 'FaceColor', greenColor)
    
    %% general styling
        box on
        set(gca, 'FontSize', 9, 'FontName', 'Georgia', 'XColor', [.5 .5 .5], 'YColor', [.5 .5 .5])
        set(gca, 'Position', [0.05 0.05 0.90 0.90])
        set(gca, 'XLim', xlimits, 'YLim', ylimits)
        
        leg = legend(['Rhodopsin (', num2str(peak), ' nm)'], ['Std. Observer, age ', num2str(ageY), ' yrs'], ['Senior Observer, age ', num2str(ageO), ' yrs'], 3);
        set(leg, 'Location', 'NorthEast', 'FontName', 'Georgia', 'FontSize', 9)
        legend('boxoff')
            
        
    %% AUTOSAVE
    if autoSaveOn == 1
        export_fig('densityDiagram.png', expRes, expAntiAlias, expFormat)
    end
        
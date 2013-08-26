% Demo for rhodopsin bleaching as function of light intensity
function demo_rhodopsinBleaching()
    
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
        
    
    %% DATA
    
        % From Pugh (1975)
        % http://www.ncbi.nlm.nih.gov/pmc/articles/PMC1309530/
        % 450 nm light
        j = 1;
        rhBleach{j}.label = 'Pugh (1975)';
        
            % I guessed that based on the graph that the 2nd the 5th were
            % dropped of from Figure 4 f Pugh (2004) to get the Figure 6 of
            % Lamb and Pugh (2004): http://dx.doi.org/10.1016/j.preteyeres.2004.03.001
            rhBleach{j}.x = [4.7 5.3 5.6 6.1 6.4 6.7 7.0 7.3 7.6]; % Fig. 3 of Pugh (1075) + the 7.6
            rhBleach{j}.y = [0.5 2 4 8 22 39 63 86 98]; % Fig. 6 of Lamb and Pugh (2004)
        
        % Add other papers here later
        
        
    %% PLOT
    
        fig = figure('Color','w');
            rows = 1;
            cols = 1;
        
        for j = 1 : length(rhBleach)
           
            sp(j) = subplot(rows,cols,j);
                p(j) = plot(rhBleach{j}.x, rhBleach{j}.y, '-ro');
                lab(j,1) = xlabel('Scotopic Troland');
                lab(j,2) = ylabel('Rhodopin Bleach');
                tit(j) = title(rhBleach{j}.label);
        end
        
        
        %% STYLE
            set(sp, 'FontName', style.fontName, 'FontSize', style.fontBaseSize)  
            set(p, 'MarkerFaceColor', 'k')
            set(lab, 'FontName', style.fontName, 'FontSize', style.fontBaseSize, 'FontWeight', 'bold')    
            set(tit, 'FontName', style.fontName, 'FontSize', style.fontBaseSize+1, 'FontWeight', 'bold')            
            % set(leg, 'FontSize', style.fontBaseSize-1, 'FontName', style.fontName)
        
        % autosave the figure      
        if style.imgOutautoSavePlot == 1            
            fileNameOut = ['rhodopsinBleaching.png'];
            cd(path.figuresOut)
            saveToDisk(fig, fileNameOut, style)
            cd(path.Code)
        end
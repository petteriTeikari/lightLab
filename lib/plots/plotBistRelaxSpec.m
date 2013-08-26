 function h = plotBistRelaxSpec(lambda, y, handles)
        
        % default values
        defFontName = 'Georgia';
        defFontSize = 8;
        defXLimits = [400 700];
        defYLimits = [0 1.6];      
        
        if nargin < 2
            errodlg('Not enough input parameters')
        elseif nargin == 2            
            
            % set values
            handles.fontName = defFontName;
            handles.fontSizeBase = defFontSize;
            handles.xLimits = defXLimits;
            handles.yLimits = defYLimits;
            
        else            
            fieldNames = fieldnames(handles);
            
            if isempty(cell2mat(strfind(fieldNames, 'fontName')))
               handles.fontName = defFontName;
            end
                
            if isempty(cell2mat(strfind(fieldNames, 'fontSizeBase')))
               handles.fontSizeBase = defFontSize;
            end
                
            if isempty(cell2mat(strfind(fieldNames, 'xLimits')))
               handles.xLimits = defXLimits;
            end
                
            if isempty(cell2mat(strfind(fieldNames, 'yLimits')))
                handles.yLimits = defYLimits;
            end
        end
        
        % plot
        h.p = plot(lambda,y);
        
        % annotate
        h.tit = title('Relaxation Spectrum');
        set(h.tit, 'FontName', handles.fontName, 'FontSize', handles.fontSizeBase)
        
        h.lab(1) = xlabel('Wavelength [nm]');
        h.lab(2) = ylabel('Relative Sensitivity');
        
        % style
        set(gca, 'XLim', handles.xLimits) 
        set(gca, 'YLim', handles.yLimits) 
     
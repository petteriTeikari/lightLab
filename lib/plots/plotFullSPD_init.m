function h = plotFullSPD_init(lambda, irrad, irrad_norm, colorim, photom, radiom, photorecep, options, analysisOptions)

    h.fig = figure('Color', 'w', 'Name', 'Full SPD Analysis Plot');
    set(h.fig, 'Position', [0.05*options.scrsz(3) 0.55*options.scrsz(4) 0.8*options.scrsz(3) 0.36*options.scrsz(4)])
        
    % subplot elements
    rows = 4; 
    cols = 4;
    
    % define positions for the text boxes
    xlimits  = [0 6];
    xoffset  = 0; 
    yoffset  = 0.06;    
    xPoint   = [0.47 0.72 0.9]*max(xlimits); % four column as the first one is the header
    
    % define shortened filename
    strFileName = strrep(options.filename, '.txt', '');
    strFileName = strrep(strFileName, '380nm_to_780nm', '');
    strFileName = strrep(strFileName, '1nm', '');    
    strFileName = strrep(strFileName, '_', ' ');
    
        
    %% Graph, absolute / original
    h.sp(1) = subplot(rows, cols, [1 2 5 6]);
    
        h.ar(1)  = area([1 2], [1 1]);
        h.lab(1) = xlabel(' ');
        h.lab(2) = ylabel('Irradiance');      
        h.tit(1) = title(['Irrad " ', strFileName, '"']);
        
        set(gca, 'XTickLabel', [])
        
        get(gca, 'Position')
        
        
    %% Graph, normalized
    h.sp(2) = subplot(rows, cols, [9 10 13 14]);
    
        h.ar(2)  = area([1 2], [1 1]);
        h.lab(3) = xlabel('Wavelength [nm]');
        h.lab(4) = ylabel('Irradiance');      
        h.tit(2) = title(['Irrad norm, method = ', analysisOptions.inputNorm]);
        
        get(gca, 'Position')
                
    
    %% Colorimetry
    h.sp(3) = subplot(rows, cols, [3 7 11 15]);
    
        axis off
        box off
        xlim(xlimits); ylim([0 1]); % boxes for text so these are relative
        h.tit(3) = title('Colorimetry');
    
        h.noOfColorimValues = length(fieldnames(colorim)); % number of fields in a structure
        
        % preallocate
        h.colorim_textFields = zeros(1,h.noOfColorimValues);       
        h.colorim_numFields = zeros(1,h.noOfColorimValues);
        h.colorim_unitFields = zeros(1,h.noOfColorimValues);
        
        yInterv = 1 / h.noOfColorimValues;        
        for i = 1 : h.noOfColorimValues
            h.colorim_textFields(i) = text(xPoint(1)+xoffset, 1 - yoffset - ((i-1)*yInterv), '1');
            h.colorim_numFields(i)  = text(xPoint(2)+xoffset, 1 - yoffset - ((i-1)*yInterv), '2');
            h.colorim_unitFields(i) = text(xPoint(3)+xoffset, 1 - yoffset - ((i-1)*yInterv), '3');
        end
        
        get(gca, 'Position')
        
        
    %% Photometry/radiometry
    h.sp(4) = subplot(rows, cols, [4 8]);
    
        axis off
        box off
        xlim(xlimits); ylim([0 1]); % boxes for text so these are relative
        h.tit(4) = title('Radiometry/Photometry');
        
        h.noOfPhotomValues = length(fieldnames(photom)); % number of fields in a structure
        h.noOfRadiomValues = length(fieldnames(radiom)); % number of fields in a structure
        h.noOfPhoRadValues = h.noOfPhotomValues + h.noOfRadiomValues;
        h.noOfPhoRadValues = 7; % manual override
        
        % preallocate
        h.phoRad_textFields = zeros(1,h.noOfPhoRadValues);
        h.phoRad_numFields  = zeros(1,h.noOfPhoRadValues);
        h.phoRad_unitFields = zeros(1,h.noOfPhoRadValues);
        
        yInterv = 1 / h.noOfPhoRadValues;
        for i = 1 : h.noOfPhoRadValues
            h.phoRad_textFields(i) = text(xPoint(1)+xoffset, 1 - yoffset - ((i-1)*yInterv), '1');
            h.phoRad_numFields(i)  = text(xPoint(2)+xoffset, 1 - yoffset - ((i-1)*yInterv), '2');
            h.phoRad_unitFields(i) = text(xPoint(3)+xoffset, 1 - yoffset - ((i-1)*yInterv), '3');
        end
        
        get(gca, 'Position')
        
    
    %% Photoreceptor responses
    h.sp(5) = subplot(rows, cols, [12 16]);
    
        axis off
        box off
        xlim(xlimits); ylim([0 1]); % boxes for text so these are relative
        h.tit(5) = title('Photoreceptors');
        
        h.noOfPhotorecepValues = 9; % manual override
        
        % preallocate
        h.photorecep_textFields = zeros(1,h.noOfPhotorecepValues);
        h.photorecep_numFields  = zeros(1,h.noOfPhotorecepValues);
        h.photorecep_unitFields = zeros(1,h.noOfPhotorecepValues);
        
        yInterv = 1 / h.noOfPhotorecepValues;
        for i = 1 : h.noOfPhotorecepValues
            h.photorecep_textFields(i) = text(xPoint(1)+xoffset, 1 - yoffset - ((i-1)*yInterv), '1');
            h.photorecep_numFields(i)  = text(xPoint(2)+xoffset, 1 - yoffset - ((i-1)*yInterv), '2');            
            h.photorecep_unitFields(i) = text(xPoint(3)+xoffset, 1 - yoffset - ((i-1)*yInterv), '3');
        end
        
        get(gca, 'Position')
        
    
    %% Styling
        
        % subplot styling
        set(h.sp, 'FontName', options.fontName, 'FontSize', options.fontSizeBase)

        % labels
        set(h.lab, 'FontName', options.fontName, 'FontSize', options.fontSizeBase)

        % area plot
        set(h.ar, 'FaceColor',[0.3098 0.6980 0.76863], 'EdgeColor',[0.3137 0.3137 0.3137])
        
        % titles
        set(h.tit, 'FontName', options.fontName, 'FontSize', options.fontSizeBase,...
                   'FontWeight', 'bold', 'interpreter', 'none')
        
        % text plots
        
            % the text part
            set([h.colorim_textFields h.phoRad_textFields h.photorecep_textFields],...
                'FontName', options.fontName, 'FontSize', options.fontSizeBase, ...
                'FontWeight', 'bold', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle',...
                'interpreter', 'none')
            
            % the numerical part
            set([h.colorim_numFields h.phoRad_numFields h.photorecep_numFields],...
                 'FontName', options.fontName, 'FontSize', options.fontSizeBase,...
                 'HorizontalAlignment', 'center','VerticalAlignment', 'middle')
             
            % the unit part
            set([h.colorim_unitFields h.phoRad_unitFields h.photorecep_unitFields],...
                 'FontName', options.fontName, 'FontSize', options.fontSizeBase,...
                 'HorizontalAlignment', 'left','VerticalAlignment', 'middle')

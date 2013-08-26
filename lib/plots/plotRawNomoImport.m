function h = plotRawNomoImport(dataIn, options, fitOptions)  
    
    % get the fields of the input structure
    structNames = fieldnames(dataIn);    
            
        % possible conditional checking
        %{
        isempty(cell2mat(strfind(structNames, 'w')))  
        isempty(cell2mat(strfind(structNames, 'SEM')))        
        isempty(cell2mat(strfind(structNames, 'SD')))                
        isempty(cell2mat(strfind(structNames, 'response')))
        isempty(cell2mat(strfind(structNames, 'lambda')))
        isempty(cell2mat(strfind(structNames, 'fileName')))        
        %}
    
    %% init figure
    h.fig = figure('Color', 'w', 'Name', ['Template Fit:', dataIn.fileName]);
    set(h.fig, 'Position', [0.55*options.scrsz(3) 0.30*options.scrsz(4) 0.35*options.scrsz(3) 0.50*options.scrsz(4)])       
    
    %% Plot the data
    
        %% texts for plot annotations
        
            % fit method
            if fitOptions.fitInLOG == 1
               fitType = 'Fitting in LOG domain';
            else
               fitType = 'Fitting in LINEAR domain';
            end
            
            % date
                cl = fix(clock); hours = num2str(cl(4)); 
                if cl(5) < 10; mins = ['0', num2str(cl(5))]; else mins = num2str(cl(5)); end
                dateText = [date, ', ', hours, ':', mins];
                
            % density
                densityText = ['axial density: ', num2str(fitOptions.nomoOptions.density,2)];
            
        

        %% LINEAR PLOT
        h.sp(1) = subplot(2,1,1);
        
            box off
            hold on
            % SEM
            if ~isempty(cell2mat(strfind(structNames, 'SEM')))
                h.errBar_SEM = errorbar(dataIn.lambda, dataIn.response, dataIn.SEM, 'ko');
            else % if no SEM data is available
                h.errBar_SEM = plot(dataIn.lambda, dataIn.response, 'ko');
            end

            % SD
            if ~isempty(cell2mat(strfind(structNames, 'SD'))) 
                h.errBar_SD  = errorbar(dataIn.lambda, dataIn.response, dataIn.SD, 'ko');    
            else % if no SD data is available
                h.errBar_SD  = plot(dataIn.lambda, dataIn.response, 'ko');    
            end
            hold off
            
            set(gca, 'FontName', options.fontName, 'FontSize', options.fontSizeBase)
            lab(1,1) = xlabel('Wavelength [nm]');
            lab(1,2) = ylabel('Response');
            xlim([400 650])
            ylim([0 1.2])
            h.leg = legend('w SEM', 'w SD', 2);
            set(h.leg, 'EdgeColor', [.7 .7 .7], 'Location', 'NorthEast')
            
            % annotate the plot
            ylims = get(gca, 'YLim'); xlims = get(gca, 'XLim'); yOffset = 0.1;
            h.annotText(1) = text(xlims(1), ylims(2)+yOffset, fitType);
            h.annotText(2) = text(xlims(2), ylims(2)+yOffset, dateText, 'HorizontalAlignment', 'right');
            
            
        %% LOG PLOT
        h.sp(2) = subplot(2,1,2);        
        
            box off
            
            % SEM           
            if ~isempty(cell2mat(strfind(structNames, 'SEM'))) && ~isempty(cell2mat(strfind(structNames, 'SD')))
                
                % do something to plot the error bars in LOG domain
                % correctly
                %{
                log10(dataIn.SEM)
                log10(dataIn.SD)
                h.errBar_LOG(1:2) = errorbar(dataIn.lambda, log10(dataIn.response), log10(dataIn.SEM), 'ko',...
                                             dataIn.lambda, log10(dataIn.response), log10(dataIn.SD), 'ko');
                %}
                h.errBar_LOG(1:2) = plot(dataIn.lambda, log10(dataIn.response), 'ko',...
                                         dataIn.lambda, log10(dataIn.response), 'ko');
                                         
            else % if no SD&SEM data is available
                h.errBar_LOG(1:2) = plot(dataIn.lambda, log10(dataIn.response), 'ko',...
                                         dataIn.lambda, log10(dataIn.response), 'ko');
            end
            xlim([400 650])
            ylim([-4 1.0])
            set(gca, 'FontName', options.fontName, 'FontSize', options.fontSizeBase)
            lab(2,1) = xlabel('Wavelength [nm]');
            lab(2,2) = ylabel('Response');
            h.leg = legend('w SEM', 'w SD', 2);
            set(h.leg, 'EdgeColor', [.7 .7 .7], 'Location', 'NorthEast')
            
            % annotate the plot
            ylims = get(gca, 'YLim'); xlims = get(gca, 'XLim'); yOffset = 0.2;
            h.annotText(3) = text(xlims(1), ylims(2)+yOffset, densityText);
            h.annotText(4) = text(xlims(2), ylims(2)+yOffset, '', 'HorizontalAlignment', 'right');
            
    
    %% Common STYLE
        
        set(h.annotText, 'FontName', options.fontName, 'FontSize', options.fontSizeBase)
        set(h.errBar_SEM, 'Color', [0.5 0.5 0.5], 'LineWidth', 1) % all plots
        set([h.errBar_SD h.errBar_SEM h.errBar_LOG], 'MarkerFaceColor', [0 .3 .9], 'MarkerEdgeColor', [0 0 0], 'MarkerSize', 4)
            
        
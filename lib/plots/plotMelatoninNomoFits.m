function h = plotMelatoninNomoFits(dataIn, templateFit, options, fitOptions, path)
    
    %% init figure
    h.fig = figure('Color', 'w', 'Name', 'Template Fits:');
    set(h.fig, 'Position', [0.025*options.scrsz(3) 0.57*options.scrsz(4) 0.95*options.scrsz(3) 0.58*options.scrsz(4)])       
    
    %% Plot the data
    
    rows = 2; % one for LIN and the OTHER for LOG scale
    cols = length(dataIn);
    
     % "full" wavelength vector corresponding to the fitted curve
    lambdaFull = (fitOptions.nomoOptions.xLims(1) : fitOptions.nomoOptions.xRes : fitOptions.nomoOptions.xLims(2))';
    
    for i = 1 : cols % number of plots        
        
        % get the fields of the input structures
        structNames_data = fieldnames(dataIn{i});
        structNames_fit = fieldnames(templateFit{i});
        
        %% texts for plot annotations
        
            % fit method
            if i <= cols/2
               fitType = 'LIN Fit';
               fitOptions.fitInLOG = 0;
            else
               fitType = 'LOG Fit';
               fitOptions.fitInLOG = 1;
            end
            
            % date
                cl = fix(clock); hours = num2str(cl(4)); 
                if cl(5) < 10; mins = ['0', num2str(cl(5))]; else mins = num2str(cl(5)); end
                dateText = [date, ', ', hours, ':', mins];
                
            % density
                densityText = ['axial density: ', num2str(fitOptions.nomoOptions.boundsDens(1),2)];
            
            % filename text
                filenameText = strrep(dataIn{i}.fileName, '.txt', '');
                filenameText = strrep(strrep(strrep(filenameText, '_LIN_', ''), 'Data', ''), 'Melatonin', '');
                filenameText = strrep(strrep(strrep(filenameText, 'Estimate', ''), 'Data', ''), 'Melatonin', '');
                
            % optimizer
                optimizerText = ['Function: ', 'fmincon'];
                algorithmText = ['Algorithm: ', 'interior-point'];               
                
        

        %% LINEAR PLOT
        h.sp(i,1) = subplot(rows,cols,i);
        
            box off
            hold on
            % SEM
            if ~isempty(cell2mat(strfind(structNames_data, 'SEM')))
                h.errBar_SEM = errorbar(dataIn{i}.lambda, dataIn{i}.response, dataIn{i}.SEM, 'ko');
            else % if no SEM data is available
                h.errBar_SEM = plot(dataIn{i}.lambda, dataIn{i}.response, 'ko');
            end

            % SD
            if ~isempty(cell2mat(strfind(structNames_data, 'SD'))) 
                h.errBar_SD  = errorbar(dataIn{i}.lambda, dataIn{i}.response, dataIn{i}.SD, 'ko');    
            else % if no SD data is available
                h.errBar_SD  = plot(dataIn{i}.lambda, dataIn{i}.response, 'ko');    
            end
            hold off
            
            set(gca, 'FontName', options.fontName, 'FontSize', options.fontSizeBase)
            lab(1,1) = xlabel('Wavelength [nm]');
            lab(1,2) = ylabel('Response');
            xlim([400 650])
            ylim([0 1.2])
            
            % h.leg = legend('w SEM', 'w SD', 2);
            % set(h.leg, 'EdgeColor', [.7 .7 .7], 'Location', 'NorthEast')
            
            % annotate the plot
            ylims = get(gca, 'YLim'); xlims = get(gca, 'XLim'); yOffset = 0.1;
            h.annotText(1) = text(xlims(1), ylims(2)+yOffset, filenameText, 'HorizontalAlignment', 'left');
            h.annotText(2) = text(xlims(2), ylims(2)+yOffset, fitType, 'HorizontalAlignment', 'right');
            
            
        %% LOG PLOT
        h.sp(i,2) = subplot(rows,cols,cols+i);
        
            box off
            
            % SEM           
            if ~isempty(cell2mat(strfind(structNames_data, 'SEM'))) && ~isempty(cell2mat(strfind(structNames_data, 'SD')))
                
                % do something to plot the error bars in LOG domain
                % correctly
                %{
                log10(dataIn.SEM)
                log10(dataIn.SD)
                h.errBar_LOG(1:2) = errorbar(dataIn.lambda, log10(dataIn.response), log10(dataIn.SEM), 'ko',...
                                             dataIn.lambda, log10(dataIn.response), log10(dataIn.SD), 'ko');
                %}
                h.errBar_LOG(1:2) = plot(dataIn{i}.lambda, log10(dataIn{i}.response), 'ko',...
                                         dataIn{i}.lambda, log10(dataIn{i}.response), 'ko');
                                         
            else % if no SD&SEM data is available
                h.errBar_LOG(1:2) = plot(dataIn{i}.lambda, log10(dataIn{i}.response), 'ko',...
                                         dataIn{i}.lambda, log10(dataIn{i}.response), 'ko');
            end
            
            xlim([400 650])
            ylim([-4 1.0])
            set(gca, 'FontName', options.fontName, 'FontSize', options.fontSizeBase)
            lab(2,1) = xlabel('Wavelength [nm]');
            lab(2,2) = ylabel('Response');
            
            % h.leg = legend('w SEM', 'w SD', 2);
            % set(h.leg, 'EdgeColor', [.7 .7 .7], 'Location', 'NorthEast')
            
            % annotate the plot
            ylims = get(gca, 'YLim'); xlims = get(gca, 'XLim'); yOffset = 0.2;
            if i == 1
                h.annotText(3) = text(xlims(2), ylims(2)+yOffset, dateText, 'HorizontalAlignment', 'right');
            elseif i == 2
                h.annotText(4) = text(xlims(2), ylims(2)+yOffset, densityText, 'HorizontalAlignment', 'right');
            elseif i == 3
                h.annotText(5) = text(xlims(2), ylims(2)+yOffset, optimizerText, 'HorizontalAlignment', 'right');
            elseif i == 4
                h.annotText(6) = text(xlims(2), ylims(2)+yOffset, algorithmText, 'HorizontalAlignment', 'right');
            end            
            
            % PLOT THE FITs
            if fitOptions.fitInLOG == 1

                currDir = pwd;
                cd(path.library_nomo)
                templateFit{i} = templateFitToLIN(templateFit{i});
                cd(currDir)

                % update the plots
                indx = 1;
                h.fig = updatePlot(h.fig, h.sp(i,indx), indx, lambdaFull, templateFit{i}.specOut, fitOptions.nomoOptions, 'nomogram'); % LIN
                indx = 2;
                h.fig = updatePlot(h.fig, h.sp(i,indx), indx, lambdaFull, log10(templateFit{i}.specOut), fitOptions.nomoOptions, 'nomogram'); % LOG      

                    % ADD THE FIT descriptors
                    h.fitDesc(1) = text(xlims(1)+10, ylims(1)+0.92, ['AIC = ', num2str(templateFit{i}.fitStats.AIC,'%3.1f')]);
                    h.fitDesc(2) = text(xlims(1)+10, ylims(1)+0.6,  ['SSE = ', num2str(templateFit{i}.fitStats.SS_err,'%1.2f')]);
                    h.fitDesc(3) = text(xlims(1)+10, ylims(1)+0.26, ['r   = ', num2str(templateFit{i}.fitStats.rCorr,'%1.2f')]);

            else

                % update the plots
                indx = 1;
                h.fig = updatePlot(h.fig, h.sp(i,indx), indx, lambdaFull, templateFit{i}.specOut, fitOptions.nomoOptions, 'nomogram'); % LIN
                
                    % ADD THE FIT descriptors
                    h.fitDesc(1) = text(xlims(1)+10, 0.21, ['AIC = ', num2str(templateFit{i}.fitStats.AIC,'%3.1f')]);
                    h.fitDesc(2) = text(xlims(1)+10, 0.14,  ['SSE = ', num2str(templateFit{i}.fitStats.SS_err,'%1.2f')]);
                    h.fitDesc(3) = text(xlims(1)+10, 0.07, ['r   = ', num2str(templateFit{i}.fitStats.rCorr,'%1.2f')]);
                
                indx = 2;
                h.fig = updatePlot(h.fig, h.sp(i,indx), indx, lambdaFull, log10(templateFit{i}.specOut), fitOptions.nomoOptions, 'nomogram'); % LOG


            end
            set(h.fig.fitText, 'FontName', options.fontName, 'FontSize', options.fontSizeBase+1, 'FontWeight', 'bold')
            set(h.fitDesc, 'FontName', options.fontName, 'FontSize', options.fontSizeBase)
            
            
            
    
        %% Common STYLE

            set(h.annotText, 'FontName', options.fontName, 'FontSize', options.fontSizeBase)
            set(h.errBar_SEM, 'Color', [0.5 0.5 0.5], 'LineWidth', 1) % all plots
            set([h.errBar_SD h.errBar_SEM h.errBar_LOG], 'MarkerFaceColor', [1 0.2 0], 'MarkerEdgeColor', [0 0 0], 'MarkerSize', 4)
        
    end
            
        
        
    function h = updatePlot(h, axActiv, indx, x, y, fitOptions, dataType) 
        
        hold(axActiv, 'on')
            plot(axActiv, x, y, 'Color', [0 0.556862771511078 0.560784339904785], 'LineWidth', 1)
        hold off
        
        % h.leg = legend('SEM', 'SD', 'Nomog');
        
        % annotate the peak of the fit        
        if indx == 1 % for linear plot
            offset = 0.1;
        else
            offset = 0.45;
        end
        
        axes(axActiv)
        [C,I] = max(y);
        peakX = x(I);
        h.fitText(indx) = text(peakX, C+offset, [num2str(peakX,'%3.1f'), ' nm']);
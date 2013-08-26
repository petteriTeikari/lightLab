function QuickPlotDisplayResults(x, lb, ub, fval, t, K, N, outSpectrum, handles, style, mode)   
            
        % Define the strings to be displayed
        plotStrings{1} = sprintf('%s\t%s','AICc', num2str(outSpectrum.AICc, '%2.2f'));
        plotStrings{2} = sprintf('%s\t%s','R^2', num2str(outSpectrum.R2, '%1.2f'));
        plotStrings{3} = sprintf('%s\t%s', '', 'wo weights atm');        
        plotStrings{4} = sprintf('%s\t%s', '', '');
        if strcmp(mode, 'original') ~= 1 || strcmp(mode, 'opponent_wo_bistability') ~= 1
            plotStrings{5} = sprintf('%s\t%s\t%s%s%s%s%s%s', 'OPN4', num2str(x(6), '%1.2f'), '(m)', ' [', num2str(lb(6),'%1.2f'), ', ', num2str(ub(6),'%1.2f'), ']');
        else
            plotStrings{5} = sprintf('%s\t%s\t%s%s%s%s%s%s', 'OPN4', num2str(x(1), '%1.2f'), '(m)', ' [', num2str(lb(1),'%1.2f'), ', ', num2str(ub(1),'%1.2f'), ']');
        end
        plotStrings{6} = sprintf('%s\t%s\t%s%s%s%s%s%s', 'Cones', num2str(x(2), '%1.2f'), '(c)', ' [', num2str(lb(2),'%1.2f'), ', ', num2str(ub(2),'%1.2f'), ']');
        plotStrings{7} = sprintf('%s\t%s\t%s%s%s%s%s%s', 'Rods', num2str(x(3), '%1.2f'), '(r)', ' [', num2str(lb(3),'%1.2f'), ', ', num2str(ub(3),'%1.2f'), ']');
        plotStrings{8} = sprintf('%s\t%s', '', '');
        plotStrings{9} = sprintf('%s\t%s', 'k_1', num2str(x(4), '%2.1f')); 
        plotStrings{10} = sprintf('%s\t%s', 'k_2', num2str(x(5), '%2.1f'));
        plotStrings{11} = sprintf('%s\t%s', 'fval', num2str(fval));

        % define x/y -offsets for text
        xAx0 = handles.xlimits(2);
        yAx0 = handles.ylimits(2); y_interv = (handles.ylimits(2) - handles.ylimits(1)) / length(plotStrings);

        % go through the strings
        for i = 1 : length(plotStrings)            
            te(i) = text(xAx0*0.85, yAx0 - ((i-1)*y_interv), plotStrings{i});
        end
        
        % Additional text
        minusOffset = 0.3;
        t_add(1) = text(handles.xlimits(1), 1.06*handles.ylimits(2), ['Optimization finished! (' , num2str(t.optimization,3), ' s)']); 
        
        cl = fix(clock); hours = num2str(cl(4)); 
        if cl(5) < 10; mins = ['0', num2str(cl(5))]; else mins = num2str(cl(5)); end        
        t_add(2) = text(handles.xlimits(2), handles.ylimits(1) - 0.16, ['v. ', date, ', ', hours, ':', mins]); 
        t_add(3) = text(handles.xlimits(2), handles.ylimits(1) - 0.24, ['model: ', mode]); 
        
            set(t_add, 'FontName', style.fontName, 'FontSize', style.fontBaseSize)
            set(t_add(2:3), 'HorizontalAlignment', 'right', 'Interpreter', 'none')
            
        % display the model equation
        if strcmp(mode, 'bistable_lensCorr') == 1           
            str = ['S_T_o_t_a_l = ', '[ ', '(m * S_e_q_u_i)', '^1^/^k^1', ' + [(c * S_c_o_n_e_s + r * S_r_o_d_s)^1^/^k^1]', '^k^2', ' ]', '^1^/^k^2'];
            % ( melanopsinBistableTerm_wLens .^ (1/x(4)) + ( (coneTerm + rodTerm).^(1/x(4)) ).^x(5)  ).^(1/x(5));            
        else
            str = '';
        end
        modelText = text(handles.xlimits(1), handles.ylimits(1) - minusOffset, str);

        % style the text & legend
        set(te, 'FontName', style.fontName, 'FontSize', style.fontBaseSize+1)
        set(modelText, 'FontName', style.fontName, 'FontSize', style.fontBaseSize+2)
        set(te, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom')

        leg = legend(['S_T_o_t_a_l', '  K = ', num2str(K)], ['S_e_x_p', '  N = ', num2str(N)], 'Data points', 3); 
            set(leg, 'Location', 'North', 'EdgeColor', [.4 .4 .4])           
            set(leg, 'FontName', style.fontName, 'FontSize', style.fontBaseSize)  
            legend('boxoff')

        % annotate the peak value of the final fit
        annotatePeakValue(outSpectrum.spectrum, outSpectrum.wavelength, style, handles)
        

        
       
        
    function annotatePeakValue(spectrum, wavelength, style, handles)

        % 1st column - wavelength
        % 2nd column - sensitivity/response/irradiance    

        [maxValue, index] = max(spectrum);
        peakWavelength = wavelength(index);    

        t = text(peakWavelength, 1.04*maxValue, [num2str(peakWavelength), ' nm'], 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center');
        set(t, 'FontName', style.fontName, 'FontSize', style.fontBaseSize+1, 'FontWeight', 'bold')
function [figureHandle, handles] = initQuickPoolFigure(handles, style, S)
% Preallocate/Initialize the figure

        figureHandle.figurePlot = figure('Color','w');    
            set(figureHandle.figurePlot, 'Position', [0.1*handles.scrsz(3) 0.1*handles.scrsz(4) 0.6*handles.scrsz(3) 0.7*handles.scrsz(4)])
            handles.xlimits = [400 700];
            handles.ylimits = [0 1.2];
            

        %% SUBPLOT 1 : Total Action Spectra vs. Experimental Data
        handles.sp(1) = subplot(2,2,[1 2]);            
            hold on
            figureHandle.total = plot(NaN, NaN, 'b--'); 
            figureHandle.exp = plot(NaN, NaN, 'g');                 
            figureHandle.diff = plot(NaN, NaN, 'r');
            xlim(handles.xlimits)
            ylim(handles.ylimits)           
            set(gca, 'FontName', style.fontName, 'FontSize', style.fontBaseSize) %, 'Color', [.4 .4 .4])
            hold off

            
        %% SUBPLOT 2 : Static Photoreceptor Sensitivities
        handles.sp(2) = subplot(2,2,3);            
        
            figureHandle.p_static(1:6) = plot(S.wavelength, S.rods,...
                            S.wavelength, S.cones,...
                            S.wavelength, S.opn4,...                                                            
                            S.wavelength, S.LWS,...
                            S.wavelength, S.SWS,...
                            S.wavelength, S.MWS); 
                        
            xlim(handles.xlimits); ylim(handles.ylimits) 
            set(gca, 'FontName', style.fontName, 'FontSize', style.fontBaseSize) %, 'Color', [.4 .4 .4])
            leg = legend('Rods', 'Cones', 'OPN4', 'LWS', 'SWS', 'MWS', 6); 
                set(leg, 'Location', 'NorthEast', 'EdgeColor', [.4 .4 .4])
                legend('boxoff')
                set(leg, 'FontName', style.fontName, 'FontSize', style.fontBaseSize-1)
            

            
        %% SUBPLOT 3 : Dynamic Photoreceptor Sensitivities
        handles.sp(3) = subplot(2,2,4);

            hold on
            figureHandle.p_dynamic(1:3) = plot(S.rods(:,1), S.rods,...
                            S.rods(:,1), S.cones,...
                            S.rods(:,1), S.opn4);

            xlim(handles.xlimits)
            ylim(handles.ylimits) 
            set(gca, 'FontName', style.fontName, 'FontSize', style.fontBaseSize) %, 'Color', [.4 .4 .4])
            leg = legend('Rods', 'Cones', 'Melanopsin', 3); 
                set(leg, 'Location', 'NorthEast', 'EdgeColor', [.4 .4 .4])
                set(leg, 'FontName', style.fontName, 'FontSize', style.fontBaseSize-1)
            hold off

            % set PLOT COLORs
            set(figureHandle.p_static(1), 'Color', [0 0 0])
            set(figureHandle.p_static(2), 'Color', [0 1 0])
            set(figureHandle.p_static(3), 'Color', [.8 .8 1])
            set(figureHandle.p_static(4), 'Color', [0 0 1])
            set(figureHandle.p_static(5), 'Color', [1 .8 .9])
            set(figureHandle.p_static(6), 'Color', [1 0 .2])
            %{
            set(figureHandle.p_static(7), 'Color', [.7 .55 .55], 'LineStyle', '--')
            set(figureHandle.p_static(8), 'Color', [.55 .55 .7], 'LineStyle', '--')
            set(figureHandle.p_static(9), 'Color', [.55 .7 .55], 'LineStyle', '--')
            set(figureHandle.p_static(10), 'Color', [1 .808 .671], 'LineStyle', '--')
            %}

            set(figureHandle.p_dynamic(1), 'Color', [0 0 0])
            set(figureHandle.p_dynamic(2), 'Color', [0 1 0])
            set(figureHandle.p_dynamic(3), 'Color', [0 0 1])

        axes(handles.sp(1)) %#ok<MAXES>

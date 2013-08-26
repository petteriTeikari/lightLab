%% DOCUMENTATION
% All the lines starting with %DOC% in similar sense as Java's javadoc

    %DOC%<desc>Demo for van de Kraats and van Norren 2007 ocular media model<desc/>

    %DOC%<h2>Description</h2>
    %DOC%cmdLine_sessionAnalysis() runs the session-by session analysis of lens density analysis input files

%% CODE
function demo_compare_Van2007components()
    
    close all
    scrsz = get(0,'ScreenSize'); % get screen size for plotting

    l = (300:1:800)';
    offset = 0;

    ageY = 25;
    ageO = 65;
    
    lensY = lensModel_vanDeKraats2007(ageY, l, offset);
    lensO = lensModel_vanDeKraats2007(ageO, l, offset);
    
    figure('Color', 'w', 'Position', [0.05*scrsz(3) 0.1*scrsz(4) 0.55*scrsz(3) 0.8*scrsz(4)])
    
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
        set(sp, 'FontName', 'Georgia', 'FontSize', 8, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3])
        set(p, 'LineWidth', 2)
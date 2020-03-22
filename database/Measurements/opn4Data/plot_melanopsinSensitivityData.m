function plot_melanopsinSensitivityData(lambda, lucas2001, berson2002, hattar2003, gamlin2007, bailes2013_mouse, bailes2013_human, opn4_nomogram, timeToEquilibrium, rFraction)
    
    if nargin == 0
        load spectralData.mat
    else
        save spectralData.mat
    end
    
    close all
    scrsz = get(0,'ScreenSize'); % get screen size for plotting
    whos
    
    % normalize
    rFraction.retinal = rFraction.retinal / max(rFraction.retinal);
    
    fig = figure('Color', 'w');
        set(fig,  'Position', [0.48*scrsz(3) 0.05*scrsz(4) 0.500*scrsz(3) 0.9*scrsz(4)])
        rows = 2; 
        cols = 1;
    
        fieldName = 'retinal';
        i = 1;        
        sp(i) = subplot(rows, cols, i);
        
            p(i,:) = semilogy(  lucas2001.(fieldName)(:,1), lucas2001.(fieldName)(:,2), 'o', ...
                            berson2002.(fieldName)(:,1), berson2002.(fieldName)(:,2), 'o', ...
                            hattar2003.(fieldName)(:,1), hattar2003.(fieldName)(:,2), 'o', ...
                            gamlin2007.(fieldName)(:,1), gamlin2007.(fieldName)(:,2), 'o', ...
                            bailes2013_mouse.(fieldName)(:,1), bailes2013_mouse.(fieldName)(:,2), 'o', ...
                            bailes2013_human.(fieldName)(:,1), bailes2013_human.(fieldName)(:,2), 'o', ...
                            lambda, opn4_nomogram.retinal, lambda, timeToEquilibrium.retinal, lambda, rFraction.retinal);
                            
                ylim([0.001 1.2])
           
                tit(i) = title('OPN4 Sensitivities from Studies');
                lab(i,1) = xlabel('Wavelength [nm]');
                lab(i,2) = ylabel('Relative sensitivity');
                
                    legStr = {'Lucas 2001 mouse', 'Berson 2002 rat', 'Hattar 2003 mouse', 'Gamlin 2007 macaque', 'Bailes 2013 mouse', 'Bailes 2013 human', ...
                                'OPN4 Nomogram: 479 nm', 'TimeToEquilibrium (467/476/446 nm)', 'R fraction'};
                    leg(i) = legend(legStr, 'Location', 'NorthEastOutside');
                    legend('boxoff')
                
            %{
            hold on
            j = 1; p1(j) = errorbar(lucas2001.(fieldName)(:,1), lucas2001.(fieldName)(:,2), lucas2001.(fieldName)(:,3), 'o');
            j = 2; p1(j) = errorbar(berson2002.(fieldName)(:,1), berson2002.(fieldName)(:,2), berson2002.(fieldName)(:,3), 'o');
            j = 3; p1(j) = errorbar(hattar2003.(fieldName)(:,1), hattar2003.(fieldName)(:,2), hattar2003.(fieldName)(:,3), 'o');
            j = 4; p1(j) = errorbar(gamlin2007.(fieldName)(:,1), gamlin2007.(fieldName)(:,2), gamlin2007.(fieldName)(:,3), 'o');
            j = 5; p1(j) = errorbar(bailes2013_mouse.(fieldName)(:,1), bailes2013_mouse.(fieldName)(:,2), bailes2013_mouse.(fieldName)(:,3), 'o');
            j = 6; p1(j) = errorbar(bailes2013_human.(fieldName)(:,1), bailes2013_human.(fieldName)(:,2), bailes2013_human.(fieldName)(:,3), 'o');
            hold off
            %}
        
        i = 2;        
        sp(i) = subplot(rows, cols, i);
        
            p(i,:) = plot(  lucas2001.(fieldName)(:,1), lucas2001.(fieldName)(:,2), 'o', ...
                            berson2002.(fieldName)(:,1), berson2002.(fieldName)(:,2), 'o', ...
                            hattar2003.(fieldName)(:,1), hattar2003.(fieldName)(:,2), 'o', ...
                            gamlin2007.(fieldName)(:,1), gamlin2007.(fieldName)(:,2), 'o', ...
                            bailes2013_mouse.(fieldName)(:,1), bailes2013_mouse.(fieldName)(:,2), 'o', ...
                            bailes2013_human.(fieldName)(:,1), bailes2013_human.(fieldName)(:,2), 'o', ...
                            lambda, opn4_nomogram.retinal, lambda, timeToEquilibrium.retinal, lambda, rFraction.retinal);
                            
                ylim([0.001 1.05])
           
                tit(i) = title('OPN4 Sensitivities from Studies');
                lab(i,1) = xlabel('Wavelength [nm]');
                lab(i,2) = ylabel('Relative sensitivity');
                
                    legStr = {'Lucas 2001 mouse', 'Berson 2002 rat', 'Hattar 2003 mouse', 'Gamlin 2007 macaque', 'Bailes 2013 mouse', 'Bailes 2013 human', ...
                                'OPN4 Nomogram: 479 nm', 'TimeToEquilibrium (467/476/446 nm)', 'R fraction'};
                    leg(i) = legend(legStr, 'Location', 'NorthEastOutside');
                    legend('boxoff')
                
                    
        % style
        set(p, 'MarkerSize', 5)
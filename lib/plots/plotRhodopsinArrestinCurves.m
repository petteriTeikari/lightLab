function plotRhodopsinArrestinCurves(T, Y, handles)

    %% molecule numbers
    
    % define f_Me
    f_Me = (Y(:,2) + Y(:,3)) ./ (Y(:,1) + Y(:,2) + Y(:,3) + Y(:,4) + Y(:,5));

    % Plot
    plot(T,Y(:,1),'-', T,Y(:,2), '-', T,Y(:,3),'--', T,Y(:,4),'--', T,Y(:,5),':', T, f_Me, '-')    

    
    leg(1) = legend('R_a', 'M_a', 'M_i', 'R_i', 'A', 'f_M_e', 6);
    set(leg(1),'Units','pixels','Position',[817.250000000002 40.6249999999999 69.5 142.125]);

    lab(1) = xlabel('');
    lab(2) = ylabel('Relative number of molecules');

    
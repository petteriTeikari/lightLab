function CCT_anal = calc_CCTanal(x, y, CCT_geom)
        
    % McCamy's polymomial formula for CCT: (CS McCamy (1992), Color Res. Appl. 17:142-144)
    % CCT = a*n^3 + b* n^2 + c*n + d
    % with inverse line slope n is given by
    % n = (x - x_e) / (y - y_e)

    % Hernandez-Andres et al. improved alternative for McCamy: 
    % (Hernandez-Andres et al. (1999), Applied Optics 38(27):5703-5709 
    % http://dx.doi.org/10.1364/AO.38.005703
    
    if nargin == 2
       CCT_geom = 6500; 
    end

    % Constants are defined slightly differently for high CCTs over 50'000K    

        if CCT_geom < 50000 || isnan(CCT_geom) == 1 % valid range 3'000 - 50'000 K

            % constants taken from the original paper
            x_e = 0.3366;
            y_e = 0.1735;
            A0 = -949.86315;
            A1 = 6253.80338;
            t1 = 0.92159;
            A2 = 28.70599;
            t2 = 0.20039;
            A3 = 0.00004;
            t3 = 0.07125;

            % inverse slope
            n = (x - x_e) / (y - y_e);

            % CCT
            CCT_anal = A0 + A1 * exp(-n/t1) + A2 * exp(-n/t2) + A3*exp(-n/t3);
            
        else % if color temperature is above 50'000 K

            % constants taken from the original paper
            x_e = 0.3356;
            y_e = 0.1691;
            A0 = 36284.48953;
            A1 = 0.00228;
            t1 = 0.07861;
            A2 = 5.4535 * 10^-36;
            t2 = 0.01543;

            % inverse slope
            n = (x - x_e) / (y - y_e);

            % CCT
            CCT_anal = A0 + A1 * exp(-n/t1) + A2 * exp(-n/t2);

        end
        
    if CCT_anal < 0
        CCT_anal = NaN;
    end
        
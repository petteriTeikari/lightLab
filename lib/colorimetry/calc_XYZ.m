function [X, Y, Z, x, y, z] = calc_XYZ(S, CMF)       

    % remove NaN-values (if there are any from the input spectrum)
    indx    = isnan(S);
    S(indx) = 0;    
    
    wavelength_spacing = CMF(2,1) - CMF(1,1);

    % trapezoid integration for calculating X, Y, Z from CMFs
    X = wavelength_spacing * trapz( S .* CMF(:,2));
    Y = wavelength_spacing * trapz( S .* CMF(:,3));
    Z = wavelength_spacing * trapz( S .* CMF(:,4));
    
    x = X / (X + Y + Z);
    y = Y / (X + Y + Z);
    z = Z / (X + Y + Z);
   
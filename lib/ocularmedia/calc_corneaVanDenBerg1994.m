function vanDenBergTan1994 = calc_corneaVanDenBerg1994(lambda)
    
    % Van Den Berg, T.J.T.P., and K.E.W.P. Tan. 
    % "Light transmittance of the human cornea from 320 to 700 nm for different ages." 
    % Vision Research 34, no. 11 (June 1994): 1453-1456. 
    % http://dx.doi.org/10.1016/0042-6989(94)90146-5.

    % constants
    c_direct = 85 * 10^3; % nm^4 for direct transmittance (acceptance angle of the order of 1 deg) and 
    c_total = 21 * 10^8; % nm^4 for total transmittance (acceptance angle close to 180 deg).

    % (λ = wavelength in nm, λ > 310nm)
    vanDenBergTan1994.Direct = -0.016 - (c_direct .* (lambda .^ 4));
    venBergTan1994.Total =  -0.016 - (c_total  .* (lambda .^ 4));
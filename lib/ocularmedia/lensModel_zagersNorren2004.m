function Zagers2004 = lensModel_zagersNorren2004(A, lambda)

    % Zagers, Niels P. A., and Dirk van Norren. 
    % "Absorption of the eye lens and macular pigment derived from the reflectance of cone photoreceptors.” 
    % Journal of the Optical Society of America A 21, no. 12 (December 1, 2004): 2257-2268. 
    % http://dx.doi.org/10.1364/JOSAA.21.002257.
                    
    % Zagers and van Norren (2004) - YOUNG LENS
    ones370 = 370 * ones(length(lambda),1);
    delta = 37.2;
    
    Zagers2004.youngLens = 6.09 .* exp( -1 .* (((lambda - ones370) / delta) .^ 2));             

    % Zagers and van Norren (2004) - OLD LENS
    ones320 = 320 * ones(length(lambda),1);
    delta = 76.0;
    
    Zagers2004.oldLens = 5.65 .* exp( -1 .* (((lambda - ones320) / delta) .^ 2));         

    % Zagers and van Norren (2004) - TOTAL                
    Zagers2004.totalLens = ((0.42 - (0.0064*A)) .* Zagers2004.youngLens) ...
                            + ((-0.08 + (0.0094*A)) .* Zagers2004.oldLens);                                  
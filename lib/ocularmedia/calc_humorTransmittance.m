function humors = calc_humorTransmittance(lambda)

    % Smith, Raymond C., and Karen S. Baker. 
    % "Optical properties of the clearest natural waters (200-800 nm)."
    % Applied Optics 20, no. 2 (January 15, 1981): 177-184. 
    % http://dx.doi.org/10.1364/AO.20.000177.
    
    templatesSmithBaker1981_file = 'smithBaker1981_opticalPropertiesOfWater_table1_orig+interp200-800-1nm.mat';

    % van de Kraats and van Norren (2008) - WATER (24mm) ABSORBANCE
    water_l = 24 * 10^-3; % [m]    
     
    orig = load(templatesSmithBaker1981_file);        
    humors.density = water_l .* orig.data_interp(:,2); % K_w
    humors.water_l = water_l;
    
    % do zero padding / interpolation 
    humors.density = zeroPadding_forTemplates(humors.density, lambda, [200 800]);
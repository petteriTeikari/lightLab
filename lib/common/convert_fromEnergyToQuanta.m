function Q = convert_fromEnergyToQuanta(E, lambda)
     
    % Inputs
     %      E       - Irradiance [W/cm^2/sec (/nm)]
     %      lambda  - Wavelength [nm]
     % Output
     %      Q       - Photon density [ph/cm^2/sec]       
     
     h = 6.62606896 * 10^-34; % Planck's constant [J*s]
     c = 299792458; % Speed of light [m/s]  
     photonEnergy_vector = (h * c) ./ (lambda * 10^-9); % [J]
     Q = E ./ photonEnergy_vector;         
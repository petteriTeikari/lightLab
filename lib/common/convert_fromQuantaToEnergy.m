function E = convert_fromQuantaToEnergy(Q, lambda)
     
     % Inputs
     %      Q       - Photon density [ph/cm^2/sec]
     %      lambda  - Wavelength [nm]
     % Output
     %      E       - Irradiance [W/cm^2/sec (/nm)]
     
     h = 6.62606896 * 10^-34; % Planck's constant [J*s]
     c = 299792458; % Speed of light [m/s]  
     photonEnergy_vector = (h * c) ./ (lambda * 10^-9); % [J]
     %whos
     E = Q .*  photonEnergy_vector;
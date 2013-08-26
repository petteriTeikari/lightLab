function irrad = norm_unityPhotonDensity(lambda, irrad)

    % Constants    
    h = 6.62606896 * 10^-34; % Planck's constant [J*s]
    c = 299792458; % Speed of light [m/s]  
    
    % photon energy per lambda
    photonEnergies = (h * c) ./ (lambda * 10^-9); % [J]
    
    % photon density 
    Q = irrad .* photonEnergies;        
    
    % normalize to one
    sumQ = trapz(Q);
    Q = Q / sumQ;
    
    % convert back to irrad
    irrad = Q ./ photonEnergies;
    
    sumTest = trapz(Q)
    
    
function CMF_out = truncate_CMF(CMF, lambda, path)

    currDir = pwd;
    cd(path)    
    
    wavelength_spacing = CMF(2,1) - CMF(1,1);
    
    % add check fo "size inconsistency"
    CMF_out(:,1) = lambda;
    CMF_out(:,2) = truncate_spectrum(CMF(:,1), CMF(:,2), [min(lambda) max(lambda)], wavelength_spacing);
    CMF_out(:,3) = truncate_spectrum(CMF(:,1), CMF(:,3), [min(lambda) max(lambda)], wavelength_spacing);
    CMF_out(:,4) = truncate_spectrum(CMF(:,1), CMF(:,4), [min(lambda) max(lambda)], wavelength_spacing);
    
    cd(currDir)
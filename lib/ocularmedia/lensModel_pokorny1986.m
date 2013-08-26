function pokorny1986 = lensModel_pokorny1986(lambda, A, smallPupilCorr)

    % Pokorny, Joel, Vivianne C. Smith, and Margaret Lutze. 
    % "Aging of the human lens." 
    % Applied Optics 26, no. 8 (1987): 1437. 
    % http://dx.doi.org/10.1364/AO.26.001437  

    Pokorny1986_file = 'pokorny_table1_vanNorrenMod_orig+interp380-780-1nm.mat';
    pokornyImport = load(Pokorny1986_file);
    
    if smallPupilCorr == 0
        pokorny1986_dataInterp(:,2) = pokornyImport.data_interp(:,2) * 0.86;
        pokorny1986_dataInterp(:,3) = pokornyImport.data_interp(:,3) * 0.86;
        pokorny1986_dataInterp(:,4) = pokornyImport.data_interp(:,4) * 0.86;
    else
        pokorny1986_dataInterp(:,2) = pokornyImport.data_interp(:,2) * 1;
        pokorny1986_dataInterp(:,3) = pokornyImport.data_interp(:,3) * 1;
        pokorny1986_dataInterp(:,4) = pokornyImport.data_interp(:,4) * 1;
    end

    % replace NaNs with zeroes
    pokorny1986_dataInterp(isnan(pokorny1986_dataInterp(:,2)),2) = 0;
    pokorny1986_dataInterp(isnan(pokorny1986_dataInterp(:,3)),3) = 0;
    pokorny1986_dataInterp(isnan(pokorny1986_dataInterp(:,4)),4) = 0;        

    % PAD with zeros    
    pokorny1986_data = zeros(length(lambda),4);
    for j = 2 : 4
        pokorny1986_data(:,j) = zeroPadding_forTemplates(pokorny1986_dataInterp(:,j), lambda);        
    end
    
    
    % Pokorny aged, Piecewise definition
    if A >= 20 && A <= 60
        pokorny1986 = pokorny1986_data(:,3) .* ( ones(length(lambda),1) + (0.02*(A-32)) ) + pokorny1986_data(:,4);
        
    elseif A > 60
        pokorny1986 = pokorny1986_data(:,3) .* ( (1.56 * ones(length(lambda),1)) + (0.0667*(A-60)) ) + pokorny1986_data(:,4);                
        
    % actually not defined in the original paper, now we just 
    % use the same values as for ages between 20 and 60
    elseif A < 20                   
        pokorny1986 = pokorny1986_data(:,3) .* ( ones(length(lambda),1) + (0.02*(20-32)) ) + pokorny1986_data(:,4);
    end
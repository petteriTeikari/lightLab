function [spectrum, headers] = import_spectrumTemplate(templateStr, lambdaIn, templatePath, commonPath)

    currDir = pwd;
    cd(templatePath)
    
    if strcmpi(templateStr, 'SWS')
        impTmp = importdata('coneFundamentals_LINss10deg_380to780nm_1nm_Lin-E.txt', '\t', 1);
        spectrum = impTmp.data(:,4);
        lambda = impTmp.data(:,1);
        headers  = impTmp.textdata;
        
    elseif strcmpi(templateStr, 'MWS')
        impTmp = importdata('coneFundamentals_LINss10deg_380to780nm_1nm_Lin-E.txt', '\t', 1);
        spectrum = impTmp.data(:,3);
        lambda = impTmp.data(:,1);
        headers  = impTmp.textdata;
        
    elseif strcmpi(templateStr, 'LWS')        
        impTmp = importdata('coneFundamentals_LINss10deg_380to780nm_1nm_Lin-E.txt', '\t', 1);
        lambda = impTmp.data(:,1);
        spectrum = impTmp.data(:,2);
        headers  = impTmp.textdata;
       
    elseif strcmpi(templateStr, 'Vl') % photopic 10deg
        impTmp = importdata('v_lambda_linCIE2008v10e_LIN_380to780nm_1nm.txt', '\t', 1);
        lambda = impTmp.data(:,1);
        spectrum = impTmp.data(:,2);
        headers  = impTmp.textdata;
        
    elseif strcmpi(templateStr, 'Vl2deg') % photopic 2deg
        errordlg('Not implemented yet') 
        %{
        lambda = impTmp.data(:,1);
        impTmp = importdata('', '\t', 1);
        spectrum = impTmp.data(:,2);
        headers  = impTmp.textdata;
        %}
        
    elseif strcmpi(templateStr, 'Vprimel') % scotopic
        impTmp = importdata('v_lambda_Scotopic_1951e_LIN_380to780nm_1nm.txt', '\t', 1);
        lambda = impTmp.data(:,1);
        spectrum = impTmp.data(:,2);
        headers  = impTmp.textdata;
        
    elseif strcmpi(templateStr, 'Cl') % circadian
        impTmp = importdata('cLambda-Philips_LIN_380to780nm_1nm.txt', '\t', 1);
        lambda = impTmp.data(:,1);
        spectrum = impTmp.data(:,2);
        headers  = impTmp.textdata;
        
    elseif strcmpi(templateStr, 'BLH') % Blue Light Hazard
        impTmp = importdata('BLH_actionSpectrum_CIE2000_pons2007_LIN_380to780nm_1nm.txt', '\t', 1);
        lambda = impTmp.data(:,1);
        spectrum = impTmp.data(:,2);
        headers  = impTmp.textdata;
        
    elseif strcmpi(templateStr, 'CMF_x') % color match function x        
        impTmp = importdata('cie_xyz64_colorMatching_360to830nm_1nm.txt', '\t', 1);
        lambda = impTmp.data(:,1);
        spectrum = impTmp.data(:,2);
        headers  = impTmp.textdata;
        
    elseif strcmpi(templateStr, 'CMF_y') % color match function y
        impTmp = importdata('cie_xyz64_colorMatching_360to830nm_1nm.txt', '\t', 1);
        lambda = impTmp.data(:,1);
        spectrum = impTmp.data(:,3);
        headers  = impTmp.textdata;
        
    elseif strcmpi(templateStr, 'CMF_z') % color match function z
        impTmp = importdata('cie_xyz64_colorMatching_360to830nm_1nm.txt', '\t', 1);
        lambda = impTmp.data(:,1);
        spectrum = impTmp.data(:,4);
        headers  = impTmp.textdata;
       
       
    end
    
    %% CHANGE POSSIBLE NaNs to zeroes
    spectrum(isnan(spectrum)) = 0;
    
    %% TRUNCATE THE OUTPUT TO 380 - 780 nm in 1 nm steps if that is not
    % already the case
    cd(commonPath)
    lambdaLimits = [380 780];
    specRes_out  = 1;
    spectrum = truncate_spectrum(lambda, spectrum, lambdaLimits, specRes_out);
    cd(currDir)
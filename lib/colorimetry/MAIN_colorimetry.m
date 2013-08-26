function colorim = MAIN_colorimetry(lambda, S, path)

%   WRAPPER Function for calculating various colorimetric metrics

    %   Petteri Teikari (petteri.teikari@gmail.com), v. 04/2011
    %   INSERM U846, Lyon, France
    %
    %   INPUT    
    %       lambda          - wavelength vector
    %       S               - irradiance / relative power / etc. vector
    %       pathConstants   - path/folder containing the xyz-functions and
    %                         other constants needed for CCT and CRI
    %                         calculations
    %
    %   OUTPUT:
    %       colorim     -structure containing:
    %       .X          (CIE XYZ color coordinate) ?
    %       .Y          (CIE XYZ color coordinate) ?
    %       .Z          (CIE XYZ color coordinate) ?
    %       .x          (CIE XYZ color coordinate) ?
    %       .y          (CIE XYZ color coordinate) ?
    %       .z          (CIE XYZ color coordinate) ?
    %       .u          (CIE 1960 color coordinate)
    %       .v          (CIE 1960 color coordinate)
    %       .CCT        (Correlated Color Temperature), "main variable"
    %       .CCT_geom   (Correlated Color Temperature), "geometric"
    %       .CCT_anal   (Correlated Color Temperature), "analytic", not
    %                                       valid for CCTs under 3000 K
    %       .CRI        (CIE Color Rendering Index)
    %       .GA         (Gamut area)
    %       .FSI        (Full-Spectrum Index)
    %       .FSCI       (Full-Spectrum Color Index)
        
    % for further help, see:
    % http://www.lrc.rpi.edu/programs/nlpip/lightinganswers/lightsources/appendixb.asp
    
    % NOTE!
    % no input checking whatsoever yet implemented

    %% import from text files or from .MAT-file the constants, 
    % faster to import from the MAT-file but if you change the original TXT-files
    % that the MAT-files is not automatically updated then
    
    importFromMATs = 1;
    colorimetricConstantsFilename = 'colorimetricConstants.mat';
    currentPath = cd;    
        
        if importFromMATs == 1
            cd(path.templates)
            load(colorimetricConstantsFilename)
            cd(currentPath)
            
        else
            cd(path.templates)

            % import color matching (CMF) functions from files
            % i.e. The CIE 1931 RGB Color matching functions
            % http://cvrl.ucl.ac.uk/ccs.htm
            importedData = importdata('cie_xyz64_colorMatching_360to830nm_1nm.txt', '\t', 1);
            CMF = importedData.data(:,:);    

            save('colorimetricConstants.mat', 'CMF')
            cd(currentPath)            
            
        end
        
        % truncate the CMF
        cd(path.colorimetry)
        CMF = truncate_CMF(CMF, lambda, path.common);
            
    %% Do the actual calculations using other functions           
        
        %% Calculate CIE X, Y, Z from CMFs and the input spectrum with the x, y, z values
        %  http://en.wikipedia.org/wiki/XYZ_color_space (1931 Color Space)
            [colorim.X, colorim.Y, colorim.Z, colorim.x, colorim.y, colorim.z] = calc_XYZ(S, CMF);    

        %% Calculate u and v, 
        %  http://en.wikipedia.org/wiki/CIE_1960_color_space
            [colorim.u, colorim.v] = calc_uv(colorim.x, colorim.y);  

        %% CIEUVW   1964, (U*, V*, W*) color space (CIEUVW), 
        %  http://en.wikipedia.org/wiki/CIE_1964_color_space
            % to be implemented     

        %% CIELUV   1971, 
        %  http://en.wikipedia.org/wiki/CIELUV (1971        
            % to be implemented

        %% CIELAB   1976, 
        %  http://en.wikipedia.org/wiki/Lab_color_space
            % to be implemented

        %% CIECAM02 2002, 
        %  http://en.wikipedia.org/wiki/CIECAM02
            % to be implemented

        %% Calculate CCTs          

            % geometrical method
            % colorim.CCT_geom = calc_CCTgeom(colorim.u, colorim.v, isoTempLines);

            % analytical method
            colorim.CCT_geom = 3500; % if over 50'000 K, this won't work, so implement the geometricla method later
            colorim.CCT_anal = calc_CCTanal(colorim.x, colorim.y, colorim.CCT_geom);

            % The analytical implementation is not valid for
            % correlated color temperatures below 3'000 K so then the
            % "main variable" is defined according to this
            if colorim.CCT_anal < 3000                    
                colorim.CCT = 3000; % colorim.CCT_geom;
                    % Implement later the McCamy method to handle color
                    % temperatures below 3000 K
            else
                colorim.CCT = colorim.CCT_anal;
            end

        %% Calculate CRI    
            % [colorim.CRI, uki, vki] = calc_CRI(lambda, S, colorim.CCT, colorim.X, colorim.Y, colorim.Z, CMF, TCS, CIEDaySN);

        %% Calculate GA (Gamut Area)    
            % colorim.GA = calc_GA(uki, vki);   

        %% Calculate FSI and FSCI
            % [colorim.FSI, colorim.FSCI] = calc_FSI(lambda, S);    

        %% calculate FSCI    
            % colorim.FSCI = 100 - 5.1*colorim.FSI;
            
    cd(currentPath)
    
    

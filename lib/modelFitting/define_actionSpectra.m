function actSpectra = define_actionSpectra(lambda, peak, templates, path, callFrom)

    %% INPUTS
    
        % lambda    - wavelength vector

        % peaks     - cell structure with a cell directly fitting to nomogram
        %             creation function, e.g.
        %             S = nomog_Govardovskii2000(peak_nm, bands, linLog, quantaE, density, xRes, xLims, optFilter)
        %             {1}.nomogInputs = {482;'both';'lin';'Q';0.5;1;[lambda(1) lambda(end)];[]}
        %             {1}.header
        
        % templates - cell with the wanted templates as strings
        %             e.g. 'SWS', 'MWS', LWS', 'VL', 'VprimeL', 'BLH'
        
        % path      - structure containing paths
        
        % callFrom  - defining where this function is called for better use of
        %             different if-else-end structures
        
        if nargin == 4 % not necessary to include in the call
            callFrom = [];
        end


    %% DEFINE the OUTPUT
    
        currDir = pwd;
    
        % preallocate memory
        actSpectra = cell((length(peak) + length(templates)),1);
        
        %% CREATE the WANTED NOMOGRAMS
        if ~isempty(peak)
            cd(path.library_nomo)
            for i = 1 : length(peak)
                
                % redefine the inputs
                peak_nm   = peak{i}.nomogInputs{1};
                bands     = peak{i}.nomogInputs{2};
                linLog    = peak{i}.nomogInputs{3};
                quantaE   = peak{i}.nomogInputs{4}; 
                density   = peak{i}.nomogInputs{5};
                xRes      = peak{i}.nomogInputs{6};
                xLims     = peak{i}.nomogInputs{7};
                optFilter = peak{i}.nomogInputs{8};
                
                % create the spectrum
                actSpectra{i}.spectrum = nomog_Govardovskii2000(peak_nm, bands, linLog, quantaE, density, xRes, xLims, optFilter);
                
                % copy the header from input
                actSpectra{i}.header   = peak{i}.header;
                
            end
        end
        
        %% IMPORT the WANTED TEMPLATES
        if ~isempty(templates)            
            for j = i+1 : length(templates)+i
                
                % copy the header from the input
                actSpectra{j}.header   = templates{j-i};
                
                % match the string given as an input for the wanted action
                % sepctrumt template file, i.e. simple lookup table
                % function                
                cd(path.common)
                [actSpectra{j}.spectrum,~] = import_spectrumTemplate(templates{j-i}, lambda, path.templates, path.common);
                
                if strcmp(peak{1}.nomogInputs{3}, 'log')
                    actSpectra{j}.spectrum = log10(actSpectra{j}.spectrum);
                end
                
            end
        end
        
        actSpectra{1}.lambda = (xLims(1):xRes:xLims(2))';
        
        cd(currDir)
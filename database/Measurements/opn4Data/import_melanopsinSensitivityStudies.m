function [lucas2001,berson2002, hattar2003, gamlin2007, bailes2013_mouse, bailes2013_human] = import_melanopsinSensitivityStudies(path, lambda, lensY, lensO)


    %% Lucas (2001), mouse OPN4 sensitivity, 
    
        % http://dx.doi.org/10.1038/88443
        % extracted graphically from the paper by Petteri
        filename = 'lucas2001.csv';
        dataIn = importdata(fullfile(path,filename));

           % now the obtained spectral sensitivity corresponds to the
           % retinal sensitivity, so we add standard observer on top of
           % this to have short-wavelength attenuation to make this dataset
           % comparable to others
           lucas2001 = correctForLens(dataIn, lambda, lensY, lensO);

    %% Berson (2002), rat OPN4 sensitivity, 
    
        % http://dx.doi.org/10.1126/science.1067262
        % extracted graphically from the paper by Petteri
        filename = 'berson2002.csv';
        dataIn = importdata(fullfile(path,filename));

           % now the obtained spectral sensitivity corresponds to the
           % retinal sensitivity, so we add standard observer on top of
           % this to have short-wavelength attenuation to make this dataset
           % comparable to others
           berson2002 = correctForLens(dataIn, lambda, lensY, lensO);
   
     %% Hattar (2003), mouse OPN4 sensitivity, 
    
        % http://dx.doi.org/10.1038/nature01761
        % extracted graphically from the paper by Petteri
        filename = 'hattar2003.csv';
        dataIn = importdata(fullfile(path,filename));

           % now the obtained spectral sensitivity corresponds to the
           % retinal sensitivity, so we add standard observer on top of
           % this to have short-wavelength attenuation to make this dataset
           % comparable to others
           hattar2003 = correctForLens(dataIn, lambda, lensY, lensO);
           
    %% Gamlin (2007), macaque OPN4 sensitivity, 
    
        % http://dx.doi.org/10.1038/nature01761
        % extracted graphically from the paper by Petteri
        filename = 'gamlin2007.csv';
        dataIn = importdata(fullfile(path,filename));

           % now the obtained spectral sensitivity corresponds to the
           % retinal sensitivity, so we add standard observer on top of
           % this to have short-wavelength attenuation to make this dataset
           gamlin2007 = correctForLens(dataIn, lambda, lensY, lensO);
           
           
    %% Bailes and Lucas (2013), mouse OPN4 sensitivity, 
    
        % http://dx.doi.org/10.1098/rspb.2012.2987
        % extracted graphically from the paper by Petteri
        filename = 'bailes2013_mouse.csv';
        dataIn = importdata(fullfile(path,filename));

           % now the obtained spectral sensitivity corresponds to the
           % retinal sensitivity, so we add standard observer on top of
           % this to have short-wavelength attenuation to make this dataset
           % comparable to others
           bailes2013_mouse = correctForLens(dataIn, lambda, lensY, lensO);

    %% Bailes and Lucas (2013), human OPN4 sensitivity, 
    
        % http://dx.doi.org/10.1098/rspb.2012.2987
        % extracted graphically from the paper by Petteri
        filename = 'bailes2013_human.csv';
        dataIn = importdata(fullfile(path,filename));

           % now the obtained spectral sensitivity corresponds to the
           % retinal sensitivity, so we add standard observer on top of
           % this to have short-wavelength attenuation to make this dataset
           % comparable to others
           bailes2013_human = correctForLens(dataIn, lambda, lensY, lensO);

    
   % Subfunction to do some general conditioning and lens correction
   function dataOut = correctForLens(dataIn, lambda, lensY, lensO)
        
        % do input check, if SD column is missing
        if size(dataIn.data,2) < 3
           dataInTmp = zeros(length(dataIn.data),3);
           dataInTmp(:,1:2) = dataIn.data;
           dataIn.data = dataInTmp;
           dataIn.data(:,3) = NaN;
        end
        
        dataOut.retinal = dataIn.data;
        dataOut.headers = dataIn.textdata;
        
        % find the comparable wavelenghts from young lens template                
        for i = 1 : length(dataIn.data(:,1))
            indicesBailes(i) = find(dataIn.data(i,1) == lambda);
        end
        lensY_point = lensY(indicesBailes);
        lensO_point = lensO(indicesBailes);
        
        % Young LENS
        dataOut.lensY(:,1) = dataIn.data(:,1);
        dataOut.lensY(:,2) = dataIn.data(:,2) .* lensY_point;

            % normalize again
            dataOut.lensY(:,2) = dataOut.lensY(:,2) / max(dataOut.lensY(:,2));
            
        % Old LENS
        dataOut.lensO(:,1) = dataIn.data(:,1);
        dataOut.lensO(:,2) = dataIn.data(:,2) .* lensO_point;

            % normalize again
            dataOut.lensO(:,2) = dataOut.lensO(:,2) / max(dataOut.lensO(:,2));
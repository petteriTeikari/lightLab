function lensDensity = import_vanNorren1974_template(lambda)
    
    vanNorren1974_file = 'vanNorren1974_table2_ocularMediaDensity_standardObserver_orig+interp380-780-1nm.mat';
    template = load(vanNorren1974_file);
    lensDensity = template.data_interp(:,2);
    
    % do zero padding / interpolation 
    lensDensity = zeroPadding_forTemplates(lensDensity, lambda);
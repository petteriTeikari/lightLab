function lensD = import_stockmanSharpe2000_template(lambda)

    StockmanSharpe2000_file = 'stockmanSharpe2000_lensDensityTemplate_orig380-780nm_LOG.mat';
    template = load(StockmanSharpe2000_file);
    lensD = template.lensOD_stockmanSharpe(:,2);
    
    % do zero padding / interpolation 
    lensD = zeroPadding_forTemplates(lensD, lambda);
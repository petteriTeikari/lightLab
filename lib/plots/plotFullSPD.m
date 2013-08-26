function plotFullSPD(lambda, irrad, irrad_norm, colorim, photom, radiom, photorecep, options, analysisOptions)

    % init the figure
    h = plotFullSPD_init(lambda, irrad, irrad_norm, colorim, photom, radiom, photorecep, options, analysisOptions);
    
    % update the figure
    plotFullSPD_update(h, lambda, irrad, irrad_norm, colorim, photom, radiom, photorecep, options, analysisOptions)
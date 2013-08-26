function path = useDefaultMixedModelPaths(path)

    cd(path.Code); 
    cd ..; cd ..; 
    path.mainCode = pwd;

    path.library            = fullfile(path.mainCode, 'lib');
    path.library_nomo       = fullfile(path.library, 'nomogram');
    path.library_fit        = fullfile(path.library, 'modelFitting');
    path.plotFunc           = fullfile(path.library, 'plots');
    path.common             = fullfile(path.library, 'common');

    path.defForMeasurements = fullfile(path.mainCode, 'database', 'Measurements');
    path.melatoninData      = fullfile(path.defForMeasurements, 'melatonin data');        

    path.templates          = fullfile(path.mainCode, 'database', 'Templates'); 
    
    cd(path.Code);
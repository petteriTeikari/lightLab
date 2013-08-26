function path = setDefaultFolders(path)

    path.library      = fullfile(path.lightLab, 'lib');

    path.figuresOut = fullfile(path.lightLab, 'figuresOut');    
    
    path.nomogram     = fullfile(path.lightLab, 'lib', 'nomogram');
    path.lightSources = fullfile(path.lightLab, 'database', 'LightSources', 'artificial');
    path.bistability  = fullfile(path.lightLab, 'lib', 'bistability');            
    path.nomogram     = fullfile(path.lightLab, 'lib', 'nomogram');   
    path.colorimetry  = fullfile(path.lightLab, 'lib', 'colorimetry');   
    path.common       = fullfile(path.lightLab, 'lib', 'common');   
    path.templates    = fullfile(path.lightLab, 'database', 'Templates');
    path.ocularMedia  = fullfile(path.lightLab, 'lib', 'ocularmedia');
function MAIN_mixedModel(x,y,err,options)

    % CHECK INPUTS
    if nargin == 0 || nargin == 1
        disp('No experimental data is given so we use the defaults dataset used for testing')        
        load najjar2011_deCorr_melatonin.mat
        options = useDefaultOptionsForMixedModels(); % options for model fitting
        
    elseif nargin == 2
        disp('No errors provided for the y-data, so error is 0 for all the samples')
        err = zeros(length(y),1);
        options = useDefaultOptionsForMixedModels(); % options for model fitting
        
    elseif nargin == 3
        disp('No options provided for this function, default options used')
        options = useDefaultOptionsForMixedModels(); % options for model fitting
        
    else
        %
    end
        
%% SETTINGS

    % paths
    path.Code = mfilename('fullpath'); % Setting the path for the code    
    path.Code = strrep(path.Code,'MAIN_mixedModel',''); % Removing the filename from the path     
    path = useDefaultMixedModelPaths(path);    
    
    

%% SUBFUNCTION CALLS for different MIXED MODELS

    if strcmp(options.mixedModels.model, 'poolingModel') || strcmp(options.mixedModels.model, 'All')

        %% Photoreceptor Pooling model      
        % Used for example by:
        % * Quick (1974) “A vector-magnitude model of contrast detection.” Biological Cybernetics 16(2): 65-67. http://dx.doi.org/10.1007/BF00271628
        % * Kurtenbach et al. (1999) “Spectral sensitivities in dichromats and trichromats at mesopic retinal illuminances.” JOSA A 16(7): 1541-1548. http://dx.doi.org/10.1364/JOSAA.16.001541
        % * McDougal and Gamlin (2009) “The Influence of Intrinsically Photosensitive Retinal Ganglion Cells on the Spectral Sensitivity and Response Dynamics of the Human Pupillary Light Reflex.” Vis Res. http://dx.doi.org/10.1016/j.visres.2009.10.012
        options.poolingModel
        
        % get the parameters from the options given as input to
        % fix_mixedModelsForMelatonin() from MAIN_mixedModel() 
            mode    = options.poolingModel.mode;
            comb_k  = options.poolingModel.comb_k;
            contr   = options.poolingModel.contr;
            p       = options.poolingModel.p;
            densit  = options.poolingModel.densit;
            fMe     = options.poolingModel.fMe;
            oppon   = options.poolingModel.oppon;
            bound   = options.poolingModel.bound;
            costF   = options.poolingModel.costF;
            options = options.poolingModel;
            
            mode = 'simple';
            %mode = 'simpleBi';

        % call the sunfunction
        [poolingModel.spec, poolingModel.points, poolingModel.stats] = ...
            poolingModel_main(x,y,err,mode,comb_k,contr,p,densit,fMe,oppon,bound,costF,options,path);

    elseif 1 == 2
        % some other model here
        
    else
        errordlg('Incorrect mixed model!')
        
    end








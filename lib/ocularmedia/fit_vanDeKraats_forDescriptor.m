function [template, virtualAge, virtualAge_SD] = fit_vanDeKraats_forDescriptor(average, stdev, lambda, neutrOffset, SPD1, SPD2, compPath, age, scaleFactorStd)

    currDir = pwd;
    
    % correct the input average with the scale factor    
    average = average + scaleFactorStd;
    
    % define the function for the fitting procedure
    fitFunc = @(ageOptim) minimScaleFactor(ageOptim, average, stdev, lambda, SPD1, SPD2, neutrOffset, currDir, compPath);
    
    % define the input age as the initial guess
    A0 = age;
    
    % define optimization parameters
    optimOpt = optimset('fmincon');
    optimOpt = optimset(optimOpt, 'Algorithm', 'interior-point', 'Display', 'notify');    
    
    % constrain the age
    lb = -20; % lowest possible age
    ub = 120; % highes possible age
    
    % empty variables for fmincon
    A = []; b = []; Aeq = []; beq = []; nonlcon = [];

    % use the function X from "Optimization Toolbox"
    ageOptim_mean  = fmincon(fitFunc, A0, A, b, Aeq, beq, lb, ub, nonlcon, optimOpt);
    
        %% MAYBE NOT THE OPTIMAL WAY TO DO THE STATS, CHECK THIS!
        % computational overhead for fitting three times 
    
        % upper estimate for the virtual age
        fitFunc = @(ageOptim) minimScaleFactor(ageOptim, average+stdev, stdev, lambda, SPD1, SPD2, neutrOffset, currDir, compPath);
        ageOptim_upper = fmincon(fitFunc, A0, A, b, Aeq, beq, lb, ub, nonlcon, optimOpt);

        % lower estimate for the virtual age
        fitFunc = @(ageOptim) minimScaleFactor(ageOptim, average-stdev, stdev, lambda, SPD1, SPD2, neutrOffset, currDir, compPath);
        ageOptim_lower = fmincon(fitFunc, A0, A, b, Aeq, beq, lb, ub, nonlcon, optimOpt);        
        
    
    % Finally create the lens density template with the found "virtual age"
    % matching the model
    cd(currDir)
    lensMedia = lensModel_vanDeKraats2007(ageOptim_mean, lambda, neutrOffset);
    
    %% Assign output
    template = lensMedia.totalMedia; % sum of all components
    virtualAge = ageOptim_mean;    
    virtualAge_SD = [abs(ageOptim_mean-ageOptim_lower) abs(ageOptim_mean-ageOptim_upper)];
    
    % debug
    debug = 0;
    if debug == 1
        disp('fit for lens density')
        disp([age virtualAge average])       
    end

    
    function costFunction = minimScaleFactor(ageOptim, average, stdev, lambda, SPD1, SPD2, neutrOffset, currDir, compPath)
        
        % create template
        lensMedia = lensModel_vanDeKraats2007(ageOptim, lambda, neutrOffset);
        template = lensMedia.totalMedia; % sum of all components
        
        % calculate the scale factor of the created template
        cd(compPath)
        scaleFactor = calculate_scaleFactor(template, SPD1, SPD2);
        cd(currDir)
        
        % cost function is now the difference between scale factor and the
        % average (think of how to add the stdev later to give a better 
        % estimate of the uncertainty in our estimate?)
        costFunction = abs(average - scaleFactor);
    
        debug = 0;
        if debug == 1
            disp([ageOptim average scaleFactor costFunction])
        end
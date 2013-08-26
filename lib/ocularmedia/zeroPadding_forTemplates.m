function templatePadded = zeroPadding_forTemplates(template, lambda, templateLim)

    if min(lambda) == 380 && max(lambda) == 780
        templatePadded = template;
        return
    end

    %_ hard-coded for most of the templates
    if nargin == 2
        templateLim = [380 780];
    end

    % create first 1nm resolution wavelength vector to match the
    % lambda-limits
    lambdaLimits       = [min(lambda) max(lambda)];
    lambdaExtended_1nm = (lambdaLimits(1) : 1 : lambdaLimits(2))';
    
    % if desired lambda is larger from both sides
    if lambdaLimits(1) < templateLim(1) && lambdaLimits(2) >= templateLim(2)
        ind1 = find(lambdaExtended_1nm == templateLim(1));
        ind2 = find(lambdaExtended_1nm == templateLim(2));
        
        % no copy the input template to the extended template
        templatePadded_1nm = zeros(length(lambdaExtended_1nm),1);
        templatePadded_1nm(ind1:ind2) = template;
        
    % desired lambda is larger than template (long lambda) but smaller than
    % template (short lamda)
    elseif lambdaLimits(1) > templateLim(1) && lambdaLimits(2) >= templateLim(1)
        ind1 = lambdaLimits(1) - templateLim(1) + 1;
        ind2 = find(lambdaExtended_1nm == templateLim(2)) + ind1 - 1;
        
        % no copy the input template to the extended template        
        templatePadded_1nm = template(ind1:ind2);
        
    % desired lambda is shorter than template (long lambda) and also 
    % smaller than template (short lamda)
    elseif lambdaLimits(1) > templateLim(1) && lambdaLimits(2) <= templateLim(1)
        warndlg('No Implementation yet, crash happens most likely next :p')
        
    % desired lambda is shorter than template (long lambda) but longer from 
    % the short side
    elseif lambdaLimits(1) < templateLim(1) && lambdaLimits(2) <= templateLim(2)
        warndlg('No Implementation yet, crash happens most likely next :p')
        
    else
        errordlg('Condition?')
    end    
    
    
    if length(templatePadded_1nm) < length(lambda)
        templatePadded = interp1(lambdaExtended_1nm, templatePadded_1nm, lambda, 'pchip');
    else
        templatePadded = templatePadded_1nm;
    end
    
    % DEBUG  
    %{
    whos   
    figure
    subplot(1,3,1)
    plot(template)
    subplot(1,3,2)
    plot(lambdaExtended_1nm, templatePadded_1nm)
    subplot(1,3,3)
    plot(lambda, templatePadded)
    %}
  
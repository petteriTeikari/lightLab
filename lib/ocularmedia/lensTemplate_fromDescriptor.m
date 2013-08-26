%% DOCUMENTATION
% All the lines starting with %DOC% in similar sense as Java's javadoc

    %DOC%<desc><desc/>

    %DOC%<h2>Description</h2>
    %DOC%cmdLine_sessionAnalysis() runs the session-by session analysis of lens density analysis input files

%% CODE
function [templates, virtualAges] = lensTemplate_fromDescriptor(ages, descr, descrStr, model, lambda, offset, field, SPD1, SPD2, handles)    
    
    if strcmp('meanBoth', field)        
        average = descr.(field).mean;
        stdev   = descr.(field).SD;
        %disp('Debug from lensTemplate_fromDescriptor.m')
        %disp([ages average stdev])
    elseif field == 2
       % if you want to add a selector of which field to use
    end

    A = 25; % always 25 on this script as the standard observer
   
    
    % subtract offset from the mean vector and SD is the same 
    average = average - handles.calibOffset;

        
    %% THIS PART OF THE SCRIPT IS RATHER SPECULATIVE so please be especially 
    %% critical here if this could have been done better also ! (Petteri)
    
    if strcmp(model, 'van de Kraats and van Norren 2007') == 1
    
        % We are fitting the lens template to the measured data. In other
        % words the following function tries to find the age of the model
        % that matches for the obtained lens density descriptor.
        
        % More strictly speaking we are investigating the scale factor for
        % the two light sources and what kind of template is needed to
        % produce this "experimental scale factor" which is the standard
        % observer (25 years) "standard scale factor" plus the measured
        % experimental indexNew.
        
        % preallocate memory
        templates   = zeros(length(lambda), length(average));
        virtualAges = zeros(1, length(average));
        
        disp('  fitting lens density templates for experimental data')
        scaleFactor = handles.scaleFactor;
        compPath    = handles.path.computationFolder;
        
        parfor i = 1 : length(average)            
            fprintf([num2str(i), ' ']); % status print
            [templates(:,i), virtualAgesMean(i), virtualAgesSD(i,:)] = fit_vanDeKraats_forDescriptor(average(i), stdev(i), lambda, offset, ...
                                                    SPD1, SPD2, compPath, ages(i), scaleFactor);            
        end            
        fprintf('\n'); % line change
                      
            % Total Lens media from van de Kraats and van Norren 2007 is
            % defined as following

                %{
                lensMedia.totalMedia = lensMedia.rayleighScatter... % RAYLEIGH SCATTER
                                        + lensMedia.TP...           % TRYPTOPHAN ABSORPTION
                                        + lensMedia.LY...           % LENS YOUNG COMPONENT
                                        + lensMedia.LOUV...         % LENS OLD UV COMPONENT
                                        + lensMedia.LO...           % LENS OLD COMPONENT
                                        + offset;                   % "NEUTRAL DENSITY" filter
                %}
        
        % not used at the moment for nothing but could be used so this is
        % here for pedagogic purposes mainly
        if strcmp(descrStr, 'IndexNew') == 1 
        elseif strcmp(descrStr, 'Index') == 1
        elseif strcmp(descrStr, 'X') == 1
        else
            % errordlg('what is this descriptor for template generation?')
        end
        
    end
    
    % wrap to output
    virtualAges.mean = virtualAgesMean;
    virtualAges.SD   = virtualAgesSD;
    
function plotFullSPD_update(h, lambda, irrad, irrad_norm, colorim, photom, radiom, photorecep, options, analysisOptions)

    %% first define the data to be updated
    
        % "text boxes": subplot 2 -4
        fields = plotFullSPD_defineData(h, colorim, photom, radiom, photorecep, options, analysisOptions);
        
    % quick fix 
        irrad_non_neg = irrad;
        irrad_non_neg(irrad < 0) = 0;

        irrad_Norm_non_neg = irrad_norm;
        irrad_Norm_non_neg(irrad < 0) = 0;
        
    %% update subplot 1
    set(h.ar(1), 'XData', lambda, 'YData', irrad_non_neg)
    
    %% update subplot 2
    set(h.ar(2), 'XData', lambda, 'YData', irrad_Norm_non_neg/max(irrad_Norm_non_neg))
    
    %% update subplot 3
    for i = 1 : h.noOfColorimValues
        set(h.colorim_textFields(i), 'String', fields.colorim_text{i});
        set(h.colorim_numFields(i), 'String', fields.colorim_numerStr{i});
        set(h.colorim_unitFields(i), 'String', fields.colorim_units{i});        
    end    
    
    %% update subplot 4
    for i = 1 : h.noOfPhoRadValues        
        set(h.phoRad_textFields(i), 'String', fields.phoRad_text{i});
        set(h.phoRad_numFields(i), 'String', fields.phoRad_numerStr{i});
        set(h.phoRad_unitFields(i), 'String', fields.phoRad_units{i});
    end    
    
    %% update subplot 5
    for i = 1 : h.noOfPhotorecepValues        
        set(h.photorecep_textFields(i), 'String', fields.photorecep_text{i});
        set(h.photorecep_numFields(i), 'String', fields.photorecep_numerStr{i});
        set(h.photorecep_unitFields(i), 'String', fields.photorecep_units{i});
    end        
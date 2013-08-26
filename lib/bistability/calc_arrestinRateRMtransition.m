%% DOCUMENTATION
% All the lines starting with %DOC% in similar sense as Java's javadoc

    %DOC%<desc><desc/>

    %DOC%<h2>Description</h2>
    %DOC%cmdLine_sessionAnalysis() runs the session-by session analysis of lens density analysis input files

%% CODE
function k = calc_arrestinRateRMtransition(alpha_rel, alpha_multip, sigma, I, nm_spacing)

    % subfunction to calculate the rate constant, Equation (1), Stavenga and Hardie (2010)

    % INPUTS
    % alpha - absorbance spectrum (e.g. R-melanopsin)
    % sigma - quantum efficiency
            % beta     - photosensitivity vector (alpha * sigma)                
    % I     - photon flux vector (photon density) [photons * cm⁻² * s⁻¹ * nm⁻¹]
    %         
    % OUTPUTS
    % k     - rate constant for visual pigment    

    % we need to scale the relative absorbance spectrum to some
    % absolute values

        % the multiplier was estimated from the study of Mure et al.
        % (2009) based on the used photon density of 10¹² and the
        alpha_abs = alpha_rel * alpha_multip; % [cm²]

    % photosensitivity (vector * scalar)
    beta = alpha_abs .* sigma; 

    % rate constant (trapz integration)
    k = nm_spacing * trapz(beta .* I); % [1/s]


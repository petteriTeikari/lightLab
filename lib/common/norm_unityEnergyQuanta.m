function irrad = norm_unityEnergyQuanta(irrad)

    integral = trapz(irrad);
    irrad = irrad / integral;
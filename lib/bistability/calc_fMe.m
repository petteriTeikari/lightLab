function fMe = calc_fMe(kR, kM)

    ONE = ones(length(kR),1);
    fMe = ONE ./ (ONE + (kM / kR));
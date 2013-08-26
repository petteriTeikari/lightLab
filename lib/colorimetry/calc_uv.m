function [u, v] = calc_uv(x, y)

    u = 4*x / ( (-2*x) + (12*y) + 3 );
    v = 6*y / ( (-2*x) + (12*y) + 3 );
    
    
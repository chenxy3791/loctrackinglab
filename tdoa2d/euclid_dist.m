function dist = euclid_dist(pos1, pos2)
    
    dist = sqrt( sum( (pos1 - pos2).*(pos1 - pos2) ) );
    
end
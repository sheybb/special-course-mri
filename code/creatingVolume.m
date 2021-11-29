function data_Volume = creatingVolume(data, range,data_type)
    
    j = 1;
    if strcmp(data_type, 'phase')
        k = range(1)+1:2:range(2);
    elseif strcmp(data_type, 'magnitude')
        k = range(1):2:range(2);
    end
    for i = k
        data_Volume(:,:,j) = data{1,i};
        j = j + 1;
    end
    

end
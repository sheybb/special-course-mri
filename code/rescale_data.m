function data_rs = rescale_data(data,info,idx)
    
    if isfield(info, 'RescaleIntercept')
        RI = info.RescaleIntercept;
    else
        RI = 1;
    end

    if isfield(info, 'RescaleSlope')
        RS = info.RescaleSlope;
    else
        RS = 1;
    end
  
    if isfield(info, 'ScaleSlope')
        SS = info.ScaleSlope;
    else
        SS = 1;
    end

    if (isfield(info, 'RescaleIntercept') && isfield(info, 'RescaleSlope')) == 0
        warning(strcat('No scaling is needed in ', idx));
    end
    data_rs = data*SS + RI/(RS+SS);
end
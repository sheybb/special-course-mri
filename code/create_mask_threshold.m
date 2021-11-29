function V_mask = create_mask_threshold (magnitude_V,data)
%CREATE_MASK_THRESHOLD uses an adaptative threshold and morphological
%operations to create a mask that adjust better the data.

    V = magnitude_V;
    V_mask = zeros(size(V));

    for i = 1:size(V,3)
        if strcmp(data, 'balloon')
            slice = V(:,:,size(V,3));
        else
            slice = V(:,:,i);
        end
        maximum = max(max(slice));
        threshold = 0.05;
        mask_init = (slice > maximum*threshold);
        
        if strcmp(data, 'balloon')
            marker = false(size(mask_init)); 
            marker(92,127) = true;
            marker(158,116) = true;
            mask = imreconstruct(marker, mask_init);
            se = strel('diamond',100);
            mask_close = imdilate(mask_init,se);
            mask = imfill(mask,'holes');
        else
            marker = false(size(mask_init)); 
            marker(290,100) = true;
            marker(263,268) = true;
            mask = imreconstruct(marker, mask_init);
            mask = imfill(mask,'holes');
            se = strel('disk',10);
            mask = imdilate(mask,se);
        end
        V_mask(:,:,i) = mask;
    end

end
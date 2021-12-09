function phases_cell_no_background = applying_mask_remove_background(v_cell,mask_th)

for i = 1:length(v_cell)
    apply_mask = @(vol)(mask_th .* double(vol));
    phases_cell_no_background = cellfun(apply_mask, v_cell, 'UniformOutput',false);
end
figure, sliceViewer(phases_cell_no_background{2});
end
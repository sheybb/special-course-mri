function phase_difference_between_image_n_and_image_1 = correcting_phases(data,minVal,maxVal)


aux = (double(data) - (minVal))/ (maxVal-(minVal));
data1_balloon_ph_scaled = (aux - 0.5) * 2*pi;
phase_difference_between_image_n_and_image_1 = ...
    angle(exp(1i*data1_balloon_ph_scaled) ./ exp(1i*data1_balloon_ph_scaled(:,:,1)));
figure, sliceViewer(phase_difference_between_image_n_and_image_1,'DisplayRange',[]);

end
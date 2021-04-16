path_to_data = '/media/will/data/Dropbox/Hackathon/data/stensola/recordings/';
sessions = dir(strcat(path_to_data,'*.h5'));

% Bin sizes and smoothing kernel 
bin_size = 0.03;
kern_size = 5;
kern = ones(kern_size);


% Initialise empty arrays for grids properties
orientations = [];
gridness = [];
scale = [];
biases = [];
gridness_threshold = 0.3;


for sess_i = 1:length(sessions)
    sess = sessions(sess_i).name(1:end-3);
    [posx,posy,post, unitList, unitData] = readNwb_wdc(sessions(sess_i).name);
    sampleTime = mean(diff(post));
    dist_from_centre = sqrt(posx.^2 + posy.^2);
    bias = sum(wrapTo180(diff(atan2d(posy,posx))));
%     bias = sum(dist_from_centre(2:end) .* wrapTo180(diff(atan2d(posy,posx))));
    
    xmin = floor(min(posx)); xmax = ceil(max(posx)); ymin = floor(min(posy)); ymax = ceil(max(posy));
    
    edges{1} = xmin:bin_size:xmax;
    edges{2} = ymin:bin_size:ymax;
    
    occ =hist3([posx,posy],edges);
    smth_occ = imfilter(occ, kern, 'same', 'conv');
    
    for cell_i = 1:length(unitData)
        spkPos = ceil((unitData{cell_i})/sampleTime);
        spk_map =hist3([posx(spkPos),posy(spkPos)],edges);
        smth_spk_map = imfilter(spk_map, kern, 'same', 'conv');
        ratemap = smth_spk_map./(smth_occ*sampleTime);
        sac = xPearson(ratemap);
        sacStats = sacProps(sac);
        orientations = [orientations; sacStats.peakOrient'];
        gridness = [gridness; sacStats.gridness];
        scale = [scale; sacStats.scale];
        biases = [biases; bias];
    end
    
end

% Calculate shearing wrt the walls of the environment
all_shears = [orientations, orientations - 90, orientations - 180];
[~, min_idx] = min(abs(all_shears), [], 2);

% Extract the grid orientation closest to the walls 
shears = all_shears(sub2ind(size(all_shears), 1:length(min_idx), min_idx'))';

% Apply gridness threshold to only consider grid cells
thresholded_orientations = reshape(orientations(gridness > gridness_threshold,:),1,[]);
thresholded_shears =  shears(gridness > gridness_threshold);
thresholded_biases = biases(gridness > gridness_threshold);

% Plot grid orientations
[num,edge_points] = histcounts(thresholded_orientations,0:3:180);
figure
polarplot(deg2rad(1.5:3:360), repmat(num,1,2),'linewidth',2)

% Plot grid shearing
figure
histogram(thresholded_shears,-30:1:30)
xlabel('shears / degrees')

% Plot behavrioual biases vs grid shears
figure
scatter(thresholded_biases, thresholded_shears,'k')
ylabel('shearing / degrees')
xlabel('rotational bias')
title(sprintf('r = %.3f', corr(thresholded_biases,thresholded_shears)))

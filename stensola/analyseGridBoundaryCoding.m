path_to_data = '/media/will/data/Dropbox/Hackathon/data/stensola/recordings/';
addpath('recordings')
sessions = dir(strcat(path_to_data,'*.h5'));

bin_size = 0.03;
kern_size = 5;
kern = ones(kern_size);


% Initialise empty arrays for grids properties
orientations = [];
gridness = [];
scale = [];

inner = [];
outer = [];


for sess_i = 1:length(sessions)
    sess = sessions(sess_i).name(1:end-3);
    [posx,posy,post, unitList, unitData] = readNwb_wdc(sessions(sess_i).name);
    sampleTime = mean(diff(post));
    
    xmin = min(posx); xmax = max(posx); ymin = min(posy); ymax = max(posy);
    
    xdim = xmax - xmin; ydim = ymax - ymin;
    % Could set an equal area mask
%     inner_dim = ceil(sqrt((xdim*ydim)/2)/bin_size);

    % or an equal width mask
    inner_dim = ceil(mean([xdim/2,ydim/2])/bin_size);

    edges{1} = xmin:bin_size:xmax;
    edges{2} = ymin:bin_size:ymax;
    
    occ =hist3([posx,posy],edges);
    smth_occ = imfilter(occ, kern, 'same', 'conv');
    
    inner_mask = zeros(size(smth_occ));
    [tmpy, tmpx] = size(inner_mask);
    tmpx = ceil((tmpx - inner_dim)/2);
    tmpy = ceil((tmpy - inner_dim)/2);
    inner_mask(tmpy:(tmpy+inner_dim),tmpx:(tmpx+inner_dim)) = 1;
    
    clear tmp*
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
        
        inner = [inner, nanmean(ratemap(inner_mask==1))];
        outer = [outer, nanmean(ratemap(inner_mask==0))];

    end
    
end

% add some selection criteria here if desired i.e. gridness scores
crit = gridness > 0.3;
crit_inner = inner;%(crit);
crit_outer = outer;%(crit);

figure
hold on
bar([1,2],[nanmean(crit_inner),nanmean(crit_outer)],'FaceColor','w', 'linewidth',1.5)
errorbar([1,2],[nanmean(crit_inner),nanmean(crit_outer)], [std(crit_inner),std(crit_outer)]./sqrt(length(crit_inner)), '.k', 'linewidth',1.5)
xticks([1,2])
xticklabels({'inner', 'outer'})
ylabel('avg firing rate')
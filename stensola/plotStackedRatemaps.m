path_to_data = '/media/will/data/Dropbox/Hackathon/data/stensola/recordings/';
sessions = dir(strcat(path_to_data,'*.h5'));

bin_size = 0.03;
kern_size = 5;
kern = ones(kern_size);


for sess_i = 1:length(sessions)
    sess = sessions(sess_i).name(1:end-3);
    [posx,posy,post, unitList, unitData] = readNwb_wdc(sessions(sess_i).name);
    sampleTime = mean(diff(post));
    
    %     if (length(unitData) > 2)
    xmin = min(posx); xmax = max(posx); ymin = min(posy); ymax = max(posy);
    
    edges{1} = xmin:bin_size:xmax;
    edges{2} = ymin:bin_size:ymax;
    
    
    occ =hist3([posx,posy],edges);
    smth_occ = imfilter(occ, kern, 'same', 'conv');
    stacked_map = zeros(numel(edges{1}),numel(edges{2}));
    
    for cell_i = 1:length(unitData)
        spkPos = ceil((unitData{cell_i})/sampleTime);
        spk_map =hist3([posx(spkPos),posy(spkPos)],edges);
        smth_spk_map = imfilter(spk_map, kern, 'same', 'conv');
        ratemap = smth_spk_map./(smth_occ*sampleTime);
        stacked_map = stacked_map + ratemap;
        %         figure
        %         imagesc(ratemap)
        %         colormap jet
    end
    h = figure;
    imagesc(stacked_map)
    colorbar
    colormap jet
    daspect([1 1 1])
    axis off
    title(sprintf('%i Cells',length(unitData)))
    saveas(h,sprintf('/media/will/data/Dropbox/Hackathon/data/stensola/stacked_maps/%s.png',sess))
    close(h)
    %     end
end

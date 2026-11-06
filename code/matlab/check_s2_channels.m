function check_s2_channels()
% 看 S2 在多个后部通道上的 ERP，判断是 O1 单个电极的问题还是整体响应弱
addpath('D:\eeglab\eeglab2024.2');
eeglab('nogui');
outDir = 'D:\脑与认知科学\_dsh_work\out';
conds = {'S 31','S 32','S 33','S 34'};

for k = 1:2
    name = sprintf('S%d', k);
    EEG = pop_loadset('filename', [name '_clean.set'], 'filepath', outDir);
    sel = cell(1, numel(conds));
    for c = 1:numel(conds)
        m = false(1, numel(EEG.epoch));
        for e = 1:numel(EEG.epoch)
            et = EEG.epoch(e).eventtype;
            if ischar(et), et = {et}; end
            m(e) = any(strcmp(et, conds{c}));
        end
        sel{c} = m;
    end
    chans = {'O1','Oz','O2','POz','Pz','Cz','PO7','PO8'};
    fprintf('\n==== %s ====  每条件 ERP 峰值 (µV @ ms)\n', name);
    fprintf('%-5s', 'ch');
    for c = 1:4, fprintf(' %14s', conds{c}); end
    fprintf('\n');
    for ch = 1:numel(chans)
        ci = find(strcmp({EEG.chanlocs.labels}, chans{ch}));
        if isempty(ci), continue; end
        fprintf('%-5s', chans{ch});
        for c = 1:4
            x = mean(EEG.data(ci, :, sel{c}), 3);
            [pk, ip] = max(x); [tr, it] = min(x);
            fprintf('  %5.1f/%4.0f %4.1f/%3.0f', pk, EEG.times(ip), tr, EEG.times(it));
        end
        fprintf('\n');
    end
end
end

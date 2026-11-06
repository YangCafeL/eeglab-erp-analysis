function inspect_data()
% Inspect S1/S2: geometry, events, channel labels, epoching.
addpath('D:\eeglab\eeglab2024.2');
eeglab('nogui');

dataDir = 'D:\脑与认知科学\第三次实验课\data';
for k = 1:2
    name = sprintf('S%d', k);
    fprintf('\n================ %s ================\n', name);
    EEG = pop_loadset('filename', [name '.set'], 'filepath', dataDir);
    fprintf('setname : %s\n', EEG.setname);
    fprintf('srate   : %d Hz\n', EEG.srate);
    fprintf('nbchan  : %d\n', EEG.nbchan);
    fprintf('trials  : %d\n', EEG.trials);
    fprintf('pnts    : %d\n', EEG.pnts);
    fprintf('xmin/xmax: %g / %g\n', EEG.xmin, EEG.xmax);
    fprintf('ref     : %s\n', EEG.ref);
    fprintf('epochs  : %d\n', numel(EEG.epoch));
    fprintf('chanlocs(%d): %s\n', numel(EEG.chanlocs), strjoin({EEG.chanlocs.labels}, ' '));
    fprintf('X set   : %d\n', ~isempty(EEG.chanlocs(1).X));
    fprintf('event fields: %s\n', strjoin(fieldnames(EEG.event)', ' '));
    types = {EEG.event.type};
    [u,~,j] = unique(types);
    fprintf('nevents : %d, %d unique types\n', numel(EEG.event), numel(u));
    for i = 1:numel(u)
        fprintf('  type "%s" count %d\n', u{i}, sum(j==i));
    end
    fprintf('first 5 events: ');
    for i = 1:min(5, numel(EEG.event))
        fprintf('[%s@%.0f] ', EEG.event(i).type, EEG.event(i).latency);
    end
    fprintf('\n');
end
end

function pipeline_final()
%PIPELINE_FINAL  EEGLAB preprocessing + ICA + ERP extraction for both subjects.
%
%   Reproduces the third lab session (EEG time-domain analysis):
%     1. load raw dataset                     (32 ch, 500 Hz, already epoched)
%     2. channel locations                    (BESA standard-10-5-cap385)
%     3. band-pass 1-30 Hz                    (FIR, zero phase)
%     4. extract epochs, 4 stimulus conditions, -0.2 ~ 0.8 s
%     5. remove epoch baseline                (-200 ~ 0 ms)
%     6. bad-channel rejection                (|x| > 800 uV after baseline)
%     7. average reference
%     8. artifact epoch rejection             (any channel |x| > 100 uV)
%     9. ICA (runica) + ICLabel
%    10. remove artifact components           (Eye/Muscle/Heart/LineNoise/ChanNoise > 0.5)
%    11. ERP of channel O1 for every condition
%
%   Run:  pipeline_final

P = project_paths();
addpath(P.eeglab);
eeglab('nogui');

conds  = {'S 31', 'S 32', 'S 33', 'S 34'};
labels = {'31', '32', '33', '34'};
elp    = fullfile(P.eeglab, 'plugins', 'dipfit2.3', 'standard_BESA', 'standard-10-5-cap385.elp');

RESULTS = struct();

for k = 1:2
    name = sprintf('S%d', k);
    t0 = tic;
    fprintf('\n################ subject %s ################\n', name);

    % ---- 1. load ----
    EEG = pop_loadset('filename', [name '.set'], 'filepath', P.dataRaw);
    fprintf('[%6.1fs] loaded: %d ch, %d epochs\n', toc(t0), EEG.nbchan, EEG.trials);

    % ---- 2. channel locations ----
    EEG = pop_chanedit(EEG, 'lookup', elp);
    fprintf('[%6.1fs] channel locations\n', toc(t0));

    % ---- 3. band-pass 1-30 Hz ----
    EEG = pop_eegfiltnew(EEG, 1, 30);
    fprintf('[%6.1fs] 1-30 Hz\n', toc(t0));

    % ---- 4. epoch + 5. baseline ----
    EEG = pop_epoch(EEG, conds, [-0.2 0.8]);
    EEG = pop_rmbase(EEG, [-200 0]);
    fprintf('[%6.1fs] epochs: %d\n', toc(t0), EEG.trials);

    % ---- 6. bad channels (|x| > 800 uV, evaluated on baseline-corrected data) ----
    mx  = squeeze(max(max(abs(EEG.data), [], 2), [], 3));
    bad = find(mx > 800);
    if numel(bad) > 0.25 * EEG.nbchan
        error('bad-channel criterion flagged %d/%d channels, check threshold', numel(bad), EEG.nbchan);
    end
    if ~isempty(bad)
        fprintf('  bad channel(s): %s (peak %s uV)\n', ...
            strjoin({EEG.chanlocs(bad).labels}, ', '), mat2str(round(mx(bad)')));
        EEG = pop_select(EEG, 'nochannel', bad);
    else
        fprintf('  no bad channel\n');
    end

    % ---- 7. average reference ----
    EEG = pop_reref(EEG, []);
    fprintf('[%6.1fs] average reference (%d ch)\n', toc(t0), EEG.nbchan);

    if ~any(strcmp({EEG.chanlocs.labels}, 'O1'))
        error('O1 was flagged as a bad channel - abort');
    end

    % ---- 8. artifact epoch rejection ----
    keep = true(1, EEG.trials);
    for e = 1:EEG.trials
        seg = EEG.data(:, :, e);
        keep(e) = all(abs(seg(:)) < 100);
    end
    fprintf('  rejected %d / %d epochs (kept %.0f%%)\n', sum(~keep), numel(keep), 100*mean(keep));
    EEG = pop_select(EEG, 'trial', find(keep));
    fprintf('[%6.1fs] %d epochs left\n', toc(t0), EEG.trials);

    % ---- 9. ICA + ICLabel ----
    fprintf('[       ] running ICA ...\n');
    EEG = pop_runica(EEG, 'icatype', 'runica', 'extended', 0);
    fprintf('[%6.1fs] ICA done: %d components\n', toc(t0), size(EEG.icaweights, 1));

    EEG = iclabel(EEG);
    cnames = EEG.etc.ic_classification.ICLabel.classes;
    cls    = EEG.etc.ic_classification.ICLabel.classifications;
    artIdx = find(ismember(cnames, {'Eye', 'Muscle', 'Heart', 'Line Noise', 'Channel Noise'}));
    [maxArt, ~] = max(cls(:, artIdx), [], 2);
    comps = find(maxArt > 0.5);
    fprintf('  removing %d component(s): %s\n', numel(comps), mat2str(comps(:)'));
    for c = comps(:)'
        [~, bi] = max(cls(c, :));
        fprintf('     IC%02d %s %.2f\n', c, cnames{bi}, cls(c, bi));
    end

    EEG.setname = [name '_ica'];
    EEG = pop_saveset(EEG, 'filename', [name '_ica.set'], 'filepath', P.dataProc);
    plot_comps(EEG, fullfile(P.figures, [name '_ICLabel.png']), cnames);

    % ---- 10. remove components ----
    EEG = pop_subcomp(EEG, comps, 0);
    EEG.setname = [name '_clean'];
    EEG = pop_saveset(EEG, 'filename', [name '_clean.set'], 'filepath', P.dataProc);
    fprintf('[%6.1fs] saved %s_clean.set\n', toc(t0), name);

    % ---- 11. ERP per condition ----
    O1  = find(strcmp({EEG.chanlocs.labels}, 'O1'));
    erp = zeros(numel(conds), EEG.pnts);
    cnt = zeros(1, numel(conds));
    for c = 1:numel(conds)
        sel = false(1, numel(EEG.epoch));
        for e = 1:numel(EEG.epoch)
            et = EEG.epoch(e).eventtype;
            if ischar(et), et = {et}; end
            sel(e) = any(strcmp(et, conds{c}));
        end
        cnt(c) = sum(sel);
        erp(c, :) = mean(EEG.data(O1, :, sel), 3);
    end
    fprintf('  trials per condition: %s\n', mat2str(cnt));

    RESULTS.(name).erp    = erp;
    RESULTS.(name).counts = cnt;
    RESULTS.(name).times  = EEG.times;
    RESULTS.(name).labels = labels;
    RESULTS.(name).comps  = comps;
end

save(fullfile(P.results, 'ERP_results.mat'), 'RESULTS');
fprintf('\nall done\n');
end

function plot_comps(EEG, outFile, cnames)
% Scalp map of every IC plus its ICLabel verdict.
cls = EEG.etc.ic_classification.ICLabel.classifications;
n   = size(EEG.icawinv, 2);
ncol = 6; nrow = ceil(n / ncol);
fig = figure('Visible', 'off', 'Position', [0 0 2000 260*nrow], 'Color', 'w');
for c = 1:n
    subplot(nrow, ncol, c);
    topoplot(EEG.icawinv(:, c), EEG.chanlocs, ...
        'numcontour', 4, 'electrodes', 'on', 'emarker', {'.', 'k', 6, 1}, ...
        'style', 'both', 'maplimits', 'absmax');
    [~, bi] = max(cls(c, :));
    title(sprintf('IC%d  %s %.0f%%', c, cnames{bi}, 100*cls(c, bi)), 'FontSize', 9);
end
print(fig, outFile, '-dpng', '-r110');
close(fig);
fprintf('  component figure: %s\n', outFile);
end

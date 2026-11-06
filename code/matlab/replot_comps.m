function replot_comps()
%REPLOT_COMPS  Re-draw the IC scalp maps of both subjects from the saved
%    *_ica.set datasets (component maps + ICLabel verdicts go to figures/).
%
%   Run:  replot_comps   (after pipeline_final)

P = project_paths();
addpath(P.eeglab);
eeglab('nogui');

for k = 1:2
    name = sprintf('S%d', k);
    EEG    = pop_loadset('filename', [name '_ica.set'], 'filepath', P.dataProc);
    cnames = EEG.etc.ic_classification.ICLabel.classes;
    cls    = EEG.etc.ic_classification.ICLabel.classifications;

    n = size(EEG.icawinv, 2);
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
    out = fullfile(P.figures, sprintf('%s_ICLabel.png', name));
    print(fig, out, '-dpng', '-r110');
    close(fig);
    fprintf('re-drew %s\n', out);
end
end

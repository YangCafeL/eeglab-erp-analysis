function plot_results()
%PLOT_RESULTS  Draw the ERP figures from results/ERP_results.mat.
%
%   Produces, in figures/:
%     S1_all4_O1.png / S2_all4_O1.png   four conditions overlaid (the figure
%                                       style required by the lab manual)
%     S1_cond31.png ... S2_cond34.png   one figure per subject and condition
%                                       (8 figures in total)
%
%   Run:  plot_results   (after pipeline_final)

P = project_paths();
load(fullfile(P.results, 'ERP_results.mat'), 'RESULTS');

names    = {'S1', 'S2'};
labels   = {'31', '32', '33', '34'};
partname = {'1-parts', '2-parts', '3-parts', '4-parts'};
colors   = [1 0 1; 1 0 0; 0 0 0; 0 0 1];   % magenta / red / black / blue

summary = cell(0, 7);
for s = 1:numel(names)
    R = RESULTS.(names{s});
    t = R.times;

    % ---------- four conditions in one axes ----------
    fig = figure('Visible', 'off', 'Position', [100 100 900 620], 'Color', 'w');
    hold on;
    h = gobjects(1, 4);
    for c = 1:4
        h(c) = plot(t, R.erp(c, :), 'LineWidth', 1.4, 'Color', colors(c, :));
    end
    hold off;
    box on;
    xlim([-200 800]);
    xlabel('Time (ms)', 'FontSize', 12);
    ylabel('Potential (\muV)', 'FontSize', 12);
    legend(h, labels, 'Location', 'northeast', 'FontSize', 11);
    text(-150, min(ylim) + 0.12*diff(ylim), 'O1', 'FontSize', 12);
    set(gca, 'FontSize', 11);
    print(fig, fullfile(P.figures, sprintf('%s_all4_O1.png', names{s})), '-dpng', '-r150');
    close(fig);
    fprintf('wrote %s_all4_O1.png\n', names{s});

    % ---------- one figure per condition ----------
    for c = 1:4
        fig = figure('Visible', 'off', 'Position', [100 100 800 550], 'Color', 'w');
        plot(t, R.erp(c, :), 'LineWidth', 1.6, 'Color', [0 0.447 0.741]);
        box on;
        xlim([-200 800]);
        xlabel('Time (ms)', 'FontSize', 12);
        ylabel('Potential (\muV)', 'FontSize', 12);
        title(sprintf('Sub %d  |  %s (condition %s)  |  O1  |  N=%d', ...
            s, partname{c}, labels{c}, R.counts(c)), 'FontSize', 12);
        set(gca, 'FontSize', 11);
        print(fig, fullfile(P.figures, sprintf('%s_cond%s.png', names{s}, labels{c})), '-dpng', '-r150');
        close(fig);
    end
    fprintf('wrote %s_cond31..34.png\n', names{s});

    % ---------- peak summary ----------
    for c = 1:4
        x = R.erp(c, :);
        [pk, ipk] = max(x);
        [tr, itr] = min(x);
        summary(end+1, :) = {names{s}, labels{c}, R.counts(c), ...
            round(pk, 2), round(t(ipk)), round(tr, 2), round(t(itr))}; %#ok<SAGROW>
    end
end

fprintf('\n%-4s %-4s %5s %10s %12s %10s %12s\n', ...
    'Sub', 'Cond', 'N', 'PosPeak', 'PosLat(ms)', 'NegPeak', 'NegLat(ms)');
for i = 1:size(summary, 1)
    fprintf('%-4s %-4s %5d %10.2f %12d %10.2f %12d\n', summary{i, :});
end
end

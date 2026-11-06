function export_results()
%EXPORT_RESULTS  Write the ERP time courses and peak statistics as CSV.
%
%   results/ERP_O1_timecourse.csv  -200..800 ms, 8 curves (2 subjects x 4 conditions)
%   results/ERP_O1_peaks.csv       - N1 / P2 peaks and window means
%
%   Run:  export_results   (after pipeline_final)

P = project_paths();
load(fullfile(P.results, 'ERP_results.mat'), 'RESULTS');

labels = {'31', '32', '33', '34'};
S = {'S1', 'S2'};
t = RESULTS.S1.times(:);

% ---------- time courses ----------
fid = fopen(fullfile(P.results, 'ERP_O1_timecourse.csv'), 'w');
fprintf(fid, 'time_ms');
for s = 1:2
    for c = 1:4
        fprintf(fid, ',%s_cond%s', S{s}, labels{c});
    end
end
fprintf(fid, '\n');
for i = 1:numel(t)
    fprintf(fid, '%.2f', t(i));
    for s = 1:2
        for c = 1:4
            fprintf(fid, ',%.4f', RESULTS.(S{s}).erp(c, i));
        end
    end
    fprintf(fid, '\n');
end
fclose(fid);

% ---------- peaks ----------
fid = fopen(fullfile(P.results, 'ERP_O1_peaks.csv'), 'w');
fprintf(fid, 'subject,condition,trials,N1_amp_uV,N1_lat_ms,P2_amp_uV,P2_lat_ms,mean_150_200,mean_220_320\n');
for s = 1:2
    R = RESULTS.(S{s});
    for c = 1:4
        x  = R.erp(c, :);
        i1 = t >= 100 & t <= 220;     % N1 window
        i2 = t >= 220 & t <= 320;     % P2 window
        [n1, j1] = min(x(i1)); tt1 = t(i1);
        [p2, j2] = max(x(i2)); tt2 = t(i2);
        w1 = mean(x(t >= 150 & t <= 200));
        w2 = mean(x(t >= 220 & t <= 320));
        fprintf(fid, '%s,%s,%d,%.2f,%.0f,%.2f,%.0f,%.2f,%.2f\n', ...
            S{s}, labels{c}, R.counts(c), n1, tt1(j1), p2, tt2(j2), w1, w2);
    end
end
fclose(fid);

fprintf('wrote ERP_O1_timecourse.csv and ERP_O1_peaks.csv\n');
end

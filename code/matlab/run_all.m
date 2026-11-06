function run_all()
%RUN_ALL  One-click reproduction of the whole analysis.
%
%   Preprocessing + ICA + ERP extraction  ->  figures  ->  CSV tables
%
%   1. put S1.set/S1.fdt/S2.set/S2.fdt into data/raw/
%   2. make sure EEGLAB is on the path (or set the EEGLAB_PATH env variable)
%   3. run:  run_all

pipeline_final();
plot_results();
export_results();

fprintf('\nAll outputs are in figures/ and results/\n');
end

% verify_all.m
clear; clc; close all;
addpath(fullfile(pwd, 'generators'));
addpath(fullfile(pwd, 'solvers'));

if ~exist('data', 'dir'), mkdir('data'); end
if ~exist('output', 'dir'), mkdir('output'); end

fprintf('Starting Comprehensive Validation...\n');

% 1. Create Target Files
disp('Generating synthetic targets...');
if exist('data/simple_truth.s2p', 'file'), delete('data/simple_truth.s2p'); end
target_simple = generate_synthetic('simple_truth.s2p');

if exist('data/multipole_truth.s2p', 'file'), delete('data/multipole_truth.s2p'); end
target_multi = generate_synthetic_multipole('multipole_truth.s2p');

target_ring = 'data/ring slot.s2p';

% 2. Run Matrix Tests
runs = {
    {target_simple, 'solve_inverse_passive', 'simple_synth_blackbox'},
    {target_simple, 'solve_inverse_physical', 'simple_synth_physical'},
    {target_multi, 'solve_inverse_passive', 'multi_synth_blackbox'},
    {target_multi, 'solve_inverse_physical', 'multi_synth_physical'},
    {target_ring, 'solve_inverse_passive', 'ring_data_blackbox'},
    {target_ring, 'solve_inverse_physical', 'ring_data_physical'}
};

for i = 1:length(runs)
    r = runs{i};
    target = r{1};
    solver = r{2};
    out_name = r{3};
    
    fprintf('\n----------------------------------------\n');
    fprintf('RUNNING TEST %d: %s \ngoing to %s\n', i, target, out_name);
    try
        if strcmp(solver, 'solve_inverse_passive')
            solve_inverse_passive(target, out_name);
        else
            solve_inverse_physical(target, out_name);
        end
        fprintf('SUCCESS: %s\n', out_name);
    catch ME
        fprintf('FAILED: %s - %s\n', out_name, ME.message);
    end
end
fprintf('\nALL TESTS EXECUTED.\n');

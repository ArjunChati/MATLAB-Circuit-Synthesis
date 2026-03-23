%% Inverse Problem Master Controller (Hybrid Mode)
clear; clc; close all; % Absolute reset to prevent data "bleeding"

% 1. Project Directory Check
if ~exist('data', 'dir'), mkdir('data'); end
if ~exist('output', 'dir'), mkdir('output'); end

% --- CONFIGURATION ---
% Set to 'golden' for the Multipole Skin Model (image_628a1c.png style)
% Set to 'data' for recorded laboratory measurements (ring_slot.s2p)
RUN_MODE = 'golden'; 

switch RUN_MODE
    case 'golden'
        fprintf('--- RUNNING GOLDEN CASE: Multipole Skin Model ---\n');
        % Use your existing generator script
        target_file = generate_synthetic_multipole('golden_truth.s2p');
        
        % Run the solver to verify the fit and plots
        solve_inverse_passive(target_file, 'golden_skin_model');
        
    case 'data'
        fprintf('--- RUNNING LABORATORY DATA MODE ---\n');
        % Point to the recorded lab file
        target_file = 'data/ring_slot.s2p'; 
        
        if ~exist(target_file, 'file')
            error('Lab file not found: %s. Check your /data folder.', target_file);
        end
        
        % Run solver on the recorded data
        solve_inverse_passive(target_file, 'lab_measurement_model');
end
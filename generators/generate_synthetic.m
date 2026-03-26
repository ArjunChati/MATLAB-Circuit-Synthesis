function s2p_file = generate_synthetic(filename)
    % Purpose: Create a "Known Truth" RLC model of tissue
    % Frequency sweep: 0.1 to 10 GHz
    f = linspace(1e8, 10e9, 500); 
    
    % Golden Truth Values (e.g., Skin Layer)
    R = 150; L = 5e-9; C = 2e-12; 
    
    % Calculate Admittance (Y) for parallel RLC: Y = 1/R + 1/jWL + jWC
    Y = 1/R + 1./(1j*2*pi*f*L) + 1j*2*pi*f*C;
    Z = 1./Y;
    
    % Convert Impedance to S-parameters (S11) with 50-ohm reference
    S11 = (Z - 50) ./ (Z + 50);
    
    % --- THE FIX: Use sparameters instead of rfnetwork ---
    % S-parameters must be [Ports x Ports x Frequencies]
    S_tensor = reshape(S11, [1, 1, 500]);
    nw = sparameters(S_tensor, f); %

    % Add a tiny bit of "Numerical Salt" (Noise)
S11 = S11 + (randn(size(S11)) + 1j*randn(size(S11))) * 1e-6; 

% Then proceed to create the sparameters object
S_tensor = reshape(S11, [1, 1, 500]);
nw = sparameters(S_tensor, f);
    
    % Ensure the data folder exists
    if ~exist('data', 'dir'), mkdir('data'); end
    
    % Save as a Touchstone (.s1p) file
    s2p_file = fullfile('data', filename);
    if exist(s2p_file, 'file'), delete(s2p_file); end
    rfwrite(nw, s2p_file); %
    fprintf('Synthetic data created: %s\n', s2p_file);
end
function s2p_file = generate_synthetic_multipole(filename)
    % Purpose: Model real human skin using a 2-pole Debye model
    f = linspace(0.1e9, 10e9, 500); 
    omega = 2*pi*f;
    
    % IEEE Standard Properties for Human Skin (approximate)
    ep_inf = 4.0;      % Infinite frequency permittivity
    del_ep1 = 32.0;    % Static minus infinite permittivity
    tau1 = 7.23e-12;   % Relaxation time 1
    sigma = 0.8;       % Static conductivity (S/m)
    ep0 = 8.854e-12;
    
    % Complex Permittivity: er = ep_inf + del_ep1/(1 + j*w*tau1) + sigma/(j*w*ep0)
    er = ep_inf + (del_ep1 ./ (1 + 1j*omega*tau1)) + (sigma ./ (1j*omega*ep0));
    
    % Convert to Impedance (Simplified 1-port model)
    % Z = sqrt(mu0 / (er * ep0)) -- Simplified wave impedance
    Z = sqrt((4*pi*1e-7) ./ (er .* ep0)); 
    
    % Convert to S11
    S11 = (Z - 50) ./ (Z + 50);
    S11 = S11 + (randn(size(S11)) + 1j*randn(size(S11))) * 0.005; % Add real noise
    
    % Save to .s2p
    S_tensor = reshape(S11, [1, 1, 500]);
    nw = sparameters(S_tensor, f);
    if ~exist('data', 'dir'), mkdir('data'); end
    s2p_file = fullfile('data', filename);
    rfwrite(nw, s2p_file);
    fprintf('Realistic tissue data created: %s\n', s2p_file);
end
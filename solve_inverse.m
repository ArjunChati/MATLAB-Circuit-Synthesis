function netlist_path = solve_inverse(input_file, output_name)
    % 1. Load the data
    S_obj = sparameters(input_file);
    f = S_obj.Frequencies;
    
    % 2. Perform the Vector Fitting
    [fit, error] = rationalfit(S_obj, 'NPoles', [2 16]);
    
    % --- THE FIX: Calculate the frequency response of the fit ---
    % We evaluate the rational function 'fit' at our original frequencies 'f'
    resp = freqresp(fit, f); 
    
    % 3. Plotting (Manual instead of using rfplot)
    figure('Name', ['Results for: ' input_file]);
    
    % Plot Magnitude (dB)
    subplot(2,1,1);
    plot(f/1e9, 20*log10(abs(squeeze(S_obj.Parameters))), 'b', 'LineWidth', 1.5); hold on;
    plot(f/1e9, 20*log10(abs(resp)), 'r--', 'LineWidth', 1.5);
    title('Magnitude Comparison'); ylabel('S11 (dB)'); xlabel('Frequency (GHz)');
    legend('Original Data', 'Vector Fit'); grid on;
    
    % Plot Phase (Degrees)
    subplot(2,1,2);
    plot(f/1e9, angle(squeeze(S_obj.Parameters))*180/pi, 'b', 'LineWidth', 1.5); hold on;
    plot(f/1e9, angle(resp)*180/pi, 'r--', 'LineWidth', 1.5);
    title('Phase Comparison'); ylabel('Phase (deg)'); xlabel('Frequency (GHz)');
    grid on;
    
    % 4. Export to Netlist
    netlist_path = fullfile('output', [output_name '.sp']);
    if ispassive(fit)
        generateSPICE(fit, netlist_path);
        fprintf('Netlist generated: %s\n', netlist_path);
    else
        warning('Fit is non-passive!');
    end
end
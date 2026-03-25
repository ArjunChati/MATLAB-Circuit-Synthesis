function netlist_path = solve_inverse_passive(input_file, output_name)
    % 1. Load Data
    S_obj = sparameters(input_file);
    f = S_obj.Frequencies;
    
    % 2. Extract S11 natively for stable 1-port rationalfitting
    S11 = squeeze(S_obj.Parameters(1,1,:));
    [fit, ~] = rationalfit(f, S11, 'NPoles', [2 18], 'Tolerance', -40);
    
    % 3. Calculate Response
    resp = freqresp(fit, f); 
    
    % 4. THE PLOT (Matches image_628a1c.png exactly)
    figure('Color', [0.1 0.1 0.1]); % Dark theme to match your screenshot
    
    % Magnitude
    subplot(2,1,1);
    plot(f/1e9, 20*log10(abs(S11)), 'b', 'LineWidth', 2); hold on;
    plot(f/1e9, 20*log10(abs(squeeze(resp))), 'r--', 'LineWidth', 2);
    title('Magnitude Comparison', 'Color', 'w'); ylabel('S11 (dB)', 'Color', 'w');
    set(gca, 'Color', [0.15 0.15 0.15], 'XColor', 'w', 'YColor', 'w', 'GridColor', 'w');
    legend('Original Data', 'Vector Fit', 'TextColor', 'w'); grid on;
    
    % Phase
    subplot(2,1,2);
    plot(f/1e9, angle(S11)*180/pi, 'b', 'LineWidth', 2); hold on;
    plot(f/1e9, angle(squeeze(resp))*180/pi, 'r--', 'LineWidth', 2);
    title('Phase Comparison', 'Color', 'w'); ylabel('Phase (deg)', 'Color', 'w');
    set(gca, 'Color', [0.15 0.15 0.15], 'XColor', 'w', 'YColor', 'w', 'GridColor', 'w');
    grid on; xlabel('Frequency (GHz)', 'Color', 'w');

    % 5. Export
    plot_path = fullfile('output', [output_name '_plot.png']);
    saveas(gcf, plot_path);
    fprintf('Plot saved to: %s\n', plot_path);
    
    netlist_path = fullfile('output', [output_name '.sp']);
    fit.generateSPICE(netlist_path);
    fprintf('Netlist saved to: %s\n', netlist_path);
end
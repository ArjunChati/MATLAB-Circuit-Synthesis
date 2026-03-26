function netlist_path = solve_inverse_physical(input_file, output_name)
    % 1. Load Data
    S_obj = sparameters(input_file);
    f = S_obj.Frequencies;
    
    % 2. Convert to Z-parameters for Foster I synthesis mapping
    Z_obj = zparameters(S_obj);
    
    % Extract the Z11 input impedance for a 1-port physical synthesis
    Z11 = squeeze(Z_obj.Parameters(1,1,:));
    
    % 3. Vector Fit on Z11 directly
    % Let default allocation handle fitting structure to prevent numerical hangs
    [fit, ~] = rationalfit(f, Z11);
    
    % 4. Generate the Plot
    resp = freqresp(fit, f); 
    figure('Color', [0.1 0.1 0.1], 'Name', ['Physical RLC Fit: ' input_file]);
    
    % Magnitude
    subplot(2,1,1);
    plot(f/1e9, 20*log10(abs(Z11)), 'b', 'LineWidth', 2); hold on;
    plot(f/1e9, 20*log10(abs(squeeze(resp))), 'r--', 'LineWidth', 2);
    title('Impedance Magnitude Comparison', 'Color', 'w'); ylabel('Z11 (dB)', 'Color', 'w');
    set(gca, 'Color', [0.15 0.15 0.15], 'XColor', 'w', 'YColor', 'w', 'GridColor', 'w');
    legend('Original Z Data', 'Vector Fit', 'TextColor', 'w'); grid on;
    
    % Phase
    subplot(2,1,2);
    plot(f/1e9, angle(Z11)*180/pi, 'b', 'LineWidth', 2); hold on;
    plot(f/1e9, angle(squeeze(resp))*180/pi, 'r--', 'LineWidth', 2);
    title('Impedance Phase Comparison', 'Color', 'w'); ylabel('Phase (deg)', 'Color', 'w');
    set(gca, 'Color', [0.15 0.15 0.15], 'XColor', 'w', 'YColor', 'w', 'GridColor', 'w');
    grid on; xlabel('Frequency (GHz)', 'Color', 'w');

    % 5. Save Plot
    if ~exist('output', 'dir'), mkdir('output'); end
    plot_path = fullfile('output', [output_name '_plot.png']);
    saveas(gcf, plot_path);
    fprintf('Plot saved to: %s\n', plot_path);
    
    % 6. Export directly to RLC Network
    netlist_path = fullfile('output', [output_name '.sp']);
    writefoster_RLC(fit, netlist_path, output_name);
    fprintf('Physical RLC Netlist successfully synthesized to: %s\n', netlist_path);
    
    % 7. Export natively to LTSpice Schematic (.asc)
    asc_path = fullfile('output', [output_name '.asc']);
    writefoster_asc(fit, asc_path, output_name);
    fprintf('LTSpice Schematic generated at: %s\n', asc_path);
end

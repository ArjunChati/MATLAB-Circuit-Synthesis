function writefoster_asc(fit_z, filename, output_name)
    % Extracts Vector Fitting poles/residues into an LTSpice .asc schematic
    
    fid = fopen(filename, 'w');
    fprintf(fid, 'Version 4\n');
    fprintf(fid, 'SHEET 1 3000 1500\n');
    
    % Add Simulation Directives for "Immediate Running"
    fprintf(fid, 'TEXT -160 -100 Left 2 !.ac dec 100 1meg 10g\n');
    
    A = fit_z.A;
    C = fit_z.C;
    D = fit_z.D;
    E = fit_z.E;
    
    % Starting offset to accommodate the Test Source
    x_start = 400;
    y_center = 800;
    
    % --- TEST BENCH (Voltage Source V1) ---
    % Vertical source
    fprintf(fid, 'SYMBOL voltage 160 720 R0\n');
    fprintf(fid, 'SYMATTR InstName V1\n');
    fprintf(fid, 'SYMATTR Value AC 1\n');
    fprintf(fid, 'WIRE 160 720 160 640\n');
    fprintf(fid, 'WIRE 160 640 400 640\n'); % Bus to the circuit
    fprintf(fid, 'WIRE 160 800 160 880\n');
    fprintf(fid, 'FLAG 160 880 0\n');
    
    x_curr = x_start;
    
    % Input pin label
    fprintf(fid, 'FLAG %d 640 p1\n', x_curr);
    fprintf(fid, 'IOPIN %d 640 InOut\n', x_curr);
    
    branch_count = 1;
    dx = 400; % Increased spacing to prevent label collision
    
    % --- SERIES D RESISTANCE ---
    if abs(D) > 1e-6
        xa = x_curr; xb = xa + dx;
        fprintf(fid, 'SYMBOL res %d 640 R270\n', xa);
        fprintf(fid, 'SYMATTR InstName R_series_D\n');
        fprintf(fid, 'SYMATTR Value %g\n', abs(D));
        fprintf(fid, 'WIRE %d 640 %d 640\n', xa+80, 640, xb, 640);
        x_curr = xb;
    end
    
    % --- SERIES E INDUCTANCE ---
    if abs(E) > 1e-15
        xa = x_curr; xb = xa + dx;
        fprintf(fid, 'SYMBOL ind %d 640 R270\n', xa);
        fprintf(fid, 'SYMATTR InstName L_series_E\n');
        fprintf(fid, 'SYMATTR Value %g\n', abs(E));
        fprintf(fid, 'WIRE %d 640 %d 640\n', xa+80, 640, xb, 640);
        x_curr = xb;
    end
    
    % --- POLES (FOSTER TANKS) ---
    i = 1;
    while i <= numel(A)
        p = A(i); r = C(i);
        xa = x_curr; xb = xa + dx;
        
        if isreal(p) && isreal(r)
            % REAL POLE -> RC Tank
            Cap = 1 / r; Res = -r / p;
            
            y_r = 640 - 120;
            y_c = 640 + 120;
            
            % Draw Node wires
            fprintf(fid, 'WIRE %d %d %d %d\n', xa, y_r, xa, y_c);
            fprintf(fid, 'WIRE %d %d %d %d\n', xb, y_r, xb, y_c);
            
            % R Branch
            fprintf(fid, 'SYMBOL res %d %d R270\n', xa, y_r);
            fprintf(fid, 'SYMATTR InstName R_p%d\n', branch_count);
            fprintf(fid, 'SYMATTR Value %g\n', Res);
            fprintf(fid, 'WIRE %d %d %d %d\n', xa+80, y_r, xb, y_r);
            
            % C Branch
            fprintf(fid, 'SYMBOL cap %d %d R270\n', xa, y_c);
            fprintf(fid, 'SYMATTR InstName C_p%d\n', branch_count);
            fprintf(fid, 'SYMATTR Value %g\n', Cap);
            fprintf(fid, 'WIRE %d %d %d %d\n', xa+64, y_c, xb, y_c);
            
            x_curr = xb;
            i = i + 1;
            branch_count = branch_count + 1;
            
        else
            % COMPLEX POLE -> RLC Tank
            alpha = real(p); beta = imag(p); c1 = real(r);
            Cap = 1 / (2 * c1); Res = -c1 / alpha; Ind = (2 * c1) / (alpha^2 + beta^2);
            
            % Vertically spread out the R, L, and C branches
            y_r = 640 - 240;
            y_l = 640;
            y_c = 640 + 240;
            
            if Cap > 0 && Res > 0 && Ind > 0
                % Valid Passive Tank
                fprintf(fid, 'WIRE %d %d %d %d\n', xa, y_r, xa, y_c);
                fprintf(fid, 'WIRE %d %d %d %d\n', xb, y_r, xb, y_c);
                
                % R
                fprintf(fid, 'SYMBOL res %d %d R270\n', xa, y_r);
                fprintf(fid, 'SYMATTR InstName R_p%d\n', branch_count);
                fprintf(fid, 'SYMATTR Value %g\n', Res);
                fprintf(fid, 'WIRE %d %d %d %d\n', xa+80, y_r, xb, y_r);
                
                % L
                fprintf(fid, 'SYMBOL ind %d %d R270\n', xa, y_l);
                fprintf(fid, 'SYMATTR InstName L_p%d\n', branch_count);
                fprintf(fid, 'SYMATTR Value %g\n', Ind);
                fprintf(fid, 'WIRE %d %d %d %d\n', xa+80, y_l, xb, y_l);
                
                % C
                fprintf(fid, 'SYMBOL cap %d %d R270\n', xa, y_c);
                fprintf(fid, 'SYMATTR InstName C_p%d\n', branch_count);
                fprintf(fid, 'SYMATTR Value %g\n', Cap);
                fprintf(fid, 'WIRE %d %d %d %d\n', xa+64, y_c, xb, y_c);
            else
                % Non-physical root, bypass with short
                fprintf(fid, 'WIRE %d 640 %d 640\n', xa, xb);
                fprintf(fid, 'SYMBOL res %d 640 R270\n', xa);
                fprintf(fid, 'SYMATTR InstName R_pass_%d\n', branch_count);
                fprintf(fid, 'SYMATTR Value 1e-3\n');
                fprintf(fid, 'WIRE %d 640 %d 640\n', xa+80, xb);
            end
            
            x_curr = xb;
            i = i + 2; % Skip conjugate
            branch_count = branch_count + 1;
        end
    end
    
    % End connection to Ground
    fprintf(fid, 'FLAG %d 640 0\n', x_curr);
    
    fclose(fid);
end

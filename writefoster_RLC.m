function writefoster_RLC(fit_z, filename, output_name)
    % Extracts Vector Fitting poles/residues into a physical Foster I SPICE Netlist
    
    fid = fopen(filename, 'w');
    fprintf(fid, '* Foster Equivalent RLC Circuit for %s\n', output_name);
    fprintf(fid, '.SUBCKT %s p1 0\n', output_name);
    
    A = fit_z.A; % Poles
    C = fit_z.C; % Residues
    D = fit_z.D; % Constant
    E = fit_z.E; % Proportional
    
    node_last = 'p1';
    
    % Series D Resistance
    if abs(D) > 1e-6
        fprintf(fid, 'R_D %s nd_D %g\n', node_last, abs(D));
        node_last = 'nd_D';
    end
    
    % Series E Inductance
    if abs(E) > 1e-15
        fprintf(fid, 'L_E %s nd_E %g\n', node_last, abs(E));
        node_last = 'nd_E';
    end
    
    % Process Poles
    i = 1;
    branch_count = 1;
    
    while i <= numel(A)
        p = A(i);
        r = C(i);
        
        node_next = sprintf('n_%d', branch_count);
        if i == numel(A) || (i == numel(A)-1 && ~isreal(A(i))), node_next = '0'; end
        
        if isreal(p) && isreal(r)
            % REAL POLE -> Parallel RC Branch
            % Z_i = r / (s - p)
            Cap = 1 / r;
            Res = -r / p;
            
            fprintf(fid, '* Real Pole Branch %d\n', branch_count);
            fprintf(fid, 'C_%d %s %s %g\n', branch_count, node_last, node_next, Cap);
            fprintf(fid, 'R_%d %s %s %g\n', branch_count, node_last, node_next, Res);
            
            node_last = node_next;
            i = i + 1;
            branch_count = branch_count + 1;
        else
            % COMPLEX CONJUGATE POLE -> Parallel RLC Tank
            % Form: Z(s) ~ (2*Re(r)*s) / (s^2 - 2*Re(p)*s + |p|^2)
            alpha = real(p);
            beta = imag(p);
            c1 = real(r);
            % c2 = imag(r); (Ignored for strict passive RLC synthesis mapping)
            
            Cap = 1 / (2 * c1);
            Res = -c1 / alpha;
            Ind = (2 * c1) / (alpha^2 + beta^2);
            
            fprintf(fid, '* Complex Pole Branch %d\n', branch_count);
            if Cap > 0 && Res > 0 && Ind > 0
                fprintf(fid, 'C_%d %s %s %g\n', branch_count, node_last, node_next, Cap);
                fprintf(fid, 'R_%d %s %s %g\n', branch_count, node_last, node_next, Res);
                fprintf(fid, 'L_%d %s %s %g\n', branch_count, node_last, node_next, Ind);
            else
                % If non-physical negative components arise, bind with a 1mOhm short 
                % to maintain SPICE integrity (usually means unstable fitting root)
                fprintf(fid, 'R_short_%d %s %s 1e-3\n', branch_count, node_last, node_next);
            end
            
            node_last = node_next;
            i = i + 2; % Skip the conjugate pair
            branch_count = branch_count + 1;
        end
    end
    
    % Tie to ground if not already
    if ~strcmp(node_last, '0')
        fprintf(fid, 'R_end %s 0 1e-6\n', node_last); 
    end
    
    fprintf(fid, '.ENDS\n');
    fclose(fid);
end

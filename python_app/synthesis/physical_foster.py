import numpy as np

def write_foster_rlc(A, C, D, E, filename, output_name):
    """
    Extracts Vector Fitting poles/residues into a physical Foster I SPICE Netlist
    A: Poles
    C: Residues
    D: Constant
    E: Proportional
    """
    with open(filename, 'w') as fid:
        fid.write(f"* Foster Equivalent RLC Circuit for {output_name}\n")
        fid.write(f".SUBCKT {output_name} p1 0\n")
        
        node_last = 'p1'
        
        # Series D Resistance
        if abs(D) > 1e-6:
            fid.write(f"R_D {node_last} nd_D {abs(D):g}\n")
            node_last = 'nd_D'
            
        # Series E Inductance
        if abs(E) > 1e-15:
            fid.write(f"L_E {node_last} nd_E {abs(E):g}\n")
            node_last = 'nd_E'
            
        i = 0
        branch_count = 1
        num_poles = len(A)
        
        while i < num_poles:
            p = A[i]
            r = C[i]
            
            node_next = f"n_{branch_count}"
            # Check if this is the last pole (or last complex pair)
            if i == num_poles - 1 or (i == num_poles - 2 and not np.isreal(A[i])):
                node_next = '0'
                
            if np.isreal(p) and np.isreal(r):
                # REAL POLE -> Parallel RC Branch
                Cap = 1 / np.real(r)
                Res = -np.real(r) / np.real(p)
                
                fid.write(f"* Real Pole Branch {branch_count}\n")
                fid.write(f"C_{branch_count} {node_last} {node_next} {Cap:g}\n")
                fid.write(f"R_{branch_count} {node_last} {node_next} {Res:g}\n")
                
                node_last = node_next
                i += 1
                branch_count += 1
            else:
                # COMPLEX CONJUGATE POLE -> Parallel RLC Tank
                alpha = np.real(p)
                beta = np.imag(p)
                c1 = np.real(r)
                
                Cap = 1 / (2 * c1)
                Res = -c1 / alpha
                Ind = (2 * c1) / (alpha**2 + beta**2)
                
                fid.write(f"* Complex Pole Branch {branch_count}\n")
                if Cap > 0 and Res > 0 and Ind > 0:
                    fid.write(f"C_{branch_count} {node_last} {node_next} {Cap:g}\n")
                    fid.write(f"R_{branch_count} {node_last} {node_next} {Res:g}\n")
                    fid.write(f"L_{branch_count} {node_last} {node_next} {Ind:g}\n")
                else:
                    fid.write(f"R_short_{branch_count} {node_last} {node_next} 1e-3\n")
                    
                node_last = node_next
                i += 2 # Skip conjugate
                branch_count += 1
                
        if node_last != '0':
            fid.write(f"R_end {node_last} 0 1e-6\n")
            
        fid.write(".ENDS\n")

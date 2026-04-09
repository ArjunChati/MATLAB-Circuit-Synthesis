import numpy as np
import skrf as rf
from skrf.vectorFitting import VectorFitting

def fit_network(network, n_poles=40, port_idx=0):
    """
    Performs vector fitting on an skrf.Network object.
    Extracts the matrix components A, C, D, E for a specific S-parameter (e.g. S11).
    
    Returns:
    A: poles (array)
    C: residues (array)
    D: proportional constant
    E: linear constant
    """
    vf = VectorFitting(network)
    
    # Simple fitting logic: 50% real poles, 50% complex-conjugate pair poles
    real_poles = n_poles // 2
    cmplx_poles = (n_poles - real_poles) // 2
    
    # Generate initial poles and fit
    vf.vector_fit(n_poles_real=real_poles, n_poles_cmplx=cmplx_poles)
    
    # Extract data for the single target parameter
    # skrf stores residues as shape (N_responses, N_poles) where N_responses = N_ports^2
    # So for 1-port, index 0 is S11.
    A = np.array(vf.poles)
    C = np.array(vf.residues[port_idx, :])
    D = vf.constant_coeff[port_idx] if vf.constant_coeff is not None else 0.0
    E = vf.proportional_coeff[port_idx] if vf.proportional_coeff is not None else 0.0
    
    # Enforce left-half plane stability
    for i in range(len(A)):
        if np.real(A[i]) > 0:
            print(f"Warning: Flipped unstable pole {A[i]}")
            A[i] = -np.real(A[i]) + 1j * np.imag(A[i])
            
    return A, C, D, E

import sys
import os
sys.path.append(os.path.dirname(__file__))

from core.data_parser import load_touchstone
from core.vector_fitter import fit_network
from synthesis.physical_foster import write_foster_rlc

def run_test():
    target_file = r"c:\GitHub\CircuitSynthesis_ModelAlgo\data\simple_truth.s1p"
    print(f"Loading {target_file}")
    
    network = load_touchstone(target_file)
    print("Vector fitting...")
    
    # Simple data usually fits nicely in 18 poles
    A, C, D, E = fit_network(network, n_poles=18)
    
    out_file = "test_output.sp"
    write_foster_rlc(A, C, D, E, out_file, "simple_model")
    
    print(f"Physical RLC SPICE Netlist generated successfully -> {out_file}")

if __name__ == "__main__":
    run_test()

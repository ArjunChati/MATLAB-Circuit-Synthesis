# Automated RF-to-SPICE Modeling Pipeline

### Overview
This project provides an automated toolchain for the "Inverse Problem" in RF engineering: converting frequency-domain S-parameter data into passive, stable SPICE subcircuits. 

Designed for the Akinwande Research Group, this pipeline specializes in modeling human tissue loading and wearable RF sensor verification, allowing for high-fidelity co-simulation with active integrated circuits.

---

### Core Features
* **Multi-Source Input Support**: Seamlessly handles 1-port (.s1p) and 2-port (.s2p) Touchstone files from VNA recordings or mathematical models.
* **Automated S11 Slicing**: Automatically extracts reflection parameters from multi-port data to isolate surface loading and input impedance.
* **High-Order Vector Fitting**: Employs a robust pole-residue framework (up to 64 poles) to track complex biological responses and high-frequency resonators.
* **Guaranteed Passivity**: Integrates passivity enforcement via residue perturbation, ensuring generated models do not cause simulation divergence.
* **Batch Processing**: A robust controller mode processes entire directories of laboratory data into individual SPICE subcircuits in seconds.
* **Visual Verification**: Generates Magnitude and Phase comparison plots to ensure mathematical fit accuracy before netlisting.

---

### Technical Process

1. DATA ACQUISITION
   - Synthetic Tissue Phantoms: A MATLAB-based generator uses IEEE standard multipole Debye parameters to simulate complex skin permittivity.
   - Laboratory Recorded Data: Verified against 75–110 GHz Ring Slot Resonator data. The system extracts the physical response even with measurement noise.

2. THE INVERSE PROBLEM SOLVER
   - Dimensional Reduction: Squeezes multi-port S-parameter matrices into 1-port vectors.
   - Rational Approximation: Fits the frequency response to a sum of partial fractions (poles and residues).
   - Passivity Correction: Adjusts residues to ensure the real part of modeled impedance remains positive.

3. SPICE NETLIST GENERATION
   - The output is a .sp file using a Foster-form equivalent circuit composed of frequency-dependent voltage-controlled current sources (VCCS).

---

### SPICE Integration & Simulation

To use the generated model in LTspice, follow these steps:

1. INCLUDING THE MODEL:
   Use the .inc directive in your schematic:
   .inc output\final_tissue_model.sp

2. DEFINING THE COMPONENT:
   Instantiate the subcircuit using the 'X' prefix. Connect it to your RF node:
   X1 RF_In 0 final_tissue_model

3. AC SWEEP TESTBENCH:
   - Source: Add a voltage source V1 with 'AC 1'.
   - Command: .ac dec 100 100Meg 10G (matches the 0.1–10 GHz range).
   - Measurement: Plot V(RF_In)/-I(V1) to see complex impedance.

---

### Implementation Status & Roadmap

[X] Robust S11 Extraction (No magnitude distortion)
[X] Automated Verification Plots (.png generation)
[X] Silent Batch Processing
[X] LTspice Compatibility (.sp netlists)
[ ] Automatic Symbol Creation (.asy generator)
[ ] Multi-Layer Tissue Synthesis (Muscle, Fat, Bone)
[ ] Temperature Sensitivity for Debye parameters

---

### Usage Instructions
1. Place lab .s2p or .s1p files in the /data directory.
2. Set RUN_MODE = 'data' in main.m for lab data, or 'golden' for the skin phantom.
3. Run main.m in MATLAB.
4. Retrieve the .sp subcircuit from /output and include it in LTspice using the .inc command.
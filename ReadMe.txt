# Automated RF-to-SPICE Modeling Pipeline for Wearable Biosensors

Designed for the Akinwande Research Group, this project provides an automated toolchain to transition from high-frequency electromagnetic laboratory measurements to physical circuit simulations. 

---

## 1. The Big Picture: Why Does This Tool Exist?
The ultimate goal of this research is to develop **near-field RF wearable sensors** that monitor changes in human hemodynamics (such as blood volume pulse and hydration) seamlessly and non-invasively. 

* **In the Field (The Final Device):** A smartwatch or wearable patch tracks a patient's **blood pulse amplitude** by firing a continuous RF wave into the wrist and measuring the reflection (*S-parameters*). Every time the heart beats, blood (which is highly conductive and water-dense) rushes into the capillaries, temporarily shifting the RF reflection. By tracking this S-parameter shift over time, the wearable extracts a perfect cardiovascular waveform.
* **In the Lab (The Simulation Problem):** Before spending thousands of dollars manufacturing a custom RF PCB and antenna, you must simulate the wearable's performance in software. However, you cannot attach a physical simulated antenna to a simple "math equation" or a raw data file of reflections. You need a **"Virtual Human Wrist"** made of electronic components to test your antenna against.

**This MATLAB pipeline is the bridge.** It ingests raw RF laboratory measurements of human tissue, reverses the physics, and automatically synthesizes a literal SPICE schematic (a "Virtual Human Wrist" made of Resistors, Inductors, and Capacitors) that you can drop directly into LTSpice to co-simulate with your wearable antenna designs.

---

## 2. Breaking Down the Physics: S vs Z vs Transfer Functions
To understand how the program builds a virtual human body, you must understand the three ways we look at data:

### A. S-Parameters (The "RF Radar" Perspective)
* **What it is:** A measure of how much RF energy *scatters* (reflects or transmits) when hitting the tissue. S11 represents the reflected wave.
* **Why we use it:** At high microwave frequencies, standard oscilloscope probes become antennas. Emitting a wave from a Vector Network Analyzer (VNA) and measuring the reflection is the *only* physically accurate way to measure human tissue in the lab.
* **The Catch:** S-parameters are a *system-level* measurement relative to the VNA's 50-Ohm cables. They tell you the RF reflection changed, but they don't tell you the intrinsic Ohms or biological state of the tissue. 

### B. Z-Parameters (The "Biological Impedance" Perspective)
* **What it is:** The strict mathematical conversion of S-parameters into actual **Ohms** (Impedance). 
* **Why we use it:** Z-parameters strip away the 50-Ohm test cables and isolate the *actual biology*. Human tissue is fundamentally an electrical network: 
    * **Resistors (R)** represent ionic conductivity (sweat, blood, extracellular fluid).
    * **Capacitors (C)** represent dielectric permittivity (cell membranes storing charge).
* By converting lab measurements to Z-parameters, the algorithm can calculate the exact R and C values of the human wrist.

### C. Discrete Transfer Functions (The "Black Box" Perspective)
* **What it is:** A unitless, mathematical curve-fit (like V_out / V_in) that traces the data perfectly but ignores the underlying physics. It generates a "Black Box" model that simulates extremely fast but doesn't output tangible components.

---

## 3. The "Magic Trick": How the Pipeline Works

1. **Acquire S-Parameters:** You place biological tissue on a VNA and record the Touchstone data (`.s1p` or `.s2p`).
2. **Convert to Z-Parameters:** The MATLAB script translates the RF reflections into physical tissue Impedance (Ohms).
3. **Rational Fitting:** The `rationalfit` algorithm traces a continuous mathematical equation (poles and residues) smoothly through your discrete lab data points.
4. **Physical Synthesis:** The script geometrically maps that mathematical curve into a **Foster Canonical Form RLC Network**. It calculates exact numerical values for Resistors, Inductors, and Capacitors.
5. **Output "The Virtual Wrist":** The tool programmatically draws that RLC network into a visual LTSpice schematic (`.asc`). 
6. **The Result:** When you simulate this `.asc` schematic in LTSpice, its baseline reflection **perfectly matches** the original real-world wrist you measured. You can now tweak the synthesized resistor values in software to simulate a "rush of blood" and watch how your virtual antenna's S11 detection changes!

---

## 4. Program Architecture

* **`main.m`:** The master controller. Allows you to easily switch between generating physical RLC circuits, generating "golden" abstract black-box models, or processing actual raw laboratory data. 
* **`verify_all.m`:** The automated testing suite. Runs a matrix of combinations, feeding synthetic inputs and lab data through the solvers to guarantee the pipeline isn't broken.
* **`generators/`**: Contains scripts to mathematically create "fake" perfect S-parameter Touchstone files (simulating resonance or Debye skin models) so the solvers have a ground-truth to test against.
* **`solvers/`**: The core mathematical brains.
    * `solve_inverse_passive.m`: The **Black-Box solver**. Generates rapid Laplace-based behavioral SPICE netlists.
    * `solve_inverse_physical.m`: The **Physical solver**. Converts data to Z-parameters, fits the impedance, and calls the synthesis functions.
    * `writefoster_RLC.m` & `writefoster_asc.m`: The **Synthesis Engines**. They calculate the discrete RLC components and write the `.sp` text netlist or draw the visual `.asc` LTSpice schematic.

---

## 5. Usage Instructions

1. Place your VNA lab `.s2p` or `.s1p` files (or synthetic Touchstone files) in the `/data` directory.
2. Open `main.m` and set `RUN_MODE` to your desired workflow (e.g., `'physical_foster'` for the LTspice schematic generator, or `'data'` for lab measurements).
3. Run `main.m` in MATLAB.
4. Check the `/output` folder for your generated verification plots (`.png`) and your synthesized SPICE models (`.sp` or `.asc`).
5. Open the generated `.asc` file directly in LTSpice, or include the `.sp` subcircuit in your main testbench using the `.inc` command.
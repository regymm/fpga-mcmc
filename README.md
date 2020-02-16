# fpga-mcmc
FPGA accelerated Markov Chain Monte Carlo. Project for computational physics course. 

- [mcPi](./reports/mcpi.md): Monte Carlo calculation of Pi
- [PIHO](reports/piho.md): Path Integral Harmonic Oscillator simulation using Markov Chain Monte Carlo. 7x speedup over CPU. 



**Directories:**

Verilog sources: 

- Design source `./verilog/src` , especially `piho_unit.v`, `mc_top.v`. 
- Simulation source `./verilog/sim`
- Memory file `./verilog/coe`
- Vivado project tcl `./verilog/tcl`, can be used to rebuild Vivado projects. 

Vivado projects:

- `mcPi-on-chip-2019.1/mcPi-core` is the computation part and packaged as IP core 
- `mcPi-on-chip-2019.1/ip_repo` is the simple IP for PS/PL communication 
- `mcPi-on-chip-2019.1/project_1` is the whole mcPi project using mcPi-core and myaxi_passthrough
- `piho-on-chip-2019.1/piho-core` is the computation part and packaged as IP core
- `piho-on-chip-2019.1/delaypass` is a simple IP core to delay for a clock cycle
- `piho-on-chip-2019.1/piho` is the whole PIHO project using piho-core, myaxi_passthrough and delaypass
- Those IP cores are a little bit messed-up, you can find the location and name of these at the fifth line of the `components.xml`s

C/C++ sources:

- `./C/mcPi.c`
- `./C/piho.cpp`, compile with `g++ -O3 -mavx`
- `./C/piho_old.cpp`, and older version of piho, contains more function and is more memory-hungry, compile with `g++ -O3 -mavx`
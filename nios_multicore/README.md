# Performance Analysis of Multi-Core SoPC on Terasic FPGA DE2-115 Board
### A Project Focused on Leveraging Multi-Core Architecture on FPGA for Efficient Matrix Multiplicatoin

This project delves into the synchronization of multiple Nios II processors on the Terasic FPGA DE2-115 board. The primary aim is to foster coordination among these processors, which is a critical facet for achieving efficiency in multi-core systems. A matrix multiplication application is utilized to validate the synchronization and to evaluate the system's efficacy, serving as a fundamental computational benchmark test.

## System Design

Utilizing the Quartus Prime software tool, a system comprising nine cores was designed. The main processor takes on a crucial role in overseeing data distribution and synchronization amongst the auxiliary processors. This not only assures data integrity but also facilitates the efficient execution of the matrix multiplication operation by each processor.

## Hardware Integration

The melding of hardware components, encompassing processors and memory, was expedited using the Platform Designer (SoPC Builder) tool. This tool is instrumental in amalgamating these components into a singular unit, which is then replicated to materialize the multi-core architecture.

## Getting Started

### Prerequisites

- Quartus Prime software
- Terasic FPGA DE2-115 board
- Platform Designer (SoPC Builder) tool

### Installation

1. Install Quartus Prime software on your machine.
2. Connect the Terasic FPGA DE2-115 board to your machine.
3. Launch the Platform Designer (SoPC Builder) tool and follow the on-screen instructions to integrate the hardware components and instantiate the multi-core architecture.

## Running the Matrix Multiplication Application

1. Compile and upload the provided code to the main processor on the FPGA board.
2. Monitor the output on the connected display to observe the matrix multiplication operation and assess the synchronization and efficiency of the multi-core system.

## Contributing

Feel free to fork the project, create a new branch for your work, and open a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Acknowledgements

- [Altera](https://www.intel.com/content/www/us/en/products/programmable.html) for Nios II processors and Quartus Prime software.
- [Terasic](https://www.terasic.com.tw/) for FPGA DE2-115 board.
- [Platform Designer (SoPC Builder)](https://www.intel.com/content/www/us/en/software/programmable/quartus-prime/download.html) for hardware integration tool.

# COMP3601 Audio Project
## Audio to MIDI Converter

## Table of Contents
1. [Introduction](#1-introduction)
2. [File Organisation](#2-file-organisation)
3. [Explanation of Hardware](#3-explanation-of-hardware)
4. [Explanation of Software](#4-explanation-of-software)
5. [How to Run This Project](#5-how-to-run-this-project)

# 1 Introduction

This project was created by Aaron Nyholm (z5316510), Daniel Craig (z5417681) and Michael Benney (z5478530)

### 1.1 Project Overview
This repository contains the files for an audio to MIDI converter. This device takes in raw audio via I2S microphone (and even recorded audio data via AXI Stream into audio_pipeline), converts this into bins in the frequency domain using Xilinx's Fast Fourier Transform core, and outputs prominent notes within octaves 3-5 (130.81Hz - 987.77Hz) via the MIDI data standard.
This project is ran on the Xilinx Kria KV260 Vision AI Starter Kit. Attached to this is a specially designed PMod Board alongside a SPH0645 I2S Mic, allowing for I2S audio input into the KV260's PL.

### 1.2 MIDI Overview
MIDI is a data standard for electronic musical instruments and synthesizers to connect over a UART line of communication. A typical MIDI packet is 10 bits wide, with a start bit (low), 8 data bits and a stop bit (high), with MIDI transfers typically consisting of an instruction packet followed by an expected amount of data packets. Whilst there are many facets of the MIDI protocol, this project simply focuses on the transferral of data relating to turning on and off notes.

### 1.3 Internal Project Diagram
-- TODO: perhaps include the diagram from the project plan?

### 1.4 How Does this Project Integrate into a Wider System?

-- TODO: mermaid diagram showing flow of data from raw audio  -> i2s microphone/AXI stream in -> audio_pipeline -> raw data over AXI STREAM -> FFT -> frequency data over AXI STREAM -> PS -> MIDI over UART -> Synthesizer -> Audio Amplifier -> Output Tones 

# 2 File Organisation

-- TODO: brief overview of all files in the github directory, consider grouping together related files such as VHDL source files into their own directory

# 3 Explanation of Hardware

### 3.1 Vivado Block Diagram
-- TODO: insert image of block diagram via ![alt text](http://url/to/img.png)

### 3.2 audio_pipeline Module
-- TODO: explain the data flow into/out of audio pipeline (including feedback)

Moreover, the pmod_btn_sw1 port has been wired into the MSB of the version register inside audio_pipeline to allow for reading of the button from the PS.

### 3.3 Xilinx Fast Fourier Transform IP
This raw data is then fed out of the audio pipeline module and into the xfft IP via AXI Stream. The data fed into AXI Stream is reduced from 32 bits to 15 bits wide, this is because the input to the xfft is comprised of two 16 bit signed numbers representing imaginary and real data (and so we reduce to 15 bits to ensure our real input doesn't experience sign changes)
In our case, we take the bits [28 downto 14] of audio_pipeline's axis_o_tdata since the microphone's resolution causes bits [13 downto 0] to always be zero, and we observed the dc offset of the data causing bits [31 downto 29] to be constant. For the xfft's S_AXIS_CONFIG input, we input the constant bit string x"0d57". This config input is split up as [15 downto 13] are padding zeroes, [12 downto 1] is the scaling schedule of the FFT (in our case, to avoid overflowing, our scaling schedule is [1 2 2 2 2 3]), and the LSB is '1' so that the FFT works in forward mode.
This FFT is of size 2048 which, coupled with our sampling frequency of 25201Hz, provides us with an output bin size of ~12Hz. We chose Pipelined Streaming I/O for the FFT's architecture to allow the audio pipeline to continually send data whilst the PS system purely interacts with the FFT using the axi dma. Under the implementation settings, we use fixed point scaled data, and ensure that the output is naturally ordered. The latency of this module is 62.730 us.

The output of this FFT is again carried via axi stream to AXI DMA IP. To save some data manipulation in the PS system, the output m_axis_data_tdata of the FFT is split into the real and imaginary parts, performing combinational calculations to ensure the input to the dma s_axis_s2mm_tdata = re^2 + im^2. Originally, a CORDIC IP block was also used to calculate the square root of that value, however the delay introduced caused issues so the square root function was allocated in responsibility to the PS.
This AXI DMA then acts as the interface by which, through an AXI SmartConnect module, the PS can extract data from the FFT. Moreover, the FFT has 6 event signals which describe what is happening within the block, these are fed into the audio_pipeline module to be added to the status register for reading from the PS.

### 3.4 UART0

Finally, in order to transmit our MIDI, we have enabled UART0 in the Zynq Ultrascale+ MPSoC IP, setting the I/O to EMIO which allows us to access the UART signal on the internal hardware lines. From this, we have attached emio_uart0_txd to the pmod_i2s2_lrclk pin and the (unused) emio_uart0_rxd to the pmod_i2s2_bclk pin.

# 4 Explanation of Software

All of the project's software is contained within the helloworld.c file. TODO -- change the file name

### 4.1 Functions

- **`int main()`**
	The main function where execution begins, currently the data printing format is tied to **curr_state**

- **`void init_axi_dma()`**
	Initialises the AXI DMA for transferral of data between the PS and PL

- **`void print_regs()`**
	Prints the version, control and status registers from audio_pipeline module, allowing for debugging

- **`void fetch_fft_data()`**
	Completes an AXI DMA transfer of the FFT data into **rx_buf**

- **`void process_fft_data()`**
	Converts the data in **rx_buf** into the FFT bins in **fft_bins**

- **`void print_fft_data()`**
	Simply prints the first 200 bins' data alongside their corresponding frequencies (we are only really interested in the first 200 bins, although there are 2048 bins in total)

- **`void get_top_freqs()`**
	Prints the 3 frequencies with the highest bin magnitude between the 6th and 200th bins (we omit the first 5 bins due to large DC offset distorting this region)

- **`void print_waterfall()`**
	Prints a makeshift waterfall output using the frequencies of the first 180 bins and splitting them into relative quintiles

- **`void check_btn()`**
	Checks the MSB of the version register to see the value of the btn, if the button has been pushed then change the **curr_state**

- **`void check_freqs()`**
	Checks the pre-allocated bins (in **frequency_bins**) associated with our notes of interest and sort any notes which have a bin magnitude greater than **MIN_THRESHOLD** into the top 6 notes, converting the notes into their MIDI values with the **MIN_NOTE** offset 

- **`void transmit_midi()`**
	Sends MIDI signals over UART to turn off notes no longer found in the audio and turn on new notes which have popped up, with the number of notes transmitted being dictated by **curr_state**

- **`print_midi_master_input()`**
	Prints the (up to) top 6 notes detected in their MIDI value

- **`int initialise_uart(XUartPs* Uart_Ps, u16 DeviceId, int baud_rate)`**
	Initialises the UART0 line for transmission of MIDI

- **`int send_note(XUartPs* Uart_Ps, int note, int velocity)`**
	Sends a specified MIDI note over UART0, with velocity 0 turning a note off whilst other velocities specify how loud a given note is

### 4.2 Global Variables

AXI DMA related variables
- **XAxiDma_Config *CfgPtr**
	The configuration pointer for the AXI DMA

- **XAxiDma AxiDma**
	Reference to the AXI DMA used in data transfers

- **volatile char rx_buf[BUF_SIZE]**
	Array which stores data received from AXI DMA

UART related variables
- **XUartPs Uart0_Ps**
	Instance of the UART0 driver

- **int curr_notes[6]**
	Array for the notes detected in the current batch of fft bins

- **int prev_notes[6]**
	Array for the previously detected notes, signifying those already active

State related variables
- **uint32_t prev_btn**
	Stores the previous value of button used in state updating

- **uint32_t curr_state**
	Stores the current state

Misc
- **uint32_t fft_bins[FFT_SIZE]**
	Bins corresponding to frequencies between 0Hz and 25kHz differing by 12Hz each, output of the fft

- **int frequency_bins[36]**
	Constant array for bin locations corresponding with each note

### 4.3 Execution Flow

When ran, the program first initialises both the AXI DMA and UART0 lines. After this, the program enters an indefinite loop of the form

```mermaid
flowchart TD
	A[Check Button and State Transition] --> B[Fetch FFT Data via AXI DMA];
	B --> C[Process Raw Data into FFT Bins];
	C --> D[Process FFT Bin Data into Selected MIDI Notes Data];
	D --> E[Send MIDI for Current Notes over Uart (no. of notes based on curr_state)];
	E -- curr_state == FREQS_1 --> F[Print Waterfall];
	E -- curr_state == FREQS_3 --> G[Print Detected Top MIDI Notes];
	E -- curr_state == FREQS_6 --> H[Print Top 3 Frequencies];
	F -- loop --> A;
	G -- loop --> A;
	H -- loop --> A;
```

# 5 How to Run This Project

### 5.1 Building Vivado Model

-- TODO instructions on building vivado model

**Exporting block design**
```write_bd_tcl -include_layout -force pl_audio_pipeline.tcl```

**Importing block design**
In Vivado IDE
```Tools > Run Tcl Script```

### 5.2 Building Vitis Platform and Project

-- TODO instructions on doing this from a .xsa file <=> essentially copy over code, build, add math library via C/C++ Build Configurations and make stdin and stdout on ps_uart_1

### 5.3 Running this Project

-- Undecided whether or not to mention the need for repeated runs (in which case the print gives a good indicator of needing to restart), include image here highlighting the i2s2 pin location on the PMod Board for using an oscilloscope

### 5.4 Integrating this project

-- TODO describe setup for getting the MIDI from our board and transferring it to synthesizer of choice

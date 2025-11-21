/******************************************************************************
* Copyright (C) 2023 Advanced Micro Devices, Inc. All Rights Reserved.
* SPDX-License-Identifier: MIT
******************************************************************************/
/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xil_io.h"
#include "sleep.h"
#include "xaxidma.h"
#include "xuartps.h"

// defines
#define AXI_FIFO_BASE                 0xA0000000
#define AXI_I2S_CTR_OFFSET             0
#define AXI_FIFO_STATUS_OFFSET         4
#define AXI_VERSION_OFFSET             8
#define AXI_AXI_CTR_OFFSET             12
#define AXI_FFT_STATUS_OFFSET         16
#define AXI_AXIS_MASTER_OFFSET         20

#define I2S_ENABLE_CAPTURE     0x0001
#define I2S_ENABLE_LEFT     0x0002
#define I2S_ENABLE_RIGHT     0x0004
#define I2S_ENABLE_FEEDBACK 0x0040

#define AXI_FFT_BYPASS        (1<<31)

#define UART0_DEVICE_ID        XPAR_XUARTPS_0_DEVICE_ID
#define UART1_DEVICE_ID        XPAR_XUARTPS_1_DEVICE_ID

#define BUF_SIZE 8192
#define FFT_SIZE 2048
#define SAMPLING_FREQ 25201
#define MIN_THRESHOLD 5000
#define MIN_NOTE 48

// global variables
volatile char tx_buf[BUF_SIZE] = {0};
volatile char rx_buf[BUF_SIZE] = {0};
uint32_t fft_bins[FFT_SIZE] = {0};
int curr_notes[6] = {0};
int prev_notes[6] = {0};
int frequency_bins[36] = {10, 11, 12, 13, 13, 14, 15, 16,
        17, 18, 19, 20, 21, 22, 24, 25, 27, 28, 30, 32, 34, 36,
        38, 40, 42, 45, 47, 50, 53, 56, 60, 63, 67, 71, 75, 80
};

XAxiDma_Config *CfgPtr;
XAxiDma AxiDma;

XUartPs Uart0_Ps;        /* The instance of the UART Driver */
XUartPs Uart1_Ps;        /* The instance of the UART Driver */

// state machine
#define FREQS_1 0
#define FREQS_3 1
#define FREQS_6 2
#define NUM_STATES 3

uint32_t prev_btn = 0;
uint32_t curr_state = FREQS_1;

// function declarations
void init_axi_dma();
void print_regs();

void fetch_data();
void process_fft_data();
void print_fft_data();
void get_top_freqs();
void print_waterfall();
void print_data();
void send_data();

void check_btn();
void check_freqs();

void transmit_midi();
void print_midi_master_input();

int initialise_uart(XUartPs* Uart_Ps, u16 DeviceId, int baud_rate);
int send_note(XUartPs* Uart_Ps, int note, int velocity);


int main()
{
    int feedback = 0;
    int fft = 1;
    int midi = 1;
    init_platform();

    print("Hello World\n\r");

    init_axi_dma(fft, feedback);
    if (midi) {
        initialise_uart(&Uart1_Ps, UART1_DEVICE_ID, 31250);
    }
    print_regs();


    uint32_t progression = 1;
    // continually read data from the fft and handle MIDI transaction
    while (1) {
        fetch_data();
        if (fft) {
            check_btn();
            process_fft_data();
            check_freqs();
            transmit_midi(midi);
        }
        if (feedback) {
            progression = (progression + 1) % (FFT_SIZE);
            send_data(progression);
            printf("% 4d: ", progression);
        }

        if (fft == 0) {
            print_regs();
            print_data();
        } else if (curr_state % 4 == FREQS_1) {
            print_waterfall();
        } else if (curr_state % NUM_STATES == FREQS_3) {
            print_midi_master_input();
        } else if (curr_state % NUM_STATES == FREQS_6) {
            get_top_freqs();
        }
    }

    cleanup_platform();
    return 0;
}

void init_axi_dma(int fft, int feedback) {
    uint32_t axi_ctr = FFT_SIZE;
    uint32_t i2s_ctr = I2S_ENABLE_CAPTURE | I2S_ENABLE_LEFT;

    if (!fft) {
        printf("Bypassing FFT\n");
        axi_ctr |= AXI_FFT_BYPASS;
    }
    if (feedback) {
        printf("Enabling Feedback\n");
        i2s_ctr |= I2S_ENABLE_FEEDBACK;
    }

    printf("Enabling I2S Left channel\n");
    Xil_Out32(AXI_FIFO_BASE + AXI_I2S_CTR_OFFSET, i2s_ctr);
    printf("Setting AXI transfer length to %d\n", FFT_SIZE);
    Xil_Out32(AXI_FIFO_BASE + AXI_AXI_CTR_OFFSET, axi_ctr);
    print_regs();

    int Status = XST_SUCCESS;

    CfgPtr = XAxiDma_LookupConfig(XPAR_AXI_DMA_0_DEVICE_ID);
    if (!CfgPtr) {
        print("No CfgPtr");
        return;
    }

    Status = XAxiDma_CfgInitialize(&AxiDma, CfgPtr);
    if (Status != XST_SUCCESS) {
        print("DMA cfg init failure");
        return;
    }

    if (XAxiDma_HasSg(&AxiDma)) {
        print("Device configured as SG mode \r\n");
        return;
    }

    print("DMA initialised\r\n");

    Status = XAxiDma_Selftest(&AxiDma);
    if (Status != XST_SUCCESS) {
        print("DMA failed selftest\r\n");
        return ;
    }
    print("DMA passed self test\r\n");

    /* Disable interrupts, we use polling mode */
    XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
    XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);
}

void print_regs() {
    printf("   Bitfile Version: 0x%08x\n", Xil_In32(AXI_FIFO_BASE + AXI_VERSION_OFFSET));
    printf("       I2S Control: 0x%08x\n", Xil_In32(AXI_FIFO_BASE + AXI_I2S_CTR_OFFSET));
    printf("       AXI Control: 0x%08x\n", Xil_In32(AXI_FIFO_BASE + AXI_AXI_CTR_OFFSET));
    printf("       FIFO Status: 0x%08x\n", Xil_In32(AXI_FIFO_BASE + AXI_FIFO_STATUS_OFFSET));
    printf("        FFT Status: 0x%08x\n", Xil_In32(AXI_FIFO_BASE + AXI_FFT_STATUS_OFFSET));
    printf("AXIS master Status: 0x%08x\n", Xil_In32(AXI_FIFO_BASE + AXI_AXIS_MASTER_OFFSET));
}

void print_data() {
    for (int i = 0; i < BUF_SIZE/4; i++) {
        printf("Sample %d: 0x%02x%02x%02x%02x\n", i*4, rx_buf[i*4 + 3], rx_buf[i*4 + 2], rx_buf[i*4 + 1], rx_buf[i*4]);
    }
}

void send_data(uint32_t progression) {
    uint32_t* buf;
    buf = (uint32_t*)tx_buf;

    for (int i = 0; i < (FFT_SIZE); ++i) {
        uint32_t x = i%progression;
        double sine_val = ((double)x/(double)progression)/32;
        buf[i] = 0x3FFF * (sin(sine_val) + 1);
        buf[i] = buf[i] << 15;
    }

    Xil_DCacheFlushRange((UINTPTR)tx_buf, BUF_SIZE);
    int Status = XST_SUCCESS;
    Status = XAxiDma_SimpleTransfer(&AxiDma, (UINTPTR) tx_buf,
        BUF_SIZE, XAXIDMA_DMA_TO_DEVICE);
    if (Status != XST_SUCCESS) {
        print("failed tx transfer call\r\n");
        return;
    }
}

void fetch_data() {
    int Status = XST_SUCCESS;

    Xil_DCacheFlushRange((UINTPTR)rx_buf, BUF_SIZE);

    Status = XAxiDma_SimpleTransfer(&AxiDma, (UINTPTR)rx_buf, BUF_SIZE, XAXIDMA_DEVICE_TO_DMA);
    if (Status != XST_SUCCESS) {
        print("failed rx transfer call\r\n");
        return;
    }

    while (1) {
        if (!(XAxiDma_Busy(&AxiDma, XAXIDMA_DEVICE_TO_DMA))) {
            break;
        }

    }

    Xil_DCacheFlushRange((UINTPTR)rx_buf, BUF_SIZE);
}

void process_fft_data() {
    for (int i = 0; i < FFT_SIZE; i++) {
        fft_bins[i] = 0;
        fft_bins[i] = (fft_bins[i] << 8) | rx_buf[4*i+3];
        fft_bins[i] = (fft_bins[i] << 8) | rx_buf[4*i+2];
        fft_bins[i] = (fft_bins[i] << 8) | rx_buf[4*i+1];
        fft_bins[i] = (fft_bins[i] << 8) | rx_buf[4*i];
        fft_bins[i] = sqrt(fft_bins[i]);
    }
}

void print_fft_data() {
    // we only really care about samples in the range of 0-2kHz
    for (int i = 0; i < 200; i = i + 4) {
        int freq1 = i * (SAMPLING_FREQ / FFT_SIZE);
        int freq2 = (i + 1) * (SAMPLING_FREQ / FFT_SIZE);
        int freq3 = (i + 2) * (SAMPLING_FREQ / FFT_SIZE);
        int freq4 = (i + 3) * (SAMPLING_FREQ / FFT_SIZE);
        printf("% 5dHz: % 6d | % 5dHz: % 6d | % 5dHz: % 6d | % 5dHz: % 6d\n\r", freq1, fft_bins[i], freq2, fft_bins[i+1], freq3, fft_bins[i+2], freq4, fft_bins[i+3]);
    }
}

void get_top_freqs() {
    // only looking at range of 0-2kHz
    int top_index = 6;
    int top_val = fft_bins[6];
    int second_index = 7;
    int second_val = fft_bins[7];
    int third_index = 8;
    int third_val = fft_bins[8];

    // find the top 3 values in the first 200 samples
    for (int i = 9; i < 200; i++) {
        if (fft_bins[i] > top_val) {
            third_index = second_index;
            third_val = second_val;
            second_index = top_index;
            second_val = top_val;
            top_index = i;
            top_val = fft_bins[i];
        } else if (fft_bins[i] > second_val) {
            third_index = second_index;
            third_val = second_val;
            second_index = i;
            second_val = fft_bins[i];
        } else if (fft_bins[i] > third_val) {
            third_index = i;
            third_val = fft_bins[i];
        }
    }

    // print the top 3 frequencies for the cycle
    printf("#1: % 4dHz Mag: % 5d\n\r", top_index * (SAMPLING_FREQ / FFT_SIZE), top_val);
    printf("#2: % 4dHz\n\r", second_index * (SAMPLING_FREQ / FFT_SIZE));
    printf("#3: % 4dHz\n\r", third_index * (SAMPLING_FREQ / FFT_SIZE));
    print("\n\r");
}

void print_waterfall() {
    uint32_t lowest = 0xFFFFFFFF;
    uint32_t highest = 0;
    for (int i = 1; i < 200; ++i) {
        if (fft_bins[i] > highest) {
            highest = fft_bins[i];
        }
        if (fft_bins[i] < lowest) {
            lowest = fft_bins[i];
        }
    }    uint32_t quintile = (highest - lowest)/5;
    uint32_t q2 = lowest + 1 * quintile;
    uint32_t q3 = lowest + 2 * quintile;
    uint32_t q4 = lowest + 3 * quintile;
    uint32_t q5 = lowest + 4 * quintile;
    for (int i = 1; i < 180; ++i) {
        char out = '.';
        if (fft_bins[i] > q2 && fft_bins[i] <= q3) {
            out = 'o';
        }
        if (fft_bins[i] > q3 && fft_bins[i] <= q4) {
            out = 'O';
        }
        if (fft_bins[i] > q4 && fft_bins[i] <= q5) {
            out = '0';
        }
        if (fft_bins[i] > q5) {
            out = 'X';
        }
        printf("%c", out);
    }
    printf("\n");
}

void check_btn() {
    uint32_t curr_btn = Xil_In32(AXI_FIFO_BASE + AXI_FFT_STATUS_OFFSET);
    curr_btn = curr_btn >> 31;

    if (curr_btn != prev_btn) {
        prev_btn = curr_btn;
        if (curr_btn == 1) {
            curr_state = (curr_state + 1) % NUM_STATES;
        }
    }
}

void check_freqs() {
    int top_freqs[6] = {0};
    int top_freqs_mags[6] = {0};

    for (int i = 0; i < 6; i++) {
        top_freqs[i] = -1;
        top_freqs_mags[i] = 0;
    }

    for (int i = 0; i < 36; i++) {
        int curr_mag = fft_bins[frequency_bins[i]];
        // if the frequency is over the threshold, sort it
        if (curr_mag > MIN_THRESHOLD) {
            // check top_freqs_mags array from highest [0] to lowest [5]
            // if curr_mag is at the jth spot, move down the rest of the array from [5] downto [j], then replace the [j] spot and break
            for (int j = 0; j < 6; j++) {
                if (curr_mag > top_freqs_mags[j]) {
                    for (int k = 5; k > j; k--) {
                        top_freqs_mags[k] = top_freqs_mags[k-1];
                        top_freqs[k] = top_freqs[k-1];
                    }
                    top_freqs_mags[j] = curr_mag;
                    top_freqs[j] = i;
                    break;
                }
            }
        }
    }

    // at this point, we have an array of up to 6 frequencies, turn them into curr_notes
    for (int i = 0; i < 6; i++) {
        if (top_freqs[i] != -1) {
            curr_notes[i] = top_freqs[i] + MIN_NOTE;
        } else {
            curr_notes[i] = -1;
        }
    }

}

void transmit_midi(int send) {
    // todo: transmit midi based on the difference between curr_notes and prev_notes arrays, optional to use the 3 states to actually do something
    // check the number of notes to transmit based on curr_state
    int num_notes = 0;
    if (curr_state == FREQS_1) {
        num_notes = 1;
    } else if (curr_state == FREQS_3) {
        num_notes = 3;
    } else if (curr_state == FREQS_6) {
        num_notes = 6;
    }

    // for all the valid notes in the prev_notes array, check if we must turn them off
    for (int i = 0; i < num_notes; i++) {
        int remove_note_i = 1;
        for (int j = 0; j < num_notes; j++) {
            if (prev_notes[i] == curr_notes[j]) {
                remove_note_i = 0;
            }
        }
        if (remove_note_i == 1) {
            // send a MIDI signal to turn off prev_notes[i]
            if (send) {
                send_note(&Uart0_Ps, prev_notes[i], 0);
            }
        }
    }

    // for all the valid notes in the curr_notes_array, check if we must turn them on
    for (int i = 0; i < num_notes; i++) {
        int add_note_i = 1;
        for (int j = 0; j < num_notes; j++) {
            if (curr_notes[i] == prev_notes[j]) {
                add_note_i = 0;
            }
        }
        if (add_note_i == 1) {
            // send a MIDI signal to turn on curr_notes[i]
            if (send) {
                send_note(&Uart0_Ps, curr_notes[i], 80);
            }
        }
    }

    // after transmitting all the midi required, copy curr_notes into prev_notes
    for (int i = 0; i < 6; i++) {
        prev_notes[i] = curr_notes[i];
    }
}

void print_midi_master_input() {
    for (int i = 0; i < 6; i++) {
        if (curr_notes[i] != -1) {
            printf("Note %d: %d\n\r", i, curr_notes[i]);
        }
    }
    print("\n\r");
}

int initialise_uart(XUartPs* Uart_Ps, u16 DeviceId, int baud_rate)
{
    int Status;
    XUartPs_Config *Config;

    /*
     * Initialize the UART driver so that it's ready to use
     * Look up the configuration in the config table and then initialize it.
     */
    Config = XUartPs_LookupConfig(DeviceId);

    if (NULL == Config) {
        return XST_FAILURE;
    }

    Status = XUartPs_CfgInitialize(Uart_Ps, Config, Config->BaseAddress);
    if (Status != XST_SUCCESS) {
        return XST_FAILURE;
    }

    XUartPs_SetBaudRate(Uart_Ps, baud_rate);

    return Status;
}

int send_note(XUartPs* Uart_Ps, int note, int velocity)
{
    u8 HelloWorld[] = {144, note, velocity}; //command, note, velocity
    int SentCount = 0;

    SentCount += XUartPs_Send(Uart_Ps, &HelloWorld[0], 3);

    return SentCount;
}



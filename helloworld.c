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


// defines
#define AXI_FIFO_BASE 				0xA0000000
#define AXI_I2S_CTR_OFFSET 			0
#define AXI_DATA_FIFO_STATUS_OFFSET 4
#define AXI_VERSION_OFFSET 			8
#define AXI_AXI_CTR_OFFSET 			12
#define AXI_FB_FIFO_STATUS_OFFSET 	16
#define AXI_AXIS_MASTER_OFFSET 		20

#define I2S_ENABLE_CAPTURE 	0x0001
#define I2S_ENABLE_LEFT 	0x0002
#define I2S_ENABLE_RIGHT 	0x0004
#define I2S_ENABLE_FEEDBACK 0x0040

#define BUF_SIZE 8192
#define FFT_SIZE 2048
#define SAMPLING_FREQ 25201

// global variables
volatile char rx_buf[BUF_SIZE] = {0};
uint32_t fft_bins[FFT_SIZE] = {0};

XAxiDma_Config *CfgPtr;
XAxiDma AxiDma;

// function declarations
void init_axi_dma();
void print_regs();

void fetch_fft_data();
void process_fft_data();
void print_fft_data();
void get_top_freqs();
void print_waterfall();


int main()
{
    init_platform();

    print("Hello World\n\r");
    print("Successfully ran Hello World application");

    // initialise the axi dma
    init_axi_dma();

    // continually read data from the fft and (TODO) handle MIDI transaction
    while (1) {
    	fetch_fft_data();
    	process_fft_data();
    	//print_fft_data();
    	//get_top_freqs();
    	print_waterfall();
    }

    cleanup_platform();
    return 0;
}

void init_axi_dma() {
	printf("Enabling I2S Left channel\n");
	Xil_Out32(AXI_FIFO_BASE + AXI_I2S_CTR_OFFSET, I2S_ENABLE_CAPTURE | I2S_ENABLE_LEFT);
	printf("Setting AXI transfer length to %d\n", BUF_SIZE/4);
	Xil_Out32(AXI_FIFO_BASE + AXI_AXI_CTR_OFFSET, BUF_SIZE/4);
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
	printf("  Data FIFO Status: 0x%08x\n", Xil_In32(AXI_FIFO_BASE + AXI_DATA_FIFO_STATUS_OFFSET));
	printf("    FB FIFO Status: 0x%08x\n", Xil_In32(AXI_FIFO_BASE + AXI_FB_FIFO_STATUS_OFFSET));
	printf("AXIS master Status: 0x%08x\n", Xil_In32(AXI_FIFO_BASE + AXI_AXIS_MASTER_OFFSET));
}

void fetch_fft_data() {
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
		//print_regs();
		// printf("Waiting for XAxiDma_Busy, Status : 0x%08x\n", Xil_In32(AXI_FIFO_BASE + AXI_FIFO_STATUS_OFFSET));
		//print("waiting");
		usleep(1U);
	}

	Xil_DCacheFlushRange((UINTPTR)rx_buf, BUF_SIZE);
	//print("DMA done\r\n");
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


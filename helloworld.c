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
#include "platform.h"
#include "xaxidma.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xsdps.h"
#include "xil_io.h"
#include "sleep.h"
#include "ff.h"

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

#define BUF_SIZE 1024
#define SAMPLES 500

volatile char rx_buf[BUF_SIZE*SAMPLES] = {0};
volatile char tx_buf[BUF_SIZE] = {0};

FATFS FatFs;
FIL fil;

XAxiDma_Config *CfgPtr;
XAxiDma AxiDma;

void print_regs() {
	printf("   Bitfile Version: 0x%08x\n", Xil_In32(AXI_FIFO_BASE + AXI_VERSION_OFFSET));
	printf("       I2S Control: 0x%08x\n", Xil_In32(AXI_FIFO_BASE + AXI_I2S_CTR_OFFSET));
	printf("       AXI Control: 0x%08x\n", Xil_In32(AXI_FIFO_BASE + AXI_AXI_CTR_OFFSET));
	printf("  Data FIFO Status: 0x%08x\n", Xil_In32(AXI_FIFO_BASE + AXI_DATA_FIFO_STATUS_OFFSET));
	printf("    FB FIFO Status: 0x%08x\n", Xil_In32(AXI_FIFO_BASE + AXI_FB_FIFO_STATUS_OFFSET));
	printf("AXIS master Status: 0x%08x\n", Xil_In32(AXI_FIFO_BASE + AXI_AXIS_MASTER_OFFSET));

}

void wav_write_header() {
    FRESULT fr;
    int wcount;
    char wav_buf[256] = {0};

    /* Give a work area to the default drive */
    fr = f_mount(&FatFs, "1:/", 0);
    if (fr) {
		printf("SD WAV: Mount failed %d\n", fr);
		return;
	}

    fr = f_open(&fil, "1:/mic.wav", FA_WRITE | FA_CREATE_ALWAYS);
    if (fr) {
    	printf("SD WAV: Open failed %d\n", fr);
    	return;
    }

    wav_buf[0] = 'R';
    wav_buf[1] = 'I';
    wav_buf[2] = 'F';
    wav_buf[3] = 'F';

    wav_buf[4] = ( (uint32_t)BUF_SIZE*SAMPLES + 44 - 8) & 0xFF;
    wav_buf[5] = (((uint32_t)BUF_SIZE*SAMPLES + 44 - 8) >> 8) & 0xFF;
    wav_buf[6] = (((uint32_t)BUF_SIZE*SAMPLES + 44 - 8) >> 16) & 0xFF;
    wav_buf[7] = (((uint32_t)BUF_SIZE*SAMPLES + 44 - 8) >> 24) & 0xFF;

    wav_buf[8] = 'W';
    wav_buf[9] = 'A';
    wav_buf[10] = 'V';
    wav_buf[11] = 'E';

    wav_buf[12] = 'f';
    wav_buf[13] = 'm';
    wav_buf[14] = 't';
    wav_buf[15] = 0x20;

    wav_buf[16] = 0x10;

    wav_buf[20] = 0x01;

    wav_buf[22] = 0x01;

    wav_buf[24] = ( (uint32_t)25201) & 0xFF;
    wav_buf[25] = (((uint32_t)25201) >> 8) & 0xFF;
    wav_buf[26] = (((uint32_t)25201) >> 16) & 0xFF;
    wav_buf[27] = (((uint32_t)25201) >> 24) & 0xFF;

    wav_buf[28] = ( (uint32_t)25201 * 4) & 0xFF;
    wav_buf[29] = (((uint32_t)25201 * 4) >> 8) & 0xFF;
    wav_buf[30] = (((uint32_t)25201 * 4) >> 16) & 0xFF;
    wav_buf[31] = (((uint32_t)25201 * 4) >> 24) & 0xFF;

    wav_buf[32] = 0x4;

    wav_buf[34] = 32;

    wav_buf[36] = 'd';
    wav_buf[37] = 'a';
	wav_buf[38] = 't';
	wav_buf[39] = 'a';

	wav_buf[40] = ( (uint32_t)BUF_SIZE*SAMPLES) & 0xFF;
    wav_buf[41] = (((uint32_t)BUF_SIZE*SAMPLES) >> 8) & 0xFF;
    wav_buf[42] = (((uint32_t)BUF_SIZE*SAMPLES) >> 16) & 0xFF;
    wav_buf[43] = (((uint32_t)BUF_SIZE*SAMPLES) >> 24) & 0xFF;

    fr = f_write(&fil, wav_buf, 44, &wcount);
    if (fr) {
    	printf("SD WAV: Write failed %d: %d\n", fr, wcount);
    	return;
    }
    printf("SD WAV: Wrote %d bytes\n", wcount);
}

void wav_write_data() {
	FRESULT fr;
    int wcount;
    for (int i = 0; i < SAMPLES; ++i) {
		fr = f_write(&fil, &rx_buf[BUF_SIZE * i], BUF_SIZE, &wcount);
		if (fr) {
			printf("SD WAV: Write failed %d: %d\n", fr, wcount);
			return;
		}
    }
}

void wav_close() {
	FRESULT fr;
    fr = f_close(&fil);
    if (fr) {
		printf("SD WAV: Close failed %d\n", fr);
		return;
	}
}

void record_audio() {
	printf("SD WAV: Record Started\n");
	int Status = XST_SUCCESS;
	for (int i = 0; i < SAMPLES; ++i) {
		Xil_DCacheFlushRange((UINTPTR)rx_buf, BUF_SIZE);
		Status = XAxiDma_SimpleTransfer(&AxiDma, (UINTPTR) (&rx_buf[BUF_SIZE * i]),
				BUF_SIZE, XAXIDMA_DEVICE_TO_DMA);
		if (Status != XST_SUCCESS) {
			print("SD WAV: failed rx transfer call\r\n");
			return 1;
		}

		while (1) {
			if (!(XAxiDma_Busy(&AxiDma, XAXIDMA_DEVICE_TO_DMA))) {
				break;
			}
		}
	}
	printf("SD WAV: Record finished\nSD WAV: Write Start\n");
	wav_write_data();
	wav_close();
	printf("SD WAV: Write end\n");
}

void send_data() {

	for (int i = 0; i < BUF_SIZE; ++i) {
		tx_buf[i] = i & 0xff;
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

void print_data() {
	for (int i = 0; i < BUF_SIZE; ++i) {
		rx_buf[i] = 0;
	}
	int Status = XST_SUCCESS;
	Xil_DCacheFlushRange((UINTPTR)rx_buf, BUF_SIZE);

	Status = XAxiDma_SimpleTransfer(&AxiDma, (UINTPTR) (rx_buf),
			BUF_SIZE, XAXIDMA_DEVICE_TO_DMA);

	if (Status != XST_SUCCESS) {
		print("failed rx transfer call\r\n");
		return 1;
	}

	while (1) {
		if (!(XAxiDma_Busy(&AxiDma, XAXIDMA_DEVICE_TO_DMA))) {
			break;
		}
	}

	for (int i = 0; i < BUF_SIZE; i = i + 4) {
		printf("Sample %4d: 0x%02x%02x%02x%02x\n",
				(i/4), rx_buf[i+3], rx_buf[i+2], rx_buf[i+1], rx_buf[i]);
	}
}

int main()
{
    init_platform();

    print("Hello World\n\r");

	print_regs();
	printf("Setting AXI transfer length to %d\n", BUF_SIZE/4);
	Xil_Out32(AXI_FIFO_BASE + AXI_AXI_CTR_OFFSET, BUF_SIZE/4);
	Xil_Out32(AXI_FIFO_BASE + AXI_I2S_CTR_OFFSET, I2S_ENABLE_FEEDBACK);
	print_regs();

	wav_write_header();

	int Status = XST_SUCCESS;

	CfgPtr = XAxiDma_LookupConfig(XPAR_AXI_DMA_0_DEVICE_ID);
	if (!CfgPtr) {
		print("No CfgPtr");
		return 1;
	}

	Status = XAxiDma_CfgInitialize(&AxiDma, CfgPtr);
	if (Status != XST_SUCCESS) {
		print("DMA cfg init failure");
		return 1;
	}

	if (XAxiDma_HasSg(&AxiDma)) {
		print("Device configured as SG mode \r\n");
		return 1;
	}

	Status = XAxiDma_Selftest(&AxiDma);
	if (Status != XST_SUCCESS) {
		print("DMA failed selftest\r\n");
		return 1;
	}
	print("DMA passed self test\r\n");

	/* Disable interrupts, we use polling mode */
	XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
	XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);

	print("DMA initialised\r\n");

	printf("Writing %d values to feedback system\n", (BUF_SIZE/4) * 2);
	send_data();
	send_data();

	printf("Enabling I2S Left channel and feedback\n");
	Xil_Out32(AXI_FIFO_BASE + AXI_I2S_CTR_OFFSET,
		I2S_ENABLE_CAPTURE | I2S_ENABLE_LEFT | I2S_ENABLE_FEEDBACK);
	print_regs();

	printf("Reading %d values\n", (BUF_SIZE/4) * 2);
	print_data();
	print_data();

	print_regs();

    cleanup_platform();
    return 0;
}
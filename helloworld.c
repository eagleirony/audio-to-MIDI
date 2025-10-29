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
#include "xil_io.h"
#include "sleep.h"

#define AXI_FIFO_BASE 			0xA0000000
#define AXI_I2S_CTR_OFFSET 		0
#define AXI_FIFO_STATUS_OFFSET 	4

#define I2S_ENABLE_CAPTURE 	0x0001
#define I2S_ENABLE_LEFT 	0x0002
#define I2S_ENABLE_RIGHT 	0x0004

#define BUF_SIZE 1024

volatile char rx_buf[BUF_SIZE] = {0};

int main()
{
	XAxiDma_Config *CfgPtr;
	XAxiDma AxiDma;
    init_platform();

    print("Hello World\n\r");

	printf("FIFO Status: 0x%08x\n", Xil_In32(AXI_FIFO_BASE + AXI_FIFO_STATUS_OFFSET));
	printf("I2S Control: 0x%08x\n", Xil_In32(AXI_FIFO_BASE + AXI_I2S_CTR_OFFSET));
	printf("Enabling I2S Left channel\n");
	Xil_Out32(AXI_FIFO_BASE + AXI_I2S_CTR_OFFSET, I2S_ENABLE_CAPTURE | I2S_ENABLE_LEFT);
	printf("I2S Control: 0x%08x\n", Xil_In32(AXI_FIFO_BASE + AXI_I2S_CTR_OFFSET));


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

	print("DMA initialised\r\n");

	Status = XAxiDma_Selftest(&AxiDma);
	if (Status != XST_SUCCESS) {
		print("DMA failed selftest\r\n");
		return 1;
	}
	print("DMA passed self test\r\n");

	/* Disable interrupts, we use polling mode */
	XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
	XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);

	/* We will need to always flush the buffers before
	* using DMA-managed memory,
	* unless we properly configure cache coherency */
	Xil_DCacheFlushRange((UINTPTR)rx_buf, BUF_SIZE);
	Status = XAxiDma_SimpleTransfer(&AxiDma, (UINTPTR) rx_buf,
			BUF_SIZE, XAXIDMA_DEVICE_TO_DMA);
	if (Status != XST_SUCCESS) {
		print("failed rx transfer call\r\n");
		return 1;
	}

	print("rx call good\r\n");

	while (1) {
		if (!(XAxiDma_Busy(&AxiDma, XAXIDMA_DEVICE_TO_DMA))) {
			break;
		}
		usleep(1U);
	}
	/* We will need to always flush the buffers before
	* using DMA-managed memory,
	* unless we properly configure cache coherency */
	Xil_DCacheFlushRange((UINTPTR)rx_buf, BUF_SIZE);
	print("DMA done\r\n");

	Xil_DCacheFlushRange((UINTPTR)rx_buf, BUF_SIZE);
	Status = XAxiDma_SimpleTransfer(&AxiDma, (UINTPTR) rx_buf,
			BUF_SIZE, XAXIDMA_DEVICE_TO_DMA);
	if (Status != XST_SUCCESS) {
		print("failed rx transfer call\r\n");
		return 1;
	}

	while (1) {
		if (!(XAxiDma_Busy(&AxiDma, XAXIDMA_DEVICE_TO_DMA))) {
			break;
		}
		printf("Waiting on DMA: FIFO Status: 0x%08x\n", Xil_In32(AXI_FIFO_BASE + AXI_FIFO_STATUS_OFFSET));
		usleep(1U);
	}

	for (int i = 0; i < BUF_SIZE; i = i + 4) {
		printf("Sample %4d: 0x%02x%02x%02x%02x\n",
				(i/4), rx_buf[i+3], rx_buf[i+2], rx_buf[i+1], rx_buf[i]);
	}
	printf("\n");

	printf("Status: 0x%08x\n", Xil_In32(AXI_FIFO_BASE + AXI_FIFO_STATUS_OFFSET));

    cleanup_platform();
    return 0;
}

//*******************************************************************************
// * Copyright 2023 Naim Lemar
// * Copyright 2020 Igor Semenov and LaCASA@UAH
// *
// * This program is free software: you can redistribute it and/or modify
// * it under the terms of the GNU General Public License as published by
// * the Free Software Foundation, either version 3 of the License, or
// * (at your option) any later version.
// *
// * This program is distributed in the hope that it will be useful,
// * but WITHOUT ANY WARRANTY; without even the implied warranty of
// * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// * GNU General Public License for more details.
// *
// * You should have received a copy of the GNU General Public License
// * along with this program.  If not, see <http://www.gnu.org/licenses/>
// *******************************************************************************/


#include "io.h"
#include "nios2.h"
#include "stddef.h"
#include "stdint.h"
#include "stdio.h"
#include "sys/alt_cache.h"
#include "altera_avalon_mailbox_simple.h"

// Define macros for clock counter operations
#define clk_counter_base (CLOCK_COUNTER_BASE) 
#define rst_clk_counter() IOWR(clk_counter_base, 0, 0)
#define get_low_clk_counter() IORD(clk_counter_base, 0)
#define get_high_clk_counter() IORD(clk_counter_base, 4)
#define capture_clk_counter() (get_low_clk_counter() | ((uint64_t)(get_high_clk_counter()) << 32))

// Constants for core identification and matrix dimensions
#define primary_core 0
#define matrix_size (99)
#define rows_per_core (matrix_size / CORE_COUNT)
#define row_start (CORE_ID * rows_per_core)

// Type definition for a square matrix
typedef int matrix_t[matrix_size][matrix_size];

// Shared matrices for multiplication
__attribute__((section(".shared")))
matrix_t matA, matB, matC;

// Function to initialize a mailbox for a given core and direction
altera_avalon_mailbox_dev* init_mailbox(int ID, char* direction)
{
    char mailboxName[20];
    sprintf(mailboxName, "/dev/core_%d_mbox_%s", ID, direction);
    return altera_avalon_mailbox_open(mailboxName, NULL, NULL);
}

int main()
{
    // Initialize timeout and message variables for mailbox
    alt_u32 timeout = 0;
    alt_u32 message[2];

    // Code specific to the primary core
#if (CORE_ID == primary_core)
    // Initialize matrices matA and matB
    for(int row = 0; row < matrix_size; row++)
    {
        for (int col = 0; col < matrix_size; col++)
        {
            matA[row][col] = (row * matrix_size + col) % 0x10;
        }
    }
    for(int row = 0; row < matrix_size; row++)
    {
        for (int col = 0; col < matrix_size; col++)
        {
            matB[row][col] = (row == col ? 1 : 0);
        }
    }
    // Flush data cache
    alt_dcache_flush_all();

    // Initialize mailboxes for communication with secondary cores
    altera_avalon_mailbox_dev* inMailboxList[CORE_COUNT];
    altera_avalon_mailbox_dev* outMailboxList[CORE_COUNT];
    for(int i = 0; i < CORE_COUNT; i++)
    {
        if (i == primary_core) continue;
        inMailboxList[i] = init_mailbox(i, "in");
        outMailboxList[i] = init_mailbox(i, "out");
    }

    // Start measuring execution time
    rst_clk_counter();
    for(int i = 0; i < CORE_COUNT; i++)
    {
        altera_avalon_mailbox_send(inMailboxList[i], message, timeout, POLL);
    }
#endif

    // Code specific to secondary cores
#if (CORE_ID != primary_core)
    // Initialize mailboxes for the current core
    altera_avalon_mailbox_dev* outMailbox = init_mailbox(CORE_ID, "out");
    altera_avalon_mailbox_dev* inMailbox = init_mailbox(CORE_ID, "in");
    altera_avalon_mailbox_retrieve_poll(inMailbox, message, timeout);
#endif

    // Code common to all cores: Perform matrix multiplication
    for (int row = row_start; row < row_start + rows_per_core; row++)
    {
        for (int col = 0; col < matrix_size; col++)
        {
            matC[row][col] = 0;
            for (int k = 0; k < matrix_size; k++)
            {
                matC[row][col] += matA[row][k] * matB[k][col];
            }
        }
    }

    // Code specific to secondary cores
#if (CORE_ID != primary_core)
    // Flush data cache and notify the primary core
    alt_dcache_flush_all();
    altera_avalon_mailbox_send(outMailbox, message, timeout, POLL);
#endif

    // Code specific to the primary core
#if (CORE_ID == primary_core)
    // Wait for completion signals from secondary cores
    for(int i = 0; i < CORE_COUNT; i++)
    {
        if (i == primary_core) continue;
        altera_avalon_mailbox_retrieve_poll(outMailboxList[i], message, timeout);
    }

    // Capture and print execution time
    const uint64_t execTime = capture_clk_counter();
    printf("\nResulting Matrix:\n");
    for(int row = 0; row < matrix_size; row++)
    {
        for (int col = 0; col < matrix_size; col++)
        {
            printf("%x", matC[row][col]);
        }
        printf("\n");
    }
    printf("\nExecution time for %d cores is %llu clock cycles\n", CORE_COUNT, execTime);
#endif

    // Keep the program running
    while(1);
}
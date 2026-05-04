// ========================================================================================
//     TEAM  INFO
// Group member 1 name:
// Group member 1 PID:
// Group member 2 name:
// Group member 2 PID:
// ========================================================================================

// ========================================================================================
// This is the data loading and runInference code. DO NOT MODIFY. 
// You can edit or run your own test cases by modifying the .txt data files
// ========================================================================================
// Load the initialized input matrices
LDA     X0, a
LDA     X1, b
LDA     X2, c
LDA     X3, stride
LDA     X4, base

LDUR    X5, [X3, #0] // load stride
ADD     X3, X5, XZR  // Set n = stride
LDUR    X4, [X4, #0] // load base 

runInference:
        // Input:
        //  X0: The address of (pointer to) the first value of matirx A.
        //  X1: The address of (pointer to) the first value of matirx B.
        //  X2: The address of (pointer to) the first value of matirx C.
        //  X3: The current matrix size needed (n)
        //  X4: The base
        //  X5: The stride of the matrices

        BL     recBlockMul

        // Print trace
        ADDI   X1, XZR, #10      // X1 = newline character
        PUTCHAR X1
        ADD    X1, X0, XZR       // X1 = trace value returned in X0
        PUTINT X1
        ADDI   X1, XZR, #10      // newline
        PUTCHAR X1

        // Print result matrix C
        LDA    X0, c               // base address of result matrix
        LDA    X6, stride          // load stride's address
        LDUR    X1, [X6, #0]       // set n = stride
        LDUR    X2, [X6, #0]       // set stride
        
        BL     PRINTMATRIX

        STOP

// ========================================================================================





////////////////////////////////
//                            //
//       getAddr              //
//                            //
////////////////////////////////
getAddr:
        //  Input:
        //  X5: The address of (pointer to) the first value of the matirx.
        //  X6: The row of the element(0 indexed).
        //  X7: The column of the element(0 indexed).
        //  X8: The stride of the matirx(how many elements to skip to get to the next row).

        //   Output:
        //   X5: The address of (pointer to) the desired element of the matrix.

        //YOUR CODE STARTS HERE



        //YOUR CODE ENDS HERE





////////////////////////////////
//                            //
//       baseMultiplyAdd      //
//                            //
////////////////////////////////
baseMultiplyAdd:
        //  Input:
        //  X0: The address of (pointer to) the first value of matirx A.
        //  X1: The address of (pointer to) the first value of matirx B.
        //  X2: The address of (pointer to) the first value of matirx C.
        //  X3: n
        //  X4: The stride of the matrices
        //
        //  Output:
        //  X0: The trace of the resulting n*n block of C.

        //YOUR CODE STARTS HERE


        //YOUR CODE ENDS HERE





////////////////////////////////
//                            //
//       splitOffset          //
//                            //
////////////////////////////////
splitOffset:
        //  Input:
        //  X0: The address of (pointer to) the first value of the matirx.
        //  X1: n
        //  X2: 0-3 corresponding to the four quadrant of the matrix.
        //  X3: stride

        //   Output:
        //   X8: The address of (pointer to) the desired submatrix.


        //YOUR CODE STARTS HERE



        //YOUR CODE ENDS HERE





////////////////////////////////
//                            //
//       recBlockMul          //
//                            //
////////////////////////////////
recBlockMul:
        //  Input:
        //  X0: address of matrix A
        //  X1: address of matrix B
        //  X2: address of matrix C
        //  X3: current n
        //  X4: base
        //  X5: stride
        //
        //  Output:
        //  X0: sum of traces of all diagonal base-case blocks

        //YOUR CODE STARTS HERE



        //YOUR CODE ENDS HERE






// ========================================================================================
// Functions after this are for printing results. DO NOT MODIFY
// ========================================================================================
PRINTMATRIX:
        // Input:
        // X0: base address of matrix
        // X1: n (matrix dimension)
        // X2: stride

        SUBI   SP, SP, #40
        STUR   FP, [SP, #0]
        ADDI   FP, SP, #8
        STUR   LR, [SP, #8]

        // Save parameters
        STUR   X0, [SP, #16]     // save base
        STUR   X1, [SP, #24]     // save n
        STUR   X2, [SP, #32]     // save stride

        ADDI   X5, XZR, #32      // X5 = space character
        ADDI   X6, XZR, #10      // X6 = newline character
        ADDI   X3, XZR, #0       // i = 0 (row counter)

ROW_LOOP:
        LDUR   X1, [SP, #24]     // load n
        CMP    X3, X1            // if i >= n, done
        B.GE   PRINT_DONE

        ADDI   X4, XZR, #0       // j = 0 (col counter)

COL_LOOP:
        LDUR   X1, [SP, #24]     // load n
        CMP    X4, X1            // if j >= n, end row
        B.GE   END_ROW

        // Calculate address: base + (i * stride + j) * 8
        LDUR   X7, [SP, #16]     // load base
        MUL    X19, X3, X2       // i * stride
        ADD    X19, X19, X4      // i * stride + j
        LSL    X19, X19, #3      // * 8 for byte offset
        ADD    X7, X7, X19       // final address

        // Load and print value
        LDUR   X1, [X7, #0]      // load matrix[i][j]
        PUTINT X1

        // Print space
        PUTCHAR X5

        // j++
        ADDI   X4, X4, #1
        B      COL_LOOP

END_ROW:
        // Print newline
        PUTCHAR X6

        // i++
        ADDI   X3, X3, #1
        B      ROW_LOOP

PRINT_DONE:
        LDUR   LR, [SP, #8]
        LDUR   FP, [SP, #0]
        ADDI   SP, SP, #40
        BR     LR
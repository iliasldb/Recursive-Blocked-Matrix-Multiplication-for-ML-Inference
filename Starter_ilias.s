// ========================================================================================
//     TEAM  INFO
// Group member 1 name: Ilias Lahdab
// Group member 1 PID: A18504845
// Group member 2 name: Elisabeth Hsu
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
                //row * stride
        MUL X9, X8, X6
        //row * stride + col    
        ADD X9, X9, X7
        //byte offset by 3 /same as multiplying by 8 for the long conversion
        LSL X9, X9, #3
        //add byte offset to base address
        ADD X5, X5, X9
        BR LR //return the address in X5


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
        //Save the input parameters of getAddr in case they get overwritten
        SUBI SP, SP, #32
        STUR X5, [SP, #0]
        STUR X6, [SP, #8]
        STUR X7, [SP, #16]
        STUR X8, [SP, #24] 


        ADDI X11, XZR, #0 //initialize i to 0
        row_iter:
        SUBS XZR, X11, X3 //compare i to n
        B.GE end_row_iter //if i >= n, end row iteration
        ADDI X12, XZR, #0 //initialize j to 0
        col_iter:
        SUBS XZR, X12, X3 //compare j to n
        B.GE end_col_iter //if j >= n, end column iteration
        ADDI X13, XZR, #0 //initialize SUM TO zero
        ADDI X14, XZR, #0 //initialize k to 0
        k_iter:
        SUBS XZR, X14, X3 //compare k to n
        B.GE end_k_iter //if k >= n, end k iteration
        //get A[i][k] by passing base address of A, i, k, and stride to getAddr
        //needs to make sure to reset X5, X6, X7, and X8 for the getAddr function

        ADD X5, XZR, X0 //base address of A
        ADD X6, XZR, X11 //row i
        ADD X7, XZR, X14 //col k
        ADD X8, X4, XZR //stride

        BL getAddr // returns value in X5 of address of A[i][k]
        LDUR X15, [X5, #0] //load A[i][k] into X15

        ADD X5, XZR, X1 //base address of B
        ADD X6, XZR, X14 //row k
        ADD X7, XZR, X12 //col j
        ADD X8, X4, XZR //stride
        BL getAddr // returns value in X5 of address of B[k][j]
        LDUR X16, [X5, #0] //load B[k][j] into X16

        //multiply A[i][k] and B[k][j] and add to SUM
        MUL X17, X15, X16 //A[i][k] * B[k][j]
        ADD X13, X13, X17 //SUM += A[i][k] * B[k][j]
        ADDI X14, X14, #1 //k++
        B k_iter //repeat for next k

        end_k_iter:
        //store SUM in C[i][j] by passing base address of C, i, j, and stride to getAddr
        ADD X5, XZR, X2 //base address of C
        ADD X6, XZR, X11 //row i
        ADD X7, XZR, X12 //col j
        ADD X8, X4, XZR //stride
        BL getAddr // returns value in X5 of address of C[i][j]

        LDUR X18, [X5, #0] //load current value of C[i][j] into X18
        ADD X18, X18, X13 //C[i][j] += SUM
        STUR X18, [X5, #0] //store new value of C[i][j]
        //if i == j, add SUM to trace
        SUBI XZR, X11, X12 //compare i and j
        B.NE not_diagonal //if i != j, skip adding to trace
        ADD X0, X0, X13 //trace += SUM

        not_diagonal:
        ADDI X12, X12, #1 //j++
        B col_iter //repeat for next j
        end_col_iter:
        ADDI X11, X11, #1 //i++
        B row_iter //repeat for next i
        end_row_iter:
        //reset the used registers for cleanliness
        LDUR X5, [SP, #0]
        LDUR X6, [SP, #8]
        LDUR X7, [SP, #16]
        LDUR X8, [SP, #24]
        ADDI SP, SP, #32
        
        BR LR //return trace in X0

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

        //  Other Registers:
	//  X9: Half of n
	//  X10: Half*stride


        //YOUR CODE STARTS HERE
	
	LSR X9, X1, #1 // Divide n by 2
	ADD X8, X0, XZR // base

	SUBS XZR, X2, XZR // branch to return if quadrant == 0
	B.LE return

	ADD X8, X0, X9 // base + half
	
	SUBIS XZR, X2, #1 // branch to return if quadrant == 1
	B.LE return

	MUL X10, X9, X3 // half*stride
	ADD X8, X0, X10 // base + half*stride

	SUBIS XZR, X2, #2 // branch to return if quadrant == 2
	B.LE return

	ADD X8, X8, X9 // base + half*stride + half
	
	return: 
	BR LR	// branch to back where function was called
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

        //if statement
        SUBS XZR, X3, X4
        B.GT skip //if n <= base, do base case multiplication
        //make sure that the parameters for the basemultiplyAdd function are correct before calling it
        //X4 should have the row stride for the call X5
        //Save current value of X4 in stack
        SUBI SP, SP, #8
        STUR X4, [SP, #0]

        ADD X4, X5, XZR //set X4 to stride

        BL baseMultiplyAdd //else, do base case multiplication for the current block and add to trace
        //reset X4 to the original value
        LDUR X4, [SP, #0]
        //reset stack pointer
        ADDI SP, SP, #8

        skip: 
        ADD X11, XZR, XZR //initialize i to 0
        ADD X12, XZR, XZR//initialize j to 0 (j =0 for A, then j= 1 for B, then j = 2 for C in the recursive calls)
        ADD X13, XZR, XZR //initialize k to 0 (keeps track of the stack used for the adresses)
        
        SUBI SP, SP, #32
        STUR X0, [SP, #0] //save A
        STUR X1, [SP, #8] //save B
        STUR X2, [SP, #16] //save C
        STUR X3, [SP, #24] //save n
        STUR X4, [SP, #32] //save base

        loop:
        SUBI X11, XZR, #4 //compare i to 4
        B.GE end_loop //if i >= 4, end loop
        ADD X0, XZR, X0 //reset A
        ADD X1, XZR, X3 // block size n
        ADD X2, XZR, X11 // block number 0-3
        ADD X3, XZR, X5 // stride
        BL splitOffset //get the offset for the current block 
        SUBI SP, SP, #8
        STUR X8, [SP, #0] //save offset
        ADDI X13, X13, #1 //increment k for stack used
        ADDI X11, X11, #1 // I++
        B loop //repeat for next quadrant

        end_loop:
        ADDI X12, X12, #1 //j++
        //update X0 to the next block
//FOr future reference:
        //not sure about how to access the value store in stack (need to check where SP is pointing)
        SUBIS XZR, X12, #1 //compare j to 1
        B.NE two
        LDUR X0, [SP, #8] //load B
        ADD X11, XZR, XZR //reset i to 0
        B loop
        two:
        SUBIS XZR, X12, #2 //compare j to 2
        B.NE default
        LDUR X0, [SP, #16] //load C
        ADD X11, XZR, XZR //reset i to 0
        B loop
        default:
        //if j > 2, we are done with all the recursive calls and can exit the loop

        ADD X14, XZR, XZR //set trace to 0





        
        //reset the used registers for cleanliness
//Again need to check where SP is actually pointing
        LDUR X0, [SP, #0] //restore A
        LDUR X1, [SP, #8] //restore B
        LDUR X2, [SP, #16] //restore C
        LDUR X3, [SP, #24] //restore n
        LDUR X4, [SP, #32] //restore base
        ADDI SP, SP, #32



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
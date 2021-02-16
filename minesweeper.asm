									// CPSC355 Project Part II
									// By Haipeng Qiao
									// Users can play minesweeper game by typing on the command line ./minesweeper username size

define(name, x19)							// Macros
define(size, x20)
define(coveredNums,x21)
define(startTime, x22)
define(remainingTime, x23)
define(elem_size, x24)
define(struct_size, x25)
define(board_adr, x26)
define(board_offset, x27)
define(score_r, d19)

		.data							// String formats for displaying, receiving and writing data
fmt0:		.asciz	"   "
fmt1:		.asciz	"%2d "
fmt2:		.asciz	" X "
fmt3:		.asciz	" $ "
fmt4:		.asciz	" ! "
fmt5:		.asciz	" @ "
fmt6:		.asciz	" - "
fmt7:		.asciz	" + "
fmt8:		.asciz	"\n"
fmt9:		.asciz	"Wow, 10s are added.\n"
fmt10:		.asciz	"Wow, the score is doubled.\n"
fmt11:		.asciz	"Oh, the score is halved.\n"
fmt12:		.asciz	"Oh, %.2f points are lost.\n"
fmt13:		.asciz	"Wow, %.2f points are added.\n"
fmt14:		.asciz	"Score: %.2f\n"
fmt15:		.asciz	"Time: %ld\n\n"
fmt16:		.asciz	"Enter the cell to uncover or an invalid one to exit the game (row column): "
fmt17:		.asciz	"%d %d"
fmt18:		.asciz	"Congratulations! All cells are uncovered.\n"
fmt19:		.asciz	"Sorry, time is up.\n"
fmt20:		.asciz	"Sorry, the score drops below zero.\n"
fmt21:		.asciz	"Bye, the game is exited.\n"
fmt22:		.asciz	"Error opening the file!"
fmt23:		.asciz	"Error closing the file!"
fmt24:		.asciz	"Name: %5s\nDuration: %4d\nRemaining time: %4d\nScore: %6.2f\n\n"
buf:		.asciz	""

row:		.word	0						// Variables to receive user selected row and column indices
column:		.word	0

locvar1_s = 16
locvar2_s = 24
locvar3_s = 32
locvar4_s = 40
alloc = -(16 + 32) & -16
dealloc = -alloc

pathname:	.asciz	"minesweeper.log"				// File name to write

AT_FDCWD = -100
flags = 02|0100|02000
mode = 0700

fp		.req x29						// Frame pointer
lr		.req x30						// Link Register

		.text
		.balign 4
		.global main
//**********************************************************************//
randomNum:	stp	fp, lr, [sp, alloc]!				// Allocation in stack memory and saving the state of registers
		mov	fp, sp						// Updating FP to the current SP

		str	x0, [fp, locvar1_s]
		str	x1, [fp, locvar2_s]
		str	x2, [fp, locvar3_s]

		bl	rand						// x0 = rand()

		ldr	x9, [fp, locvar1_s]				// x9 = low limit
		ldr	x10, [fp, locvar2_s]
		sub	x10, x10, x9					// x10 = high limit - low limit
		ldr	x11, [fp, locvar3_s]				// x11 = 0(+) or 1(-)

		mov	x12, 1
		b	test0

loop0:		lsl	x12, x12, 1					// x12 = x12 * 2

test0:		cmp	x12, x10
		b.le	loop0

		sub	x12, x12, 1					// x12 = x12 - 1
		and	x0, x0, x12					// x0 = x0 mod x12
		cmp	x0, x10
		b.le	end0
		sub	x0, x0, x10					// x0 = x0 - x10 if x0 > x10

end0:		add	x0, x0, x9					// x0 = x0 + low limit

		cmp	x11, 0
		b.eq	exit0
		mvn	x0, x0

exit0:		ldp	fp, lr, [sp], dealloc				// Restoring the state
		ret							// Returning control to calling code
//**********************************************************************//



//**********************************************************************//
initializeGame:	stp	fp, lr, [sp, alloc]!				// Allocation in stack memory and saving the state of registers
		mov	fp, sp						// Updating FP to the current SP

		mov	x9, 0						// i = 0
		mov	x10, 0						// j = 0
		b	test1

loop1:		madd	board_offset, x9, size, x10
		mul	board_offset, board_offset, struct_size		// board_offset = (i * size + j) * struct_size

		mov	x11, 0
		add	board_offset, board_offset, elem_size
		str	x11, [board_adr, board_offset]			// cell. scoreDoubled = 0
		add	board_offset, board_offset, elem_size
		str	x11, [board_adr, board_offset]			// cell. scoreHalved = 0
		add	board_offset, board_offset, elem_size
		str	x11, [board_adr, board_offset]			// cell. extraTime = 0
		mov	x11, 1
		add	board_offset, board_offset, elem_size
		str	x11, [board_adr, board_offset]			// cell. covered = 1
		mov	x11, 0
		add	board_offset, board_offset, elem_size
		str	x11, [board_adr, board_offset]			// cell. ready = 0

		add	x10, x10, 1					// j++
test2:		cmp	x10, size					// j < size
		b.lt	loop1

		add	x9, x9, 1					// i++
		mov	x10, 0						// j = 0
test1:		cmp	x9, size					// i < size
		b.lt	test2

		mov	x0, 0
		bl	time
		bl	srand						// srand(time(0))

		mov	x3, 5
		udiv	x3, size, x3					// size / 5
		mov	x4, 0						// i = 0

		str	x3, [fp, locvar1_s]
		str	x4, [fp, locvar2_s]
		mov	x5, 3
		mul	x3, x3, x5					// x3 = 3 * size / 5

		b	test3

loop2:		mov	x0, 0
		sub	x1, size, 1
		mov	x2, 0
		bl	randomNum					// j = 0 ~ size-1
		str	x0, [fp, locvar3_s]

		mov	x0, 0
		sub	x1, size, 1
		mov	x2, 0
		bl	randomNum					// k = 0 ~ size-1
		str	x0, [fp, locvar4_s]

		ldr	x6, [fp, locvar3_s]
		ldr	x7, [fp, locvar4_s]

		madd	board_offset, x6, size, x7
		mul	board_offset, board_offset, struct_size		// board_offset = (j * size + k) * struct_size
		mov	x9, 5
		mul	x9, x9, elem_size
		add	x9, x9, board_offset

		ldr	x10, [board_adr, x9]				// x10 = cell.ready

		cmp	x10, 1
		b.eq	loop2

		mov	x11, 1
		str	x11, [board_adr, x9]				// cell.ready = 1

		ldr	x1, [fp, locvar1_s]				// x1 = 1 * size / 5
		mov	x2, 2
		mul	x2, x2, x1					// x2 = 2 * size / 5
		mov	x3, 3
		mul	x3, x3, x1					// x3 = 3 * size / 5
		ldr	x4, [fp, locvar2_s]

		cmp	x4, x1
		b.ge	next0
		mov	x9, 1
		mul	x9, x9, elem_size
		add	x9, x9, board_offset
		mov	x10, 1
		str	x10, [board_adr, x9]				// cell.scoreDoubled = 1 if i is in [0, x1)
		b	end1

next0:		cmp	x4, x2
		b.ge	next1
		mov	x9, 2
		mul	x9, x9, elem_size
		add	x9, x9, board_offset
		mov	x10, 1
		str	x10, [board_adr, x9]				// cell.scoreHalved = 1 if i is in [x1, x2)
		b	end1

next1:		mov	x9, 3
		mul	x9, x9, elem_size
		add	x9, x9, board_offset
		mov	x10, 1
		str	x10, [board_adr, x9]				// cell.extraTime = 1 if i is in [x2, x3)

end1:		add	x4, x4, 1					// i++
		str	x4, [fp, locvar2_s]

test3:		cmp	x4, x3						// i < x3?
		b.lt	loop2

		mul	x3, x1, size
		str	x3, [fp, locvar1_s]				// x3 = size * size / 5
		mov	x4, 0						// i = 0
		str	x4, [fp, locvar2_s]

		b	test4

loop3:		mov	x0, 0
		sub	x1, size, 1
		mov	x2, 0
		bl	randomNum					// j = 0 ~ size-1
		str	x0, [fp, locvar3_s]

		mov	x0, 0
		sub	x1, size, 1
		mov	x2, 0
		bl	randomNum					// k = 0 ~ size-1
		str	x0, [fp, locvar4_s]

		ldr	x6, [fp, locvar3_s]
		ldr	x7, [fp, locvar4_s]

		madd	board_offset, x6, size, x7
		mul	board_offset, board_offset, struct_size		// board_offset = (j * size + k) * struct_size
		mov	x9, 5
		mul	x9, x9, elem_size
		add	x9, x9, board_offset

		ldr	x10, [board_adr, x9]				// x10 = cell.ready

		cmp	x10, 1
		b.eq	loop3

		mov	x0, 1
		mov	x1, 1500
		mov	x2, 1
		bl	randomNum

		scvtf	d0, x0
		mov	x1, 100
		scvtf	d1, x1
		fdiv	d0, d0, d1					// d0 = - (0.01 ~ 15.00)

		ldr	x6, [fp, locvar3_s]
		ldr	x7, [fp, locvar4_s]

		madd	board_offset, x6, size, x7
		mul	board_offset, board_offset, struct_size
		mov	x9, 0
		mul	x9, x9, elem_size
		add	x9, x9, board_offset

		str	d0, [board_adr, x9]				// cell.points = d0

		mov	x9, 5
		mul	x9, x9, elem_size
		add	x9, x9, board_offset
		mov	x10, 1
		str	x10, [board_adr, x9]				// cell.ready = 1

		ldr	x3, [fp, locvar1_s]
		ldr	x4, [fp, locvar2_s]
		add	x4, x4, 1					// i++
		str	x4, [fp, locvar2_s]

test4:		cmp	x4, x3						// i < x3?
		b.lt	loop3

		mov	x3, 0						// i = 0
		mov	x4, 0						// j = 0
		str	x3, [fp, locvar1_s]
		str	x4, [fp, locvar2_s]

		b	test5

loop4:		madd	board_offset, x3, size, x4
		mul	board_offset, board_offset, struct_size		// board_offset = (i * size + j) * struct_size
		mov	x9, 5
		mul	x9, x9, elem_size
		add	x9, x9, board_offset

		ldr	x10, [board_adr, x9]				// cell.ready

		cmp	x10, 0
		b.ne	end2

		mov	x0, 1
		mov	x1, 1500
		mov	x2, 0
		bl	randomNum

		scvtf	d0, x0
		mov	x1, 100
		scvtf	d1, x1
		fdiv	d0, d0, d1					// d0 = (0.01 ~ 15.00)

		ldr	x3, [fp, locvar1_s]
		ldr	x4, [fp, locvar2_s]

		madd	board_offset, x3, size, x4
		mul	board_offset, board_offset, struct_size
		mov	x9, 0
		mul	x9, x9, elem_size
		add	x9, x9, board_offset

		str	d0, [board_adr, x9]				// cell.points = d0

		mov	x9, 5
		mul	x9, x9, elem_size
		add	x9, x9, board_offset
		mov	x10, 1
		str	x10, [board_adr, x9]				// cell.ready = 1

end2:		ldr	x4, [fp, locvar2_s]
		add	x4, x4, 1					// j++
		str	x4, [fp, locvar2_s]

test6:		cmp	x4, size					// j < size?
		b.lt	loop4

		ldr	x3, [fp, locvar1_s]
		add	x3, x3, 1					// i++
		str	x3, [fp, locvar1_s]
		mov	x4, 0						// j = 0
		str	x4, [fp, locvar2_s]

test5:		cmp	x3, size					// i < size?
		b.lt	test6

		ldp	fp, lr, [sp], dealloc				// Restoring the state
		ret							// Returning control to calling code
//**********************************************************************//



//**********************************************************************//
displayGame:	stp	fp, lr, [sp, alloc]!				// Allocation in stack memory and saving the state of registers
		mov	fp, sp						// Updating FP to the current SP

		mov	x3, -1						// i = -1
		str	x3, [fp, locvar1_s]
		mov	x4, -1						// j = -1
		str	x4, [fp, locvar2_s]

		b	test7

loop5:		cmp	x3, -1
		b.eq	next2
		b	next3

next2:		cmp	x4, -1
		b.ne	next4
		adrp	x0, fmt0
		add	x0, x0, :lo12: fmt0
		bl	printf						// print("   ") if i == j == -1
		b	end3

next3:		cmp	x4, -1
		b.ne	next5
		adrp	x0, fmt1
		add	x0, x0, :lo12: fmt1
		mov	x1, x3
		bl	printf						// print(" i ") if i != -1 && j == -1
		b	end3

next4:		adrp	x0, fmt1
		add	x0, x0, :lo12: fmt1
		mov	x1, x4
		bl	printf						// print(" j ") if i == -1 && j != -1
		b	end3

next5:		madd	board_offset, x3, size, x4
		mul	board_offset, board_offset, struct_size
		mov	x9, 4
		mul	x9, x9, elem_size
		add	x9, x9, board_offset

		ldr	x10, [board_adr, x9]

		cmp	x10, 1
		b.ne	next6
		adrp	x0, fmt2
		add	x0, x0, :lo12: fmt2
		bl	printf						// print(" X ") if cell.covered == 1
		b	end3

next6:		mov	x9, 1
		mul	x9, x9, elem_size
		add	x9, x9, board_offset

		ldr	x10, [board_adr, x9]

		cmp	x10, 1
		b.ne	next7
		adrp	x0, fmt3
		add	x0, x0, :lo12: fmt3
		bl	printf						// print(" $ ") if cell.scoreDoubled == 1
		b	end3

next7:		add	x9, x9, elem_size
		ldr	x10, [board_adr, x9]

		cmp	x10, 1
		b.ne	next8
		adrp	x0, fmt4
		add	x0, x0, :lo12: fmt4
		bl	printf						// print(" ! ") if cell.scoreHalved == 1
		b	end3

next8:		add	x9, x9, elem_size
		ldr	x10, [board_adr, x9]

		cmp	x10, 1
		b.ne	next9
		adrp	x0, fmt5
		add	x0, x0, :lo12: fmt5
		bl	printf						// print(" @ ") if cell.extraTime == 1
		b	end3

next9:		ldr	d10, [board_adr, board_offset]
		mov	x11, 0
		scvtf	d11, x11
		fcmp	d10, d11
		b.ge	next10
		adrp	x0, fmt6
		add	x0, x0, :lo12: fmt6
		bl	printf						// print(" - ") if cell.points < 0
		b	end3

next10:		adrp	x0, fmt7
		add	x0, x0, :lo12: fmt7
		bl	printf						// print(" + ") if cell.points > 0

end3:		ldr	x3, [fp, locvar1_s]
		ldr	x4, [fp, locvar2_s]
		add	x4, x4, 1					// j++
		str	x4, [fp, locvar2_s]

test8:		cmp	x4, size					// j < size?
		b.lt	loop5

		adrp	x0, fmt8
		add	x0, x0, :lo12: fmt8
		bl	printf						// print("\n") if finishing one line

		ldr	x3, [fp, locvar1_s]
		add	x3, x3, 1					// i++
		str	x3, [fp, locvar1_s]
		mov	x4, -1						// j = -1
		str	x4, [fp, locvar2_s]

test7:		cmp	x3, size					// i < size?
		b.lt	test8

		ldp	fp, lr, [sp], dealloc				// Restoring the state
		ret							// Returning control to calling code
//**********************************************************************//



//**********************************************************************//
calculateScore:	stp	fp, lr, [sp, -16]!				// Initial allocation of 16 bytes in stack memory and saving the state of registers
		mov	fp, sp						// Updating FP to the current SP

		adr	x1, row
		adr	x2, column
		ldr	w3, [x1]
		sxtw	x3, w3						// x3 = row
		ldr	w4, [x2]
		sxtw	x4, w4						// x4 = column

		madd	board_offset, x3, size, x4
		mul	board_offset, board_offset, struct_size		// board_offset = (row * size + column) * struct_size
		mov	x9, 1
		mul	x9, x9, elem_size
		add	x9, x9, board_offset

		ldr	x10, [board_adr, x9]				// Checking cell.scoreDoubled
		cmp	x10, 1
		b.ne	next15
		fmov	d20, 2.0
		fmul	score_r, score_r, d20				// score *= 2
		adrp	x0, fmt10
		add	x0, x0, :lo12: fmt10
		bl	printf
		b	end6

next15:		add	x9, x9, elem_size
		ldr	x10, [board_adr, x9]				// Checking cell.scoreHalved
		cmp	x10, 1
		b.ne	next16
		fmov	d20, 0.5
		fmul	score_r, score_r, d20				// score *= 0.5
		adrp	x0, fmt11
		add	x0, x0, :lo12: fmt11
		bl	printf
		b	end6

next16:		ldr	d10, [board_adr, board_offset]			// Checking cell.points
		mov	x11, 0
		scvtf	d11, x11
		fcmp	d10, d11
		b.ge	next17
		fadd	score_r, score_r, d10
		fabs	d0, d10						// Add the value and display the absolute value if cell.points < 0
		adrp	x0, fmt12
		add	x0, x0, :lo12: fmt12
		bl	printf
		b	end6

next17:		fadd	score_r, score_r, d10
		fmov	d0, d10						// Add and display the value if cell.points > 0
		adrp	x0, fmt13
		add	x0, x0, :lo12: fmt13
		bl	printf

end6:		ldp	fp, lr, [sp], 16				// Restoring the state
		ret							// Returning control to calling code
//**********************************************************************//



//**********************************************************************//
logScore:	stp	fp, lr, [sp, -16]!				// Initial allocation of 16 bytes in stack memory and saving the state of registers
		mov	fp, sp						// Updating FP to the current SP

		mov	x0, AT_FDCWD					// Current working directory
		adrp	x1, pathname					// Pathname
		add	x1, x1, :lo12: pathname
		mov	x2, flags					// Flags to open with
		mov	x3, mode					// Permissions
		mov	x8, 56						// Open I/O request
		svc	0						// Call system function
		mov	x28, x0						// Save file descriptor to work with

		cmp	x28, 0						// Check if the file opened normally
		b.ge	openok

		adrp	x0, fmt22
		add	x0, x0, :lo12: fmt22
		bl	printf
		mov	x0, -1
		b	end9						// exit(-1) if errors occur

openok:		adrp	x0, buf
		add	x0, x0, :lo12: buf				// x0 saves buffer address
		adrp	x1, fmt24
		add	x1, x1, :lo12: fmt24				// x1 saves the string format address
		mov	x2, name					// x2 saves name

		mov	x3, 60
		mul	x3, x3, size
		mul	x3, x3, size
		mov	x10, 25
		udiv	x3, x3, x10					// x3 saves duration

		mov	x4, remainingTime				// x4 saves remaining time
		fmov	d0, score_r					// d0 saves score

		bl	sprintf						// Writing x1~x4 and d0 into the buffer

		mov	x0, x28						// Writing the file pointed by file descriptor
		adrp	x1, buf
		add	x1, x1, :lo12: buf				// Buffer to write to the file
		mov	x2, 63						// Size of the buffer
		mov	x8, 64						// Write file I/O
		svc	0						// Call system function to write

		mov	x0, x28						// Closing the file pointed by file descriptor
		mov	x8, 57
		svc	0

		cmp	x0, 0						// Check if the file closed normally
		b.eq	end8

		adrp	x0, fmt23
		add	x0, x0, :lo12: fmt23
		bl	printf
		mov	x0, -1
		b	end9						// exit(-1) if errors occur

end8:		mov	x0, 0

end9:		ldp	fp, lr, [sp], 16				// Restoring the state
		ret
//**********************************************************************//



//**********************************************************************//
main:		stp	fp, lr, [sp, -16]!				// Initial allocation of 16 bytes in stack memory and saving the state of registers
		mov	fp, sp						// Updating FP to the current SP

		ldr	name, [x1, 8]					// Load argv[1] into name
		ldr	x0, [x1, 16]					// Load argv[2] into x0
		bl	atoi						// Call atoi in C
		mov	size, x0					// size = (int) argv[2]
		mul	coveredNums, size, size				// coveredNums = size * size
		mov	x9, 60
		mul	remainingTime, coveredNums, x9
		mov	x10, 25
		udiv	remainingTime, remainingTime, x10		// remainingTime = coveredNums * 60 /25

		mov	elem_size, 8
		mov	x11, 6
		mul	struct_size, elem_size, x11			// struct_size = 6 * elem_size
		mov	x12, 0
		scvtf	score_r, x12					// score = 0.00
		mul	x13, coveredNums, struct_size
		sub	sp, sp, x13
		mov	board_adr, sp					// board_adr = sp - coveredNums * struct_size

		bl	initializeGame

loop6:		bl	displayGame

		adrp	x0, fmt14
		add	x0, x0, :lo12: fmt14
		fmov	d0, score_r
		bl	printf						// print score

		adrp	x0, fmt15
		add	x0, x0, :lo12: fmt15
		mov	x1, remainingTime
		bl	printf						// print remaining time

loop7:		adrp	x0, fmt16
		add	x0, x0, :lo12: fmt16
		bl	printf

		adrp	x0, fmt17
		add	x0, x0, :lo12: fmt17
		adr	x1, row
		adr	x2, column
		bl	scanf						// Receiving user selected row and column

		adr	x1, row
		adr	x2, column
		ldr	w3, [x1]
		sxtw	x3, w3						// x3 = row
		ldr	w4, [x2]
		sxtw	x4, w4						// x4 = column

		cmp	x3, 0
		b.lt	exitGame
		cmp	x3, size
		b.ge	exitGame
		cmp	x4, 0
		b.lt	exitGame
		cmp	x4, size
		b.ge	exitGame					// Exit the game if x3 or x4 is not in the valid range

		madd	board_offset, x3, size, x4
		mul	board_offset, board_offset, struct_size		// board_offset = (row * size + column) * struct_size
		mov	x9, 4
		mul	x9, x9, elem_size
		add	x9, x9, board_offset

		ldr	x10, [board_adr, x9]				// cell.covered

		cmp	x10, 0
		b.eq	loop7						// loop until a covered cell is selected

		mul	x11, size, size
		cmp	coveredNums, x11
		b.ne	next11
		mov	x0, 0
		bl	time
		mov	startTime, x0					// startTime = time(NULL) if coveredNums == size * size

next11:		adrp	x0, fmt8
		add	x0, x0, :lo12: fmt8
		bl	printf

		mov	x9, 4
		mul	x9, x9, elem_size
		add	x9, x9, board_offset
		mov	x10, 0
		str	x10, [board_adr, x9]				// cell.covered = 0

		sub	coveredNums, coveredNums, 1			// coveredNums--

		sub	x9, x9, elem_size
		ldr	x10, [board_adr, x9]				// Checking cell.extraTime

		cmp	x10, 1
		b.ne	next12
		add	remainingTime, remainingTime, 10		// remainingTime += 10
		adrp	x0, fmt9
		add	x0, x0, :lo12: fmt9
		bl	printf
		b	end4

next12:		bl	calculateScore					// Updating the score

end4:		mov	x0, 0
		bl	time
		sub	x0, x0, startTime
		sub	remainingTime, remainingTime, x0		// Updating remaining time

		cmp	coveredNums, 0
		b.le	end5
//		cmp	remainingTime, 0
//		b.le	end5
		fcmp	score_r, 0.0
		b.gt	loop6
		mul	x11, size, size
		sub	x11, x11, 1
		cmp	coveredNums, x11
		b.eq	loop6						// while(coveredNums > 0 && remainingTime > 0 && (score_r > 0 || coveredNums == size * size - 1))

end5:		bl	logScore
		cmp	coveredNums, 0
		b.ne	next13
		adrp	x0, fmt18
		add	x0, x0, :lo12: fmt18
		bl	printf
		b	end7

next13:		cmp	remainingTime, 0
		b.gt	next14
		adrp	x0, fmt19
		add	x0, x0, :lo12: fmt19
		bl	printf
		b	end7

next14:		adrp	x0, fmt20
		add	x0, x0, :lo12: fmt20
		bl	printf
		b	end7

exitGame:	adrp	x0, fmt21
		add	x0, x0, :lo12: fmt21
		bl	printf

end7:		mov	x0, 0
		mul	x13, coveredNums, struct_size
		add	sp, sp, x13
		ldp	fp, lr, [sp], 16				// Restoring the state
		ret							// Returning control to calling code
//**********************************************************************//

# File: proj_sw03.s
# Author: Emily Beiser
# Purpose: to model the Collatz Conjecture, find whether a string contains 
# the percent symbol, and model a letterTree. Each task is implemented via
# a function.

.data
NEWLINE:    .asciiz "\n"
SPACE:      .asciiz " "
COLLATZ:    .asciiz "collatz("
PAREN:	    .asciiz ") "
COMPLETED:  .asciiz "completed after "
CALLS:	    .asciiz " calls to collatz_line().\n"
PERCENT:    .asciiz "%"

.text
.globl collatz_line
# prints out the parameter, which is an int
# if the parameter is even, divide it by 2 and print
# repeat until the number becomes odd
collatz_line:
   #prologue
   addiu    $sp, $sp, -24 # allocate stack space -- default of 24 here
   sw       $fp, 0($sp) # save caller’s frame pointer
   sw       $ra, 4($sp) # save return address
   addiu    $fp, $sp, 20 # setup main’s frame pointer
	
   # preserve original $s0 value
   addiu	 $sp, $sp, -4 		# allocate room on the stack for $s0's value 
   sw	 	 $s0, 0($sp)  			# store $s0 on stack
	
   add	 $s0, $zero, $a0		# store parameter in $s0

   # print 1st parameter
   addi 	  $v0, $zero, 1	
   add	  	  $a0, $zero, $s0 		 	 
   syscall  					# print out first parameter
	
#if we fall into the following code, we have an even number
Loop:
   andi  	  $t0, $s0, 1			# check if the number is odd by masking
									# least significant bit 
   bne	    $t0, $zero, isOdd		# if the result is not 0, the number was 					
                                # odd, so we want to jump to isOdd
   sra	  	$s0, $s0, 1			    # divide integer by 2
	
	
   addi 	  $v0, $zero, 4
   la   	  $a0, SPACE
   syscall				# print out " "
	
   addi 	  $v0, $zero, 1	
   add	  	$a0, $zero, $s0 		 	 
   syscall  			# print out integer
		
   j Loop

isOdd:	
   addi 	  $v0, $zero, 4
   la   	  $a0, NEWLINE
   syscall			  # print out "\n"
	
   # save current value into $v0
   add 	  $v0, $zero, $s0

   # restore $s0's values
   lw	     $s0, 0($sp)  # load $s0 back from stack
   addiu	 $sp, $sp, 4   
	
   #epilogue 
   lw 	   $ra, 4($sp)
   lw 	   $fp, 0($sp)
   addiu 	 $sp, $sp, 24
   jr	     $ra

# models the Collatz Conjecture; calls upon collatz_line() to accomplish this.
.globl collatz
collatz:
   # prologue
   addiu    $sp, $sp, -24 # allocate stack space -- default of 24 here
   sw       $fp, 0($sp)   # save caller’s frame pointer
   sw       $ra, 4($sp)   # save return address
   addiu    $fp, $sp, 20  # setup main’s frame pointer
      	
   # preserve original $sX values
   addiu	 $sp, $sp, -20 # allocate room on the stack for $s0's value 
   sw	     $s3, 0($sp)   # store $s3 on stack
   sw	     $s1, 4($sp)   # store $s3 on stack
   sw	     $s4, 8($sp)   # store $s4 on stack
   sw	     $s5, 12($sp)  # store $s5 on stack
   sw	     $s2, 16($sp)  # store $s2 on stack
	
   # set values 
   add	   $s3, $zero, $a0	# s3 == val
   add	   $s1, $zero, $s3	# s1 == cur

   add     $s4, $zero, $zero	# set $t0 aka calls to 0
   addi    $s5, $zero, 1		  # set $t1 to 1, will be loop invariant	
	
   add	  $a0, $zero, $s1	    # store 1st parameter in $s1
   jal    collatz_line		    # jump and link collatz_line
   add	  $s1, $zero, $v0	    # store collatz_line output in s1 (cur)
	
Loop2:
   beq	  $s1, $s5, Print	    # if cur == 1, exit loop and print
   sll	  $s2, $s1, 1	 	      # multiply cur by 2 + store in $s2
   add	  $s1, $s2, $s1 	    # add original to $s2 to make it x3
   addi   $s1, $s1, 1	        # add 1 to $s1*3
   add	  $a0, $zero, $s1	    # input $s2 to collatz_line() call
   jal	  collatz_line		    # make call to collatz_line()
   add	  $s1, $zero, $v0	    # set cur to collatz_line's output, again
   addi   $s4, $s4, 1		      # increment calls
			
   j Loop2

Print:
   addi 	  $v0, $zero, 4
   la   	  $a0, COLLATZ
   syscall				# print out collatz message
	
   addi 	  $v0, $zero, 1
   add   	  $a0, $zero, $s3
   syscall				# print out val
	
   addi 	  $v0, $zero, 4
   la   	  $a0, PAREN
   syscall				# print out closing parenthesis
	
   addi 	  $v0, $zero, 4
   la   	  $a0, COMPLETED
   syscall				# print out completed message
	
   addi 	  $v0, $zero, 1
   add   	  $a0, $zero, $s4
   syscall				# print out calls
	
   addi 	  $v0, $zero, 4
   la   	  $a0, CALLS
   syscall				# print out calls message	

   addi      $v0, $zero, 4
   la        $a0, NEWLINE
   syscall 

   # restore $sX's values
   lw        $s2, 16($sp)
   lw   	   $s5, 12($sp)  # load back from stack
   lw	 	     $s4, 8($sp)
   lw	 	     $s1, 4($sp)
   lw   	   $s3, 0($sp)   
   addiu     $sp, $sp, 20

   #epilogue
   lw        $ra, 4($sp)
   lw        $fp, 0($sp)
   addiu     $sp, $sp, 24
   jr        $ra

# this function takes a string as a parameter and returns an int; it returns
# the index of the string (aka array of chars) that the percent symbol "%"
# was found in. if it was not found, then we return -1.
.globl percentSearch
percentSearch:
   #prologue
   addiu      $sp, $sp, -24
   sw 	  	  $fp, 0($sp)
   sw 	  	  $ra, 4($sp)
   addiu 	    $fp, $sp, 20

   addiu     $sp, $sp, -8      # allocate room on the stack for $s0's value 
   sw        $s5, 0($sp)       # store $s3 on stack
   sw	  	   $s6, 4($sp)

   la	  	   $s5, PERCENT
   lb	  	   $s5, 0($s5) 		# "%" is stored in $s5
	
   add	  	 $t1, $zero, $zero	# set index to 0
	
   add	  	 $s6, $zero, $a0	# store parameter in $s6
   
# this loop will iterate through the inputted string to find whether there is
# is a percent symbol or not. if there is, we will return 0, if not, -1	
Loop3:
   lb	  	 $t0, 0($s6)			        # load byte at first index into $s6
   beq	   $t0, $s5, returnIndex		# if this element == "%", exit loop 
	                                  # and print index. if we hit a 0,
   beq	   $t0, $zero, returnNegOne	# or null char, we've reached the 
							  			              # end of str without seeing a "%"
   addi	   $t1, $t1, 1				      # increment index
   addi	   $s6, $s6, 1				      # traverse to next index
   j Loop3								          # loop again

returnIndex:
   add	    $v0, $zero, $t1				  # store index as return value
   j done
	
returnNegOne:
   addi 	  $v0, $zero, -1		      # return -1
				
done:
   lw       $s6, 4($sp)
   lw       $s5, 0($sp)  			       # load $s0 back from stack
   addiu    $sp, $sp, 8

   #epilogue 
   lw 	  	$ra, 4($sp)
   lw 	  	$fp, 0($sp)
   addiu 	  $sp, $sp, 24
   jr	      $ra
	
.globl letterTree
letterTree:
   #prologue
   addiu     $sp, $sp, -24
   sw 	  	 $fp, 0($sp)
   sw 	  	 $ra, 4($sp)
   addiu 	   $fp, $sp, 20
	
   add 	      $t0, $zero, $zero	# set count to zero
   add 	      $t1, $zero, $zero	# set pos to zero
   add	  	  $t4, $zero, $zero	# i == 0 (for inner loop)
   add	  	  $t9, $zero, $a0  	# $t9 == step, parameter
	
Loop4:
   addiu	    $sp, $sp, -8
   sw	  	    $t0, 4($sp)
   sw	  	    $t1, 0($sp)
	
   add	  	  $a0, $t1, $zero 	 # pass pos as parameter for func call
   jal	  	  getNextLetter		 # call getNextLetter
   add	  	  $t3, $zero, $v0	 # store c in $t3
	
   lw	  	    $t1, 0($sp)
   lw	  	    $t0, 4($sp)
   addiu	    $sp, $sp, 8
	
   beq	  	  $t3, $zero, Done	 # break if c == '\0' 
   add	  	  $t4, $zero, $zero	 # reset $t5

innerLoop:
   slt	  	  $t5, $t0, $t4 	       # $t5 == 1 if i > count (!<=)
   bne	  	  $t5, $zero, exitInner	 # exit if count < i
	
   addi 	    $v0, $zero, 11
   add   	    $a0, $t3, $zero
   syscall				      # print out c
	
   addi	      $t4, $t4, 1		    # increment i
   j innerLoop
	
exitInner:
  addi 	      $v0, $zero, 4
  la   	      $a0, NEWLINE		  # print a newline
  syscall				
	
   addi	      $t0, $t0, 1		    # increment count 
   add	      $t1, $t1, $t9	    # pos += step   
	
   j Loop4	
	
Done:
   add	  	  $v0, $zero, $t1   # store pos in return value
   #epilogue 
   lw 	  	  $ra, 4($sp)
   lw 	  	  $fp, 0($sp)
   addiu 	    $sp, $sp, 24
   jr	        $ra

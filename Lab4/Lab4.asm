##########################################################################
# Created by:  Yasar, Sameer
#              syasar
#              2 March 2020
#
# Assignment:  Lab 4: Synatx Checker
#              CSE 012, Computer Systems and Assembly Language
#              UC Santa Cruz, Winter 2020
# 
# Description: This program checks the syntax of a text file.
# 
# Notes:       This program is intended to be run from the MARS IDE.
##########################################################################
#Pseudocode:
#This is a macro for printing a newline.
.macro newLinePrint
	li $v0 4
	la $a0 newLine
	syscall
.end_macro	
#Pseudocode:
#This is a macro to push the data of register onto the stack.
.macro push(%reg)
	subi $sp $sp 4
	sw %reg 0($sp)
.end_macro
#Pseudocode:
#This is a macro to pop data off the stack and put it into a register.
.macro pop(%reg)
	lw %reg 0($sp)
	addi $sp $sp 4
.end_macro
#Pseudocode:
#These are strings that will be called later into the program. The
#buffer is an allocated space of 128 bits that will hold segments
#of the text file that is read.
.data
	enteredFile: .asciiz "You entered the file:\n"
	successOne: .asciiz "SUCCESS: There are "
	successTwo: .asciiz " pairs of braces.\n"
	newLine: .asciiz "\n"
	fileError: .asciiz "ERROR: Invalid program argument."
	stackError: .asciiz "ERROR - Brace(s) still on stack: "
	braceError1: .asciiz "ERROR - There is a brace mismatch: "
	braceError2: .asciiz " at index "
	space: .asciiz " "
	buffer: .space 128

.text
#Pseudocode:
#The file entered file prints that the user has inputted a file
#and its name. Then it goes onto store the file name in register
#$s0 and loads the index of the file name in $t1.
	fileEntered:
		li $v0 4
		la $a0 enteredFile
		syscall
		
		lw $a0 ($a1)
		li $v0 4
		syscall
		
		newLinePrint
		newLinePrint
		
		lw $s0 ($a1) #$s0 - file name
		li $t1 0 #$t1 - name index
#Pseudocode:
#The fileNameCharacterCheck labels will load the first character
#of the file name and check to see if it is only from the alphabet.		
	fileNameCharacterCheck1:
		lb $t4 0($s0)
		blt $t4 'A' nameError
		bgt $t4 'Z' firstCharacterCheck2
		
		j fileLengthCheck
		
	firstCharacterCheck2:
		blt $t4 'a' nameError
		bgt $t4 'z' nameError
#Pseudocode:
#The fileLengthCheck label will check if the loaded character is
#a null terminator (end of name) and then go into the maxLength label.
#If not, it will increment the index as well as the character to be 
#loaded.		
	fileLengthCheck:	
		beqz $t4 maxLength
		addi $t1 $t1 1
		addi $s0 $s0 1
		lb $t4 0($s0)
		
		j fileNameCharacterCheck3		
#Pseudocode:
#The fileNameCharacterCheck3 label will check to see if the other
#characters in the file name is only alphanumeric or an underscore
#or period.			
	fileNameCharacterCheck3:
		beqz $t4 maxLength
		beq $t4 '_' fileLengthCheck
		beq $t4 '.' fileLengthCheck
		blt $t4 '0' nameError
		bgt $t4 '9' fileNameCharacterCheck1
		
		j fileLengthCheck		
#Pseudocode:
#The maxLength label will check the index of the last character
#of the file name and produce an error message if it is greater
#than 20 characters.						
	maxLength:
		bgt $t1 20 nameError
#Pseudocode:
#The openFile label will move the file name into $s0 and open
#the using its name. It will then store the file descriptor 
#into register $s1 and set $t1 to be the index for the
#overall text in the file.		
	openFile:
		lw $s0 ($a1)
	
		li $v0 13
		la $a0 ($s0)
		li $a1 0
		li $a2 0
		syscall
		move $s1 $v0 #$s1 - file descriptor
		
		li $t1 0 #$t1 - text file index
#Pseudocode:
#The readFile label will read the file and store 127
#characters from it into the allocated buffer. When
#looped back to the readFile label, it will then 
#read the next 127 characters if there were more
#text to read.		
	readFile:
		li $v0 14
		move $a0 $s1
		la $a1 buffer
		li $a2 127
		syscall
#Pseudocode:
#The bufferStoring label stores the buffer address
#into the $s2 register as well as sets the buffer
#index to 0 in register $t8. It will also check if
#the loaded character is an opening bracket.			
	bufferStoring:
		la $s2 buffer #$s2 - buffer address
		li $t8 0 #$t8 - buffer index
		
		beq $t2 '[' bracketIndexI
		beq $t2 '{' curlyBracketIndexI
		beq $t2 '(' paranthesisIndexI
#Pseudocode:
#The bufferI label will iterate through the buffer
#to see for opening braces or brace mismatches and 
#then send them to the corresponding label. If the
#loaded character is a null terminator, the program
#will jump to the bufferEnd label. If it is the 
#last character in the buffer and not a null
#terminator, the program will jump to the 
#bufferReset labels.		
	bufferI:
		lb $t2 0($s2)
		beqz $t2 bufferEnd
		beq $t2 '[' bracketIndexPush
		beq $t2 '{' curlyBracketIndexPush
		beq $t2 '(' paranthesisIndexPush
		beq $t2 ']' braceMismatch1
		beq $t2 '}' braceMismatch1
		beq $t2 ')' braceMismatch1
		
		beq $t8 126 bufferReset1
		
		addi $t1 $t1 1
		addi $s2 $s2 1
		addi $t8 $t8 1
		
		j bufferI
#Pseudocode:
#The bufferReset labels will iterate through the
#buffer, filling it with null terminators. When
#the last character in the buffer is changed, it
#will then jump back to the readFile label to 
#read the next 127 characters. It will also 
#increment the index to maintain continuity.		
	bufferReset1:
		li $t9 0 #$t9 - index for buffer reset
		
		addi $t1 $t1 1
		
		j bufferReset2
		
	bufferReset2:
		beq $t9 126 readFile
		
		sb $0 0($s2)
		
		addi $t9 $t9 1
		addi $s2 $s2 1
		
		j bufferReset2  
#Pseudocode:
#The Push labels for their corresponding braces
#will store the type of brace and its index onto
#the stack. It will also keep track of how many
#braces are in the stack by incrementing $s5.
#If the brace was the last character in the 
#buffer, it will jump to the bufferReset labels.	
	bracketIndexPush:
		push($t2) #storing character and its index in stack
		push($t1)
		addi $s5 $s5 1 #$s5 - number of characters and their indices in the stack
	
		beq $t8 126 bufferReset1		
						
		addi $t1 $t1 1
		addi $t8 $t8 1
		addi $s2 $s2 1
		
		j bracketIndexI
#Pseudocode:
#The IndexI labels for their corresponding braces
#will be jumped to if an opening brace was pushed
#into the stack. It will then look for its 
#respective closing braces to form a pair. It will
#also look for mismatches or another opening brace
#to push into the stack. If the loaded character
#was the last in the buffer, it will jump to the 
#bufferReset labels.	
	bracketIndexI:
		lb $t2 0($s2)
		beqz $t2 bufferEnd
		beq $t2 '}' braceMismatch2
		beq $t2 ')' braceMismatch2
		beq $t2 ']' bracketIndexPop
		beq $t2 '[' bracketIndexPush
		beq $t2 '{' curlyBracketIndexPush
		beq $t2 '(' paranthesisIndexPush
		
		beq $t8 126 bufferReset1
		
		addi $t1 $t1 1
		addi $t8 $t8 1
		addi $s2 $s2 1
		
		j bracketIndexI
#Pseudocode:
#The IndexPop labels of their corresponding
#braces will be jumped to if the IndexI
#iterates through the buffer and find their
#respective closing brace. It will pop the
#opening brace out of the stack, decrement
#the number of braces in the stack in $s5,
#and increment the number of pairs of braces
#in $s4. It will then pop the previous brace
#from the stack to see if it needs to find
#a closing brace from a previously pushed outer
#brace. It will push it back onto the stack and
#jump to a certain IndexI label if there was a 
#brace. If not, it will jump back to the 
#bufferI label and iterate through the buffer
#there.		
	bracketIndexPop:
		pop($s6)
		pop($s7)
		subi $s5 $s5 1
		
		beq $t8 126 bufferReset1		
						
		addi $t1 $t1 1
		addi $t8 $t8 1
		addi $s2 $s2 1
		addi $s4 $s4 1 #s4 - number of pairs of braces
		
		pop($s6)
		pop($s7)
		la $t5 ($s7)
		push($s7)
		push($s6)
		
		beq $t5 '[' bracketIndexI
		beq $t5 '{' curlyBracketIndexI
		beq $t5 '(' paranthesisIndexI
		
		j bufferI
		
	curlyBracketIndexPush:
		push($t2) #storing character and its index in stack
		push($t1)
		addi $s5 $s5 1
		
		beq $t8 126 bufferReset1		
						
		addi $t1 $t1 1
		addi $t8 $t8 1
		addi $s2 $s2 1
		
		j curlyBracketIndexI
		
	curlyBracketIndexI:
		lb $t2 0($s2)
		beqz $t2 bufferEnd
		beq $t2 ']' braceMismatch2
		beq $t2 ')' braceMismatch2
		beq $t2 '}' curlyBracketIndexPop
		beq $t2 '[' bracketIndexPush
		beq $t2 '{' curlyBracketIndexPush
		beq $t2 '(' paranthesisIndexPush
		
		beq $t8 126 bufferReset1
		
		addi $t1 $t1 1
		addi $t8 $t8 1
		addi $s2 $s2 1
		
		j curlyBracketIndexI
		
	curlyBracketIndexPop:
		pop($s6)
		pop($s7)
		subi $s5 $s5 1
		
		beq $t8 126 bufferReset1		
						
		addi $t1 $t1 1
		addi $t8 $t8 1
		addi $s2 $s2 1
		addi $s4 $s4 1
		
		pop($s6)
		pop($s7)
		la $t5 ($s7)
		push($s7)
		push($s6)
		
		beq $t5 '[' bracketIndexI
		beq $t5 '{' curlyBracketIndexI
		beq $t5 '(' paranthesisIndexI
		
		j bufferI
		
	paranthesisIndexPush:
		push($t2) #storing character and its index in stack
		push($t1)
		addi $s5 $s5 1
		
		beq $t8 126 bufferReset1		
		
		addi $t1 $t1 1
		addi $t8 $t8 1
		addi $s2 $s2 1
		
		j paranthesisIndexI
		
	paranthesisIndexI:
		lb $t2 0($s2)
		beqz $t2 bufferEnd
		beq $t2 '}' braceMismatch2
		beq $t2 ']' braceMismatch2
		beq $t2 ')' paranthesisIndexPop
		beq $t2 '[' bracketIndexPush
		beq $t2 '{' curlyBracketIndexPush
		beq $t2 '(' paranthesisIndexPush
		
		beq $t8 126 bufferReset1
		
		addi $t1 $t1 1
		addi $t8 $t8 1
		addi $s2 $s2 1
		
		j paranthesisIndexI
		
	paranthesisIndexPop:
		pop($s6)
		pop($s7)
		subi $s5 $s5 1
		beq $t8 126 bufferReset1
		
		addi $t1 $t1 1
		addi $t8 $t8 1
		addi $s2 $s2 1
		addi $s4 $s4 1
		
		pop($s6)
		pop($s7)
		la $t5 ($s7)
		push($s7)
		push($s6)
		
		beq $t5 '[' bracketIndexI
		beq $t5 '{' curlyBracketIndexI
		beq $t5 '(' paranthesisIndexI
		
		j bufferI
#Pseudocode:
#The braceMismatch1 label will be jumped to
#if a closing brace is missing its respective
#opening brace. It will print the error message,
#the type of brace, and its index in the text
#file. It will then jump to the exit label.								
	braceMismatch1:
		li $v0 4
		la $a0 braceError1
		syscall
		
		li $v0 11
		la $a0 ($t2)
		syscall
		
		li $v0 4
		la $a0 braceError2
		syscall
		
		li $v0 1
		la $a0 ($t1)
		syscall
		
		newLinePrint
		
		j exit
#Pseudocode:
#The braceMismatch2 label will be jumped to if 
#a closing brace ends up being where another type
#of closing brace should be for a previously
#pushed opening brace. It will print the error
#message and the original opening brace
#and its index popped from the stack. It will
#then print the incorrect brace and its index.
#The label will then jump to the exit label.	
	braceMismatch2:
		li $v0 4
		la $a0 braceError1
		syscall
		
		pop($s6)
		pop($s7)
		
		li $v0 11
		la $a0 ($s7)
		syscall
		
		li $v0 4
		la $a0 braceError2
		syscall
		
		li $v0 1
		la $a0 ($s6)
		syscall
		
		li $v0 4
		la $a0 space
		syscall
		
		li $v0 11
		la $a0 ($t2)
		syscall
		
		li $v0 4
		la $a0 braceError2
		syscall
		
		li $v0 1
		la $a0 ($t1)
		syscall
		
		newLinePrint
		
		j exit  
#Pseudocode:
#If the name of the file was greater than 20
#characters, it will print an error message
#saying that there was an invalid program
#argument. It will then jump to the exit
#label.		
	nameError: 	
		li $v0 4
		la $a0 fileError
		syscall
		
		newLinePrint
		
		j exit
#Pseudocode:
#If the buffer has reached the last
#character of the text file, it will check
#to see if there are braces still in the
#stack. If so, it will move to the 
#bracketLeftover labels. If not, it will
#jump to the successExit label.	
	bufferEnd:
		beqz $s5 successExit	
#Pseudocode:
#The bracketLeftover labels will print an
#error message and then loop until it is 
#done printing out all the leftover braces
#in the stack using $s5. When the loop is 
#done, it will jump to the exitNewLine
#label.		
	bracketLeftover1:			
		li $v0 4
		la $a0 stackError
		syscall
		
	bracketLeftover2:
		beqz $s5 exitNewLine
		
		pop($s6)
		pop($s7)
		
		li $v0 11
		la $a0 ($s7)
		syscall
		
		subi $s5 $s5 1
		
		j bracketLeftover2
#Pseudocode:
#The successExit label will be jumped to 
#if there are no brace mismatches and no
#leftover braces in the stack. It will 
#print the success message and the number
#of pairs of braces kept track in $s4.		
	successExit:
		li $v0 4
		la $a0 successOne
		syscall
		
		li $v0 1
		la $a0 ($s4)
		syscall
		
		li $v0 4
		la $a0 successTwo
		syscall
		
		j exit
#Pseudocode:
#The exitNewLine label will print a 
#newline when jumped to. It will then
#jump to the exit label.		
	exitNewLine:
		newLinePrint
		
		j exit
#Pseudocode:
#The exit label will close the file that
#was opened in the beginning of the program
#and then exit the program.		
	exit:
		li $v0 16
		move $a0 $s1
		syscall

		li $v0 10
		syscall
		

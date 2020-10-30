##########################################################################
# Created by:  Yasar, Sameer
#              syasar
#              19 February 2020
#
# Assignment:  Lab 3: ASCII-risks (Asterisks)
#              CSE 012, Computer Systems and Assembly Language
#              UC Santa Cruz, Winter 2020
# 
# Description: This program prints a pyramid consisting of numbers and asterisks
#	       with a height inputted by the user.
# 
# Notes:       This program is intended to be run from the MARS IDE.
##########################################################################
#Pseudocode: 
#These are strings that will be called to be printed later in the program.
.data
    prompt: .asciiz "Enter the height of the trinagle (must be greater than 0): "
    invalidEntry: .asciiz "Invalid entry!\n"
    newline: .asciiz "\n"  
.text
#Pseudocode: 
#The inputPrompt label consists of asking the user to input a number greater than 0 for the height
#of the triangle. If the input, which is stored in $t0, is less than or equal to 0, the program will
#jump to the invalid label. This will tell the user that their input was invalid and then jump back to
#the inputPrompt label, asking them for an input again. If the input is greater than 0, the code will
#subtract 1 from the user input($t0) and store it in $t1, which will become the tab range used in the
#tab label. It will also set the number range, stored in register $t4, to 1 so each row has the right
#amount of numbers printed. The code will then move on to the treeLoop label.
    inputPrompt:
        li $v0 4 #loads the prompt for the height of the triangle
        la $a0 prompt
        syscall
        
        li $v0 5 #reads the integer and moves it into register $t0
        syscall 
        move $t0 $v0
        
        sle $s0 $t0 $zero #if input is less than or equal to 0, $s0 is set to 1 and skips to invalid label
        ble $t0 1 invalid
      
        subi $t1 $t0 1 #$t1 - tab range
        #$t2 - number
        #$t3 - outer loop
        addi $t4 $t4 1 #$t4 - number range        
#Pseudocode:
#The pyramidLoop label is the outer loop that will be repeated as each row is finished printing. The tab loop,
#stored in $t5, and the number loop, stored in $t6, is reset to 0 after each finished printing of a row
#so that those loops can restart for the next row to be printed.  
    pyramidLoop:    
        move $t5 $0 #$t5 - tab loop
        move $t6 $0 #$t6 - number loop
#Pseudocode: 
#The tab label firsts checks to see if the tab loop has iterated less times than the tab range. If not, 
#the program will jump to the numbers label, signifying that enough tabs are printed. If the loop has iterated
#less times than the range, the program will then go on to print a tab and increment $t5, the tab loop. The
#program will then check again if the loop has iterated less times than the range. If so, it will loop the
#tab label again. If not, the tab range will be decremented to print one less tab for the next row and then
#move on to the numbers label.             
        tab: 
            slt $s2 $t5 $t1 #if tab loop is iterated less times than the tab range, $s2 is set to 1 and continues the lab label
            beq $s2 $0 numbers #if tab loop is iterated more or equal times to the tab range, $s2 is set to 0 and jumps to numbers label
            
            li $a0 9 #prints a tab
            li $v0 11
            syscall
            
            addi $t5 $t5 1 #icrements tab loop for every tab printed
            
            slt $s2 $t5 $t1 #if tab loop is less than tab range, $s2 is set to 1 and loops back to the top of the tab label
            beq $s2 1 tab #if tab loop is greater than or equal to the tab range, $s2 is set to 0 and continues to numbers label
            
            subi $t1 $t1 1 #tab range is decremented for next row to print one less tab
#Pseudocode:
#The numbers label will first increment register $t2, which will be the number printed in the row. Then
#it will print the value of $t2 at the time and increment $t6, the number of iterations for the number
#loop. It will then check to see if the number loop has iterated the same amount of times as the range
#of the loop, stored in $t4. This signifies the end of the row, and if it is the case, then the program
#will jump to the numbersEnd label. If it is not the end of the row, the program will print an asterisk
#between two tabs. The program will then continue to the numbersEnd label.      	
      	numbers:
            addi $t2 $t2 1 #increments number that will be printed 
            
            li $v0 1 #prints number
            move $a0 $t2
            syscall
            
            addi $t6 $t6 1 #increments number loop for evert number printed
            
            seq $s4 $t6 $t4 #if number loop is equal to number range (end of row), $s4 is set to 1 and jumps to numbersEnd label
            beq $s4 1 numbersEnd #if number loop is not equal to number range, $s4 is set to 0 and continues to print tabs and asterisks
        
            li $a0 9 #prints a tab
            li $v0 11
            syscall
            
            li $a0 42 #prints an asterisk
            li $v0 11
            syscall
            
            li $a0 9 #prints another tab
            li $v0 11
            syscall 
#Pseudocode:
#The numbersEnd label will check if $t6 is less than $t4, or that the number loop has iterated less
#than the number range. If so, it will jump back to the numbers label to print more numbers;
#if not, the program will continue to the endLine label.l            
        numbersEnd:    
            slt $s3 $t6 $t4 #if number loop is less than number range, $s3 is set to 1 and jumps back to numbers label
            beq $s3 1 numbers #if number loop is equal or greater than number range, $s3 is set to 0 and continues to the endLine label
#Pseudocode:
#The endLine label will print the newline string to either start a new row or create a newline at the
#end of the pyramid. It will then increment the counter($t3) for the outerloop(pyramidLoop) as well as the
#number range($t4) so that the program prints an extra number each row. It will then check if the outerloop
#has iterated and printed rows less than the requested user input, which was stored in register $t0. If so,
#the program will jump back to the pyramidLoop to print the next row. If not, the program will continue to 
#the exit label.       
        endLine:
            li $v0 4 #calls the newline string and prints a newline
            la $a0 newline
            syscall 
            
            addi $t3 $t3 1 #increments the outerloop for every row printed
            addi $t4 $t4 1 #icrements the number range so each row prints one more number than the row prior
            
            slt $s1 $t3 $t0 #if outerloop is less than the inputed number of rows, $s1 is set to 1 and jumps to restart the entire loop
            beq $s1 1 pyramidLoop #if outerloop is equal to or greater than the inputed number of rows, $s1 is set to 0 and continues to exit label
#Pseudocode:
#The exit label will end the program.
    exit: 
        li $v0 10 #ends the program
        syscall 
#Pseudocode:
#The invalid label will be jumped to by the inputPrompt label if the user inputted an invalid
#height. It will print the invalidEntry string and jump back to the inputPrompt label to
#ask the user for an input again.        
    invalid:
        li $v0 4 #if $s0 is 1, will print invalidEntry string
        la $a0 invalidEntry
        syscall
        
        j inputPrompt #jumps back to the inputPrompt label to prompt user again  

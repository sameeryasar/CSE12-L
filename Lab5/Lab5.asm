##########################################################################
# Created by:  Yasar, Sameer
#              syasar
#              2 March 2020
#
# Assignment:  Lab 5: Functions and Graphs
#              CSE 012, Computer Systems and Assembly Language
#              UC Santa Cruz, Winter 2020
# 
# Description: This program will use functions to perform graphic 
#	       operations on a display.
# 
# Notes:       This program is intended to be run from the MARS IDE.
###########################################################################
#Pseudocode:
#Macro that stores the value in %reg on the stack 
#and moves the stack pointer.
.macro push(%reg)
subi $sp $sp 4
sw %reg 0($sp)
.end_macro 
#Pseudocode:
#Macro takes the value on the top of the stack and 
#loads it into %reg then moves the stack pointer.
.macro pop(%reg)
lw %reg 0($sp)
addi $sp $sp 4
.end_macro
#Pseudocode:
#Macro that takes as input coordinates in the format
#(0x00XX00YY) and returns 0x000000XX in %x and 
#returns 0x000000YY in %y
.macro getCoordinates(%input %x %y)
andi %y %input 0x000000ff
andi %x %input 0x00ff0000
srl %x %x 16
.end_macro
#Pseudocode:
# Macro that takes Coordinates in (%x,%y) where
# %x = 0x000000XX and %y= 0x000000YY and
# returns %output = (0x00XX00YY)
.macro formatCoordinates(%output %x %y)
sll %x %x 16
add %output %x %y
srl %x %x 16
.end_macro 
#Pseudocode:
#Origin of bitmap display is saved in
#originAddress label and last coordinate
#in display is saved in endAddress label.
.data
originAddress: .word 0xFFFF0000
endAddress: .word 0xFFFFFFFC
.text
j done
    
    done: nop
    li $v0 10 
    syscall
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Subroutines defined below
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#*****************************************************
# clear_bitmap:
#  Given a clor in $a0, sets all pixels in the display to
#  that color.	
#-----------------------------------------------------
# $a0 =  color of pixel
#*****************************************************
#Pseudocode:
#Loops through entire MMIO segment storing color in $a0
#and ends when endAddress has been recently colored.
#$s0, the register where the origin is loaded, is 
#incremented by 4 to move on to next pixel.
clear_bitmap: nop
	push($a0)
	push($s0)
	push($s1)
	push($ra)
	lw $s0 originAddress
	lw $s1 endAddress
	
	clear_bitmap_loop:	
		sw $a0 ($s0)
		beq $s0 $s1 clear_bitmap_end
		addi $s0 $s0 4
		j clear_bitmap_loop
	
	clear_bitmap_end:
		pop($ra)
		pop($s1)
		pop($s0)
		pop($a0)
		
	jr $ra	
#*****************************************************
# draw_pixel:
#  Given a coordinate in $a0, sets corresponding value
#  in memory to the color given by $a1
#  [(row * row_size) + column] to locate the correct pixel to color
#-----------------------------------------------------
# $a0 = coordinates of pixel in format (0x00XX00YY)
# $a1 = color of pixel
#*****************************************************
#Pseudocode:
#Draw_pixel function seperates coordinates given in $a0
#and calculates its position in the MMIO to then store
#the color loaded in $a1.
draw_pixel: nop
	push($a0)
	push($a1)
	push($s0)
	push($t0)
	push($t1)
	push($t2)
	push($ra)	
	lw $s0 originAddress
	
	getCoordinates($a0 $t0 $t1)
		mul $t2 $t1 128
		add $t2 $t2 $t0
		mul $t2 $t2 4
		add $s0 $s0 $t2
		sw $a1 ($s0)
	
	pop($ra)
	pop($t2)
	pop($t1)
	pop($t0)
	pop($s0)
	pop($a1)
	pop($a0)
	  	  
	jr $ra
#*****************************************************
# get_pixel:
#  Given a coordinate, returns the color of that pixel	
#-----------------------------------------------------
# $a0 = coordinates of pixel in format (0x00XX00YY)
# returns pixel color in $v0	
#*****************************************************
#Pseudocode:
#get_pixel function seperates coordinates given in $a0
#and calculates its position in the MMIO. It then loads 
#the color currently in that part of memory into $v0.
get_pixel: nop
	push($a0)
	push($a1)
	push($s0)
	push($t0)
	push($t1)
	push($t2)
	push($ra)
	lw $s0 originAddress
	
	getCoordinates($a0 $t0 $t1)
	mul $t2 $t1 128
	add $t2 $t2 $t0
	mul $t2 $t2 4
	add $s0 $s0 $t2
	lw $v0 ($s0)
	
	pop($ra)
	pop($t2)
	pop($t1)
	pop($t0)
	pop($s0)
	pop($a1)
	pop($a0)
	
	jr $ra
#***********************************************
# draw_line:
#  Given two coordinates, draws a line between them 
#  using Bresenham's incremental error line algorithm	
#-----------------------------------------------------
# 	Bresenham's line algorithm (incremental error)
# plotLine(int x0, int y0, int x1, int y1)
#    dx =  abs(x1-x0);
#    sx = x0<x1 ? 1 : -1;
#    dy = -abs(y1-y0);
#    sy = y0<y1 ? 1 : -1;
#    err = dx+dy;  /* error value e_xy */
#    while (true)   /* loop */
#        plot(x0, y0);
#        if (x0==x1 && y0==y1) break;
#        e2 = 2*err;
#        if (e2 >= dy) 
#           err += dy; /* e_xy+e_x > 0 */
#           x0 += sx;
#        end if
#        if (e2 <= dx) /* e_xy+e_y < 0 */
#           err += dx;
#           y0 += sy;
#        end if
#   end while
#-----------------------------------------------------
# $a0 = first coordinate (x0,y0) format: (0x00XX00YY)
# $a1 = second coordinate (x1,y1) format: (0x00XX00YY)
# $a2 = color of line format: (0x00RRGGBB)
#***************************************************
#Pseudocode:
#draw_line function gets the pair of coordinates from
#$a0 and $a1, then uses Bresenham's incremental error
#line algorithm to print each pixel until the x0 and y0
#equal x1 and y1, respectively. Everytime a pixel is
#colored, the color stored in $a2 is moved to $a1 and 
#draw_pixel function is called.
draw_line: nop
	push($a0)
	push($a1)
	push($t0)
	push($t1)
	push($t2)
	push($t3)
	push($t4)
	push($t5)
	push($t6)
	push($t7)
	push($t8)
	push($t9)
	push($ra)
	
	getCoordinates($a0 $t0 $t1)
	getCoordinates($a1 $t2 $t3)
	sub $t4 $t2 $t0 #$t4 - dx
	abs $t4 $t4
	sub $t5 $t3 $t1 #$t5 - dy
	abs $t5 $t5
	mul $t5 $t5 -1
	ble $t2 $t0 sx_negative
	li $t6 1 #$t6 - sx
	j draw_line2
	
	sx_negative:
		li $t6 -1
		j draw_line2
	
	draw_line2:
		ble $t3 $t1 sy_negative
		li $t7 1 #$t7 - sy
		j draw_line3
	
	sy_negative:
		li $t7 -1
		j draw_line3
		
	draw_line3:
		add $t8 $t4 $t5 #$t8 - err
		j draw_line_loop
		
	draw_line_loop:
		move $a1 $a2
		jal draw_pixel
		beq $t0 $t2 draw_line_check
		
	draw_line_loop2:
		sll $t9 $t8 1 #$t9 - e2
		bge $t9 $t5 x_increment
		j draw_line_loop3
		
	draw_line_loop3:
		ble $t9 $t4 y_increment
		formatCoordinates($a0 $t0 $t1)
		j draw_line_loop
		
	x_increment:	
		add $t8 $t8 $t5
		add $t0 $t0 $t6
		j draw_line_loop3
		
	y_increment:
		add $t8 $t8 $t4
		add $t1 $t1 $t7
		formatCoordinates($a0 $t0 $t1)
		j draw_line_loop
		
	draw_line_check:
		beq $t1 $t3 exit_draw_line
		j draw_line_loop2
		
	exit_draw_line:
		pop($ra)
		pop($t9)
		pop($t8)
		pop($t7)
		pop($t6)
		pop($t5)
		pop($t4)
		pop($t3)
		pop($t2)
		pop($t1)
		pop($t0)
		pop($a1)
		pop($a0)
		
		jr $ra
#*****************************************************
# draw_rectangle:
#  Given two coordinates for the upper left and lower 
#  right coordinate, draws a solid rectangle	
#-----------------------------------------------------
# $a0 = first coordinate (x0,y0) format: (0x00XX00YY)
# $a1 = second coordinate (x1,y1) format: (0x00XX00YY)
# $a2 = color of line format: (0x00RRGGBB)
#***************************************************
#Pseudocode:
#draw_rectangle function gets the coordinates given
#from $a0 and $a1, calculates the top right
#coordinate of the rectangle, and calls the draw_line
#function to color the line from the top left corner
#to the top right. The y values of those coordinates
#are then incremented and the function then loops to
#draw the line directly below it. The loop continues
#until it uses the draw_line function as many times
#as there are rows in the rectangle, calculated
#earlier with the two given coordinates.
draw_rectangle: nop
	push($t0)
	push($t1)
	push($t2)	
	push($t3)
	push($t4)
	push($t5)
	push($t6)
	push($t7)
	push($t8)
	push($a0)
	push($a1)
	push($a2)
	push($ra)
		
	getCoordinates($a0 $t0 $t1) #sets top left coordinate
	getCoordinates($a1 $t2 $t3) #sets bottom right coordinate
	
	move $t4 $t0 #sets current left coordinate
	move $t5 $t1
	
	move $t6 $t2 #sets current right coordinate
	move $t7 $t1
	
	sub $t8 $t3 $t1 #sets loop counter
	addi $t8 $t8 1
		
	inner_rectangle:
		formatCoordinates($a0 $t4 $t5)
		formatCoordinates($a1 $t6 $t7)
		jal draw_line
		subi $t8 $t8 1
		beqz $t8 draw_rectangle_end
		
	position_incrementor:
		addi $t5 $t5 1
		addi $t7 $t7 1
		
		j inner_rectangle	
		
	draw_rectangle_end:
		pop($ra)
		pop($a2)
		pop($a1)
		pop($a0)
		pop($t8)
		pop($t7)
		pop($t6)
		pop($t5)
		pop($t4)
		pop($t3)
		pop($t2)
		pop($t1)
		pop($t0)
		
		jr $ra	
#*****************************************************
#Given three coordinates, draws a triangle
#-----------------------------------------------------
# $a0 = coordinate of point A (x0,y0) format: (0x00XX00YY)
# $a1 = coordinate of point B (x1,y1) format: (0x00XX00YY)
# $a2 = coordinate of traingle point C (x2, y2) format: (0x00XX00YY)
# $a3 = color of line format: (0x00RRGGBB)
#-----------------------------------------------------
# Traingle should look like:
#               B
#             /   \
#            A --  C
#***************************************************
#Pseudocode:
#The draw_triangle function stores all the given coordinates
#given in temporary registers and then calls on the draw_line
#function three times, first from A to B, A to C, and then
#B to C. The coordinates stored in the t registers are moved
#around appropriately to their select a registers so the 
#draw_line function colors the correct line.	
draw_triangle: nop
	push($a0)
	push($a1)
	push($a2)
	push($a3)
	push($t0)
	push($t1)
	push($t2)
	push($ra)
	
	move $t0 $a0
	move $t1 $a1
	move $t2 $a2

	move $a2 $a3
	
	jal draw_line
	
	move $a1 $t2
	jal draw_line
	
	move $a0 $t1
	move $a1 $t2
	jal draw_line
	
	pop($ra)
	pop($t2)
	pop($t1)
	pop($t0)
	pop($a3)
	pop($a2)
	pop($a1)
	pop($a0)
	
	jr $ra	
	
	
	

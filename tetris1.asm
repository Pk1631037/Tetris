code segment
    assume cs:code, ds:data, ss:stack
    
start:
    mov ax,0b800h
    mov ds,ax
    mov di,0000 ;points di at the top left of the screen
    mov bl,' ' ;readies letter to put on screen
    
clearscreen:
    cmp di,3998 ;when it hits bottom right corner
    je border0 ;move to filling in the asterisks
    mov [di],bl ;puts the space onscreen where di is pointing
    int 21h  ;executes the putting of the space
    add di,2 ;moves one spot over
    jmp clearscreen ;repeat

border0:
    mov di,0000 ;starts off in top left
    mov ax,3198 ;used in making the bottom border
    jmp borderLR ;starts making left and right borders

borderLR:
    mov [di],'|' ;places a bar on the left side
    mov [di+1],7 ;makes it white
    add di,22 ;moves over to the right side
    mov [di],'|' ;places the bar
    mov [di+1],7 ;makes it white
    cmp di,3060 ;if we're at right side row 19
    jg borderBTM ;move on to the bottom border
    add di,138 ;else jump to the next line, line = 160
    loop borderLR ;and do the previous steps again
    
borderBTM:
    add ax,2 ;else move over one spot
    mov di,ax ;ax stores the di value for simplicity
    mov [di],'-' ;put a hyphen there
    mov [di+1],7 ;make it white
    cmp di,3222 ;if we're at the actual bottom right 
    je fillblack0 ;end
    loop borderBTM ;and repeat
    
fillblack0: 
    mov cl,0 ;column iteration
    mov dl,0 ;row iteration
    mov di,0002 ;moves di back to the top left, one space over
    mov al,'*'
    mov ah,0
    jmp fillblack1
    
fillblack1:
    cmp cl,10 ;when we get to the tenth column
    je fillblack2 ;skip to next row
    mov [di],al ;gets an asterisk ready
    mov [di+1],ah ;made color for visibility
    add di,0002 ;move to next space
    inc cl ;increment column counter
    jmp fillblack1 ;else repeat
    
fillblack2:
    mov cl,0 ;resets column counter
    add di,140 ;jumps to next line, 160 = line
    inc dl ;increments row counter
    cmp dl,20 ;after 20 rows
    je setPiece0 ;end looping
    jmp fillblack1 ;else repeat
    
setPiece0:
    push dx
    push cx
    push si
    mov cl,0 ;setting counter to 0
    mov si,offset piecex_l

setPiece1: ;creating loop
    mov dl,[si] ;set dl=di
    push dx ;not sure about this part, i think this is right, but not sure.  just trying to push dx.
    inc si ;increment di
    inc cl
    cmp cl,8 ;check if di is less than 8 because that is end condition for loop
    jl setPiece1 ;if it isn't then run loop again (may have done this wrong) ERROR

setPiece15:
    mov cl,0
    mov dh,0
    mov si,offset currentpiecex+7
    ;add di,7 ;on the assignemnt is says to di=currentpiece+7 ERROR
    
setPiece2:
    pop dx ;pop the dx we pushed earlier
    mov [si],dl ;set di=dl
    dec si ;decrement di
    inc cl
    cmp cl,8
    je show0
    loop setPiece2
    
show0:
    pop si
    pop cx
    pop dx
    
    push cx
    mov cl,0
    push si
    push bx
    push ax
    ;mov di,offset currentpiecex

showcurrentpiece: ;i don't really understand what i was doing here, i just tried to convert the java into assembly, if you look at this and the java in the assignment it should make sense.
    mov si,offset currentpiecex
    mov bl,[si]
    mov bh,[si+4] ;BH
    mov al,7 
    call setPixel
    ;inc di
    mov bl,[si+1]
    mov bh,[si+5]
    call setPixel
    mov bl,[si+2]
    mov bh,[si+6]
    call setPixel
    mov bl,[si+3]
    mov bh,[si+4]
    ; inc cl
   ; cmp cl,3
   ;jle showcurrentpiece
    
    pop ax
    pop bx
    pop si
    pop cx
    jmp finish
    
setPixel:
;input values: the x the y and the color
;x(COLUMN) = bl   y (ROW) = bh    al=color
;for this function you are getting the row, the column, and the color, and with that using the formula (r*80+c)+2 to set the pixel into memory
    push   di
    push   ax           ;push
    push   cx           ;push
    mov    al,80       ;move 80 into al
    mul    bh           ;multiply bh by 80 and puts the answer into ax 
    mov    cx,ax
    mov    al,1
    mul    bl 
    add    ax,cx        ;adds cx and ax.. the result is in ax
    add    ax,ax        ;multiplies the result by 2
    mov    di,ax        ;move ax into di
    pop    cx           ;pop
    pop    ax           ;pop
    mov    [di+1],al ;puts color into di+1
    pop    di           ;pop
    ret                     ;return the setpixel

;input values: the x the y
;output values: the color
;x(COLUMN) = bl   y (ROW) = bh    al=color
;for this function you are getting the row, the column, and returning the color
getPixel:               ;while going through the columns you will evaluat the space of that part in the column
    push   di           ;push
    push   ax           ;push
    push   cx           ;push
    mov    al, 80       ;move 80 into al
    mul    bh           ;multiply bh by 80 and puts the answer into ax 
    mov    cl,bl        ;moves the columns into the cl register
    mov    ch,0         ;makes ch 0.. cx is ch and cl together
    add    ax,cx        ;adds cx and ax.. the result is in ax
    add    ax,ax        ;multiplies the result by 2
    mov    di,ax        ;move ax into di
    pop    cx           ;pop
    pop    ax           ;pop
    mov    al,[di+1] ;set the memory into al
    pop    di           ;pop
ret                     ;return the getPixel

finish:
    mov ah,0 ;terminate program    
    int 21h ;goodbye
code ends

data segment
    piecex_line     db      5,5,5,5 
    piecey_line     db      0,1,2,3
    piecex_l        db      5,6,7,5
    piecey_l        db      0,0,0,1
    piecex_r        db      5,6,7,7
    piecey_r        db      0,0,0,1
    piecex_s        db      5,6,6,7
    piecey_s        db      1,1,0,0
    piecex_z        db      5,6,6,7
    piecey_z        db      0,0,1,1
    piecex_t        db      5,6,7,6
    piecey_t        db      0,0,0,1
    piecex_box      db      5,6,5,6
    piecey_box      db      0,0,1,1

    currentpiecex  db      0,0,0,0
    currentpiecey  db      0,0,0,0
data ends

stack segment
    db 30 dup(0)
stack ends

end start
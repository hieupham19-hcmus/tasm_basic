.model small 
.stack 100h
.data
 
x dw ?
y dw ?
z dw 10 

sum dw ?
product dw ?

ms db "Input number: $"
nl db 10,13,"$"
not_prime db "This is not a prime number.", 10, 13, "$"
prime db "This is a prime number.", 10, 13, "$"
four_ones db "The binary representation has exactly 4 set bits.", 10, 13, "$"
not_four_ones db "The binary representation does not have exactly 4 set bits.", 10, 13, "$"
digits_increasing_decreasing db "The digits are in increasing order or decreasing order.", 10, 13, "$"
digits_not_increasing_decreasing db "The digits are not in increasing order or decreasing order.", 10, 13, "$"
all_odd_even db "All even or all odd", 10, 13, "$" 
mixed_odd_even db "Mixed even and odd", 10, 13, "$" 
sum_equals_product db "The sum of the digits is equal to the product of the digits.", 10, 13, "$"
sum_not_equals_product db "The sum of the digits is not equal to the product of the digits.", 10, 13, "$"
;menu_help db "Menu:", 10, 13, "1. Check for prime number", 10, 13, "2. Check if it has exactly 4 set bits in binary representation", 10, 13, "3. Check if digits are in increasing or decreasing order", 10, 13, "4. Check if the sum of digits is equal to the product of digits", 10, 13, "5. Check if it contains all even or all odd digits", 10, 13, "6. Exit", 10, 13, "$"
;your_choice db "Your choice: $"

.code
main proc
    mov ax,@data
    mov ds,ax
    mov ah,9
    lea dx,ms
    int 21h
    call nhapso
    mov ah,9
    lea dx,nl
    int 21h
    
    call kiemtrasonguyento
    call kiemtra4bit1
    call ordered_digits_check
    call check_sum_product
    call checkAllEvenOddDigits
     

    mov ah,4Ch
    int 21h
main endp

nhapso proc
    mov x,0
    mov y,0
    mov bx,10
    nhap:
        mov ah,1
        int 21h
        cmp al,13
        je thoat_nhap
        sub al,30h
        xor ah,ah
        mov y,ax
        mov ax,x
        mul bx
        add ax,y
        mov x,ax
        jmp nhap
    thoat_nhap:
        ret
nhapso endp

xuatso proc
    mov bx,10
    mov ax,x
    xor ah,ah
    xor cx,cx  
    chia:
        mov dx,0
        div bx
        inc cx
        push dx
        cmp al,0
        je ht
        jmp chia
    ht:
        pop dx
        add dl,30h
        mov ah,2
        int 21h
        dec cx
        cmp cx,0
        jne ht
        ret
xuatso endp

kiemtrasonguyento proc
    mov ax, x  ; luu x vao thanh ghi ax
    cmp ax, 2  ; so sanh x voi 2
    jl khongphaisonguyento ; cac so nho hon 2 khong phai so nguyen to
    je la_snt  ; neu la 2 thi la so nguyen to
        
    mov cx, 3  ; gan cx la so bi chia (chay tu 3 den sqrt(x) voi buoc la 2       
    mov bx, 2         
    mov dx, 0
    cmp ax,cx  ; neu x = 3 thi la so nguyen to
    je la_snt
        
    div bx     ; kiem tra x co phai la so chan khong
    cmp dx,0   ; neu la so chan (>2) thi khong phai so nguyen to
    je khongphaisonguyento        
    kiem_tra_loop:
        xor dx,dx
        mov ax, x        
        div cx     ; kiem tra x co chia het cho so trong cx khong    
        cmp dx, 0  ; chia het thi khong phai so nguyen to 
            
        je khongphaisonguyento        
        add cx, 2   ; tang cx len sau moi lan lap           
        mov bx, x
        shr bx, 1
        cmp cx, bx  ; kiem tra cx < sqrt(x) neu nho hon thi chay tiep    
        add bx,1
        jb kiem_tra_loop        
    la_snt:
        mov ah, 9
        lea dx, prime
        int 21h
        jmp thoat_ktsgt    
    khongphaisonguyento:
        mov ah, 9
        lea dx, not_prime
        int 21h    
    thoat_ktsgt:
        ret
kiemtrasonguyento endp

kiemtra4bit1 proc
    mov ax, x   ; luu gia tri x vao ax    
    mov cx, 0   ; luu so luong bit 1    
    mov bx, 0   ; tao bien dem bit da kiem tra    
    bitcount:
        test ax, 1  ; kiem tra biet thap nhat cua ax     
        jz nextbit  ; neu bang 0, nhay toi nextbit
        inc cx      ; neu bang 1, tang bien cx         
    nextbit:
        shr ax, 1   ;dich phai ax de kiem tra bit tiep theo    
        inc bx      ; tang bien dem bit da kiem tra    
        cmp bx, 16  ; so sanh bien dem voi 16 de kiem tra da kiem tra het 16 bit chua    
        jnz bitcount ; neu chua kiem tra het 16 bit, quay lai bitcount     
        cmp cx, 4   ; so sanh bien dem bit 1 voi 4 de kiem tra co dung 4 bit 1 hay khong      
        jz equal4bit1 ; neu co dung 4 bit 1, nhay toi equal4bit1   
    not4bit1:
        mov ah, 9
        lea dx, not_four_ones
        int 21h
        jmp thoat_kt4bit1
    equal4bit1:
        mov ah, 9
        lea dx, four_ones
        int 21h
    thoat_kt4bit1:
        ret
kiemtra4bit1 endp

ordered_digits_check proc
    mov ax, x
    
    ;cx:flag    1: increasing, 0: decreasing
    
    xor dx, dx

    test ax, ax ; kiem tra ax co bang 0 khong
    jz ordered ; neu bang 0 thi la so da sap xep

    div z        ; chia ax cho z (z = 10) 
    mov bx, dx   ; luu chu so phai cung vao bx 
    test ax, ax  ; kiem tra ax co bang 0 khong
    jz ordered   ; neu la 0 thi x la so co mot chu so (sap xep)
    xor dx, dx
    div z        ; tiep tuc chia ax cho 10
    test ax, ax  ; kiem tra ax co bang 0 khong
    jz ordered   ; neu la 0 thi x la so co hai chu so (sap xep)
    cmp dx, bx   ; so sanh hai chu so cuoi cua x de lay duoc thu tu cua chuoi (neu sap xep)
    jbe set_co_tang  
    jge set_co_giam 
    
    check_loop: 
        mov bx,dx    ; bx luu chu so truoc do
        test ax,ax   ; kiem tra ax co bang 0 khong
        jz ordered   ; neu co thi ket thuc vong lap va tra ve ket qua chuoi sap xep
        xor dx,dx
        div z        ; chia ax cho 10 de lay chu so tiep theo
        cmp dx,bx    ; kiem tra chu so duoc lay voi chu so truoc do
        jle check_tang  
        jge check_giam
        
        jmp check_loop
        
check_tang:        
    cmp cx,1 ; kiem tra xem co phu hop voi flag (thu tu cua hai chu so cuoi cua x)
    jne not_ordered
    
    jmp check_loop
check_giam:
    cmp cx,0 ; kiem tra xem co phu hop voi flag (thu tu cua hai chu so cuoi cua x)
    jne not_ordered
    
    jmp check_loop 

not_ordered:
    mov ah, 9
    mov dx, offset digits_not_increasing_decreasing
    int 21h
    ret

set_co_tang:
    mov cx, 1   
    mov bx, dx  
    jmp check_loop

set_co_giam:
    mov cx, 0   
    mov bx, dx  
    jmp check_loop

ordered:
    mov ah, 9
    mov dx, offset digits_increasing_decreasing
    int 21h
    ret

ordered_digits_check endp

check_sum_product proc
    mov ax, x         
    mov sum, 0 ; khoi tao sum bang 0   
    mov product, 1 ; khoi tao product bang 1
        
    calculate_sum_and_product:
        xor dx, dx         
        div z   ; chia ax cho 10 de lay chu so cua x           
        add sum, dx  ; cong chu so vao bien sum             
        push ax   ; day chu so vao stack
        mov ax, product ; gan bien product vao thanh ghi ax  
        mul dx ; nhan ax voi chu so tren            
        mov product, ax ; gan lai bien product          
        pop ax ; lay lai gia tri ax tu stack                          
        test ax, ax ; kiem tra ax co phai 0 chua       
        jnz calculate_sum_and_product  ; neu ax khong phai 0 thi chay lai vong lap       
    mov ax,sum  ; so sanh tong va tich cac chu so neu bang thi thao yeu cau                
    cmp ax, product   
    je equal_result_1
        
    not_equal_result_1:
        mov ah, 9
        lea dx, sum_not_equals_product
        int 21h
        jmp end_check    
    equal_result_1:
        mov ah, 9
        lea dx, sum_equals_product
        int 21h    
    end_check:
        ret
check_sum_product endp

checkAllEvenOddDigits proc
    mov ax, x       
    mov cx, 0   ; so luong chu so chan    
    mov bx, 0   ; so luong chu so le
           
    count_even_odd:
        xor dx, dx       
        div z  ; chia ax cho 10 phan du duoc luu tai dx     
        test dx, 1 ; kiem tra bit thap nhat cua dx, de xac dinh so chan hay le      
        jz even_digit  

    odd_digit:
        inc bx ; neu la chu so le thi tang so luong len        
        jmp next_digit
    even_digit:
        inc cx ; neu la chu so chan thi tang so luong len         
    next_digit:
        test ax, ax ; kiem tra xem ax da la 0 chua, neu chua thi kiem tra so tiep    
        jnz count_even_odd 
    check_all_even_odd:
        cmp bx, 0   ; neu so luong so le bang 0 thi so toan chan    
        jz equal_result 
        cmp cx, 0   ; neu so luong so chan bang 0 thi so toan le    
        jz equal_result 
        jmp not_equal_result 
    equal_result:
        mov ah, 9
        lea dx, all_odd_even
        int 21h
        jmp thoat_ktchuso    
    not_equal_result:
        mov ah, 9
        lea dx, mixed_odd_even
        int 21h    
    thoat_ktchuso:
        ret
checkAllEvenOddDigits endp

End        
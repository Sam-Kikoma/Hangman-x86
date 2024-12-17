bits 16
org 0x100

section .data
    cities db "LONDON", 0, "PARIS", 0, "TOKYO", 0, "BERLIN", 0, "DUBAI", 0 ; 5 cities
    city_count dw 5
    current_word db 32 dup(0)         
    current_length db 0               
    guessed_word db 32 dup('_')       
    wrong_guesses db 0                
    max_wrong db 6                    
    letter_prompt db "Guess a letter (A-Z): $"
    win_msg db "Winner winner chicken dinner!$"
    lose_msg db "Game over! The correct city was: $"
    remaining_msg db "Remaining tries: $"
    newline db 0x0D, 0x0A, '$'        ; Newline character sequence

section .bss
    random_seed resw 1                ; Stores the random seed

section .text
global start

start:
    ; Text mode
    mov ax, 0x03
    int 0x10

    ; Seed the random number 
    mov ah, 0x00
    int 0x1A
    mov [random_seed], dx

    ; Select a random city
    call select_random_city

    ; Initialize guessed_word with underscores
    lea di, guessed_word
    mov cl, [current_length]
    mov al, '_'
    rep stosb
    mov byte [di], '$'  

    ; Game state reset
    mov byte [wrong_guesses], 0

main_game:
    call clear_screen
    call display_game_state
    call get_input
    call process_guess

    ; is Win?
    call check_win
    cmp al, 1
    je win_game

    ; is Lose?
    mov al, [wrong_guesses]
    cmp al, [max_wrong]
    jae lose_game

    jmp main_game

win_game:
    call clear_screen
    lea dx, win_msg
    call print_string
    call newline_print
    jmp exit_game

lose_game:
    call clear_screen
    lea dx, lose_msg
    call print_string
    lea dx, current_word
    call print_string
    call newline_print
    jmp exit_game

exit_game:
    mov ah, 0x4C
    xor al, al
    int 0x21

; Util Funcs 

clear_screen:
    mov ax, 0x0600
    mov bh, 0x07
    xor cx, cx
    mov dx, 0x184F
    int 0x10
    ret

print_string:
    mov ah, 0x09
    int 0x21
    ret

newline_print:
    lea dx, newline
    call print_string
    ret

get_input:
    mov ah, 0x00
    int 0x16
    cmp al, 'a'
    jl .check_upper
    cmp al, 'z'
    jg .check_upper
    sub al, 32              ; Convert lowercase to uppercase
.check_upper:
    cmp al, 'A'
    jl get_input
    cmp al, 'Z'
    jg get_input
    ret

; Random City Selection
select_random_city:
    mov ax, [random_seed]   ; Load the seed
    mov bx, 25173           ; Multiplier
    mul bx                  ; AX = AX * 25173
    add ax, 13849           ; Add increment
    mov [random_seed], ax   ; Store the new seed

    ; Use modulus to pick a city
    xor dx, dx
    mov bx, [city_count]
    div bx                  
    mov bx, dx               

    ; Find the correct city
    mov si, cities
    xor di, di
.find_city:
    cmp di, bx
    je .copy_city
.skip_city:
    lodsb
    cmp al, 0
    jne .skip_city
    inc si
    inc di
    jmp .find_city

.copy_city:
    lea di, current_word
.copy_loop:
    mov al, [si]
    stosb
    cmp al, 0
    je .done_copy
    inc si
    jmp .copy_loop

.done_copy:
    ; Word length calc
    lea si, current_word
    xor cx, cx
.count_length:
    cmp byte [si], 0
    je .store_length
    inc si
    inc cx
    jmp .count_length
.store_length:
    mov [current_length], cl
    ret

display_game_state:
    ; Guessed word 
    lea dx, guessed_word
    call print_string
    call newline_print

    ; Display remaining tries
    lea dx, remaining_msg
    call print_string
    mov al, [max_wrong]
    sub al, [wrong_guesses]
    add al, '0'
    mov dl, al
    mov ah, 0x02
    int 0x21
    call newline_print

    ; Display prompt for input
    lea dx, letter_prompt
    call print_string
    ret

process_guess:
    lea si, current_word
    lea di, guessed_word
    mov cl, [current_length]
    xor bx, bx
    mov dl, al

.check_letter:
    cmp byte [si], dl
    jne .next_letter
    mov [di], dl
    inc bx
.next_letter:
    inc si
    inc di
    loop .check_letter

    cmp bx, 0
    jne .done
    inc byte [wrong_guesses]
.done:
    ret

check_win:
    lea si, guessed_word
    mov cl, [current_length]

.check_loop:
    cmp byte [si], '_'
    je .not_winner
    inc si
    loop .check_loop

    mov al, 1
    ret

.not_winner:
    xor al, al
    ret

;Todo : Scoreboard mgt, Hangman visuals?
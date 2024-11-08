section .data
    prompt db "Guess a number between 1 and 100: ", 0
    correct db "Congratulations! You guessed it right!", 10, 0
    too_high db "Too high! Try again.", 10, 0
    too_low db "Too low! Try again.", 10, 0
    error_msg db "Invalid input! Please enter a number between 1 and 100.", 10, 0
    random_number db 0

section .bss
    user_input resb 4
    guess resb 4

section .text
    global _start

_start:
    ; Generate a random number between 1 and 100
    call random_number_generator
    mov [random_number], al

game_loop:
    ; Print prompt message
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; file descriptor: stdout
    mov rsi, prompt         ; message to write
    mov rdx, 36             ; message length
    syscall

    ; Read user input
    mov rax, 0              ; syscall: read
    mov rdi, 0              ; file descriptor: stdin
    mov rsi, user_input     ; buffer to store input
    mov rdx, 4              ; number of bytes to read
    syscall

    ; Convert input string to integer
    call string_to_integer

    ; Compare guess with the random number
    mov eax, [guess]
    cmp eax, [random_number]
    je correct_guess
    jg too_high_guess
    jl too_low_guess

correct_guess:
    ; Print correct message
    mov rax, 1
    mov rdi, 1
    mov rsi, correct
    mov rdx, 37
    syscall
    jmp exit_game

too_high_guess:
    ; Print too high message
    mov rax, 1
    mov rdi, 1
    mov rsi, too_high
    mov rdx, 22
    syscall
    jmp game_loop

too_low_guess:
    ; Print too low message
    mov rax, 1
    mov rdi, 1
    mov rsi, too_low
    mov rdx, 20
    syscall
    jmp game_loop

exit_game:
    ; Exit the program
    mov rax, 60             ; syscall: exit
    xor rdi, rdi            ; exit code 0
    syscall

; Function to generate a random number between 1 and 100
random_number_generator:
    ; This is a simple pseudo-random number generator
    ; In a real program, you would use a better method
    mov rax, 0
    rdtsc                   ; Read time-stamp counter
    xor rdx, rdx            ; Clear rdx
    mov rbx, 100            ; Max number
    div rbx                 ; Divide rax by 100
    add al, 1               ; Make it between 1 and 100
    ret

; Function to convert string to integer
string_to_integer:
    xor rax, rax            ; Clear rax
    xor rcx, rcx            ; Clear rcx (multiplier for tens)
    mov rcx, 10             ; Base 10

.next_digit:
    movzx rbx, byte [user_input + rcx] ; Load next character
    cmp rbx, 10             ; Check for newline
    je .done                ; If newline, we're done
    sub rbx, '0'            ; Convert ASCII to integer
    imul rax, rax, 10       ; Multiply rax by 10
    add rax, rbx            ; Add the new digit
    inc rcx                 ; Move to the next character
    jmp .next_digit

.done:
    mov [guess], eax        ; Store the result in guess
    ret

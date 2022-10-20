; This program is implementing a simple caesar cipher which shifts all characters in an alphabet by some value
;   "message" + shift 3 = "phvvdjh"
; if overflow happens, we returning to the start
;   "z" + shift 1 = "a"
;   "z" + shift 27 = "a"


section .data 
    welcomeMessage db "Caesar cipher", 0xA, 0
    .len equ $-welcomeMessage

    enterANum db "Enter a number: ", 0
    .len equ $-enterANum


    usageMessage db "Parse the strings as an arguments to this program:", 0xA, "./caesar [args]", 0xA
    .len equ $-usageMessage

    alphabetLenght equ 26
section .bss 
    shiftValue resb 9

section .text 
    global _start:
_start:

    cmp byte [esp], 1 
    je usage

    push  0xA
    call _printCharacter

    push welcomeMessage.len
    push welcomeMessage   
    call _print


    push enterANum.len 
    push enterANum
    call _print
    push 8
    push shiftValue
    call _read

    push shiftValue
    call _convertStringToInt
    
    mov dword [shiftValue], eax
    xor edx, edx
    mov ebx, 26
    div ebx
    mov dword [shiftValue], edx

    ; stack:
    ;
    ; argn          <-- esp
    ; pr name (arg1)<-- esp+4*1
    ; arg2          <-- esp+4*2
    ; arg3          <-- esp+4+3
    ; ...
    ; argn          <-- esp+4*n
    
    mov ecx, [esp]
next_argument:
    mov eax, [esp+4*ecx] 

    push ecx   

    push eax         
    call _encodeString
    add esp, 4

    pop ecx
    dec ecx
    cmp ecx, 1
    jne next_argument

output:
    xor eax, eax
    xor ecx, ecx 
.print: 
    test ecx, ecx

    je .skip_first_space
    pusha
    push  " " 
    call _printCharacter
    popa

.skip_first_space:
    xor edx, edx
    inc ecx
    
    cmp ecx, [esp]
    je end
    mov ebx, [esp+4*ecx+4]
.cycle:
    mov al, [ebx+edx]

    test al, al
    jz .print

    pusha
    push  eax 
    call _printCharacter
    popa

    inc edx
    jmp .cycle


usage:
    push usageMessage.len
    push usageMessage
    call _print
end:

    pusha
    push  0xA
    call _printCharacter
    popa


    mov eax, 1
    xor ebx, ebx 
    int 0x80











_encodeString:
    ; esp+4 = start of the string
    xor ecx, ecx 
    mov ebx, [esp+4]
.encode:
    mov al, byte [ebx]
    cmp al, 0
    je .end 
    cmp al, "A"
    jl .error
    cmp al, "z"
    ja .error
    cmp al, "Z"
    jle .higher
.lower:
    add al, [shiftValue]
    cmp al, "z"
    jbe .continue
    sub al, 26
    jmp .continue
.higher:
    add al, [shiftValue]
    cmp al, "Z"
    jbe .continue
    sub al, 26
    jmp .continue
.continue:
    mov byte [ebx], al
    inc ebx
    jmp .encode
.error:
    mov eax, 1
.end:
    ret







_print:
    mov edx, [esp+8]
    mov ecx, [esp+4]
    mov ebx, 1
    mov eax, 4
    int 0x80
    ret 8
    
_read:
    mov edx, [esp+8]
    mov ecx, [esp+4]
    mov ebx, 0
    mov eax, 3
    int 0x80
    ret 8

_printCharacter:
    mov   eax, 4     
    mov   ebx, 1     
    lea   ecx, [esp+4]
    mov   edx, 1     
    int   0x80        
    ret 4
    
_convertStringToInt:
    ; "1234\n"
    ; 1     1
    ; 2     10+2=12
    ; 3     120+3=123
    ; 4     1230+4=1234
    ; \n ->exit

    mov edx, [esp+4]
    xor eax, eax
    xor ecx, ecx
.continue:
    mov cl, byte [edx]
    inc edx
    cmp cl, "0"
    jb .end 
    cmp cl, "9"
    ja .end
    sub cl, "0"
    imul eax, 10
    add eax, ecx
    jmp .continue
.end:
    ret 4

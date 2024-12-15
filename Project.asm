.MODEL SMALL
.STACK 100h

.DATA
    input db 50 dup('$')          ; Buffer for user input (max 50 chars)
    message db 'Enter text: $'    ; Prompt for input text
    option db 'Enter 1 to Encrypt, 2 to Decrypt: $'
    choice db ?                   ; Holds user choice (1 or 2)
    result db 50 dup('$')         ; Buffer for encrypted/decrypted text
    key db 3                      ; Caesar cipher key (shift by 3)
    newline db 13, 10, '$'        ; Newline for display

.CODE
main PROC
    ; Initialize the data segment (DS)
    MOV AX, SEG input    ; Get the segment address of the data segment
    MOV DS, AX           ; Load it into the DS register

    ; Display the option message
    LEA DX, option
    MOV AH, 09h
    INT 21h

    ; Get user's choice (1 or 2)
    MOV AH, 01h        ; Read single character
    INT 21h
    SUB AL, '0'        ; Convert ASCII to integer
    MOV choice, AL

    ; Display newline
    LEA DX, newline
    MOV AH, 09h
    INT 21h

    ; Display input prompt
    LEA DX, message
    MOV AH, 09h
    INT 21h

    ; Get user input string
    MOV AH, 0Ah        ; Read input string
    LEA DX, input
    INT 21h

    ; Process based on user's choice
    CMP choice, 1      ; Check if choice is 1 (Encrypt)
    JE encrypt
    CMP choice, 2      ; Check if choice is 2 (Decrypt)
    JE decrypt

    ; Invalid choice, terminate program
    JMP terminate

encrypt:
    ; Encryption loop
    LEA SI, input+2      ; SI points to input string (skip length byte)
    LEA DI, result       ; DI points to result buffer
    MOV CL, key               ; Load the key in CL

encrypt_loop:
    MOV AL, [SI]         ; Load character from input string
    CMP AL, 0Dh          ; Check if it's end of input (carriage return)
    JE done_encrypt      ; Exit loop if done
    ADD AL, CL           ; Apply Caesar cipher (shift by key)
    MOV [DI], AL         ; Store encrypted character
    INC SI               ; Move to next input character
    INC DI               ; Move to next result buffer position
    JMP encrypt_loop     ; Repeat the loop

done_encrypt:
    JMP display_result   ; Skip to result display

decrypt:
    ; Decryption loop
    LEA SI, input+2      ; SI points to input string (skip length byte)
    LEA DI, result       ; DI points to result buffer
    MOV CL, key          ; Load the key in CL

decrypt_loop:
    MOV AL, [SI]         ; Load character from input string
    CMP AL, 0Dh          ; Check if it's end of input (carriage return)
    JE done_decrypt      ; Exit loop if done
    SUB AL, CL           ; Reverse Caesar cipher (subtract key)
    MOV [DI], AL         ; Store decrypted character
    INC SI               ; Move to next input character
    INC DI               ; Move to next result buffer position
    JMP decrypt_loop     ; Repeat the loop

done_decrypt:
    ; Null-terminate the decrypted string
    JMP display_result

display_result:
    ; Null-terminate the result string
    MOV BYTE PTR [DI], '$'

    ; Display newline
    LEA DX, newline
    MOV AH, 09h
    INT 21h

    ; Display result (encrypted or decrypted text)
    LEA DX, result
    MOV AH, 09h
    INT 21h

terminate:
    ; Terminate program
    MOV AH, 4Ch
    INT 21h

main ENDP
END main



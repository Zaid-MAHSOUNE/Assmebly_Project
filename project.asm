section .data
n db '0'
b db '9'
choice db "0 "
err_prompt db "Exception : ",10,10,"Invalid Choice",10,10
err_len equ $-err_prompt
prompt db "Enter a Number :",10,"1. Create user.",10,"2. Display Userlist.",10,"3. Display user by id.",10,"4. Display Youngest User.",10,"5. Quit.",10,"->"
prompt_len equ $-prompt
add_prompt db "Enter user credentials:",10
add_len equ $-add_prompt
select_prompt db "Enter user id:",10
select_len equ $-select_prompt
no_user_prompt db 10,"No User Found!!!",10,10
no_user_len equ $-no_user_prompt
invalid_prompt db 10,"Invalid Input!!!",10,10
invalid_len equ $-invalid_prompt
input db 96 dup(",") ; name : 50 char , age : 3 int
array dd 10 dup(0) ; to save ids
name_array db 1000 dup(",") ; to save names
age_array db 100 dup(",") ; to save ages 
id_string db 100 dup(",") ; 
id_counter dd 0
id dd 0
new_line db "",10
select_index db 0
store_id_count db 0
min_age dd 1000
young_id dd 0

section .text
global _start
_start:

_choice_loop:
    ; Prompt
    mov ecx , prompt
    mov edx , prompt_len
    call _display

    mov ecx , n ; msg is a pointer to our string
    mov edx , 2 ; data size
    call _read

    ; Convert ASCII Value to Integer
    mov al ,[n]
    sub al, "0"
    mov [n] ,eax


    ; Quit Call
    mov al , 5
    mov bl , [n]

    cmp bl , al
    je _exit
    ;

    ; Youngest Call
    mov al , 4
    mov bl , [n]

    cmp bl , al
    je _young
    ;
    
    ; Select Call
    mov al , 3
    mov bl , [n]

    cmp bl , al
    je _select
    ;

    ; List Call
    mov al , 2
    mov bl , [n]

    cmp bl , al
    je _list
    ;

    ; Create Call
    mov al , 1
    mov bl , [n]

    cmp bl , al
    je _create
    ; 

    ; Exception Call
    mov al , 5
    mov bl , [n]

    cmp bl , al
    jg _read_exception
     
    mov al , 1
    mov bl , [n]

    cmp bl , al
    jl _read_exception
    ;
;


_create:
; Add Prompt
    mov ecx , add_prompt
    mov edx , add_len
    call _display

; Read 
    mov ecx , input ; msg is a pointer to our string
    mov edx , 50 ; data size
    call _read
    call _input_check
;

; Seperate
    mov esi, input       ; Load the address of the name variable
    mov dh, " "
    mov ecx, 0       ; Clear ecx for counting the number of characters read
    
; Store Name

    ; search for space index
    call _space_search
    mov ebx, ecx
    ; search for space index in name_array
    mov esi, name_array
    mov dh, ","
    mov ecx, -1
    call _space_search
    ; store in name_array
    mov esi, input
    mov edi, name_array
    add edi, ecx
    mov ecx, ebx
    push ecx
    call _copy_string


; Store Age
    pop ecx
    mov esi, input
    add esi, ecx
    mov edi, esi ; store string debute
    mov dh, 10
    mov ecx, -1       ; Clear ecx for counting the number of characters read
    ; search for newline index
    call _space_search
    mov ebx, ecx ; preserve how many characters are in age in ebx
    ; search for space index in age_array
    mov esi, age_array
    mov dh, ","
    mov ecx, -1
    call _space_search
    ; store in age_array
    mov esi, edi
    mov edi, age_array
    add edi, ecx
    mov ecx, ebx
    call _copy_string
    mov byte [edi], " "

    ;increment user count
    inc dword [id_counter]

    jmp _choice_loop

jmp _choice_loop


_list:
    mov dword [id], 0
    mov eax, [id]
    cmp eax, [id_counter]
    je _no_user_exception

    mov byte [select_index], 0 ; set select index to 0 to display all users 

_user_list:
    ; display id
    mov eax, [id]
    call _display_id

    ; display name
    mov esi, name_array
    mov edi, esi
    call _display_string
    
_age_display:
    ; display age
    mov esi, age_array
    mov edi, esi
    call _display_string
    


_end_print:
    ; print new line
    mov ecx, new_line
    mov edx, 2
    call _display

    inc dword [id]
    mov eax, [id_counter]
    cmp [id], eax
    jne _user_list

    cmp byte [select_index], 1
    je _end_select

jmp _choice_loop


_select:
; Add Prompt
    mov ecx , select_prompt
    mov edx , select_len
    call _display

; Read 
    mov ecx , input ; msg is a pointer to our string
    mov edx , 50 ; data size
    call _read
    call _select_input_check


; Convert to integer
    mov dh, 10
    mov esi, input
    mov ecx, -1
    call _space_search
    mov esi, input
    xor eax, eax
    xor edx, edx
    call _str_int

; Exception
    cmp eax, [id_counter]
    jge _no_user_exception

; Display User
    mov [id], eax ; Specify wanted to display id
    mov edx, [id_counter]
    mov [store_id_count], edx
    inc eax
    mov [id_counter], eax
    mov byte [select_index], 1
    jmp _user_list
_end_select:
    mov eax, [store_id_count]
    mov [id_counter], eax

jmp _choice_loop


_young:
    mov byte [id], 0
    mov dword [min_age], 1000
    mov esi, age_array
    call _find_youngest

_find_youngest:
    mov dh, ","
    mov ecx, -1       ; Clear ecx for counting the number of characters read
    ; search for the end index
    call _space_search
    mov edi, ecx
    mov esi, age_array
_age_int:
    push esi
    mov dh, " "
    mov ecx, -1       ; Clear ecx for counting the number of characters read
    ; search for the space index
    call _space_search
    xor edx, edx
    xor eax, eax
    pop esi
    call _str_int
    mov edx, [min_age]
    cmp edx, eax
    jg _set_youngest

_age_continue:
    inc byte [id] 
    inc esi
    mov edx, age_array
    add edx, edi
    cmp edx, esi
    jne _age_int
    
    ; Display User
    mov eax, [young_id]
    mov [id], eax ; Specify wanted to display id
    mov edx, [id_counter]
    mov [store_id_count], edx
    inc eax
    mov [id_counter], eax
    mov byte [select_index], 1
    jmp _user_list

jmp _choice_loop

_set_youngest:
    mov [min_age], eax
    mov dl, [id]
    mov [young_id], dl 
    jmp _age_continue


; exceptions

_read_exception:
; Error Prompt
    mov ecx , err_prompt
    mov edx , err_len
    call _display
jmp _choice_loop

_no_user_exception:
    mov ecx, no_user_prompt
    mov edx, no_user_len
    call _display
jmp _choice_loop

_invalid_input_exception:
    mov ecx, invalid_prompt
    mov edx, invalid_len
    call _display
jmp _choice_loop

; functions
_display_id:
    ; eax contain our id integer
    xor edx, edx
    mov ecx, 10
    xor ebx, ebx
    mov esi, id_string
    call _int_str
    add esi, ebx
    inc ebx
    mov byte [esi], " "
    mov ecx, id_string  
    mov edx, ebx
    call _display
    ret

_display_string:
    ; edi, esi : initialized with string address 
    mov eax, [id] ; current id
    xor edx, edx ; loop index
    mov ecx, -1
    cmp eax, 0
    jne _display_continue

_print_first:
    ; display the first user
    mov dh, " "
    call _space_search
    inc ecx
    mov edx, ecx
    mov ecx, edi
    call _display
    cmp edi, name_array
    je _age_display
    jne _end_print

_display_continue:
    ; edi contain address of the string ; eax : 
    ; search start index
    push eax
    push edx
    mov dh, " "
    call _space_search
    pop edx
    pop eax
    inc edx
    cmp edx, eax
    jne _display_continue
    ; display name
    push esi
    xor ecx, ecx
    mov dh, " "
    call _space_search
    mov edx, ecx
    pop esi
    mov ecx, esi
    call _display
    ret

_input_check:
    mov esi, input
    mov dh, ","
    mov ecx, 0       ; Clear ecx for counting the number of characters read
    jmp _space_exist

_space_found:
    mov byte al, [esi]
    inc ecx
    inc esi

    cmp al, 10
    je _space_exist
    
    cmp al, 48
    jl _invalid_input_exception
    
    cmp al, 57
    jg _invalid_input_exception
    
    jmp _space_found

_space_exist:
    ; esi contain source address ; !!! initialize : ecx,0 ; dh: end specifier
    mov byte al, [esi]
    inc esi
    cmp al, " "
    je _space_found
    cmp al, dh
    jne _space_exist

    cmp ecx, 1
    jle _invalid_input_exception
    
    ret

_select_input_check:
    mov esi, input
    mov dh, 10
    mov ecx, 0

_select_checker:
    mov byte al, [esi]
    inc ecx
    inc esi

    cmp al, 10
    je _end_check
    
    cmp al, 48
    jl _invalid_input_exception
    
    cmp al, 57
    jg _invalid_input_exception
    
    jmp _select_checker

_end_check:
    cmp ecx, 1
    jle _invalid_input_exception

    ret

_copy_string:
    ; esi contain source address ; edi contain destination address !!! ecx contain nb characters
    mov byte al, [esi]
    mov byte [edi], al
    inc esi
    inc edi
    dec ecx
    cmp ecx, 0
    jne _copy_string
    ret

_space_search:
    ; esi contain source address ; return ecx contain index space !!! initialize : ecx,-1 ; dh: separator
    mov byte al, [esi]
    inc esi
    inc ecx
    cmp al, dh
    jne _space_search
    ret

_str_int:
    ; esi contain source address ; ecx contain number length ; !!! initialize edx,0 and eax, 0 ; return eax : number in int
    mov byte dl, [esi] 
    sub dl, "0"
    imul eax, 10       ; Multiply the current value by 10
    add eax, edx       ; Add the current digit to the result
    inc esi
    loop _str_int
    ret

_int_str:
    ; eax contain our number ; ecx contain 10 ; init esi : string source address , edx,0 , ebx,0 
    ; return esi with our number in ASCII form  
    idiv ecx
    add edx, "0"
    add esi, ebx
    mov byte [esi], dl 
    inc ebx
    xor edx, edx
    cmp eax, 0
    jne _int_str
    ret

_display:
    ; ecx : contain source address , edx : contain lenght 
    mov eax, 4
    mov ebx, 1
    int 80h
    ret

_read:
    ; ecx : contain source address, edx : contain length 
    mov eax , 3 ; sys_read 
    mov ebx , 0 ; fd (file descriptor) standard input "keyboard"
    int 80h
    ret


_exit:
mov eax , 1
mov ebx , 0
int 80h

;                             X86 64-BIT BOOTSTRAP
;                           ========================
; Ensures the CPU is compatible with AMD64, paging, and CPUID.  These features
; are configured and the CPU is configured for 64-bit long mode.  Once stack,
; long mode, and the global descriptor table are configured, execution jumps to
; the 64-bit boot assembly.

    global boot
    extern start_long
    extern fail_print

    section .text
    bits 32                         ; runs in 32-bit mode
boot:
    mov esp, stack_t                ; move stack pointer to top of stack
    
    call check_mb2
    call check_cpuid
    call check_long
    
    call init_paget
    call enable_paget
    
    lgdt [gdt64.pointer]            ; load global descriptor table
    jmp gdt64.code_segment:start_long

check_mb2:
    cmp eax, 0x36d76289             ; check multiboot magic number
    jne .fail_mb2                   ; fail if missing
    ret
.fail_mb2:
    mov al, 'M'                     ; error code is 'L'
    jmp fail_print
    hlt                             ; halt
    
check_cpuid:
    pushfd
    pop eax
    mov ecx, eax                    ; copy to check later on
    xor eax, 1 << 21                ; flip id bit
    push eax
    popfd
    pushfd
    pop eax
    push ecx
    popfd
    cmp eax, ecx                    ; check if flipped
    je .fail_cpuid                  ; unable to flip bit
    ret
.fail_cpuid:
    mov al, 'C'                     ; error code is 'C'
    jmp fail_print
    hlt                             ; halt
    
check_long:
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001             ; should set to larger number if supported
    jb .fail_long                   ; did not set to larger number
    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29               ; check long mode bit
    jz .fail_long                   ; long mode was not set
    ret
.fail_long:
    mov al, 'L'                     ; error code is 'L'
    jmp fail_print
    hlt                             ; halt
    
fail_print:
    mov dword [0xb8000], 0x4f524f45 ; print "ER"
    mov dword [0xb8004], 0x4f3a4f52 ; print "R:"
    mov dword [0xb8008], 0x4f204f20 ; print space
    mov byte  [0xb800a], al         ; print code
    hlt                             ; halt
    
init_paget:                         ; identity maps the first GB of pages
    mov eax, paget_l3
    or eax, 0b11                    ; enable present, writable
    mov [paget_l4], eax
    mov eax, paget_l2
    or eax, 0b11                    ; enable present, writable
    mov [paget_l3], eax
    mov ecx, 0                      ; i = 0
.loop:
    mov eax, 0x200000               ; 2MB page
    mul ecx                         ; multiply by page index
    or eax, 0b10000011              ; enable huge page, present, writable
    mov [paget_l2 + ecx * 8], eax   ; set each entry
    inc ecx                         ; i++
    cmp ecx, 512                    ; whole table mapped
    jne .loop                       ; loop if not
    ret

enable_paget:
    mov eax, paget_l4
    mov cr3, eax                    ; CPU looks for page address in CR3
    mov eax, cr4
    or eax, 1 << 5                  ; enable PAE flag
    mov cr4, eax
    mov ecx, 0xc0000080             ; long-mode magic value
    rdmsr                           ; read model-specific register
    or eax, 1 << 8                  ; write long-mode bit
    wrmsr                           ; write back to model-specific register
    mov eax, cr0
    or eax, 1 << 31                 ; enable paging flag
    mov cr0, eax
    ret

    section .bss
    align 4096
paget_l4:
    resb 4096                       ; reserve level 4 page table
paget_l3:
    resb 4096                       ; reserve level 3 page table
paget_l2:
    resb 4096                       ; reserve level 2 page table
stack_b:
    resb 4096 * 4                   ; reserve space for stack
stack_t:

    section .rodata
gdt64:
    dq 0
.code_segment: equ $ - gdt64
    dq (1 << 43) | (1 << 44) | (1 << 47) | (1 << 53)
.pointer:
    dw $ - gdt64 - 1
    dq gdt64

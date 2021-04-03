;                               X86-64 ENTRYPOINT
;                           ========================
; This code is executed upon entering 64-bit long mode.  At this point, paging
; is enabled and configured.  This entrypoint jumps into the C kernel.

    global start_long
    extern kernel_main

    section .text
    bits 64
    
start_long:
    mov ax, 0
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    
    call kernel_main
    
    hlt

;                               MULTIBOOT2 HEADER
;                           ========================
; Indicates to a Multiboot2-compatible bootloader that this kernel image
; is compliant with Multiboot2.
 
    HEAD_MAGIC equ 0xe85250d6
    HEAD_LEN equ head_end - head_start

    section .multiboot
head_start:
    dd HEAD_MAGIC                   ; multiboot2 magic number
    dd 0                            ; protected mode i386
    dd HEAD_LEN                     ; header length
    dd -(HEAD_MAGIC + HEAD_LEN)     ; checksum
    
    dw 0                            ; type (end tag)
    dw 0                            ; flags (no flags)
    dd 8                            ; size
head_end:

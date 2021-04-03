c_kernel := $(shell find kernel/ -name '*.c')
c_obj_kernel := $(patsubst kernel/%.c, build/%.o, $(c_kernel))

asm_x86_64 := $(shell find x86_64/ -name '*.asm')
asm_obj_x86_64 := $(patsubst x86_64/%.asm, build/%.o, $(asm_x86_64))
c_x86_64 := $(shell find x86_64/ -name '*.c')
c_obj_x86_64 := $(patsubst x86_64/%.c, build/%.o, $(c_x86_64))

$(c_obj_kernel): build/%.o : kernel/%.c
	@mkdir -p $(dir $@) && \
	gcc -m64 -c -I . -ffreestanding $(patsubst build/%.o, kernel/%.c, $@) -o $@

$(asm_obj_x86_64): build/%.o : x86_64/%.asm
	@mkdir -p $(dir $@) && \
	nasm -f elf64 $(patsubst build/%.o, x86_64/%.asm, $@) -o $@

$(c_obj_x86_64): build/%.o : x86_64/%.c
	@mkdir -p $(dir $@) && \
	gcc -m64 -c -I . -ffreestanding $(patsubst build/%.o, x86_64/%.c, $@) -o $@

.PHONY: x86_64
x86_64: $(c_obj_kernel) $(asm_obj_x86_64) $(c_obj_x86_64)
	@mkdir -p dist/ && \
	ld -m elf_x86_64 -n -o dist/kernel.bin -T link.ld $(c_obj_kernel) $(asm_obj_x86_64) $(c_obj_x86_64) && \
	mkdir -p iso/boot/grub/ && \
	cp dist/kernel.bin iso/boot/kernel.bin && \
	cp grub.cfg iso/boot/grub/grub.cfg && \
	grub-mkrescue /usr/lib/grub/i386-pc -o dist/build.iso iso/

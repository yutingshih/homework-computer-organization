RISC-V = ~/riscv/bin/riscv32-unknown-elf

.PHONY: all clean debug transform

all: debug transform

debug: add.dump
add.dump: add.elf
	$(RISC-V)-objdump -dC $< > $@

transform: add.mem
add.mem: add.elf
	$(RISC-V)-objcopy -O binary $< add.bin
	python3 bin2mem.py --bin add.bin --mem $@

add.elf: add.o
	$(RISC-V)-ld -b elf32-littleriscv -T link.ld -o $@ $^

add.o: add.s
	$(RISC-V)-as -mabi=ilp32 -o $@ $<

clean:
	-@$(RM) -rfv add.o add.elf add.bin add.mem add.dump

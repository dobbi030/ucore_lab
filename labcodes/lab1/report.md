## 练习1

### 解释Makefile 文件
```bash
gcc -Iboot/ -fno-builtin -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Os -nostdinc -c boot/bootasm.S -o obj/boot/bootasm.o
+ cc boot/bootmain.c
gcc -Iboot/ -fno-builtin -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Os -nostdinc -c boot/bootmain.c -o obj/boot/bootmain.o
+ cc tools/sign.c

```

由源码生成 .o 文件

```bash
ld -m    elf_i386 -nostdlib -N -e start -Ttext 0x7C00 obj/boot/bootasm.o obj/boot/bootmain.o -o obj/bootblock.o
'obj/bootblock.out' size: 492 bytes

```

链接 .o 文件生成执行程序

```bash
dd if=/dev/zero of=bin/ucore.img count=10000
```
把bootloader 放到一个虚拟硬盘中




### 一个被系统认为是符合规范的硬盘主引导扇区的特是什么？
- 1 文件符和stat 结构
- 2 文件bootblock.out不大于510 字节
- 3 文件bootblock 等512 字节

## 练习2

### 从CPU加电后执行的第一条指令开始， 单步跟踪BIOS的执行
Makefile 中的配置
```bash
debug: $(UCOREIMG)
	$(V)$(QEMU) -S -s -parallel stdio -hda $< -serial null &
	$(V)sleep 2
	$(V)$(TERMINAL) -e "gdb -q -tui -x tools/gdbinit"
```
gdbinit 中的配置
set architecture i8086
target remote :1234

## 分析bootloader 进入保护模式的过程. 
### 为何开启A20， 以及如何开A20
清理环境：包括将flag置0和将段寄存器置0
```c
.code16                                             # Assemble for 16-bit mode
    cli                                             # Disable interrupts
    cld                                             # String operations increment

    # Set up the important data segment registers (DS, ES, SS).
    xorw %ax, %ax                                   # Segment number zero
    movw %ax, %ds                                   # -> Data Segment
    movw %ax, %es                                   # -> Extra Segment
    movw %ax, %ss                                   # -> Stack Segment
```
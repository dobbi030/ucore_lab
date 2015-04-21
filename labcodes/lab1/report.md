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
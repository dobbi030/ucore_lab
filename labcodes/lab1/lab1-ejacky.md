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

## 练习3 分析bootloader 进入保护模式的过程. 
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
通过将键盘控制器上的A20线置于高电位，全部32条地址线可用， 可以访问4G的内存空间
```c
seta20.1:
    inb $0x64, %al                                  # Wait for not busy
    testb $0x2, %al
    jnz seta20.1

    movb $0xd1, %al                                 # 0xd1 -> port 0x64
    outb %al, $0x64

seta20.2:
    inb $0x64, %al                                  # Wait for not busy
    testb $0x2, %al
    jnz seta20.2

    movb $0xdf, %al                                 # 0xdf -> port 0x60
    outb %al, $0x60
```
初始化GDT表：一个简单的GDT表和其描述符已经静态储存在引导区中，载入即可
```c
    lgdt gdtdesc
```
进入保护模式：通过将cr0寄存器PE位置1便开启了保护模式
```c
    movl %cr0, %eax
    orl $CR0_PE_ON, %eax
    movl %eax, %cr0
```
通过长跳转更新cs的基地址
```c
    ljmp $PROT_MODE_CSEG, $protcseg

.code32                                             # Assemble for 32-bit mode
protcseg:
```
设置段寄存器，并建立堆栈
```c
    movw $PROT_MODE_DSEG, %ax                       # Our data segment selector
    movw %ax, %ds                                   # -> DS: Data Segment
    movw %ax, %es                                   # -> ES: Extra Segment
    movw %ax, %fs                                   # -> FS
    movw %ax, %gs                                   # -> GS
    movw %ax, %ss                                   # -> SS: Stack Segment

    # Set up the stack pointer and call into C. The stack region is from 0--start(0x7c00)
    movl $0x0, %ebp
    movl $start, %esp
```
转到保护模式完成，进入boot主方法
```c
call bootmain

```

## 练习4  分析bootloader加载elf格式的os 过程
读数据到内存的制定位置
```c
- 1 等待磁盘准备好
- 2 发出读取扇区的命令
- 3 等待磁盘准备好
- 4 把磁盘扇数据读到指定内存
static void
readsect(void *dst, uint32_t secno) {
    // wait for disk to be ready
    waitdisk();

    outb(0x1F2, 1);                         // count = 1
    outb(0x1F3, secno & 0xFF);
    outb(0x1F4, (secno >> 8) & 0xFF);
    outb(0x1F5, (secno >> 16) & 0xFF);
    outb(0x1F6, ((secno >> 24) & 0xF) | 0xE0);
    outb(0x1F7, 0x20);                      // cmd 0x20 - read sectors

    // wait for disk to be ready
    waitdisk();

    // read a sector
    insl(0x1F0, dst, SECTSIZE / 4);
}
```

扩展了函数readsect
```c
static void
readseg(uintptr_t va, uint32_t count, uint32_t offset) {
    uintptr_t end_va = va + count;

    // round down to sector boundary
    va -= offset % SECTSIZE;

    // translate from bytes to sectors; kernel starts at sector 1
    uint32_t secno = (offset / SECTSIZE) + 1;

    // If this is too slow, we could read lots of sectors at a time.
    // We'd write more to memory than asked, but it doesn't matter --
    // we load in increasing order.
    for (; va < end_va; va += SECTSIZE, secno ++) {
        readsect((void *)va, secno);
    }
}
```

bootmain主函数

```c
void
bootmain(void) {
    // 读磁盘的第一页
    readseg((uintptr_t)ELFHDR, SECTSIZE * 8, 0);

    // 判断是是elf 文件
    if (ELFHDR->e_magic != ELF_MAGIC) {
        goto bad;
    }

    struct proghdr *ph, *eph;

    // 加载每程段(ignores ph flags)
    ph = (struct proghdr *)((uintptr_t)ELFHDR + ELFHDR->e_phoff);
    eph = ph + ELFHDR->e_phnum;
    for (; ph < eph; ph ++) {
        readseg(ph->p_va & 0xFFFFFF, ph->p_memsz, ph->p_offset);
    }

    // elf 中调 入地址
    // note: does not return
    ((void (*)(void))(ELFHDR->e_entry & 0xFFFFFF))();

bad:
    outw(0x8A00, 0x8A00);
    outw(0x8A00, 0x8E00);

    /* do nothing */
    while (1);
}

```




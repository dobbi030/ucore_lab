### 练习1：分配并初始化一个进程控制块
* 请说明proc_struct中struct context context和struct trapframe *tf成员变量含义和在本实验中的作用是啥？
context：进程的上下文，用于进程切换（参见switch.S）。在 uCore中，所有的进程在内核中也是相对独立的（例如独立的内核堆栈以及上下文等等）。使用 context 保存寄存器的目的就在于在内核态中能够进行上下文之间的切换。实际利用context进行上下文切换的函数是在kern/process/switch.S中定义switch_to

tf：中断帧的指针，总是指向内核栈的某个位置：当进程从用户空间跳到内核空间时，中断帧记录了进程在被中断前的状态。当内核需要跳回用户空间时，需要调整中断帧以恢复让进程继续执行的各寄存器值。除此之外，uCore内核允许嵌套中断。因此为了保证嵌套中断发生时tf 总是能够指向当前的trapframe，uCore 在内核栈上维护了 tf 的链，可以参考trap.c::trap函数做进一步的了解

### 练习2：为新创建的内核线程分配资源
* 请说明ucore是否做到给每个新fork的线程一个唯一的id？请说明你的分析和理由

### 练习3：阅读代码，理解 proc_run 函数和它调用的函数如何完成进程切换的。
* 在本实验的执行过程中，创建且运行了几个内核线程？

* 语句local_intr_save(intr_flag);....local_intr_restore(intr_flag);在这里有何作用?请说明理由


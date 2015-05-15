### 练习1：分配并初始化一个进程控制块（需要编码）
#### 请说明proc_struct中struct context context和struct trapframe *tf成员变量含义和在本实验中的作用是啥？（提示通过看代码和编程调试可以判断出来）

### 练习2：为新创建的内核线程分配资源（需要编码）
#### 请说明ucore是否做到给每个新fork的线程一个唯一的id？请说明你的分析和理由

### 练习3：阅读代码，理解 proc_run 函数和它调用的函数如何完成进程切换的。（无编码工作）
#### 在本实验的执行过程中，创建且运行了几个内核线程？
#### 语句local_intr_save(intr_flag);....local_intr_restore(intr_flag);在这里有何作用?请说明理由

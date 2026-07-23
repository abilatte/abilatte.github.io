---
title: "Linux - 条件编译、库与 Makefile"
date: 2026-07-23T20:51:18+08:00
draft: false
categories: [Linux]
tags: [Linux]
---



## 条件编译

>   条件编译就是, 在预处理阶段决定包含或排除某些程序片段

主要的预处理指令如下 : 

```cpp
#if [#elif] [#else] #endif
#ifdef [#elif] [#else] #endif
#ifndef [#elif] [#else] #endif
```



### `#if`指令

```cpp
#if 常量表达式
...
#endif
```

当预处理器遇到`#if`时, 会计算后面常量表达式的值, 如果为`0`, 则`#if`和`#endif`之间的内容会在预处理阶段移除. 如果为非`0`, 代码会保留.

`#if`常用于调试程序

```cpp
#define DEBUG 1

#if DEBUG
    printf("i = %d\n", i);
    printf("j = %d\n", j);
#endif
```



### `defined`

`defined`是预处理器的一个运算符, 后面接标识符. 如果是一个定义过的宏则值为`1`, 否则为`0`

```cpp
#if defined(DEBUG)
// 括号不是必须的, 这种形式也可以
// #if defined DEBUG
...
#endif
```

`defined`仅检测`DEBUG`是否有定义, 不关心宏的值, 因此可以只定义宏名而不赋值

```cpp
#define DEBUG
```



### `#ifdef`

```cpp
#ifdef 标识符
// 等价于
// #if defined(标识符)
...
#endif
```

只有当标识符有被定义为宏的时候, 保留`#ifdef`和`#endif`之间的代码. 否则删除代码



### `#ifndef`

```cpp
#ifndef 标识符
...
#endif
```

作用与`#ifdef`相反, 当标识符没有被定义为宏时, 保留代码



### 头文件保护

>   `#ifndef`最常见的用途是做头文件保护, 防止同一个头文件被重复包含

如果多个源文件都`#include "algs.h"`, 或者头文件之间相互包含, 同一份头文件内容可能在一次编译中被展开多次, 容易引起重复定义. 头文件保护的写法如下 : 

```cpp
#ifndef ALGS_H
#define ALGS_H

// 头文件内容

#endif
```

1.  第一次包含时, `ALGS_H`尚未定义, 进入`#ifndef`, 立刻`#define ALGS_H`, 再保留后面的内容
2.  再次包含时, `ALGS_H`已经有定义, `#ifndef`条件不成立, 整段内容被跳过

宏名习惯用头文件名的大写形式, 并把`.`换成`_`, 例如`algs.h`对应`ALGS_H`



## 静态库与动态库

>   库是写好的, 可以复用的代码.
>
>   库有两种 : 静态库和动态库, 二者的格式如下 : 
>
>   静态库 : 类Unix `.a`, Windows `.lib`
>
>   动态库 : 类Unix `.so`, Windows `.dll`



### 静态库

>   在Linux中, 静态库以`lib`为前缀, `.a`为后缀, 中间是库名 : `libXXX.a`
>
>   在Windows中, 静态库扩展名一般为`.lib`, 具体命名随工具链而定

-   特点 :

    -   静态库对函数的链接是在链接阶段完成的
    -   静态库被打包到应用程序中加载速度快
    -   发布程序无需提供静态库, 移植方便

    -   浪费空间, 每个可执行程序都会各自带上一份库代码



### 动态库

>   在Linux中, 动态库以`lib`为前缀, `.so`为后缀, 中间是库名 : `libXXX.so`
>
>   在Windows中, 动态库扩展名一般为`.dll`, 具体命名随工具链而定

-   特点 :

    -   动态库对程序的链接是在运行时完成的
    -   可执行程序体积小
    -   可实现不同进程之间的资源共享

    -   发布程序需要提供依赖的动态库



## Makefile

>   Makefile 定义了整个工程的编译规则.
>
>   Makefile 采用的是"增量编译", 也就是只编译那些更新过的和新增的源文件

示例 : 

```makefile
main: main.o add.o sub.o mul.o div.o
	gcc main.o add.o sub.o mul.o div.o -o main
main.o: main.c algs.h
	gcc -c main.c -Wall -g
add.o: add.c algs.h
	gcc -c add.c -Wall -g
sub.o: sub.c algs.h
	gcc -c sub.c -Wall -g
mul.o: mul.c algs.h
	gcc -c mul.c -Wall -g
div.o: div.c algs.h
	gcc -c div.c -Wall -g
```



### 规则

>   Makefile 的核心就是规则, 一个规则由三部分构成 : 目标(target), 依赖(prerequisites), 命令(commands)

```makefile
target: prerequisites
	commands
# target : 要生成的目标文件
# prerequisites : 生成目标文件需要的依赖文件
# commands : 生成该目标所执行的命令
```

1.  如果`target`不存在, 执行`commands`
2.  如果`prerequisites`中有任意文件更新, 也要执行`commands`
3.  Makefile 会递归的去查找文件之间的依赖关系, 直到最终生成目标文件



### 伪目标

```makefile
main: main.o add.o sub.o mul.o div.o
	gcc main.o add.o sub.o mul.o div.o -o main
main.o: main.c algs.h
	gcc -c main.c -Wall -g
add.o: add.c algs.h
	gcc -c add.c -Wall -g
sub.o: sub.c algs.h
	gcc -c sub.c -Wall -g
mul.o: mul.c algs.h
	gcc -c mul.c -Wall -g
div.o: div.c algs.h
	gcc -c div.c -Wall -g
	
clean: 
	rm -f main main.o add.o sub.o mul.o div.o
rebuild: clean main
```



```bash
# 清除可执行程序和所有目标文件
$ make clean
# 先清除, 然后再构建
$ make rebuild
```

>   如果目录中有名字为 clean 或 rebuild 的文件, 那么`make clean`和`make rebuild`就不起作用了, 将其添加到`.PHONY`可以避免这种情况发生

```makefile
...
.PHONY: clean rebuild
clean: 
	rm -f main main.o add.o sub.o mul.o div.o
rebuild: clean main
```



### 自定义变量

```makefile
Objs := main.o add.o sub.o mul.o div.o 
Out := main

$(Out): $(Objs)
	gcc $(Objs) -o $(Out)
main.o: main.c algs.h
	gcc -c main.c -Wall -g
add.o: add.c algs.h
	gcc -c add.c -Wall -g
sub.o: sub.c algs.h
	gcc -c sub.c -Wall -g
mul.o: mul.c algs.h
	gcc -c mul.c -Wall -g
div.o: div.c algs.h
	gcc -c div.c -Wall -g
	
.PHONY: clean rebuild
clean: 
	rm -f $(Out) $(Objs)
rebuild: clean $(Out)
```



### 预定义变量

|  变量名  |     功能      |  默认含义  |
| :------: | :-----------: | :--------: |
|    AR    |  打包库文件   |    `ar`    |
|    AS    |   汇编程序    |    `as`    |
|    CC    |    C编译器    |    `cc`    |
|   CPP    |   C预编译器   | `$(CC) -E` |
|   CXX    |   C++编译器   |   `g++`    |
|    RM    |     删除      |  `rm -f`   |
| ARFLAGS  |    库选项     |     -      |
| ASFLAGS  |   汇编选项    |     -      |
|  CFLAGS  |  C编译器选项  |     -      |
| CPPFLAGS | C预编译器选项 |     -      |
| CXXFLAGS | C++编译器选项 |     -      |

至此可以将刚才的 Makefile 改写为 : 

```makefile
Objs := main.o add.o sub.o mul.o div.o 
Out := main
CC := gcc
CFLAGS := -Wall -g

$(Out): $(Objs)
	$(CC) $(Objs) -o $(Out)
main.o: main.c algs.h
	$(CC) -c main.c $(CFLAGS)
add.o: add.c algs.h
	$(CC) -c add.c $(CFLAGS)
sub.o: sub.c algs.h
	$(CC) -c sub.c $(CFLAGS)
mul.o: mul.c algs.h
	$(CC) -c mul.c $(CFLAGS)
div.o: div.c algs.h
	$(CC) -c div.c $(CFLAGS)
	
.PHONY: clean rebuild
clean: 
	$(RM) $(Out) $(Objs)
rebuild: clean $(Out)
```



### 规则中的特殊变量

| 变量名 |              含义              |
| :----: | :----------------------------: |
|  `$@`  |              目标              |
|  `$<`  |         第一个依赖文件         |
|  `$^`  |    所有依赖文件, 以空格分隔    |
|  `$?`  | 所有日期新于`target`的依赖文件 |

引用特殊变量后, 又可以改写为 : 

```makefile
Objs := main.o add.o sub.o mul.o div.o 
Out := main
CC := gcc
CFLAGS := -Wall -g

$(Out): $(Objs)
	$(CC) $^ -o $@
main.o: main.c algs.h
	$(CC) -c $< $(CFLAGS)
add.o: add.c algs.h
	$(CC) -c $< $(CFLAGS)
sub.o: sub.c algs.h
	$(CC) -c $< $(CFLAGS)
mul.o: mul.c algs.h
	$(CC) -c $< $(CFLAGS)
div.o: div.c algs.h
	$(CC) -c $< $(CFLAGS)
	
.PHONY: clean rebuild
clean: 
	$(RM) $(Out) $(Objs)
rebuild: clean $(Out)
```

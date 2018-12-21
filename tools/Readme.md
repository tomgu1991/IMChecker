# Usage of IMChecker Toolkit

Our tools depends on:

1. [clang-3.9](http://releases.llvm.org/3.9.0/)
   * after installing clang-3.9, we have to setup a symlink for clang, llvm-dis and llvm-link, for we use these command in our tool to preprocess the source code
   ```shell
   sudo ln -s /usr/bin/clang-3.9 /usr/local/bin/clang
   sudo ln -s /usr/bin/llvm-link-3.9 /usr/local/bin/llvm-link
   sudo ln -s /usr/bin/dis-3.9 /usr/local/bin/llvm-dis
   ```
2. java8
3. python3 & python2.7

IMChecker is still under development, and contains a lot of bugs and TODO lists. Any bugs or feature requests, feel free to email us at guzx14@mails.tsinghua.edu.cn or open issues.

### Brief usage

Our tool demonstration video is available at 

English Version: 
https://youtu.be/YGDxeyOEVIM

Chinese Version: 

https://www.youtube.com/watch?v=3ZAneGTwUto

https://pan.baidu.com/s/1diGQ0R6Wk5sHHmlOTk9kbg

Basically, usage of our tool consists of three steps:

1. create the API usage specification

   ```shell
   [~/IMChecker/tools]$python3 imspec_writer.py
   ```

   The usage of IMSpec Writer client can be found below.

   Users also can write the specification from scratch according to the syntax of IMSpec.

2. run the analysis engine

   ```shell
   [~/IMChecker/tools]$python3 engine.py --spec=spec.yaml --specDefine=define.h --input=example_code/[example.ll | example.c]
   ```

   * -- spec: is the specification location
   * --specDefine: is the macros definition file. If no macros, it can be omitted.
   * --input: is the target analysis file 

   Currently, we accept a compilable C file or LLVM-IR file. To generate IR file, run the command (**-g is used to generate debug information for report_displayer**)

   ```shell
   [~/IMChecker/tools/example_code]$clang-3.9 -S -emit-llvm -g example.c
   ```

   For projects with a Makefile, we provide a build-capture tools to help users generate LLVM-IR files. See the build-capture part for details. Our algorithm is based on under-constrained symbolic execution, therefore, we analyze from a single function entry. That is, we do not need all the source codes. For the function without definition, we simply skip them. It may lose accuracy, but it provides a strong analysis context for any compilable C files.

3. audit the result

   ```shell
   [~/IMChecker/tools]$python3 report_displayer.py
   ```

### IMSpec Writer

#### What is it

This is a graphical user interface (GUI) for user to write IMSpec. For information of IMSpec, please refer to IMChecker.

#### How to use it

Prerequisites

* python3-tk

  ```
  sudo apt-get install python3-tk
  ```

* python3

  * pyyaml

    ```shell
    pip install pyyaml
    ```

Run

After you satisfy the prerequisites, simply run:

```shell
python imspec_writer.py
```

#### User menu

IMSpec syntax

Here is the abstract syntax of IMSpec, for detailed information, please refer to IMChecker Paper.

![abstract_syntax](pics/abstract_syntax.png)

Main window

The main window is as shown below:

![main_window](pics/main_window.png)

The main window consists of several parts:

* short spec display box (red rectangle): used to display short version of spec string (introduced below)
* define loading button (yellow rectangle): used to load define file
* file saving or loading (blue rectangle): used to save to or load from file
* spec writing area (green rectangle): used to write spec
* confirm or clear (purple rectangle): used to confirm spec or clear all fields

#### How to write a spec

We will mainly introduce how to write a spec using IMSpec Writer.

1. `Target` field

   `Target` is a 'must' in IMSpec, it is a `fDef`, which consists of a `fName`, a list of `type` denoting parameters' types (`par_type`) and a `type` denoting return value type (`ret_type`). User must fill in all these fields in the `Target` area.

   User can input `_` in any `type` fields meaning that "this type is not concerned".

   In `par_type` area, user can click "add/del a par type" button to add/delete a `par_type` field.

2. `Ref` field

   `Ref` is **not** a 'must' in IMSpec, it is a set of `fDef`. Functions defined in `Ref` field must be appeared in `Post`. After the `Enable` checkbox is checked, user can click the `add ref` button to add a `fDef` frame, where user can enter the `Ref` field. User can also delete a ref fDef frame by clicking the `del ref` button.

3. `Pre` field

   `Pre` is **not** a 'must' in IMSpec, it is a set of `assume`. `assume` is a denoted by `opd1 cmpop opd2`, where `opd` means operand and `cmpop` means comparative operator. For detailed information about `assume` please refer to IMChecker paper. `Pre` field contains 0 or multiple `assume` instances. User can easily add or delete `pre` condition by clicking `add a pre cond` or `del a pre cond` button after the `Pre` checkbox is checked.

4. `Post` field

   `Post` is **not** a 'must' in IMSpec, it is a set of tuples (`eh`,`action∗`). `eh` means error handling condition, it is an `assume`, or `None` for no-condition. `action` is a `return` or a `call` or a `endwith`. For detailed information about `action` please refer to IMChecker paper.

When user done writing a spec instance, simply clicks the `confirm spec` button, the spec instance will be added to the memory and a short version of this spec instance will be displayed in the display box (the red rectangle). If the user wants to discard the unsaved spec instance, simply clicks the `clear all` button, then the whole spec writing area will be re-constructed.

User can delete a saved spec instance by clicking the `-` button under the short spec display box after selecting a spec instance in the display box.

#### Define file

Like Linux or other large projects, developers may use macros to denote error number or other meaningful output, IMSpec Writer accepts these macros as inputs as long as user load a `define file`. A define file is completely same as a `c` macro format file as follow:

```c
#define	EPERM		 1	/* Operation not permitted */
#define	ENOENT		 2	/* No such file or directory */
#define	ESRCH		 3	/* No such process */
#define	EINTR		 4	/* Interrupted system call */
#define	EIO			 5	/* I/O error */
#define	ENXIO		 6	/* No such device or address */
#define	E2BIG		 7	/* Argument list too long */
#define	ENOEXEC		 8	/* Exec format error */
#define	EBADF		 9	/* Bad file number */
#define	ECHILD		10	/* No child processes */
```

Simply click the `load define file` button and choose the define file. Or click the `clear define file location` button to clear the define file path.

#### Save-to/Load-from file

User can save the spec instances saved in memory (that is, all spec instances shown in display box) in `.yaml` format. Simply click the `save to file` button and select a destination will do the job.

User can also load spec from a previously-defined spec instance file by clicking the `load from file` button and select the file.

#### Write from scratch

Users also can write the spec from scratch according to the syntax of IMSpec referring the in `imspec` folder.

### Result Displayer

As shown below, we provde a displayer to help users audit the analysis results.

![displayer](pics/Displayer.png)



### Build Capture

Build capture tool is designed for capturing the build process of a Makefile project. Basically, it will save all the single lines of $CC$ and re-make the project to produce all the intermediate results.

That is, we can produce all the *.i files, which is a self-contained preprocessed files. Then for each *.i files, we can generate the LLVM-IR files clang. For example, 

```shell
[~/IMChecker/tools/example_code]$gcc -E example.c -o exmaple.i
[~/IMChecker/tools/example_code]$clang-3.9 -S -emit-llvm -g example.i
```

We have provide part of build-capture result of Openssl-1.1.1-pre8 in `build-cpature` folders.

In theory, any projects supported by clang can be build-capture by our tool. However, clang is different from gcc. Therefore, we suggest to replace the $CC$ in Makefile by clang-3.9, such as

```makefile
CROSS_COMPILE=
CC=$(CROSS_COMPILE)clang
```

In this way, all the *.i files can be compiled by clang to generate LLVM-IR files. 

For multiple LLVM-IR files, use the following command to combine them and use as our tool,

```shell
llvm-link a.ll b.ll -o output.bc
llvm-dis output.bc -o input4engine.ll
```

Unfortunately, build-capture tool is under the patient application process. Therefore, we cannot provide the tool here. When available, we will upload ASAP.

#### Hints

Here, we provide hints to implement build-capture. The key insight here it to capture the `make -n` command and parse the output. 

Employ OpenSSL as example:

```shell
> cd openssl
> make -n
```

We can catch lines like these,

```shell
/usr/bin/perl "-I." -Mconfigdata "util/dofile.pl" \
    "-oMakefile" crypto/include/internal/bn_conf.h.in > crypto/include/internal/bn_conf.h
/usr/bin/perl "-I." -Mconfigdata "util/dofile.pl" \
    "-oMakefile" crypto/include/internal/dso_conf.h.in > crypto/include/internal/dso_conf.h
/usr/bin/perl "-I." -Mconfigdata "util/dofile.pl" \
    "-oMakefile" include/openssl/opensslconf.h.in > include/openssl/opensslconf.h
make depend && make _all
make[1]: Entering directory '/home/guzuxing/Desktop/openssl-OpenSSL_1_1_1-pre8_patched'
: 
/usr/bin/perl ./util/add-depends.pl gcc
: 
make[1]: Leaving directory '/home/guzuxing/Desktop/openssl-OpenSSL_1_1_1-pre8_patched'
make[1]: Entering directory '/home/guzuxing/Desktop/openssl-OpenSSL_1_1_1-pre8_patched'
/usr/bin/perl "-I." -Mconfigdata "util/dofile.pl" \
    "-oMakefile" include/openssl/opensslconf.h.in > include/openssl/opensslconf.h
clang  -I. -Iinclude -fPIC -pthread -m64 -Wa,--noexecstack -Wall -O3 -DOPENSSL_USE_NODELETE -DL_ENDIAN -DOPENSSL_PIC -DOPENSSL_CPUID_OBJ -DOPENSSL_IA32_SSE2 -DOPENSSL_BN_ASM_MONT -DOPENSSL_BN_ASM_MONT5 -DOPENSSL_BN_ASM_GF2m -DSHA1_ASM -DSHA256_ASM -DSHA512_ASM -DKECCAK1600_ASM -DRC4_ASM -DMD5_ASM -DAES_ASM -DVPAES_ASM -DBSAES_ASM -DGHASH_ASM -DECP_NISTZ256_ASM -DX25519_ASM -DPADLOCK_ASM -DPOLY1305_ASM -DOPENSSLDIR="\"/usr/local/ssl\"" -DENGINESDIR="\"/usr/local/lib/engines-1.1\"" -DNDEBUG  -MMD -MF apps/app_rand.d.tmp -MT apps/app_rand.o -c -o apps/app_rand.o apps/app_rand.c
```

Then, we can re-execute the commands. For clang/gcc to compile a C file, we can do the command once and replace `-c` by `-E` to generate the preprocessed files *.i

````shell
clang  -I. -Iinclude -fPIC -pthread -m64 -Wa,--noexecstack -Wall -O3 -DOPENSSL_USE_NODELETE -DL_ENDIAN -DOPENSSL_PIC -DOPENSSL_CPUID_OBJ -DOPENSSL_IA32_SSE2 -DOPENSSL_BN_ASM_MONT -DOPENSSL_BN_ASM_MONT5 -DOPENSSL_BN_ASM_GF2m -DSHA1_ASM -DSHA256_ASM -DSHA512_ASM -DKECCAK1600_ASM -DRC4_ASM -DMD5_ASM -DAES_ASM -DVPAES_ASM -DBSAES_ASM -DGHASH_ASM -DECP_NISTZ256_ASM -DX25519_ASM -DPADLOCK_ASM -DPOLY1305_ASM -DOPENSSLDIR="\"/usr/local/ssl\"" -DENGINESDIR="\"/usr/local/lib/engines-1.1\"" -DNDEBUG  -MMD -MF apps/app_rand.d.tmp -MT apps/app_rand.o -E -o apps/app_rand.o apps/app_rand.c
````

At last, we can copy this *.i file to a folder.

For another example from Linux-kernel. Linux-kernel cannot be support completely by clang. We can directly make a single file by

```shell
> make drivers/bluetooth/bfusb.o -n
```

Then, we catch these line

```shell
make -f ./scripts/Makefile.build obj=arch/x86/entry/syscalls all
// omit
make -f ./scripts/Makefile.build obj=drivers/bluetooth drivers/bluetooth/bfusb.o
set -e; 	   echo '  CC [M]  drivers/bluetooth/bfusb.o'; 
gcc -Wp,-MD,drivers/bluetooth/.bfusb.o.d  -nostdinc -isystem /usr/lib/gcc/x86_64-linux-gnu/5/include -I./arch/x86/include -I./arch/x86/include/generated  -I./include -I./arch/x86/include/uapi -I./arch/x86/include/generated/uapi -I./include/uapi -I./include/generated/uapi -include ./include/linux/kconfig.h -include ./include/linux/compiler_types.h -D__KERNEL__ -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -fshort-wchar -Werror-implicit-function-declaration -Wno-format-security -std=gnu89 -fno-PIE -DCC_HAVE_ASM_GOTO -mno-sse -mno-mmx -mno-sse2 -mno-3dnow -mno-avx -m64 -falign-jumps=1 -falign-loops=1 -mno-80387 -mno-fp-ret-in-387 -mpreferred-stack-boundary=3 -mskip-rax-setup -mtune=generic -mno-red-zone -mcmodel=kernel -funit-at-a-time -DCONFIG_X86_X32_ABI -DCONFIG_AS_CFI=1 -DCONFIG_AS_CFI_SIGNAL_FRAME=1 -DCONFIG_AS_CFI_SECTIONS=1 -DCONFIG_AS_FXSAVEQ=1 -DCONFIG_AS_SSSE3=1 -DCONFIG_AS_CRC32=1 -DCONFIG_AS_AVX=1 -DCONFIG_AS_AVX2=1 -DCONFIG_AS_AVX512=1 -DCONFIG_AS_SHA1_NI=1 -DCONFIG_AS_SHA256_NI=1 -pipe -Wno-sign-compare -fno-asynchronous-unwind-tables -mindirect-branch=thunk-extern -mindirect-branch-register -DRETPOLINE -fno-delete-null-pointer-checks -O2 --param=allow-store-data-races=0 -Wframe-larger-than=1024 -fstack-protector-strong -Wno-unused-but-set-variable -fno-var-tracking-assignments -g -gdwarf-4 -pg -mfentry -DCC_USING_FENTRY -Wdeclaration-after-statement -Wno-pointer-sign -fno-strict-overflow -fno-merge-all-constants -fmerge-constants -fno-stack-check -fconserve-stack -Werror=implicit-int -Werror=strict-prototypes -Werror=date-time -Werror=incompatible-pointer-types -Werror=designated-init -mrecord-mcount  -DMODULE  -DKBUILD_BASENAME='"bfusb"' -DKBUILD_MODNAME='"bfusb"' -c -o drivers/bluetooth/.tmp_bfusb.o drivers/bluetooth/bfusb.c
// omit
```

Therefore, we can do as above to produce a single *.i file. Then, use clang to generate *.ll file. For the files cannot supported by clang, we just omit them.

@echo off
echo Compiling Bootloader
if exist boot.o del boot.o
nasm -f bin boot.asm -o boot.o
if exist boot.o goto compileKernel
goto eof

:compileKernel
echo Compiling Kernel
if exist kernel.o del kernel.o
nasm -f bin kernel.asm -o kernel.o
if exist kernel.o goto compilePadding
goto eof

:compilePadding
echo Compiling Padding
if exist padding.o del padding.o
nasm -f bin padding.asm -o padding.o
if exist padding.o goto combineImage
goto eof

:combineImage
if exist os.img del os.img
copy /b boot.o + kernel.o + padding.o os.img

:cleanUp
echo Cleaning Up
del boot.o kernel.o padding.o

:run
run.bat

:eof

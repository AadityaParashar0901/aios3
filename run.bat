@echo off
qemu-system-x86_64 -fda os.img -monitor stdio -display gtk,zoom-to-fit=on,show-tabs=on

This project demonstrates how make can be integrated into a project using Unity testing and subdirectories.

The makefile recreates the structure of the src and test files in the build directory by using the shell find command.
The makefile then finds the test results by using the recursive grep command.

The only hardcoded directories are src/ include/ test/ unity/ .  The structure of the test/ and include/ directories should mirror the src/ structure, i.e. if src/module/colors.c then test/module/colorsTest.c and include/module/colors.h .



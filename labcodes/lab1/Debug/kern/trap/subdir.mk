################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../kern/trap/trap.c 

S_UPPER_SRCS += \
../kern/trap/trapentry.S \
../kern/trap/vectors.S 

OBJS += \
./kern/trap/trap.o \
./kern/trap/trapentry.o \
./kern/trap/vectors.o 

C_DEPS += \
./kern/trap/trap.d 


# Each subdirectory must supply rules for building sources it contributes
kern/trap/%.o: ../kern/trap/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: Cross GCC Compiler'
	gcc -I/usr/include/x86_64-linux-gnu -I/usr/include/x86_64-linux-gnu/bits/ -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

kern/trap/%.o: ../kern/trap/%.S
	@echo 'Building file: $<'
	@echo 'Invoking: Cross GCC Assembler'
	as  -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '



################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../kern/init/init.c 

OBJS += \
./kern/init/init.o 

C_DEPS += \
./kern/init/init.d 


# Each subdirectory must supply rules for building sources it contributes
kern/init/%.o: ../kern/init/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: Cross GCC Compiler'
	gcc -I/usr/include/x86_64-linux-gnu -I/usr/include/x86_64-linux-gnu/bits/ -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '



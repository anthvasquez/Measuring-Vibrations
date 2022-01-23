#ifndef UARTDRIVER_HPP
#define UARTDRIVER_HPP

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <pthread.h>
#include <thread>

#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <time.h>

#include <string>

#ifdef __linux__
    #include <wiringSerial.h>
#endif
#ifdef __APPLE__
    #include "FPGAVibrations.cpp"
#endif

class UARTDriver {
	private:
		int serial_fd;

		void ReadLoop();
		void UARTCallback(char** data);

	public:
		UARTDriver();
		~UARTDriver();
};

#endif

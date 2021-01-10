#include "UARTDriver.hpp"

UARTDriver::UARTDriver()
{
	serial_fd = serialOpen("/dev/serial0", 9600);
	//int serialFd = open("/dev/serial0", O_RDWR);
	if(serial_fd == -1)
	{
		printf("Couldn't open file.\n");
	}

	//spawn read thread using pthread_create
}

UARTDriver::~UARTDriver()
{
	serialClose(serial_fd);
}

void UARTDriver::UARTCallback(char** data)
{

}

void UARTDriver::ReadLoop()
{
	std::string message = "1234";
	write(serial_fd, message.c_str(), message.length());

	int delay_milli = 500;
	clock_t start_time = clock();
	while(clock() < start_time + delay_milli);

	char* recvBuf = (char*)calloc(message.length(), sizeof(char));
	read(serial_fd, recvBuf, message.length());

	printf("Received: %s\n", recvBuf);
	UARTDriver::UARTCallback(&recvBuf);
}

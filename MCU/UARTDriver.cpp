
UARTDriver::UARTDriver()
{
	serial_fd = serialOpen("/dev/serial0", 9600);
	//int serialFd = open("/dev/serial0", O_RDWR);
	if(serialFd == -1)
	{
		printf("Couldn't open file.\n");
	}

	//spawn read thread using pthread_create
}

UARTDriver::~UARTDriver()
{
	serialClose(serialFd);
}

void UARTDriver::UARTCallback(char** data)
{

}

void UARTDriver::ReadLoop()
{
	char* message = "1234";
	write(serialFd, message, strlen(message));

	int delay_milli = 500;
	clock_t start_time = clock();
	while(clock() < start_time + delay_milli);

	char* recvBuf = calloc(strlen(message), sizeof(char));
	read(serialFd, recvBuf, strlen(message));

	printf("Received: %s\n", recvBuf);
	UARTDriver::UARTCallback(&recvBuf);

	close(serialFd);

}

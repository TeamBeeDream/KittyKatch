// KittyKatch.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"

extern "C" {
#include "kittykatchtests.h"
}

int main()
{
	// Launching KittyKatch.exe just runs the unit tests.
	// Prints the results to the console.
	runAllTests();

    return 0;
}


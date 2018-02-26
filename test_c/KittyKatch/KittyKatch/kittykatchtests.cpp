#include <stdlib.h>
#include <stdio.h>
#include <assert.h>

#include "kittykatchtests.h"
#include "position.h"

void runPositionerTests();

void runAllTests() {

	runPositionerTests();
}

void runPositionerTests()
{
	/* TEMPLATE
	// TEST
	printf("TEST %i - test_positioner_template - ", ++test_count);
	Positioner pX;
	positioner_init(&pX, 0.2f, 1.0f);
	positioner_free(&pX);
	printf("COMPLETE\n");
	*/
	
	printf("-----Positioner Tests-----\n");
	int test_count = 0;
	
	// TEST
	printf("TEST %i - test_positioner_init_and_free - ", ++test_count);
	Positioner p1;
	positioner_init(&p1, 0.2f, 1.0f);
	positioner_free(&p1);
	printf("COMPLETE\n");

	// TEST
	printf("TEST %i - test_positioner_add_input - ", ++test_count);
	Positioner p2;
	positioner_init(&p2, 0.2f, 1.0f);
	positioner_add_input(&p2, -1.0f);
	positioner_update(&p2, 1.0f);
	Position pos1;
	positioner_get_position(&p2, &pos1);
	assert(pos1.lane == -1.0f);
	positioner_free(&p2);
	printf("COMPLETE\n");

	// TEST
	printf("TEST %i - test_positioner_add_then_remove_input - ", ++test_count);
	Positioner p3;
	positioner_init(&p3, 0.2f, 1.0f);
	positioner_add_input(&p3, -1.0f);
	positioner_update(&p3, 1.0f);
	Position pos2;
	positioner_get_position(&p3, &pos2);
	assert(pos2.lane == -1.0f);
	positioner_remove_input(&p3);
	positioner_update(&p3, 1.0f);
	positioner_get_position(&p3, &pos2);
	assert(pos2.lane == 0.0f);
	positioner_free(&p3);
	printf("COMPLETE\n");

	printf("-----Complete!-----\n");
}
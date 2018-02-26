#include <stdbool.h>
#include <assert.h>
#include <math.h>

#include "position.h"

void positioner_init(Positioner* positioner, float tolerance, float timeToMove) {
	positioner->tolerance = tolerance;
	positioner->timeToMove = timeToMove;
	positioner->inputCount = 0;
	positioner->targetPosition = 0.0f;
	positioner->currentPosition = 0.0f;
}

void positioner_free(Positioner* positioner) {
	// @TODO: Free Positioner struct.
}

void positioner_add_input(Positioner* positioner, float input) {
	// Assert that input is one of the valid lanes.
	assert((input == LEFT) || (input == CENTER) || (input == RIGHT));

	positioner->inputCount++;
	positioner->targetPosition = input;
}

void positioner_remove_input(Positioner* positioner) {
	positioner->inputCount--;
	if (positioner->inputCount == 0) {
		positioner->targetPosition = CENTER; // By default, return to center.
	}
}

void positioner_update(Positioner* positioner, float dt) {
	// @FIXME: this update loop will bug out if the dt is above 1 second.
	assert(dt >= 0 && dt <= 1);

	float diff = positioner->targetPosition - positioner->currentPosition;
	float step = dt / positioner->timeToMove;

	positioner->currentPosition += diff * step;
}

float laneValue(Lane lane) {
	switch (lane) {
	case LEFT_LANE:		return -1.0f;
	case CENTER_LANE:	return  0.0f;
	case RIGHT_LANE:	return  1.0f;
	}
}

bool inLane(Positioner* positioner, Lane lane) {
	return fabsf(positioner->currentPosition - laneValue(lane)) < positioner->tolerance;
}

void positioner_get_position(Positioner* positioner, Position* position) {
	if (inLane(positioner, LEFT_LANE)) {
		position->lane = LEFT;	// @ROBUSTNESS: Should we use #LEFT or #LEFT_LANE?
		position->offset = positioner->currentPosition;
		position->state = IN_LANE;
	} else if (inLane(positioner, CENTER_LANE)) {
		position->lane = CENTER; // @ROBUSTNESS: Should we use #CENTER or #CENTER_LANE?
		position->offset = positioner->currentPosition;
		position->state = IN_LANE;
	} else if (inLane(positioner, RIGHT_LANE)) {
		position->lane = RIGHT; // @ROBUSTNESS: Should we use #RIGHT or #RIGHT_LANE?
		position->offset = positioner->currentPosition;
		position->state = IN_LANE;
	} else {
		position->lane = positioner->targetPosition;
		position->offset = positioner->currentPosition;
		position->state = BETWEEN_LANES;
	}
}
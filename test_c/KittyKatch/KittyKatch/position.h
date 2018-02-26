#pragma once

typedef enum {
	LEFT_LANE,
	CENTER_LANE,
	RIGHT_LANE,
} Lane;

#define LEFT	-1.0f
#define CENTER	 0.0f
#define RIGHT	 1.0f

typedef enum {
	IN_LANE,
	BETWEEN_LANES,
} PositionState;

typedef struct {
	float offset;
	int lane;
	PositionState state;
} Position;

typedef struct {
	float tolerance;
	float timeToMove;
	int inputCount;
	float targetPosition;
	float currentPosition;
} Positioner;

void positioner_init(Positioner* positioner, float tolerance, float timeToMove);
void positioner_free(Positioner* positioner);

void positioner_add_input(Positioner* positioner, float input);
void positioner_remove_input(Positioner* positioner);

void positioner_update(Positioner* positioner, float dt);
void positioner_get_position(Positioner* positioner, Position* position);
#ifndef MAP_H
#define MAP_H

const double NULL_DOUBLE = 1.7976931348623e+308;
const int CAPACITY_MULTIPLIER = 2;

typedef struct {
	char* key;
	double value;
} Pair;

typedef struct {
	Pair* pairs;
	int size;
	int capacity;
} Map;

void Map_init(Map* map, int capacity);

void Map_put(Map* map, char* key, double value);

double Map_get(Map* map, char* key);

int Map_set(Map* map, char* key, double value);

#endif
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "map.h"

/**
 * A struct to hold a pair of key and value.
 * @param key The key of the pair as a string.
 * @param value The value of the pair as a double.
 */
typedef struct {
  char* key;
  double value;
} Pair;

/**
 * A struct to hold a map of pairs.
 * @param pairs The pairs of the map.
 * @param size The number of pairs in the map.
 * @param capacity The maximum number of pairs the map can hold.
 */
typedef struct {
  Pair* pairs;
  int size;
  int capacity;
} Map;

/**
 * Map constructor.
 * @param map The map to initialize.
 * @param capacity The maximum number of pairs the map can hold.
 */
void Map_init(Map* map, int capacity) {
  map->size = 0;
  map->capacity = capacity;

  // allocate memory for the pairs
  map->pairs = (Pair*)malloc(sizeof(Pair) * map->capacity);
}

/**
 * Insert a new pair to the map.
 * @param map The map to insert the pair to.
 * @param key The key of the pair.
 * @param value The value of the pair.
 */
void Map_put(Map* map, char* key, double value) {
  // check if the map is full
  if (map->size == map->capacity) {
    // Double the capacity of the map
    map->capacity *= CAPACITY_MULTIPLIER;

    // allocate memory for the new capacity of pairs
    Pair* temp = (Pair*)malloc(sizeof(Pair) * map->capacity);

    // copy the old pairs to the new memory
    memcpy(
      temp, // destination
      map->pairs, // source
      sizeof(Pair) * map->size // number of bytes to copy
    );

    // free the old memory of pairs
    free(map->pairs);

    // assign the new memory of pairs
    map->pairs = temp;
  }

  map->pairs[map->size].key = key;
  map->pairs[map->size].value = value;

  map->size++;
}

/**
 * Get the value of a pair with the given key.
 * @param map The map to search in.
 * @param key The key of the pair to search for.
 * @return The value of the pair with the given key. If the key is not found, return -1.0.
 */
double Map_get(Map* map, char* key) {
  for (int i = 0; i < map->size; i++) {
    // compare the key of the pair with the given key
    if (strcmp(map->pairs[i].key, key) == 0) {
      return map->pairs[i].value;
    }
  }

  return NULL_DOUBLE;
}

/**
 * Set the value of a pair with the given key.
 * @param map The map to search in.
 * @param key The key of the pair to search for.
 * @param value The new value of the pair.
 * @return 1 if the key is found and the value is set. Otherwise, return 0.
 */
int Map_set(Map* map, char* key, double value) {
  for (int i = 0; i < map->size; i++) {
    if (strcmp(map->pairs[i].key, key) == 0) {
      map->pairs[i].value = value;
      return 1;
    }
  }

  return 0;
}

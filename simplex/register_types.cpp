/* register_types.cpp */

#include "register_types.h"

// For Godot 2.x
#include "object_type_db.h"

// For Godot 3.0
// #include "class_db.h"

#include "simplex.h"

void register_simplex_types() {

	// For Godot 2.0
	ObjectTypeDB::register_type<Simplex>();

	// For Godot 3.0
	// ClassDB::register_class<Simplex>();
}

void unregister_simplex_types() {
   //nothing to do here
}


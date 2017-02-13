/* register_types.cpp */

#include "register_types.h"
#include "class_db.h"
#include "simplex.h"

void register_simplex_types() {

        ClassDB::register_class<Simplex>();
}

void unregister_simplex_types() {
   //nothing to do here
}


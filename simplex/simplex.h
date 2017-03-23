/* simplex.h */

#ifndef SIMPLEX_H
#define SIMPLEX_H

#include "reference.h"

class Simplex : public Reference {

	// For Godot 2.x
	OBJ_TYPE(Simplex,Reference);

	// For Godot 3.0
	//GDCLASS(Simplex,Reference);


	const static float F2 = 0.36602540378443860;
	const static float G2 = 0.21132486540518714;
	const static float G2o = -0.577350269189626;
	const static float F3 = 0.33333333333333333;
	const static float G3 = 0.16666666666666666;

	const static int GRAD3[];
	const static int GRAD4[];
	const static int PERM[];

protected:
    static void _bind_methods();

public:
	float simplex2(float c0, float c1);
    Simplex();
};

#endif

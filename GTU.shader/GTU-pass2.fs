// Gaussian-kernel TV Upscaler	
// version : 0.3
// Author: aliaspider - aliaspider@gmail.com
// License: GPLv3      

#version 150

// this will define the bandwidth of the signal per scanline
// a value of 640.0 or double the game horizontal resolution
// work well for most cases.
// you can set it to 512.0 to get full transparancy in snes
// games that use the psoeudo-hires video mode.
// higher BANDWIDTH = sharper image
#define BANDWIDTH 640.0
 
  
// horizontal computation range or the shader,
// increasing this value will increase performance requieremnts
// you might need to increase it if you notice
// some artifacts appearing with lower bandwidth settings.
// you only need to set this to the lowest value that doesnt 
// cause artifacts to appears.
// default : 2
#define X_RANGE 2


uniform sampler2D	source[];
uniform vec4		sourceSize[];

in Vertex {
	vec2 texCoord;
};
out vec4 fragColor;

#define pi			3.14159265358
#define a(x) abs(x)
#define d(x,b) (pi*b*min(a(x)+0.5,1.0/b))
#define e(x,b) (pi*b*min(max(a(x)-0.5,-1.0/b),1.0/b))
#define STU(x,b) ((d(x,b)+sin(d(x,b))-e(x,b)-sin(e(x,b)))/(2.0*pi))
#define X(i) (offset.x-(i))
#define SOURCE(i) vec2(texCoord.x - X(i)/sourceSize[0].x,texCoord.y)
#define C(i) (texture2D(source[0], SOURCE(i)).xyz)
#define VAL(i) (C(i)*STU(X(i),((BANDWIDTH/2.0)/sourceSize[0].x)))




void main() {
	
	vec2	offset	= fract((texCoord.xy * sourceSize[0].xy) - 0.5);
	vec3	tempColor = vec3(0.0);	
#if (X_RANGE > 6)
	tempColor+=VAL(-6.0);
	tempColor+=VAL(7.0);
#endif
#if (X_RANGE > 5)
	tempColor+=VAL(-5.0);
	tempColor+=VAL(6.0);
#endif
#if (X_RANGE > 4)
	tempColor+=VAL(-4.0);
	tempColor+=VAL(5.0);
#endif
#if (X_RANGE > 3)
	tempColor+=VAL(-3.0);
	tempColor+=VAL(4.0);
#endif
#if (X_RANGE > 2)
	tempColor+=VAL(-2.0);
	tempColor+=VAL(3.0);
#endif
#if (X_RANGE > 1)
	tempColor+=VAL(-1.0);
	tempColor+=VAL(2.0);
#endif
	tempColor+=VAL(0.0);
	tempColor+=VAL(1.0);

	
	fragColor = vec4((tempColor),1.0);
}

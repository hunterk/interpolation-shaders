// Gaussian-kernel TV Upscaler	
// version : 0.3
// Author: aliaspider - aliaspider@gmail.com
// License: GPLv3      

#version 150

// scanline width
// scanlines will start to disappear with a value of 1.88.
// a value of 2.0 will produce a scanlines free image.
// lower values might require a higher resolution
// to display correctly
#define SCANLINE_WIDTH 1.3


// gamma of the current display device
// try reducing this value if the image feels too bright
#define OUTPUTG2	2.2
 

uniform sampler2D	source[];
uniform sampler2D 	texture[];
uniform vec4		sourceSize[];

in Vertex {
	vec2 texCoord;
};
out vec4 fragColor;


#define GAMMAOUT(c0)	(pow(c0, vec3(1.0/OUTPUTG2)))
#define pi			3.14159265358
#define GAUSS(x,w) ((sqrt(2.0) / (w)) * (exp((-2.0 * pi * (x) * (x)) / ((w) * (w)))))
#define Y(j) (offset.y-(j))
#define SOURCE(j) vec2(texCoord.x,texCoord.y - Y(j)/sourceSize[0].y)
#define C(j) (texture2D(source[0], SOURCE(j)).xyz)
#define VAL(j) (C(j)*GAUSS(Y(j),SCANLINE_WIDTH))



void main() {
	
	vec2	offset	= fract((texCoord.xy * sourceSize[0].xy) - 0.5);
	vec3	tempColor = vec3(0.0);	
	tempColor+=VAL(-1.0);
	tempColor+=VAL(0.0);
	tempColor+=VAL(1.0);
	tempColor+=VAL(2.0);
	
	fragColor = vec4(GAMMAOUT(tempColor), 1.0);
}
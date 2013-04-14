<?xml version="1.0" encoding="UTF-8"?>
<!--
	Gaussian-kernel TV Upscaler	
	version : 0.31
	Author: aliaspider - aliaspider@gmail.com
	License: GPLv3      	
-->
<shader language="GLSL" style="GLES2">

<!-- PASS1 -->
<vertex><![CDATA[
	#version 120
	uniform mat4 rubyMVPMatrix;
	attribute vec2 rubyVertexCoord;
	attribute vec2 rubyTexCoord;
	varying vec2 tex_coord;

	void main()
	{
		gl_Position = rubyMVPMatrix * vec4(rubyVertexCoord, 0.0, 1.0);
		tex_coord = rubyTexCoord;
	}
]]></vertex>
<fragment filter="nearest" scale="1.0" float_framebuffer="true"><![CDATA[
	#version 120
	varying vec2 tex_coord;
	uniform sampler2D rubyTexture;
//------------------------------------------------------------------------------------//
// CONFIG :	

// gamma of the emulated CRT-TV
#define INPUTG2		2.4	

// use tv levels (16-235) instead of the full range
// comment to disable
#define COMPOSITE_LEVELS	

//------------------------------------------------------------------------------------//



#ifdef COMPOSITE_LEVELS
	#define LEVELS(c) clamp((c -16.0/ 256.0)*256.0/(236.0-16.0) ,0.0,1.0)
#else
	#define LEVELS(c) c
#endif
	#define GAMMAIN(c)		(pow(c, vec3(INPUTG2)))
	void main() {
	gl_FragColor = vec4(GAMMAIN(LEVELS(texture2D(rubyTexture, tex_coord).xyz)), 1.0);
	}
]]></fragment>

<!-- PASS2 -->
<vertex><![CDATA[
	#version 120
	uniform mat4 rubyMVPMatrix;
	attribute vec2 rubyVertexCoord;
	attribute vec2 rubyTexCoord;
	varying vec2 tex_coord;

	void main()
	{
		gl_Position = rubyMVPMatrix * vec4(rubyVertexCoord, 0.0, 1.0);
		tex_coord = rubyTexCoord;
	}
]]></vertex>
<fragment filter="nearest" outscale_x="1.0" scale_y="1.0" float_framebuffer="true"><![CDATA[
#version 120
	uniform sampler2D rubyTexture;
	uniform vec2 rubyTextureSize;
	uniform vec2 rubyInputSize;
	varying vec2 tex_coord;

//------------------------------------------------------------------------------------//
// CONFIG :

// this will define the bandwidth of the signal per scanline
// a value of 640.0 or double the game horizontal resolution
// work well for most cases.
// you can set it to 512 to get full transparancy in snes
// games that use the pseudo-hires video mode.
// higher BANDWIDTH = sharper image
#define BANDWIDTH 512.0

// horizontal computation range or the shader,
// increasing this value will increase performance requieremnts
// you might need to increase it if you notice
// some artifacts appearing with lower bandwidth settings.
// you only need to set this to the lowest value that doesn't 
// cause artifacts to appears.
// default : 2
#define X_RANGE 2

//------------------------------------------------------------------------------------//

#define pi			3.14159265358
#define a(x) abs(x)
#define d(x,b) (pi*b*min(a(x)+0.5,1.0/b))
#define e(x,b) (pi*b*min(max(a(x)-0.5,-1.0/b),1.0/b))
#define STU(x,b) ((d(x,b)+sin(d(x,b))-e(x,b)-sin(e(x,b)))/(2.0*pi))
#define X(i) (offset.x-(i))
#define SOURCE(i) vec2(tex_coord.x - X(i)/rubyTextureSize.x,tex_coord.y)
#define C(i) (texture2D(rubyTexture, SOURCE(i)).xyz)
#define VAL(i) (C(i)*STU(X(i),((BANDWIDTH/2.0)/rubyInputSize.x)))

void main() {
	vec2	offset	= fract((tex_coord * rubyTextureSize) - 0.5);
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

	
	gl_FragColor = vec4((tempColor),1.0);
}
]]></fragment>

<!-- PASS3 -->
<vertex><![CDATA[
	#version 120
	uniform mat4 rubyMVPMatrix;
	attribute vec2 rubyVertexCoord;
	attribute vec2 rubyTexCoord;
	varying vec2 tex_coord;

	void main()
	{
		gl_Position = rubyMVPMatrix * vec4(rubyVertexCoord, 0.0, 1.0);
		tex_coord = rubyTexCoord;
	}
]]></vertex>
<fragment filter="nearest"><![CDATA[
#version 120
	varying vec2 tex_coord;
	uniform sampler2D rubyTexture;
	uniform vec2 rubyTextureSize;

//------------------------------------------------------------------------------------//
// CONFIG :

// scanline width
// scanlines will start to disappear with a value of 1.5.
// a value of 2.0 will produce a scanlines free image.
// lower values might require a higher resolution
// to display correctly
#define SCANLINE_WIDTH 1.0

// gamma of the current display device
// try reducing this value if the image feels too bright
#define OUTPUTG2	2.2

//------------------------------------------------------------------------------------//

#define GAMMAOUT(c0)	(pow(c0, vec3(1.0/OUTPUTG2)))
#define pi			3.14159265358
#define GAUSS(x,w) ((sqrt(2.0) / (w)) * (exp((-2.0 * pi / ((w) * (w)))* (x) * (x) )))
#define Y(j) (offset.y-(j))
#define SOURCE(j) vec2(tex_coord.x,tex_coord.y - Y(j)/rubyTextureSize.y)
#define C(j) (texture2D(rubyTexture, SOURCE(j)).xyz)
#define VAL(j) (C(j)*GAUSS(Y(j),SCANLINE_WIDTH))

	void main() {
	
	vec2	offset	= fract((tex_coord * rubyTextureSize) - 0.5);
	vec3	tempColor = vec3(0.0);		
	tempColor+=VAL(-1.0);
	tempColor+=VAL(0.0);
	tempColor+=VAL(1.0);
	tempColor+=VAL(2.0);
	
	gl_FragColor = vec4(GAMMAOUT(tempColor), 1.0);
	}
]]></fragment>

</shader>
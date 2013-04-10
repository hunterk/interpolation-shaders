#version 150
// gamma of the emulated CRT-TV
#define INPUTG2		2.4	

 

uniform sampler2D	source[];
uniform vec4		sourceSize[];

in Vertex {
	vec2 texCoord;
};
out vec4 fragColor;



#define GAMMAIN(c)		(pow(c, vec3(INPUTG2)))

void main() {
	fragColor = vec4(GAMMAIN(texture2D(source[0], texCoord.xy).xyz), 1.0);
}

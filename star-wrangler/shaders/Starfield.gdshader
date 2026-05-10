shader_type sky;

#include "res://addons/ShaderLib/Artistic/Artistic.gdshaderinc"
#include "res://addons/ShaderLib/UV/UV.gdshaderinc"

uniform float star_height = 5.0;
uniform float star_blend : hint_range(0.0,1.0,0.01) = 0.1;
uniform float depth_blend : hint_range(0.0,1.0,0.01) = 0.1;
uniform float flare_ratio : hint_range(0.0,1.0,0.01) = 0.1;
uniform float star_size = 5;
uniform float twinkle_speed = 5.0;
uniform int star_layers = 3;

// Sourced from Tenner Helland
// https://tannerhelland.com/2012/09/18/convert-temperature-rgb-algorithm-code.html
vec3 TemperatureToRGB(float temp) {
	temp /= 100.0;
	
	vec3 output = vec3(0,0,0);
	
	// RED
	if (temp <= 66.0) {
		output.r = 1.0;
	} else {
		output.r = temp - 60.0;
		output.r = 329.698727446 * pow(output.r,-0.1332047592);
		output.r = output.r / 255.0; // cast from bit to float
		output.r = clamp(output.r, 0.0, 1.0);
	}
	
	// GREEN
	if (temp <= 66.0) {
		output.g = temp;
		output.g = 99.4708025861 * log(output.g) - 161.1195681661;
	} else {
		output.g = temp - 60.0;
		output.g = 288.1221695283 * pow(output.g, -0.0755148492);
	}
	output.g = output.g / 255.0; // cast from bit to float
	output.g = clamp(output.g, 0.0, 1.0);
	
	// BLUE
	if (temp >= 66.0) {
		output.b = 1.0;
	} else {
		output.b = temp - 10.0;
		output.b = 138.5177312231 * log(output.b) - 305.0447927307;
		output.b = output.b / 255.0; // cast from bit to float
		output.b = clamp(output.b, 0.0, 1.0);
	}
	
	return output;
}

float StarTempDistribution(vec2 seed) {
	if (seed.x <= 0.76) {
		return 2300.0 + (seed.y * 1600.0); 
	} else if (seed.x <= 0.88) {
		return 3900.0 + (seed.y * 1400.0);
	} else if (seed.x <= 0.956) {
		return 5300.0 + (seed.y * 700.0);
	} else if (seed.x <= 0.986) {
		return 6000.0 + (seed.y * 1300.0);
	} else if (seed.x <= 0.9931) {
		return 10000.0 + (seed.y * 23000.0);
	} else {
		return 33000.0 + (seed.y * 33000.0);
	}
}

vec2 RandomVec2(vec2 seed){
	seed = fract(seed * vec2(123.35, 78.29));
	seed += dot(seed, seed + 875.34);
	float x = fract(seed.x * 164.32);
	float y = fract(seed.y * 287.21);
	return vec2(x,y) - 0.5;
}

float Star(vec2 uv, float flare){
	float star = 0.01 / length(uv);
	float rays = max(0, 1.0 - abs(uv.x * uv.y) * 1000.0) * star;
	star += rays * flare;
	return pow(star, 3);
}

vec3 StarLayer(vec2 uv){
	vec2 grid_uv = fract(uv) - 0.5;
	vec2 grid_id = floor(uv);
	vec3 stars = vec3(0);
	for (float y = -1.0; y <= 1.0; y++){
		for (float x = -1.0; x <= 1.0; x++){
			vec2 offset = vec2(x,y);
			vec2 rv = RandomVec2(grid_id + offset);
			float size = star_size * (rv.x + 0.5);
			float animated_size = (sin(TIME * rv.x * twinkle_speed) * 0.4 + 0.6) * size;
			float flare = smoothstep(star_size * (1.0 - flare_ratio), star_size, size);
			//vec3 star_color = hue(vec3(0,1,0), rv.y * 1.0, 1);
			stars += Star(grid_uv - offset - rv, flare) * animated_size * TemperatureToRGB(StarTempDistribution(rv + 0.5));
		}
	}
	return stars;
}

void sky() {
	float blend = smoothstep(star_blend, 1, abs(EYEDIR.y));
	float depth_curve = pow(abs(EYEDIR.y), depth_blend);
	for (float i = 1.0; i <= float(star_layers); i++){
		vec2 uv = EYEDIR.xz / depth_curve * star_height * i;
		uv += RandomVec2(vec2(i, i + 34.0)) * i *  4.4;
		if (EYEDIR.y < 0.0){
			uv = rotate_uv(uv, vec2(0), 170, true);
		}
		COLOR += StarLayer(uv) * blend;
	}
}

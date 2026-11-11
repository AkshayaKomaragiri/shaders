// HINT: Don't forget to define the uniforms here after you pass them in in A4.js

uniform float ticks;

// The value of our shared variable is given as the interpolation between normals computed in the vertex shader
// below we can see the shared variable we passed from the vertex shader using the 'in' classifier
in vec3 interpolatedNormal;
in vec3 lightDirection;
in vec3 vertexPosition;

void main() {
    // TODO:
    // HINT: First, as you've already done in the Toon fragment shader, compute the light
    // intensity of the current fragment by determining the cosine angle between the surface
    // normal and the light vector. Next, pick any two colors, blend them based on light
    // intensity to give the 3D model some color and depth. Also make the color change wrt ticks.
    // Next, implement rolling dots using the mod function, ticks and discard.

   float space = 0.25; 
    float speed = 0.005;  
    
    vec3 rollingPos = vertexPosition;
    rollingPos.y -= ticks * speed;

    vec3 cellPos = mod(rollingPos, space) - (space * 0.5);
    float dist = length(cellPos);
    float dotRadius = 0.12; 

    if (dist > dotRadius) {
        discard;
    }

    vec3 n = normalize(interpolatedNormal);
    vec3 l = normalize(lightDirection);
    float intensity = max(dot(n, l), 0.0);

    float timeCycle = sin(ticks * 0.03) * 0.5 + 0.5; 
    vec3 color1 = mix(vec3(1.0, 0.2, 0.2), vec3(0.2, 0.6, 1.0), timeCycle);
    vec3 color2 = mix(vec3(1.0, 0.9, 0.1), vec3(0.8, 0.2, 0.8), timeCycle);

    vec3 baseColor = mix(color1, color2, intensity);

    // HINT: Set final rendered colour
    gl_FragColor = vec4(baseColor, 1.0);
}

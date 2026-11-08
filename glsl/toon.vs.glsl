// The uniform variable is set up in the javascript code and the same for all vertices
uniform vec3 spherePosition;

// A shared variable is initialized in the vertex shader and attached to the current vertex being processed,
// such that each vertex is given a shared variable and when passed to the fragment shader,
// these values are interpolated between vertices and across fragments,
// below we can see the shared variable is initialized in the vertex shader using the 'out' classifier
out vec3 interpolatedNormal;
out vec3 lightDirection;
out vec3 viewPosition;
out float fresnel; // NOTE: this refers to the dot product of view direction and normal

void main() {
   vec4 viewPos = viewMatrix * modelMatrix * vec4(position, 1.0);
    viewPosition = viewPos.xyz;

    interpolatedNormal = normalize(normalMatrix * normal);

    vec3 lightPosView = (viewMatrix * vec4(spherePosition, 1.0)).xyz;
    lightDirection = normalize(lightPosView - viewPosition);

    vec3 viewDir = normalize(-viewPosition);

    fresnel = dot(interpolatedNormal, viewDir);

    gl_Position = projectionMatrix * viewMatrix * modelMatrix * vec4(position, 1.0);
}

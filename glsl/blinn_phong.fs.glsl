
uniform vec3 ambientColor;
uniform float kAmbient;

uniform vec3 diffuseColor;
uniform float kDiffuse;

uniform vec3 specularColor;
uniform float kSpecular;
uniform float shininess;

uniform mat4 modelMatrix;
varying vec3 fPosition;
varying vec3 fNormal;
varying vec3 fLight;
uniform vec3 spherePosition;

// The value of our shared variable is given as the interpolation between normals computed in the vertex shader
// below we can see the shared variable we passed from the vertex shader using the 'in' classifier
in vec3 interpolatedNormal;
in vec3 viewPosition;
in vec3 worldPosition;


void main() {
    // TODO:
    // HINT: compute the following - light direction, ambient + diffuse + specular component,

    // then set the final color as a combination of these components
    
    //gl_FragColor = vec4(1.0, 1.0, 0.0, 1.0);
 vec3 ambient = ambientColor * kAmbient;
    
    // 2. Diffuse component
    vec3 n = normalize(fNormal);
    vec3 l = normalize(fLight); // Adjust if fLight is a position rather than direction
    vec3 diffuse = diffuseColor * kDiffuse * max(dot(n, -l), 0.0);
    
    // 3. Blinn-Phong Specular component
    vec3 v = normalize(-fPosition); // View vector in view space
    vec3 h = normalize((-l) + v);   // Halfway vector (using -l or l depending on your light vector convention)
    float specAngle = max(dot(n, h), 0.0);
    vec3 specular = specularColor * kSpecular * pow(specAngle, shininess);
    
    // Combine components
    vec3 color = ambient + diffuse + specular;
    gl_FragColor = vec4(color, 1.0);



}

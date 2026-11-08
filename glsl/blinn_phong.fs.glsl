
uniform vec3 ambientColor;
uniform float kAmbient;

uniform vec3 diffuseColor;
uniform float kDiffuse;

uniform vec3 specularColor;
uniform float kSpecular;
uniform float shininess;

uniform mat4 modelMatrix;

uniform vec3 spherePosition;

// The value of our shared variable is given as the interpolation between normals computed in the vertex shader
// below we can see the shared variable we passed from the vertex shader using the 'in' classifier
in vec3 interpolatedNormal;
in vec3 viewPosition;
in vec3 worldPosition;


void main() {

    vec3 ambient = ambientColor * kAmbient;
    
    vec3 n = normalize(interpolatedNormal);
    
    vec3 lightPosView = (viewMatrix * vec4(spherePosition, 1.0)).xyz;
    vec3 l = normalize(lightPosView - viewPosition);
    
    vec3 diffuse = diffuseColor * kDiffuse * max(dot(n, l), 0.0);
    
    vec3 v = normalize(-viewPosition); 
    vec3 h = normalize(l + v);         
    float specAngle = max(dot(n, h), 0.0);
    vec3 specular = specularColor * kSpecular * pow(specAngle, shininess);
    
    vec3 color = ambient + diffuse + specular;
    gl_FragColor = vec4(color, 1.0);

}

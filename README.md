# CS 4361 Assignment 4: Shaders

**Student Name:** Laxmi Akshaya Komaragiri 
**Student Number:** 2021774290 
**NetID:** lak230000

## Assignment Overview

This assignment implements several shading algorithms in GLSL and Three.js: Blinn-Phong reflection and toon shading on the dragon, animated polka dots, and physically based rendering (PBR) of a textured helmet with `MeshStandardMaterial`.

## Part 1: Required Features (100 pts)

### (a) Scene 1: Blinn-Phong Reflection (25 pts)

**Requirements:**
- Pass the needed values (position, normal, view position) from the vertex shader to the fragment shader
- Compute the ambient, diffuse and specular terms per fragment and sum them, as in Figure 3

**Implementation:**
[Explain which frame each vector is in and how you computed the three terms]
In the vertex shader I calculated the world position by multiplying the position vector by the modelMatrix. I calculated viewPos by multiplying the position vector times the modelMatrix and viewMatrix. I calculated the iterpolatedNormal by normalizing the product of the normalMatrix and the normal vector. It transforms the local vertex normal into the view/world space and then normalizes the result. In the fragment shader first I calculated the ambient light color by multiplying the ambientColor uniform by the kAmbient  uniform.   I calculated lightPosView which is the spherePosition(also the light source) vector multiplied by the viewMatrix which transforms the position into view space. Then we calculate the unit vector pointing from the fragment to the light source. Diffuse is calculated as the diffuseColor * kDiffuse * max of the dot product of interpolated normal and the unit vector pointing to the light. The max function caps the diffuse so we don't get negative values. Vector v is the unit vector from the fragment to the camera. We add the vector v and the unit vector from fragment to light souce and normalize this. This is the half vector needed for the blinn phong model. The specular angle is the dot product between the interpolated normal and half vector. The specular term is the specular color * kspecular * specular angle ^ shininess. Finally we add the ambient diffuse and specular together.

**Files Modified:**
- `glsl/blinn_phong.vs.glsl`
- `glsl/blinn_phong.fs.glsl`

**Key Code Snippets:**
```glsl
    worldPosition = (modelMatrix * vec4(position, 1.0)).xyz;

    vec4 viewPos = viewMatrix * modelMatrix * vec4(position, 1.0);
    viewPosition = viewPos.xyz;

    interpolatedNormal = normalize(normalMatrix * normal);

    gl_Position = projectionMatrix * viewMatrix * modelMatrix * vec4(position, 1.0);
```
```glsl
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
```

---

### (b) Scene 2: Toon (25 pts)

**Requirements:**
- Quantize the light intensity into a number of steps
- Use two tones: red for darker areas and yellow for lighter areas
- Draw dark silhouette outlines that do not move with the light

**Implementation:**
[Explain how you quantized the intensity, blended the two tones, and detected the silhouette]
I found the silhouette by taking the dot product between the surface normal and the view direction. If the computed value was below a certain threshold (I chose 0.3) those pixels are colored with the outline color.  
Next for coloring the rest of the object I took the dot product of the normal unit vector and the light direction unit vector which gives us the intensity. If the intensity has above a certain threshold it was colored toonColor otherwise it is colored toonColor2.



**Files Modified:**
- `glsl/toon.vs.glsl`
- `glsl/toon.fs.glsl`

**Key Code Snippets:**
```glsl
vec4 viewPos = viewMatrix * modelMatrix * vec4(position, 1.0);
    viewPosition = viewPos.xyz;

    interpolatedNormal = normalize(normalMatrix * normal);

    vec3 lightPosView = (viewMatrix * vec4(spherePosition, 1.0)).xyz;
    lightDirection = normalize(lightPosView - viewPosition);

    vec3 viewDir = normalize(-viewPosition);

    fresnel = dot(interpolatedNormal, viewDir);

    gl_Position = projectionMatrix * viewMatrix * modelMatrix * vec4(position, 1.0);


    if (fresnel < 0.3) {
        gl_FragColor = vec4(outlineColor, 1.0);
        return;
    }

    vec3 n = normalize(interpolatedNormal);
    vec3 l = normalize(lightDirection);
    float intensity = max(dot(n, l), 0.0);

    vec3 color = (intensity > 0.5) ? toonColor : toonColor2;

    gl_FragColor = vec4(color, 1.0);

    vertexPosition = position;

    interpolatedNormal = normalize(normalMatrix * normal);

    vec4 viewPos = viewMatrix * modelMatrix * vec4(position, 1.0);
    vec3 lightPosView = (viewMatrix * vec4(spherePosition, 1.0)).xyz;
    lightDirection = normalize(lightPosView - viewPos.xyz);

    gl_Position = projectionMatrix * viewPos;
```

---

### (c) Scene 3: Polka Dots (30 pts)

**Requirements:**
- Give the dragon polka dots on a regular 3D grid (discard the fragments between dots)
- Make the dots smoothly roll down the body over time
- Make the dots smoothly change colour over time

**Implementation:**
[Explain how you built the grid, discarded fragments, and animated the dots and their colour with `ticks`]

**Files Modified:**
- `glsl/dots.vs.glsl`
- `glsl/dots.fs.glsl`

**Key Code Snippets:**
```glsl
   float spacing = 0.25; 
    float speed = 0.005;  
    
    vec3 rollingPos = vertexPosition;
    rollingPos.y -= ticks * speed;

    vec3 cellPos = mod(rollingPos, spacing) - (spacing * 0.5);
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
```

---

### (d) Scene 4: Three.js PBR and Texturing (20 pts)

**Requirements:**
- Load the helmet's textures in `gltf/` with `THREE.TextureLoader`
- Pass them to `helmetPBRMaterial` and set its metalness, so the helmet looks like Figure 7

**Implementation:**
[Explain which texture goes into which material property, and any texture settings you needed]

**Files Modified:**
- `A4.js`

**Key Code Snippets:**
```javascript
const albedoMap = loadGLTFTexture("gltf/Default_albedo.jpg", true);
const normalMap = loadGLTFTexture("gltf/Default_normal.jpg", false);
const aoMap = loadGLTFTexture("gltf/Default_AO.jpg", false);
const metalRoughnessMap = loadGLTFTexture("gltf/Default_metalRoughness.jpg", false);
const emissiveMap = loadGLTFTexture("gltf/Default_emissive.jpg", true);

const helmetPBRMaterial = new THREE.MeshStandardMaterial({
  // TODO: pass texture maps to the material. And set material's metalness.
  map: albedoMap,
  normalMap: normalMap,
  aoMap: aoMap,
  roughnessMap: metalRoughnessMap,
  metalnessMap: metalRoughnessMap,
  emissiveMap: emissiveMap,
  emissive: new THREE.Color(0xffffff), 
  metalness: 1.0,
});
```

---

## Part 2: Creative License (Optional - Bonus up to 10 pts)
[If you completed Part 2, describe your creative extensions here]
**Creative Features Implemented:**
- [Feature 1]: [Description]
- [Feature 2]: [Description]
- [etc.]

**Files Modified:**
- [List files you modified for creative features]


## Screenshots
[Include screenshots of your working program showing each part's functionality]
- **Blinn-Phong:** [Screenshot of scene 1]
- **Toon:** [Screenshot of scene 2, with the silhouette outlines visible]
- **Polka Dots:** [Screenshots of scene 3 at two different times, showing the dots rolling and changing colour]
- **PBR:** [Screenshot of scene 4 showing the textured helmet]

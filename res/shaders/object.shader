#shader vertex
#version 330 core 
layout (location = 0) in vec3 aPos; 
layout (location = 1) in vec2 aTexCoord; 

out vec2 TexCoord; 
out float fragDistance;
out vec3 fragWorldPos;

uniform mat4 model; 
uniform mat4 view; 
uniform mat4 projection;

void main() 
{ 
    vec4 worldPos = model * vec4(aPos, 1.0);
    vec4 viewPos = view * worldPos;
    gl_Position = projection * viewPos;
    TexCoord = aTexCoord;
    fragDistance = length(viewPos.xyz);
    fragWorldPos = worldPos.xyz;
}

#shader fragment
#version 330 core 

out vec4 FragColor; 

in vec2 TexCoord; 
in float fragDistance;
in vec3 fragWorldPos;

uniform sampler2D ourTexture;

// Fog parameters
const vec3 fogColor = vec3(0.6, 0.7, 0.8);  // Light blue-gray fog
const float fogStart = 100.0;                 // Distance where fog starts
const float fogEnd = 250.0;                  // Distance where fog is fully opaque

// Lighting parameters
const vec3 lightDir = normalize(vec3(0.5, 1.0, 0.3));  // Sun direction
const float ambientStrength = 0.6;                      // Minimum light level
const float diffuseStrength = 0.4;                      // How strong the directional light is

void main() 
{ 
    vec4 texColor = texture(ourTexture, TexCoord);
    
    // Calculate fake normal from fragment derivatives (flat shading for blocks)
    vec3 normal = normalize(cross(dFdx(fragWorldPos), dFdy(fragWorldPos)));
    
    // Simple directional lighting
    float diff = max(dot(normal, lightDir), 0.0);
    float lighting = ambientStrength + diffuseStrength * diff;
    
    vec3 litColor = texColor.rgb * lighting;
    
    // Calculate fog factor (0 = no fog, 1 = full fog)
    float fogFactor = clamp((fragDistance - fogStart) / (fogEnd - fogStart), 0.0, 1.0);
    
    // Mix texture color with fog color
    vec3 finalColor = mix(litColor, fogColor, fogFactor);
    
    FragColor = vec4(finalColor, texColor.a);
}
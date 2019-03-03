uniform vec2 uRepeatBase;
uniform sampler2D tNormal;
uniform sampler2D tDisplacement;
uniform float uDisplacementScale;
uniform float uDisplacementBias;

varying vec3 vTangent;
varying vec3 vBinormal;
varying vec3 vNormal;
varying vec2 vUv;
varying vec3 vViewPosition;

attribute vec4 tangent;
attribute vec3 color;

void main() {
    vNormal = normalize( normalMatrix * normal );
    vTangent = normalize( normalMatrix * tangent.xyz );
    vBinormal = cross( vNormal, vTangent ) * tangent.w;
    vBinormal = normalize( vBinormal );
    vUv = uv;
    vec2 uvBase = uv * uRepeatBase;

	vec3 dv = texture2D( tDisplacement, uvBase ).xyz;
	float df = uDisplacementScale * dv.x + uDisplacementBias;
	vec3 displacedPosition = normal * df + position;
	vec4 worldPosition = modelMatrix * vec4( displacedPosition, 1.0 );
	vec4 mvPosition = modelViewMatrix * vec4( displacedPosition, 1.0 );
	
    gl_Position = projectionMatrix * mvPosition;
    vViewPosition = -mvPosition.xyz;
    vec3 normalTex = texture2D( tNormal, uvBase ).xyz * 2.0 - 1.0;
    vNormal = normalMatrix * normalTex;
}
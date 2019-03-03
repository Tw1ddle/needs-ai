precision highp float;
precision highp int;

#define SHADER_NAME ShaderMaterial
#define VERTEX_TEXTURES
#define GAMMA_FACTOR 2
#define MAX_BONES 0
#define USE_FOG
#define BONE_TEXTURE

uniform mat4 modelMatrix;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 viewMatrix;
uniform mat3 normalMatrix;
uniform vec3 cameraPosition;
attribute vec3 position;
attribute vec3 normal;
attribute vec2 uv;

#ifdef USE_TANGENT
    attribute vec4 tangent;
#endif

#ifdef USE_COLOR
    attribute vec3 color;
#endif

#ifdef USE_MORPHTARGETS
    attribute vec3 morphTarget0;
    attribute vec3 morphTarget1;
    attribute vec3 morphTarget2;
    attribute vec3 morphTarget3;
    #ifdef USE_MORPHNORMALS
        attribute vec3 morphNormal0;
        attribute vec3 morphNormal1;
        attribute vec3 morphNormal2;
        attribute vec3 morphNormal3;
    #else
        attribute vec3 morphTarget4;
        attribute vec3 morphTarget5;
        attribute vec3 morphTarget6;
        attribute vec3 morphTarget7;
    #endif
#endif

#ifdef USE_SKINNING
    attribute vec4 skinIndex;
    attribute vec4 skinWeight;
#endif

attribute vec4 tangent;

uniform vec2 uRepeatBase;
uniform sampler2D tNormal;

#ifdef VERTEX_TEXTURES
    uniform sampler2D tDisplacement;
    uniform float uDisplacementScale;
    uniform float uDisplacementBias;
#endif

varying vec3 vTangent;
varying vec3 vBinormal;
varying vec3 vNormal;
varying vec2 vUv;
varying vec3 vViewPosition;

#ifdef USE_SHADOWMAP
    #if 1 > 0
        uniform mat4 directionalShadowMatrix[ 1 ];
        varying vec4 vDirectionalShadowCoord[ 1 ];
    #endif
    #if 0 > 0
        uniform mat4 spotShadowMatrix[ 0 ];
        varying vec4 vSpotShadowCoord[ 0 ];
    #endif
    #if 1 > 0
        uniform mat4 pointShadowMatrix[ 1 ];
        varying vec4 vPointShadowCoord[ 1 ];
    #endif
#endif

#ifdef USE_FOG
    varying float fogDepth;
#endif

void main() {
    vNormal = normalize( normalMatrix * normal );
    vTangent = normalize( normalMatrix * tangent.xyz );
    vBinormal = cross( vNormal, vTangent ) * tangent.w;
    vBinormal = normalize( vBinormal );
    vUv = uv;
    vec2 uvBase = uv * uRepeatBase;
    #ifdef VERTEX_TEXTURES
        vec3 dv = texture2D( tDisplacement, uvBase ).xyz;
        float df = uDisplacementScale * dv.x + uDisplacementBias;
        vec3 displacedPosition = normal * df + position;
        vec4 worldPosition = modelMatrix * vec4( displacedPosition, 1.0 );
        vec4 mvPosition = modelViewMatrix * vec4( displacedPosition, 1.0 );
    #else
        vec4 worldPosition = modelMatrix * vec4( position, 1.0 );
        vec4 mvPosition = modelViewMatrix * vec4( position, 1.0 );
    #endif
    gl_Position = projectionMatrix * mvPosition;
    vViewPosition = -mvPosition.xyz;
    vec3 normalTex = texture2D( tNormal, uvBase ).xyz * 2.0 - 1.0;
    vNormal = normalMatrix * normalTex;
    #ifdef USE_SHADOWMAP
        #if 1 > 0
            
            vDirectionalShadowCoord[ 0 ] = directionalShadowMatrix[ 0 ] * worldPosition;
        #endif
        #if 0 > 0
            
        #endif
        #if 1 > 0
            
            vPointShadowCoord[ 0 ] = pointShadowMatrix[ 0 ] * worldPosition;
        #endif
    #endif
    #ifdef USE_FOG
        fogDepth = -mvPosition.z;
    #endif
}
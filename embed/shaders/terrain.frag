precision highp float;
precision highp int;

#define SHADER_NAME ShaderMaterial
#define GAMMA_FACTOR 2
#define USE_FOG

uniform mat4 viewMatrix;
uniform vec3 cameraPosition;

#define TONE_MAPPING

#ifndef saturate
    #define saturate(a) clamp( a, 0.0, 1.0 )
#endif

uniform float toneMappingExposure;
uniform float toneMappingWhitePoint;

vec3 LinearToneMapping( vec3 color ) {
    return toneMappingExposure * color;
}
vec3 ReinhardToneMapping( vec3 color ) {
    color *= toneMappingExposure;
    return saturate( color / ( vec3( 1.0 ) + color ) );
}
#define Uncharted2Helper( x ) max( ( ( x * ( 0.15 * x + 0.10 * 0.50 ) + 0.20 * 0.02 ) / ( x * ( 0.15 * x + 0.50 ) + 0.20 * 0.30 ) ) - 0.02 / 0.30, vec3( 0.0 ) )
vec3 Uncharted2ToneMapping( vec3 color ) {
    color *= toneMappingExposure;
    return saturate( Uncharted2Helper( color ) / Uncharted2Helper( vec3( toneMappingWhitePoint ) ) );
}
vec3 OptimizedCineonToneMapping( vec3 color ) {
    color *= toneMappingExposure;
    color = max( vec3( 0.0 ), color - 0.004 );
    return pow( ( color * ( 6.2 * color + 0.5 ) ) / ( color * ( 6.2 * color + 1.7 ) + 0.06 ), vec3( 2.2 ) );
}
vec3 ACESFilmicToneMapping( vec3 color ) {
    color *= toneMappingExposure;
    return saturate( ( color * ( 2.51 * color + 0.03 ) ) / ( color * ( 2.43 * color + 0.59 ) + 0.14 ) );
}
vec3 toneMapping( vec3 color ) {
    return LinearToneMapping( color );
}
vec4 LinearToLinear( in vec4 value ) {
    return value;
}
vec4 GammaToLinear( in vec4 value, in float gammaFactor ) {
    return vec4( pow( value.rgb, vec3( gammaFactor ) ), value.a );
}
vec4 LinearToGamma( in vec4 value, in float gammaFactor ) {
    return vec4( pow( value.rgb, vec3( 1.0 / gammaFactor ) ), value.a );
}
vec4 sRGBToLinear( in vec4 value ) {
    return vec4( mix( pow( value.rgb * 0.9478672986 + vec3( 0.0521327014 ), vec3( 2.4 ) ), value.rgb * 0.0773993808, vec3( lessThanEqual( value.rgb, vec3( 0.04045 ) ) ) ), value.a );
}
vec4 LinearTosRGB( in vec4 value ) {
    return vec4( mix( pow( value.rgb, vec3( 0.41666 ) ) * 1.055 - vec3( 0.055 ), value.rgb * 12.92, vec3( lessThanEqual( value.rgb, vec3( 0.0031308 ) ) ) ), value.a );
}
vec4 RGBEToLinear( in vec4 value ) {
    return vec4( value.rgb * exp2( value.a * 255.0 - 128.0 ), 1.0 );
}
vec4 LinearToRGBE( in vec4 value ) {
    float maxComponent = max( max( value.r, value.g ), value.b );
    float fExp = clamp( ceil( log2( maxComponent ) ), -128.0, 127.0 );
    return vec4( value.rgb / exp2( fExp ), ( fExp + 128.0 ) / 255.0 );
}
vec4 RGBMToLinear( in vec4 value, in float maxRange ) {
    return vec4( value.rgb * value.a * maxRange, 1.0 );
}
vec4 LinearToRGBM( in vec4 value, in float maxRange ) {
    float maxRGB = max( value.r, max( value.g, value.b ) );
    float M = clamp( maxRGB / maxRange, 0.0, 1.0 );
    M = ceil( M * 255.0 ) / 255.0;
    return vec4( value.rgb / ( M * maxRange ), M );
}
vec4 RGBDToLinear( in vec4 value, in float maxRange ) {
    return vec4( value.rgb * ( ( maxRange / 255.0 ) / value.a ), 1.0 );
}
vec4 LinearToRGBD( in vec4 value, in float maxRange ) {
    float maxRGB = max( value.r, max( value.g, value.b ) );
    float D = max( maxRange / maxRGB, 1.0 );
    D = min( floor( D ) / 255.0, 1.0 );
    return vec4( value.rgb * ( D * ( 255.0 / maxRange ) ), D );
}
const mat3 cLogLuvM = mat3( 0.2209, 0.3390, 0.4184, 0.1138, 0.6780, 0.7319, 0.0102, 0.1130, 0.2969 );
vec4 LinearToLogLuv( in vec4 value ) {
    vec3 Xp_Y_XYZp = cLogLuvM * value.rgb;
    Xp_Y_XYZp = max( Xp_Y_XYZp, vec3( 1e-6, 1e-6, 1e-6 ) );
    vec4 vResult;
    vResult.xy = Xp_Y_XYZp.xy / Xp_Y_XYZp.z;
    float Le = 2.0 * log2(Xp_Y_XYZp.y) + 127.0;
    vResult.w = fract( Le );
    vResult.z = ( Le - ( floor( vResult.w * 255.0 ) ) / 255.0 ) / 255.0;
    return vResult;
}
const mat3 cLogLuvInverseM = mat3( 6.0014, -2.7008, -1.7996, -1.3320, 3.1029, -5.7721, 0.3008, -1.0882, 5.6268 );
vec4 LogLuvToLinear( in vec4 value ) {
    float Le = value.z * 255.0 + value.w;
    vec3 Xp_Y_XYZp;
    Xp_Y_XYZp.y = exp2( ( Le - 127.0 ) / 2.0 );
    Xp_Y_XYZp.z = Xp_Y_XYZp.y / value.y;
    Xp_Y_XYZp.x = value.x * Xp_Y_XYZp.z;
    vec3 vRGB = cLogLuvInverseM * Xp_Y_XYZp.rgb;
    return vec4( max( vRGB, 0.0 ), 1.0 );
}
vec4 mapTexelToLinear( vec4 value ) {
    return LinearToLinear( value );
}
vec4 matcapTexelToLinear( vec4 value ) {
    return LinearToLinear( value );
}
vec4 envMapTexelToLinear( vec4 value ) {
    return LinearToLinear( value );
}
vec4 emissiveMapTexelToLinear( vec4 value ) {
    return LinearToLinear( value );
}
vec4 linearToOutputTexel( vec4 value ) {
    return LinearToLinear( value );
}

uniform vec3 diffuse;
uniform vec3 specular;
uniform float shininess;
uniform float opacity;
uniform bool enableDiffuse1;
uniform bool enableDiffuse2;
uniform bool enableSpecular;
uniform sampler2D tDiffuse1;
uniform sampler2D tDiffuse2;
uniform sampler2D tDetail;
uniform sampler2D tNormal;
uniform sampler2D tSpecular;
uniform sampler2D tDisplacement;
uniform float uNormalScale;
uniform vec2 uRepeatOverlay;
uniform vec2 uRepeatBase;
uniform vec2 uOffset;

varying vec3 vTangent;
varying vec3 vBinormal;
varying vec3 vNormal;
varying vec2 vUv;
varying vec3 vViewPosition;

#define PI 3.14159265359
#define PI2 6.28318530718
#define PI_HALF 1.5707963267949
#define RECIPROCAL_PI 0.31830988618
#define RECIPROCAL_PI2 0.15915494
#define LOG2 1.442695
#define EPSILON 1e-6
#define saturate(a) clamp( a, 0.0, 1.0 )
#define whiteCompliment(a) ( 1.0 - saturate( a ) )

float pow2( const in float x ) {
    return x*x;
}
float pow3( const in float x ) {
    return x*x*x;
}
float pow4( const in float x ) {
    float x2 = x*x;
    return x2*x2;
}
float average( const in vec3 color ) {
    return dot( color, vec3( 0.3333 ) );
}
highp float rand( const in vec2 uv ) {
    const highp float a = 12.9898, b = 78.233, c = 43758.5453;
    highp float dt = dot( uv.xy, vec2( a, b ) ), sn = mod( dt, PI );
    return fract(sin(sn) * c);
}
struct IncidentLight {
    vec3 color;
    vec3 direction;
    bool visible;
};
struct ReflectedLight {
    vec3 directDiffuse;
    vec3 directSpecular;
    vec3 indirectDiffuse;
    vec3 indirectSpecular;
};
struct GeometricContext {
    vec3 position;
    vec3 normal;
    vec3 viewDir;
};
vec3 transformDirection( in vec3 dir, in mat4 matrix ) {
    return normalize( ( matrix * vec4( dir, 0.0 ) ).xyz );
}
vec3 inverseTransformDirection( in vec3 dir, in mat4 matrix ) {
    return normalize( ( vec4( dir, 0.0 ) * matrix ).xyz );
}
vec3 projectOnPlane(in vec3 point, in vec3 pointOnPlane, in vec3 planeNormal ) {
    float distance = dot( planeNormal, point - pointOnPlane );
    return - distance * planeNormal + point;
}
float sideOfPlane( in vec3 point, in vec3 pointOnPlane, in vec3 planeNormal ) {
    return sign( dot( point - pointOnPlane, planeNormal ) );
}
vec3 linePlaneIntersect( in vec3 pointOnLine, in vec3 lineDirection, in vec3 pointOnPlane, in vec3 planeNormal ) {
    return lineDirection * ( dot( planeNormal, pointOnPlane - pointOnLine ) / dot( planeNormal, lineDirection ) ) + pointOnLine;
}
mat3 transposeMat3( const in mat3 m ) {
    mat3 tmp;
    tmp[ 0 ] = vec3( m[ 0 ].x, m[ 1 ].x, m[ 2 ].x );
    tmp[ 1 ] = vec3( m[ 0 ].y, m[ 1 ].y, m[ 2 ].y );
    tmp[ 2 ] = vec3( m[ 0 ].z, m[ 1 ].z, m[ 2 ].z );
    return tmp;
}
float linearToRelativeLuminance( const in vec3 color ) {
    vec3 weights = vec3( 0.2126, 0.7152, 0.0722 );
    return dot( weights, color.rgb );
}
vec2 integrateSpecularBRDF( const in float dotNV, const in float roughness ) {
    const vec4 c0 = vec4( - 1, - 0.0275, - 0.572, 0.022 );
    const vec4 c1 = vec4( 1, 0.0425, 1.04, - 0.04 );
    vec4 r = roughness * c0 + c1;
    float a004 = min( r.x * r.x, exp2( - 9.28 * dotNV ) ) * r.x + r.y;
    return vec2( -1.04, 1.04 ) * a004 + r.zw;
}
float punctualLightIntensityToIrradianceFactor( const in float lightDistance, const in float cutoffDistance, const in float decayExponent ) {
    #if defined ( PHYSICALLY_CORRECT_LIGHTS )
        float distanceFalloff = 1.0 / max( pow( lightDistance, decayExponent ), 0.01 );
        if( cutoffDistance > 0.0 ) {
            distanceFalloff *= pow2( saturate( 1.0 - pow4( lightDistance / cutoffDistance ) ) );
        }
        return distanceFalloff;
    #else
        if( cutoffDistance > 0.0 && decayExponent > 0.0 ) {
            return pow( saturate( -lightDistance / cutoffDistance + 1.0 ), decayExponent );
        }
        return 1.0;
    #endif
}
vec3 BRDF_Diffuse_Lambert( const in vec3 diffuseColor ) {
    return RECIPROCAL_PI * diffuseColor;
}
vec3 F_Schlick( const in vec3 specularColor, const in float dotLH ) {
    float fresnel = exp2( ( -5.55473 * dotLH - 6.98316 ) * dotLH );
    return ( 1.0 - specularColor ) * fresnel + specularColor;
}
float G_GGX_Smith( const in float alpha, const in float dotNL, const in float dotNV ) {
    float a2 = pow2( alpha );
    float gl = dotNL + sqrt( a2 + ( 1.0 - a2 ) * pow2( dotNL ) );
    float gv = dotNV + sqrt( a2 + ( 1.0 - a2 ) * pow2( dotNV ) );
    return 1.0 / ( gl * gv );
}
float G_GGX_SmithCorrelated( const in float alpha, const in float dotNL, const in float dotNV ) {
    float a2 = pow2( alpha );
    float gv = dotNL * sqrt( a2 + ( 1.0 - a2 ) * pow2( dotNV ) );
    float gl = dotNV * sqrt( a2 + ( 1.0 - a2 ) * pow2( dotNL ) );
    return 0.5 / max( gv + gl, EPSILON );
}
float D_GGX( const in float alpha, const in float dotNH ) {
    float a2 = pow2( alpha );
    float denom = pow2( dotNH ) * ( a2 - 1.0 ) + 1.0;
    return RECIPROCAL_PI * a2 / pow2( denom );
}
vec3 BRDF_Specular_GGX( const in IncidentLight incidentLight, const in GeometricContext geometry, const in vec3 specularColor, const in float roughness ) {
    float alpha = pow2( roughness );
    vec3 halfDir = normalize( incidentLight.direction + geometry.viewDir );
    float dotNL = saturate( dot( geometry.normal, incidentLight.direction ) );
    float dotNV = saturate( dot( geometry.normal, geometry.viewDir ) );
    float dotNH = saturate( dot( geometry.normal, halfDir ) );
    float dotLH = saturate( dot( incidentLight.direction, halfDir ) );
    vec3 F = F_Schlick( specularColor, dotLH );
    float G = G_GGX_SmithCorrelated( alpha, dotNL, dotNV );
    float D = D_GGX( alpha, dotNH );
    return F * ( G * D );
}
vec2 LTC_Uv( const in vec3 N, const in vec3 V, const in float roughness ) {
    const float LUT_SIZE = 64.0;
    const float LUT_SCALE = ( LUT_SIZE - 1.0 ) / LUT_SIZE;
    const float LUT_BIAS = 0.5 / LUT_SIZE;
    float dotNV = saturate( dot( N, V ) );
    vec2 uv = vec2( roughness, sqrt( 1.0 - dotNV ) );
    uv = uv * LUT_SCALE + LUT_BIAS;
    return uv;
}
float LTC_ClippedSphereFormFactor( const in vec3 f ) {
    float l = length( f );
    return max( ( l * l + f.z ) / ( l + 1.0 ), 0.0 );
}
vec3 LTC_EdgeVectorFormFactor( const in vec3 v1, const in vec3 v2 ) {
    float x = dot( v1, v2 );
    float y = abs( x );
    float a = 0.8543985 + ( 0.4965155 + 0.0145206 * y ) * y;
    float b = 3.4175940 + ( 4.1616724 + y ) * y;
    float v = a / b;
    float theta_sintheta = ( x > 0.0 ) ? v : 0.5 * inversesqrt( max( 1.0 - x * x, 1e-7 ) ) - v;
    return cross( v1, v2 ) * theta_sintheta;
}
vec3 LTC_Evaluate( const in vec3 N, const in vec3 V, const in vec3 P, const in mat3 mInv, const in vec3 rectCoords[ 4 ] ) {
    vec3 v1 = rectCoords[ 1 ] - rectCoords[ 0 ];
    vec3 v2 = rectCoords[ 3 ] - rectCoords[ 0 ];
    vec3 lightNormal = cross( v1, v2 );
    if( dot( lightNormal, P - rectCoords[ 0 ] ) < 0.0 ) return vec3( 0.0 );
    vec3 T1, T2;
    T1 = normalize( V - N * dot( V, N ) );
    T2 = - cross( N, T1 );
    mat3 mat = mInv * transposeMat3( mat3( T1, T2, N ) );
    vec3 coords[ 4 ];
    coords[ 0 ] = mat * ( rectCoords[ 0 ] - P );
    coords[ 1 ] = mat * ( rectCoords[ 1 ] - P );
    coords[ 2 ] = mat * ( rectCoords[ 2 ] - P );
    coords[ 3 ] = mat * ( rectCoords[ 3 ] - P );
    coords[ 0 ] = normalize( coords[ 0 ] );
    coords[ 1 ] = normalize( coords[ 1 ] );
    coords[ 2 ] = normalize( coords[ 2 ] );
    coords[ 3 ] = normalize( coords[ 3 ] );
    vec3 vectorFormFactor = vec3( 0.0 );
    vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 0 ], coords[ 1 ] );
    vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 1 ], coords[ 2 ] );
    vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 2 ], coords[ 3 ] );
    vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 3 ], coords[ 0 ] );
    float result = LTC_ClippedSphereFormFactor( vectorFormFactor );
    return vec3( result );
}
vec3 BRDF_Specular_GGX_Environment( const in GeometricContext geometry, const in vec3 specularColor, const in float roughness ) {
    float dotNV = saturate( dot( geometry.normal, geometry.viewDir ) );
    vec2 brdf = integrateSpecularBRDF( dotNV, roughness );
    return specularColor * brdf.x + brdf.y;
}
void BRDF_Specular_Multiscattering_Environment( const in GeometricContext geometry, const in vec3 specularColor, const in float roughness, inout vec3 singleScatter, inout vec3 multiScatter ) {
    float dotNV = saturate( dot( geometry.normal, geometry.viewDir ) );
    vec3 F = F_Schlick( specularColor, dotNV );
    vec2 brdf = integrateSpecularBRDF( dotNV, roughness );
    vec3 FssEss = F * brdf.x + brdf.y;
    float Ess = brdf.x + brdf.y;
    float Ems = 1.0 - Ess;
    vec3 Favg = specularColor + ( 1.0 - specularColor ) * 0.047619;
    vec3 Fms = FssEss * Favg / ( 1.0 - Ems * Favg );
    singleScatter += FssEss;
    multiScatter += Fms * Ems;
}
float G_BlinnPhong_Implicit( ) {
    return 0.25;
}
float D_BlinnPhong( const in float shininess, const in float dotNH ) {
    return RECIPROCAL_PI * ( shininess * 0.5 + 1.0 ) * pow( dotNH, shininess );
}
vec3 BRDF_Specular_BlinnPhong( const in IncidentLight incidentLight, const in GeometricContext geometry, const in vec3 specularColor, const in float shininess ) {
    vec3 halfDir = normalize( incidentLight.direction + geometry.viewDir );
    float dotNH = saturate( dot( geometry.normal, halfDir ) );
    float dotLH = saturate( dot( incidentLight.direction, halfDir ) );
    vec3 F = F_Schlick( specularColor, dotLH );
    float G = G_BlinnPhong_Implicit( );
    float D = D_BlinnPhong( shininess, dotNH );
    return F * ( G * D );
}
float GGXRoughnessToBlinnExponent( const in float ggxRoughness ) {
    return ( 2.0 / pow2( ggxRoughness + 0.0001 ) - 2.0 );
}
float BlinnExponentToGGXRoughness( const in float blinnExponent ) {
    return sqrt( 2.0 / ( blinnExponent + 2.0 ) );
}
uniform vec3 ambientLightColor;
vec3 getAmbientLightIrradiance( const in vec3 ambientLightColor ) {
    vec3 irradiance = ambientLightColor;
    #ifndef PHYSICALLY_CORRECT_LIGHTS
        irradiance *= PI;
    #endif
    return irradiance;
}
#if 1 > 0
    struct DirectionalLight {
        vec3 direction;
        vec3 color;
        int shadow;
        float shadowBias;
        float shadowRadius;
        vec2 shadowMapSize;
    };
    uniform DirectionalLight directionalLights[ 1 ];
    void getDirectionalDirectLightIrradiance( const in DirectionalLight directionalLight, const in GeometricContext geometry, out IncidentLight directLight ) {
        directLight.color = directionalLight.color;
        directLight.direction = directionalLight.direction;
        directLight.visible = true;
    }
#endif
#if 1 > 0
    struct PointLight {
        vec3 position;
        vec3 color;
        float distance;
        float decay;
        int shadow;
        float shadowBias;
        float shadowRadius;
        vec2 shadowMapSize;
        float shadowCameraNear;
        float shadowCameraFar;
    };
    uniform PointLight pointLights[ 1 ];
    void getPointDirectLightIrradiance( const in PointLight pointLight, const in GeometricContext geometry, out IncidentLight directLight ) {
        vec3 lVector = pointLight.position - geometry.position;
        directLight.direction = normalize( lVector );
        float lightDistance = length( lVector );
        directLight.color = pointLight.color;
        directLight.color *= punctualLightIntensityToIrradianceFactor( lightDistance, pointLight.distance, pointLight.decay );
        directLight.visible = ( directLight.color ! = vec3( 0.0 ) );
    }
#endif
#if 0 > 0
    struct SpotLight {
        vec3 position;
        vec3 direction;
        vec3 color;
        float distance;
        float decay;
        float coneCos;
        float penumbraCos;
        int shadow;
        float shadowBias;
        float shadowRadius;
        vec2 shadowMapSize;
    };
    uniform SpotLight spotLights[ 0 ];
    void getSpotDirectLightIrradiance( const in SpotLight spotLight, const in GeometricContext geometry, out IncidentLight directLight  ) {
        vec3 lVector = spotLight.position - geometry.position;
        directLight.direction = normalize( lVector );
        float lightDistance = length( lVector );
        float angleCos = dot( directLight.direction, spotLight.direction );
        if ( angleCos > spotLight.coneCos ) {
            float spotEffect = smoothstep( spotLight.coneCos, spotLight.penumbraCos, angleCos );
            directLight.color = spotLight.color;
            directLight.color *= spotEffect * punctualLightIntensityToIrradianceFactor( lightDistance, spotLight.distance, spotLight.decay );
            directLight.visible = true;
        }
        else {
            directLight.color = vec3( 0.0 );
            directLight.visible = false;
        }
    
    }
#endif
#if 0 > 0
    struct RectAreaLight {
        vec3 color;
        vec3 position;
        vec3 halfWidth;
        vec3 halfHeight;
    };
    uniform sampler2D ltc_1;
    uniform sampler2D ltc_2;
    uniform RectAreaLight rectAreaLights[ 0 ];
#endif
#if 0 > 0
    struct HemisphereLight {
        vec3 direction;
        vec3 skyColor;
        vec3 groundColor;
    };
    uniform HemisphereLight hemisphereLights[ 0 ];
    vec3 getHemisphereLightIrradiance( const in HemisphereLight hemiLight, const in GeometricContext geometry ) {
        float dotNL = dot( geometry.normal, hemiLight.direction );
        float hemiDiffuseWeight = 0.5 * dotNL + 0.5;
        vec3 irradiance = mix( hemiLight.groundColor, hemiLight.skyColor, hemiDiffuseWeight );
        #ifndef PHYSICALLY_CORRECT_LIGHTS
            irradiance *= PI;
        #endif
        return irradiance;
    }
#endif
#ifdef USE_SHADOWMAP
    #if 1 > 0
        uniform sampler2D directionalShadowMap[ 1 ];
        varying vec4 vDirectionalShadowCoord[ 1 ];
    #endif
    #if 0 > 0
        uniform sampler2D spotShadowMap[ 0 ];
        varying vec4 vSpotShadowCoord[ 0 ];
    #endif
    #if 1 > 0
        uniform sampler2D pointShadowMap[ 1 ];
        varying vec4 vPointShadowCoord[ 1 ];
    #endif
    float texture2DCompare( sampler2D depths, vec2 uv, float compare ) {
        return step( compare, unpackRGBAToDepth( texture2D( depths, uv ) ) );
    }
    float texture2DShadowLerp( sampler2D depths, vec2 size, vec2 uv, float compare ) {
        const vec2 offset = vec2( 0.0, 1.0 );
        vec2 texelSize = vec2( 1.0 ) / size;
        vec2 centroidUV = floor( uv * size + 0.5 ) / size;
        float lb = texture2DCompare( depths, centroidUV + texelSize * offset.xx, compare );
        float lt = texture2DCompare( depths, centroidUV + texelSize * offset.xy, compare );
        float rb = texture2DCompare( depths, centroidUV + texelSize * offset.yx, compare );
        float rt = texture2DCompare( depths, centroidUV + texelSize * offset.yy, compare );
        vec2 f = fract( uv * size + 0.5 );
        float a = mix( lb, lt, f.y );
        float b = mix( rb, rt, f.y );
        float c = mix( a, b, f.x );
        return c;
    }
    float getShadow( sampler2D shadowMap, vec2 shadowMapSize, float shadowBias, float shadowRadius, vec4 shadowCoord ) {
        float shadow = 1.0;
        shadowCoord.xyz /= shadowCoord.w;
        shadowCoord.z += shadowBias;
        bvec4 inFrustumVec = bvec4 ( shadowCoord.x >= 0.0, shadowCoord.x <= 1.0, shadowCoord.y >= 0.0, shadowCoord.y <= 1.0 );
        bool inFrustum = all( inFrustumVec );
        bvec2 frustumTestVec = bvec2( inFrustum, shadowCoord.z <= 1.0 );
        bool frustumTest = all( frustumTestVec );
        if ( frustumTest ) {
            #if defined( SHADOWMAP_TYPE_PCF )
                vec2 texelSize = vec2( 1.0 ) / shadowMapSize;
                float dx0 = - texelSize.x * shadowRadius;
                float dy0 = - texelSize.y * shadowRadius;
                float dx1 = + texelSize.x * shadowRadius;
                float dy1 = + texelSize.y * shadowRadius;
                shadow = (
                texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx0, dy0 ), shadowCoord.z ) +
                texture2DCompare( shadowMap, shadowCoord.xy + vec2( 0.0, dy0 ), shadowCoord.z ) +
                texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx1, dy0 ), shadowCoord.z ) +
                texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx0, 0.0 ), shadowCoord.z ) +
                texture2DCompare( shadowMap, shadowCoord.xy, shadowCoord.z ) +
                texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx1, 0.0 ), shadowCoord.z ) +
                texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx0, dy1 ), shadowCoord.z ) +
                texture2DCompare( shadowMap, shadowCoord.xy + vec2( 0.0, dy1 ), shadowCoord.z ) +
                texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx1, dy1 ), shadowCoord.z )
                ) * ( 1.0 / 9.0 );
                #elif defined( SHADOWMAP_TYPE_PCF_SOFT )
                vec2 texelSize = vec2( 1.0 ) / shadowMapSize;
                float dx0 = - texelSize.x * shadowRadius;
                float dy0 = - texelSize.y * shadowRadius;
                float dx1 = + texelSize.x * shadowRadius;
                float dy1 = + texelSize.y * shadowRadius;
                shadow = (
                texture2DShadowLerp( shadowMap, shadowMapSize, shadowCoord.xy + vec2( dx0, dy0 ), shadowCoord.z ) +
                texture2DShadowLerp( shadowMap, shadowMapSize, shadowCoord.xy + vec2( 0.0, dy0 ), shadowCoord.z ) +
                texture2DShadowLerp( shadowMap, shadowMapSize, shadowCoord.xy + vec2( dx1, dy0 ), shadowCoord.z ) +
                texture2DShadowLerp( shadowMap, shadowMapSize, shadowCoord.xy + vec2( dx0, 0.0 ), shadowCoord.z ) +
                texture2DShadowLerp( shadowMap, shadowMapSize, shadowCoord.xy, shadowCoord.z ) +
                texture2DShadowLerp( shadowMap, shadowMapSize, shadowCoord.xy + vec2( dx1, 0.0 ), shadowCoord.z ) +
                texture2DShadowLerp( shadowMap, shadowMapSize, shadowCoord.xy + vec2( dx0, dy1 ), shadowCoord.z ) +
                texture2DShadowLerp( shadowMap, shadowMapSize, shadowCoord.xy + vec2( 0.0, dy1 ), shadowCoord.z ) +
                texture2DShadowLerp( shadowMap, shadowMapSize, shadowCoord.xy + vec2( dx1, dy1 ), shadowCoord.z )
                ) * ( 1.0 / 9.0 );
            #else
                shadow = texture2DCompare( shadowMap, shadowCoord.xy, shadowCoord.z );
            #endif
        }
        return shadow;
    }
    vec2 cubeToUV( vec3 v, float texelSizeY ) {
        vec3 absV = abs( v );
        float scaleToCube = 1.0 / max( absV.x, max( absV.y, absV.z ) );
        absV *= scaleToCube;
        v *= scaleToCube * ( 1.0 - 2.0 * texelSizeY );
        vec2 planar = v.xy;
        float almostATexel = 1.5 * texelSizeY;
        float almostOne = 1.0 - almostATexel;
        if ( absV.z >= almostOne ) {
            if ( v.z > 0.0 )
            planar.x = 4.0 - v.x;
        }
        else if ( absV.x >= almostOne ) {
            float signX = sign( v.x );
            planar.x = v.z * signX + 2.0 * signX;
        }
        else if ( absV.y >= almostOne ) {
            float signY = sign( v.y );
            planar.x = v.x + 2.0 * signY + 2.0;
            planar.y = v.z * signY - 2.0;
        }
        return vec2( 0.125, 0.25 ) * planar + vec2( 0.375, 0.75 );
    }
    float getPointShadow( sampler2D shadowMap, vec2 shadowMapSize, float shadowBias, float shadowRadius, vec4 shadowCoord, float shadowCameraNear, float shadowCameraFar ) {
        vec2 texelSize = vec2( 1.0 ) / ( shadowMapSize * vec2( 4.0, 2.0 ) );
        vec3 lightToPosition = shadowCoord.xyz;
        float dp = ( length( lightToPosition ) - shadowCameraNear ) / ( shadowCameraFar - shadowCameraNear );
        dp += shadowBias;
        vec3 bd3D = normalize( lightToPosition );
        #if defined( SHADOWMAP_TYPE_PCF ) || defined( SHADOWMAP_TYPE_PCF_SOFT )
            vec2 offset = vec2( - 1, 1 ) * shadowRadius * texelSize.y;
            return (
            texture2DCompare( shadowMap, cubeToUV( bd3D + offset.xyy, texelSize.y ), dp ) +
            texture2DCompare( shadowMap, cubeToUV( bd3D + offset.yyy, texelSize.y ), dp ) +
            texture2DCompare( shadowMap, cubeToUV( bd3D + offset.xyx, texelSize.y ), dp ) +
            texture2DCompare( shadowMap, cubeToUV( bd3D + offset.yyx, texelSize.y ), dp ) +
            texture2DCompare( shadowMap, cubeToUV( bd3D, texelSize.y ), dp ) +
            texture2DCompare( shadowMap, cubeToUV( bd3D + offset.xxy, texelSize.y ), dp ) +
            texture2DCompare( shadowMap, cubeToUV( bd3D + offset.yxy, texelSize.y ), dp ) +
            texture2DCompare( shadowMap, cubeToUV( bd3D + offset.xxx, texelSize.y ), dp ) +
            texture2DCompare( shadowMap, cubeToUV( bd3D + offset.yxx, texelSize.y ), dp )
            ) * ( 1.0 / 9.0 );
        #else
            return texture2DCompare( shadowMap, cubeToUV( bd3D, texelSize.y ), dp );
        #endif
    }
#endif
#ifdef USE_FOG
    uniform vec3 fogColor;
    varying float fogDepth;
    #ifdef FOG_EXP2
        uniform float fogDensity;
    #else
        uniform float fogNear;
        uniform float fogFar;
    #endif
#endif
float calcLightAttenuation( float lightDistance, float cutoffDistance, float decayExponent ) {
    if ( decayExponent > 0.0 ) {
        return pow( saturate( - lightDistance / cutoffDistance + 1.0 ), decayExponent );
    }
    return 1.0;
}

void main() {
    vec3 outgoingLight = vec3( 0.0 );
    vec4 diffuseColor = vec4( diffuse, opacity );
    vec3 specularTex = vec3( 1.0 );
    vec2 uvOverlay = uRepeatOverlay * vUv + uOffset;
    vec2 uvBase = uRepeatBase * vUv;
    vec3 normalTex = texture2D( tDetail, uvOverlay ).xyz * 2.0 - 1.0;
    normalTex.xy *= uNormalScale;
    normalTex = normalize( normalTex );
    if( enableDiffuse1 && enableDiffuse2 ) {
        vec4 colDiffuse1 = texture2D( tDiffuse1, uvOverlay );
        vec4 colDiffuse2 = texture2D( tDiffuse2, uvOverlay );
        colDiffuse1 = GammaToLinear( colDiffuse1, float( GAMMA_FACTOR ) );
        colDiffuse2 = GammaToLinear( colDiffuse2, float( GAMMA_FACTOR ) );
        diffuseColor *= mix ( colDiffuse1, colDiffuse2, 1.0 - texture2D( tDisplacement, uvBase ) );
    }
    else if( enableDiffuse1 ) {
        diffuseColor *= texture2D( tDiffuse1, uvOverlay );
    }
    else if( enableDiffuse2 ) {
        diffuseColor *= texture2D( tDiffuse2, uvOverlay );
    }
    if( enableSpecular )
    specularTex = texture2D( tSpecular, uvOverlay ).xyz;
    mat3 tsb = mat3( vTangent, vBinormal, vNormal );
    vec3 finalNormal = tsb * normalTex;
    vec3 normal = normalize( finalNormal );
    vec3 viewPosition = normalize( vViewPosition );
    vec3 totalDiffuseLight = vec3( 0.0 );
    vec3 totalSpecularLight = vec3( 0.0 );
    #if 1 > 0
        for ( int i = 0; i < 1; i ++ ) {
            vec3 lVector = pointLights[ i ].position + vViewPosition.xyz;
            float attenuation = calcLightAttenuation( length( lVector ), pointLights[ i ].distance, pointLights[ i ].decay );
            lVector = normalize( lVector );
            vec3 pointHalfVector = normalize( lVector + viewPosition );
            float pointDotNormalHalf = max( dot( normal, pointHalfVector ), 0.0 );
            float pointDiffuseWeight = max( dot( normal, lVector ), 0.0 );
            float pointSpecularWeight = specularTex.r * max( pow( pointDotNormalHalf, shininess ), 0.0 );
            totalDiffuseLight += attenuation * pointLights[ i ].color * pointDiffuseWeight;
            totalSpecularLight += attenuation * pointLights[ i ].color * specular * pointSpecularWeight * pointDiffuseWeight;
        }
    #endif
    #if 1 > 0
        vec3 dirDiffuse = vec3( 0.0 );
        vec3 dirSpecular = vec3( 0.0 );
        for( int i = 0; i < 1; i++ ) {
            vec3 dirVector = directionalLights[ i ].direction;
            vec3 dirHalfVector = normalize( dirVector + viewPosition );
            float dirDotNormalHalf = max( dot( normal, dirHalfVector ), 0.0 );
            float dirDiffuseWeight = max( dot( normal, dirVector ), 0.0 );
            float dirSpecularWeight = specularTex.r * max( pow( dirDotNormalHalf, shininess ), 0.0 );
            totalDiffuseLight += directionalLights[ i ].color * dirDiffuseWeight;
            totalSpecularLight += directionalLights[ i ].color * specular * dirSpecularWeight * dirDiffuseWeight;
        }
    #endif
    #if 0 > 0
        vec3 hemiDiffuse = vec3( 0.0 );
        vec3 hemiSpecular = vec3( 0.0 );
        for( int i = 0; i < 0; i ++ ) {
            vec3 lVector = hemisphereLightDirection[ i ];
            float dotProduct = dot( normal, lVector );
            float hemiDiffuseWeight = 0.5 * dotProduct + 0.5;
            totalDiffuseLight += mix( hemisphereLights[ i ].groundColor, hemisphereLights[ i ].skyColor, hemiDiffuseWeight );
            float hemiSpecularWeight = 0.0;
            vec3 hemiHalfVectorSky = normalize( lVector + viewPosition );
            float hemiDotNormalHalfSky = 0.5 * dot( normal, hemiHalfVectorSky ) + 0.5;
            hemiSpecularWeight += specularTex.r * max( pow( hemiDotNormalHalfSky, shininess ), 0.0 );
            vec3 lVectorGround = -lVector;
            vec3 hemiHalfVectorGround = normalize( lVectorGround + viewPosition );
            float hemiDotNormalHalfGround = 0.5 * dot( normal, hemiHalfVectorGround ) + 0.5;
            hemiSpecularWeight += specularTex.r * max( pow( hemiDotNormalHalfGround, shininess ), 0.0 );
            totalSpecularLight += specular * mix( hemisphereLights[ i ].groundColor, hemisphereLights[ i ].skyColor, hemiDiffuseWeight ) * hemiSpecularWeight * hemiDiffuseWeight;
        }
    #endif
    outgoingLight += diffuseColor.xyz * ( totalDiffuseLight + ambientLightColor + totalSpecularLight );
    gl_FragColor = vec4( outgoingLight, diffuseColor.a );
    #ifdef USE_FOG
        #ifdef FOG_EXP2
            float fogFactor = whiteCompliment( exp2( - fogDensity * fogDensity * fogDepth * fogDepth * LOG2 ) );
        #else
            float fogFactor = smoothstep( fogNear, fogFar, fogDepth );
        #endif
        gl_FragColor.rgb = mix( gl_FragColor.rgb, fogColor, fogFactor );
    #endif
}
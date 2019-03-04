uniform sampler2D tDiffuse1;
uniform sampler2D tDiffuse2;
uniform sampler2D tDetail;
uniform sampler2D tDisplacement;
uniform vec3 diffuse;
uniform float opacity;
uniform float uNormalScale;
uniform vec2 uRepeatOverlay;
uniform vec2 uRepeatBase;
uniform vec2 uOffset;

varying vec3 vTangent;
varying vec3 vBinormal;
varying vec3 vNormal;
varying vec2 vUv;
varying vec3 vViewPosition;

void main()
{
    vec4 diffuseColor = vec4(diffuse, opacity);
    vec2 uvOverlay = uRepeatOverlay * vUv + uOffset;
    vec2 uvBase = uRepeatBase * vUv;
    vec3 normalTex = texture2D(tDetail, uvOverlay).xyz * 2.0 - 1.0;
    normalTex.xy *= uNormalScale;
	normalTex = normalize(normalTex);

	vec4 colDiffuse1 = texture2D(tDiffuse1, uvOverlay);
	vec4 colDiffuse2 = texture2D(tDiffuse2, uvOverlay);
	colDiffuse1 = GammaToLinear(colDiffuse1, float(GAMMA_FACTOR));
	colDiffuse2 = GammaToLinear(colDiffuse2, float(GAMMA_FACTOR));
	diffuseColor *= mix(colDiffuse1, colDiffuse2, 1.0 - texture2D(tDisplacement, uvBase));

    mat3 tsb = mat3(vTangent, vBinormal, vNormal);
    vec3 finalNormal = tsb * normalTex;
    vec3 normal = normalize(finalNormal);
    vec3 viewPosition = normalize(vViewPosition);
	
	// TODO re-add lighting/normal usage

    gl_FragColor = diffuseColor;
}
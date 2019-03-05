varying vec2 vUvNoise;
varying vec2 vUvTexture;
uniform vec2 scale;
uniform vec2 offset;

void main()
{
    vUvTexture = uv;
	vUvNoise = uv * scale + offset;
	gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}
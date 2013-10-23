// Predefined uniform and attribute names. For an exhaustive list of available uniforms
// and vertex attributes, check the online documentation!
uniform mat4 metaio_mat4_modelViewProjection;

// Note: Our 3D model does not have vertex colors, so no need to consider them here
attribute vec4 inVertex; // position in object space
attribute vec2 inTexCoord; // UV coordinates

varying vec2 outTexCoord;

void main()
{
	outTexCoord = inTexCoord;
	gl_Position = metaio_mat4_modelViewProjection * inVertex;
}



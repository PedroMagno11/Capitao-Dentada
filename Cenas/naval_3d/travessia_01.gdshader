shader_type spatial;
render_mode cull_disabled;

uniform vec3 cor_funda : source_color = vec3(0.01, 0.08, 0.18);
uniform vec3 cor_media : source_color = vec3(0.02, 0.30, 0.50);
uniform vec3 cor_clara : source_color = vec3(0.12, 0.62, 0.72);

uniform float amplitude : hint_range(0.0, 1.0) = 0.18;
uniform float frequencia : hint_range(0.05, 2.0) = 0.35;
uniform float velocidade : hint_range(0.0, 5.0) = 1.2;

varying float altura_onda;


void vertex() {
	float onda_x = sin(
		VERTEX.x * frequencia
		+ TIME * velocidade
	);

	float onda_z = cos(
		VERTEX.z * frequencia * 0.8
		+ TIME * velocidade * 0.7
	);

	float onda_diagonal = sin(
		(VERTEX.x + VERTEX.z) * frequencia * 0.55
		- TIME * velocidade * 0.5
	);

	altura_onda = (
		onda_x
		+ onda_z * 0.7
		+ onda_diagonal * 0.4
	) / 2.1;

	VERTEX.y += altura_onda * amplitude;
}


void fragment() {
	float mistura = clamp(
		altura_onda * 0.5 + 0.5,
		0.0,
		1.0
	);

	vec3 cor_mar = mix(
		cor_funda,
		cor_media,
		smoothstep(0.0, 0.7, mistura)
	);

	cor_mar = mix(
		cor_mar,
		cor_clara,
		smoothstep(0.65, 1.0, mistura)
	);

	float fresnel = pow(
		1.0 - max(dot(NORMAL, VIEW), 0.0),
		3.0
	);

	ALBEDO = mix(
		cor_mar,
		cor_clara,
		fresnel * 0.25
	);

	ROUGHNESS = 0.18;
	METALLIC = 0.0;
	SPECULAR = 0.5;
}
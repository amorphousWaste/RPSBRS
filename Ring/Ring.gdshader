shader_type canvas_item;
render_mode unshaded;

uniform sampler2D image_texture : repeat_enable;
uniform sampler2D image_multiplier;
uniform sampler2D image_add : hint_default_black;
uniform sampler2D image_gradient_tint : hint_default_black;
uniform float extra_power = 1.0;
uniform float alpha = 1.0;

uniform float effect_scale = 1.0;
uniform float effect_repeat = 2.0;
uniform vec2 effect_center = vec2(0.5);
uniform vec2 uv_mod = vec2(1.0);
uniform vec2 scroll_speed = vec2(0.0);

vec2 coordinates(vec2 uv, vec2 center, float scale, float repeat) {
    vec2 dir = uv - center;
    float radius = length(dir) * 2.0;
    float angle = (atan(dir.x, dir.y) / TAU) + 0.5;
    return(vec2(angle * repeat, radius * scale));
}

void fragment() {
    vec2 uv = uv_mod * coordinates(UV, effect_center, effect_scale, effect_repeat);
    vec4 image_tex = texture(image_texture, mod(uv + (TIME * scroll_speed), 1.0));
    image_tex *= texture(image_multiplier, UV);
    image_tex += texture(image_add, UV);
    COLOR = textureLod(image_gradient_tint, vec2(clamp(image_tex.r, 0.0, 1.0) * extra_power, 0.0), alpha) * extra_power;
}

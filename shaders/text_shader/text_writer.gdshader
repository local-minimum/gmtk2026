shader_type spatial;
render_mode unshaded;

uniform sampler2D spritefont: filter_nearest;
uniform ivec2 spritefont_tex_size;
uniform vec2 character_start;
uniform vec2 character_size = vec2(8.0, 16.0);
uniform vec2 character_spacing;

// ncoded string, first letter on sprite font is 0, -1 is blank space, -2 is end of word
uniform int word[32];
uniform int word_length = 0;
uniform int word_spacing = 1;

uniform vec4 font_color: source_color;
uniform vec4 background_color: source_color;

uniform vec2 offset;
uniform bool animate;

uniform float uv_characters_per_line: hint_range(1.0, 10000.0, 0.1) = 40.0;
uniform float uv_character_spacing: hint_range(0.0, 10.0, 0.1) = 0.0;
uniform float uv_line_spacing;
uniform float uv_character_aspect_ratio: hint_range(0.0, 100.0, 0.1) = 1.0;

int positive_modulo(int i, int n) {
    return (n + (i % n)) % n;
}

float positive_modulo(float i, float n) {
    return mod(n + mod(i, n), n);
}

vec4 get_char_font_color(int ch, vec2 ch_coords) {
    if (ch < 0) {
        return background_color;
    }
    int ch_per_row = (spritefont_tex_size.x - int(floor(character_start.x))) / int(floor(character_size.x + character_spacing.x));
    int col = positive_modulo(ch, ch_per_row);
    int row = ch / ch_per_row;

    vec2 char_coords = vec2(float(col), float(row));
    vec2 char_origin = character_start + char_coords * (character_size + character_spacing);
    vec4 ch_col = texture(spritefont, (char_origin + ch_coords * character_size) / vec2(spritefont_tex_size));
    return mix(background_color, font_color, ch_col.a);
}

void fragment() {
    // 1. Calculate dimensions of a single character cell
    float uv_char_block_width = 1.0 / uv_characters_per_line;
    float uv_char_width = (uv_char_block_width - uv_character_spacing * uv_char_block_width);
    float uv_char_height = uv_character_aspect_ratio * uv_char_block_width / character_size.x * character_size.y;
    float uv_char_block_height = uv_char_height + uv_line_spacing * uv_char_block_width;
    vec2 uv_char_block = vec2(uv_char_block_width, uv_char_block_height);

    // 2. Find which character cell we are in
    vec2 uv_block = (UV + (animate ? mod(offset * TIME, 10.0) : offset)) / uv_char_block;

    // 3. Find character in string based on block
    int message_length = word_length + word_spacing;
    int cur_word_letter_idx = positive_modulo(int(floor(floor(uv_block.x) + floor(uv_block.y) * uv_characters_per_line)), message_length);

    // 4. Assign albedo color
    if (cur_word_letter_idx >= word_length) {
        ALBEDO = background_color.rgb;
    } else {
        vec2 uv_block_coords = fract(uv_block) * uv_char_block;
        if (uv_block_coords.x > uv_char_width || uv_block_coords.y  > uv_char_height || cur_word_letter_idx < -1) {
            ALBEDO = background_color.rgb;
        } else {
            if (cur_word_letter_idx < 0) {
                cur_word_letter_idx = positive_modulo(cur_word_letter_idx,  word_length);
            }
            vec2 uv_char = vec2(uv_char_width, uv_char_height);

            ALBEDO = get_char_font_color(word[cur_word_letter_idx], uv_block_coords / uv_char).rgb;
        }
    }
}
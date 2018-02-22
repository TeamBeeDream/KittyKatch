/*void main() {
    vec4 topColor = vec4(1.0, 0.0, 0.0, 1.0);
    vec4 bottomColor = vec4(1.0, 1.0, 0.0, 1.0);
    
    vec4 color = texture2D(u_texture, v_tex_coord);
    gl_FragColor = color * vec4(mix(bottomColor, topColor, v_tex_coord.y));
}
*/

void main( void ) {
    vec2 position = v_tex_coord / 4.0;
    float time = u_time * 3.0;
    
    float color = 0.0;
    color += sin( position.x * cos( time / 15.0 ) * 80.0 ) + cos( position.y * cos( time / 15.0 ) * 10.0 );
    color += sin( position.y * sin( time / 10.0 ) * 40.0 ) + cos( position.x * sin( time / 25.0 ) * 40.0 );
    color += sin( position.x * sin( time / 5.0 ) * 10.0 ) + sin( position.y * sin( time / 35.0 ) * 80.0 );
    color *= sin( time / 10.0 ) * 0.5;
    
    gl_FragColor = vec4( vec3( color, color * 0.5, sin( color + time / 3.0 ) * 0.75 ), 1.0 );
}

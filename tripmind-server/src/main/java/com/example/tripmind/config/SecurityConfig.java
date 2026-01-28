package com.example.tripmind.config;

import com.example.tripmind.security.JwtFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import static org.springframework.security.config.Customizer.withDefaults;

@Configuration
public class SecurityConfig {

    private final JwtFilter jwtFilter;

    public SecurityConfig(JwtFilter jwtFilter) {
        this.jwtFilter = jwtFilter;
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                .cors(withDefaults())
                .csrf(csrf -> csrf.disable())
                .sessionManagement(sm -> sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(reg -> reg
                        // CORS preflights (safe even if you don't think you're using CORS)
                        .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                        // Error endpoint sometimes used during exception flows
                        .requestMatchers("/error").permitAll()
                        // Your public APIs
                        .requestMatchers(
                                "/api/auth/register",
                                "/api/auth/login",
                                "/api/ai",
                                "/api/ai/itinerary",
                                "/api/public/**",
                                "/actuator/health"
                        ).permitAll()
                        // Admin / Expert APIs
                        .requestMatchers("/api/admin/**").hasRole("ADMIN")
                        .requestMatchers("/api/experts/**").hasRole("EXPERT")
                        .requestMatchers("/api/trips/**", "/api/itineraries/**").authenticated()
                        .anyRequest().authenticated()
                )
                .httpBasic(h -> h.disable())
                .formLogin(f -> f.disable())
                .logout(l -> l.disable())
                .anonymous(a -> a.authorities("ROLE_ANONYMOUS"));

        http.addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }
}

package com.example.tripmind.security;

import com.example.tripmind.model.Role;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.util.AntPathMatcher;

import java.io.IOException;
import java.util.List;

@Component
public class JwtFilter extends OncePerRequestFilter {

    private final JwtUtil jwtUtil;

    private static final AntPathMatcher MATCHER = new AntPathMatcher();

    // Endpoints that should be accessible without any JWT checks
    private static final List<String> PUBLIC_PATHS = List.of(
            "/api/auth/register",
            "/api/auth/login",
            "/api/ai/chat",
            "/api/ai/itinerary",
            "/api/public/**",
            "/actuator/health"
    );

    public JwtFilter(JwtUtil jwtUtil) {
        this.jwtUtil = jwtUtil;
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest req,
            HttpServletResponse res,
            FilterChain chain
    ) throws ServletException, IOException {

        final String uri = req.getRequestURI();

        if (isPublic(uri)) {
            chain.doFilter(req, res);
            return;
        }

        String auth = req.getHeader("Authorization");
        if (auth == null || !auth.startsWith("Bearer ")) {
            chain.doFilter(req, res);
            return;
        }

        String token = auth.substring(7);

        try {
            String email = jwtUtil.extractUsername(token); // may throw if token malformed/expired
            if (email != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                boolean valid = jwtUtil.validateToken(token, email);
                if (valid) {
                    Role role = jwtUtil.extractRole(token);
                    String authority = "ROLE_" + (role == null ? Role.USER.name() : role.name());

                    var principal = User.withUsername(email)
                            .password("") // not used
                            .authorities(new SimpleGrantedAuthority(authority))
                            .build();

                    var authentication = new UsernamePasswordAuthenticationToken(
                            principal, null, principal.getAuthorities());
                    authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(req));

                    SecurityContextHolder.getContext().setAuthentication(authentication);
                }
            }
        } catch (Exception ignored) {
            SecurityContextHolder.clearContext();
        }

        chain.doFilter(req, res);
    }

    private boolean isPublic(String uri) {
        for (String p : PUBLIC_PATHS) {
            if (MATCHER.match(p, uri)) return true;
        }
        return false;
    }
}

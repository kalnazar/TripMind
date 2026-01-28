package com.example.tripmind.security;

import com.example.tripmind.model.Role;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import io.jsonwebtoken.security.WeakKeyException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;

@Component
public class JwtUtil {

    private final SecretKey key;
    private final long expirationMs;

    private static final String ROLE_CLAIM = "role";

    public JwtUtil(@Value("${app.jwt-secret:}") String secret,
                   @Value("${app.jwt-exp-ms:604800000}") long expirationMs) {
        this.expirationMs = expirationMs;

        if (secret == null || secret.isBlank()) {
            throw new IllegalStateException(
                    "Missing app.jwt-secret. Provide a base64 key (>=256-bit). " +
                            "Example: openssl rand -base64 64");
        }

        SecretKey candidate;
        try {
            // пробуем как base64
            candidate = Keys.hmacShaKeyFor(Decoders.BASE64.decode(secret));
        } catch (IllegalArgumentException | WeakKeyException e1) {
            try {
                // иначе как сырая строка (должна быть достаточно длинной)
                candidate = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
            } catch (WeakKeyException e2) {
                throw new IllegalStateException(
                        "app.jwt-secret is too weak. Use >=32 bytes (256-bit) key, ideally base64. " +
                                "Generate with: openssl rand -base64 64", e2);
            }
        }
        this.key = candidate;
    }

    public String generateToken(String subjectEmail) {
        return generateToken(subjectEmail, Role.USER);
    }

    public String generateToken(String subjectEmail, Role role) {
        Role safeRole = role == null ? Role.USER : role;
        return Jwts.builder()
                .setSubject(subjectEmail)
                .claim(ROLE_CLAIM, safeRole.name())
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + expirationMs))
                .signWith(key, SignatureAlgorithm.HS256)
                .compact();
    }

    public String extractUsername(String token) {
        try {
            return Jwts.parserBuilder()
                    .setSigningKey(key)
                    .build()
                    .parseClaimsJws(token)
                    .getBody()
                    .getSubject();
        } catch (JwtException e) {
            return null;
        }
    }

    public Role extractRole(String token) {
        try {
            Object raw = Jwts.parserBuilder()
                    .setSigningKey(key)
                    .build()
                    .parseClaimsJws(token)
                    .getBody()
                    .get(ROLE_CLAIM);
            if (raw == null) return Role.USER;
            return Role.valueOf(raw.toString());
        } catch (Exception e) {
            return Role.USER;
        }
    }

    public boolean validateToken(String token, String expectedEmail) {
        try {
            var body = Jwts.parserBuilder()
                    .setSigningKey(key)
                    .build()
                    .parseClaimsJws(token)
                    .getBody();
            return expectedEmail != null
                    && expectedEmail.equals(body.getSubject())
                    && body.getExpiration() != null
                    && body.getExpiration().after(new Date());
        } catch (JwtException e) {
            return false;
        }
    }
}


package ma.gatekeeper.iam.security;

import ma.gatekeeper.iam.service.JwtService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component // 1. Important pour que Spring le trouve
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtService jwtService;
    private final UserDetailsService userDetailsService;

    @Override
    protected void doFilterInternal(
            @NonNull HttpServletRequest request,
            @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain
    ) throws ServletException, IOException {

        final String authHeader = request.getHeader("Authorization");
        final String jwt;
        final String username;

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        jwt = authHeader.substring(7);

        try {
            // On vérifie le token (Signature + Expiration + Type ACCESS)
            username = jwtService.validateTokenAndGetUsername(jwt, "ACCESS");

            // 3. Si valide et pas encore authentifié
            if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {

                // Charger l'utilisateur depuis la DB
                UserDetails userDetails = this.userDetailsService.loadUserByUsername(username);

                // Créer l'objet d'authentification officiel ---
                UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                        userDetails,
                        null, // Pas de mot de passe nécessaire
                        userDetails.getAuthorities() // Les rôles (Important !)
                );

                // Ajouter les détails de la requête (IP, Session)
                authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

                // --- Le mettre dans la "Poche" ---
                SecurityContextHolder.getContext().setAuthentication(authToken);
            }
        } catch (Exception e) {
            // Si le token est invalide/expiré, on ne fait RIEN.
            // L'utilisateur reste anonyme. S'il tente d'accéder à une page privée, il aura une 403 plus loin.
            // On pourrait logger : System.out.println("Token invalide : " + e.getMessage());
        }

        // 4. Toujours laisser la requête continuer sa route !
        filterChain.doFilter(request, response);
    }
}
package ma.gatekeeper.iam.service;

import ma.gatekeeper.iam.config.JwtConfig;
import ma.gatekeeper.iam.model.RefreshToken;
import ma.gatekeeper.iam.model.User;
import ma.gatekeeper.iam.repository.RefreshTokenRepository;
import ma.gatekeeper.iam.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.Instant;
import java.util.Base64;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class RefreshTokenService {

    private final RefreshTokenRepository refreshTokenRepository;
    private final UserRepository userRepository;
    private final JwtConfig jwtConfig;
    private final JwtService jwtService;

    /**
     * Crée un Refresh Token, le hache (SHA-256) et le sauvegarde en base.
     * @param userId L'ID de l'utilisateur
     * @return Le token brut (Raw) à envoyer au client.
     */
    @Transactional
    public String createRefreshToken(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Utilisateur introuvable"));

        // 1. Générer le token brut (JWT) via l'usine à tokens
        String rawToken = jwtService.generateRefreshToken(user);

        // 2. Calculer le Hash SHA-256 (C'est ce qu'on garde en base pour la sécurité)
        String tokenHash = hashToken(rawToken);

        // 3. Sauvegarder le hash en base
        RefreshToken refreshToken = RefreshToken.builder()
                .user(user)
                .tokenHash(tokenHash)
                .expiresAt(Instant.now().plusMillis(jwtConfig.getRefreshExpiration()))
                .revoked(false)
                .build();

        refreshTokenRepository.save(refreshToken);

        // 4. Retourner le token BRUT à l'utilisateur (il est le seul à le connaître)
        return rawToken;
    }

    /**
     * Vérifie si un token brut est valide (existe en base, non expiré, non révoqué).
     * @param rawToken Le token reçu du client.
     * @return L'entité RefreshToken trouvée.
     */
    public RefreshToken verifyRefreshToken(String rawToken) {
        // 1. On re-calcule le hash du token reçu pour chercher en base
        String tokenHash = hashToken(rawToken);

        // 2. On cherche ce hash (avec JOIN FETCH user pour éviter LazyInitException)
        RefreshToken token = refreshTokenRepository.findByTokenHash(tokenHash)
                .orElseThrow(() -> new IllegalArgumentException("Refresh Token inconnu ou invalide"));

        // 3. Vérifications de sécurité
        if (token.isRevoked()) {
            throw new IllegalArgumentException("Ce token a été révoqué (Logout ?)");
        }

        if (token.getExpiresAt().isBefore(Instant.now())) {
            refreshTokenRepository.delete(token); // Ménage automatique
            throw new IllegalArgumentException("Refresh Token expiré. Veuillez vous reconnecter.");
        }

        return token;
    }

    /**
     * Révoque un token (Logout).
     * @param rawRefreshToken Le token brut reçu du client.
     */
    @Transactional
    public void revokeRefreshToken(String rawRefreshToken) {
        if (rawRefreshToken == null || rawRefreshToken.isBlank()) {
            return;
        }

        String tokenHash = hashToken(rawRefreshToken);

        refreshTokenRepository.findByTokenHash(tokenHash)
                .ifPresent(token -> {
                    token.setRevoked(true);
                    refreshTokenRepository.save(token);
                });
    }

    /**
     * Supprime tous les tokens d'un utilisateur (Logout global / Changement mot de passe).
     */
    @Transactional
    public void deleteByUserId(UUID userId) {
        User user = userRepository.findById(userId).orElseThrow();
        refreshTokenRepository.deleteByUser(user);
    }

    /**
     * Fonction utilitaire pour hacher le token en SHA-256.
     */
    private String hashToken(String rawToken) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(rawToken.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(hash);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Erreur critique : SHA-256 introuvable", e);
        }
    }
}
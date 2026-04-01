package ma.gatekeeper.iam.service;

import com.nimbusds.jose.*;
import ma.gatekeeper.iam.config.JwtConfig;
import ma.gatekeeper.iam.model.User;
import com.nimbusds.jose.crypto.MACSigner;
import com.nimbusds.jose.crypto.MACVerifier;
import com.nimbusds.jwt.JWTClaimsSet;
import com.nimbusds.jwt.SignedJWT;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;
import java.util.UUID;

@Service
public class JwtService {

    private final JwtConfig jwtConfig;

    public JwtService(JwtConfig jwtConfig) {
        this.jwtConfig = jwtConfig;
    }

    public String generateAccessToken(User user) {
        return buildToken(user, jwtConfig.getExpiration(), "ACCESS");
    }

    public String generateRefreshToken(User user) {
        return buildToken(user, jwtConfig.getRefreshExpiration(), "REFRESH");
    }

    // --- NOUVEAU POUR SPRINT 3 : Token Temporaire MFA ---
    public String generateMfaToken(User user) {
        // Durée très courte (3 minutes = 180000 ms) pour éviter qu'il traîne
        long mfaExpiration = 180000;
        return buildToken(user, mfaExpiration, "MFA_PENDING");
    }

    private String buildToken(User user, long expirationMs, String type) {
        try {
            long now = System.currentTimeMillis();

            JWTClaimsSet.Builder claimsBuilder = new JWTClaimsSet.Builder()
                    .subject(user.getUsername())
                    .issuer("Gatekeeper-IAM")
                    .issueTime(new Date(now))
                    .expirationTime(new Date(now + expirationMs))
                    .jwtID(UUID.randomUUID().toString()) // AJOUT CRITIQUE : JTI (ID Unique) pour éviter les collisions de hash
                    .claim("typ", type);

            // On n'ajoute les rôles QUE pour l'Access Token final
            if ("ACCESS".equals(type)) {
                List<String> roles = user.getRoleNames();
                claimsBuilder.claim("roles", roles);
            }

            JWTClaimsSet claims = claimsBuilder.build();

            JWSHeader header = new JWSHeader(JWSAlgorithm.HS256);
            SignedJWT signedJWT = new SignedJWT(header, claims);

            JWSSigner signer = new MACSigner(jwtConfig.getSecretKey());
            signedJWT.sign(signer);

            return signedJWT.serialize();

        } catch (JOSEException e) {
            throw new IllegalStateException("Erreur lors de la signature du token", e);
        }
    }

    public String validateTokenAndGetUsername(String token, String expectedType) {
        try {
            SignedJWT signedJWT = SignedJWT.parse(token);
            JWSVerifier verifier = new MACVerifier(jwtConfig.getSecretKey());

            if (!JWSAlgorithm.HS256.equals(signedJWT.getHeader().getAlgorithm())) {
                throw new IllegalArgumentException("Algorithme interdit");
            }

            if (!signedJWT.verify(verifier)) {
                throw new IllegalArgumentException("Signature invalide");
            }

            JWTClaimsSet claims = signedJWT.getJWTClaimsSet();

            if (new Date().after(claims.getExpirationTime())) {
                throw new IllegalArgumentException("Token expiré");
            }

            String tokenType = (String) claims.getClaim("typ");
            if (!expectedType.equals(tokenType)) {
                throw new IllegalArgumentException("Type invalide. Attendu: " + expectedType + ", Reçu: " + tokenType);
            }

            return claims.getSubject();

        } catch (Exception e) {
            throw new IllegalArgumentException("Token invalide : " + e.getMessage());
        }
    }
}
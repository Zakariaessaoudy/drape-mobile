package ma.gatekeeper.iam.config;

import jakarta.annotation.PostConstruct;
import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

import java.nio.charset.StandardCharsets;

@Configuration
@ConfigurationProperties(prefix = "application.security.jwt")
@Getter @Setter
public class JwtConfig {

    private String secretKey;
    private long expiration;        // Access Token (ms)
    private long refreshExpiration; // Refresh Token (ms)

    @PostConstruct
    public void validateConfig() {
        // RÈGLE DE SÉCURITÉ : HS256 nécessite une clé de 256 bits (32 octets) minimum.
        // Si la clé est trop courte, on arrête tout immédiatement.
        if (secretKey == null || secretKey.getBytes(StandardCharsets.UTF_8).length < 32) {
            throw new IllegalStateException(
                    "CRITIQUE : La clé secrète JWT doit faire au moins 32 octets pour l'algorithme HS256."
            );
        }
    }
}
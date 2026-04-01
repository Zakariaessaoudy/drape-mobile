package ma.gatekeeper.iam.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "refresh_tokens")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class RefreshToken {

    @Id
    @GeneratedValue
    private UUID id;

    // Lien vers l'utilisateur propriétaire du token
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", referencedColumnName = "id")
    private User user;

    // CRITIQUE : On ne stocke JAMAIS le token JWT brut ici.
    // On stocke son empreinte SHA-256.
    // Si la base est volée, le hacker ne peut pas utiliser ces hashs pour se connecter.
    @Column(nullable = false, unique = true)
    private String tokenHash;

    @Column(nullable = false)
    private Instant expiresAt;

    // Si un token est compromis, on peut le révoquer manuellement
    @Column(nullable = false)
    private boolean revoked;

    @Column(nullable = false, updatable = false)
    private Instant createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = Instant.now();
    }
}

package ma.gatekeeper.iam.model;

import ma.gatekeeper.iam.security.encryption.AttributeEncryptor;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;
import java.util.List;

@Entity
@Table(name = "users")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class User {

    @Id
    @GeneratedValue
    private UUID id;

    @Column(unique = true, nullable = false)
    private String username;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(name = "password_hash", nullable = false)
    private String passwordHash;

    @Convert(converter = AttributeEncryptor.class)
    @Column(name = "mfa_secret", columnDefinition = "TEXT")
    private String mfaSecret;

    @Column(name = "mfa_enabled")
    private boolean mfaEnabled;

    @Column(name = "is_locked")
    private boolean isLocked;

    @Column(name = "failed_attempts")
    private int failedAttempts;

    @Column(name = "lock_time")
    private LocalDateTime lockTime;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
            name = "user_roles",
            joinColumns = @JoinColumn(name = "user_id"),
            inverseJoinColumns = @JoinColumn(name = "role_id")
    )
    @Builder.Default
    private Set<Role> roles = new HashSet<>();

    /**
     * Helper pour extraire les noms des rôles sous forme de liste de Strings
     * Utile pour injecter dans le JWT.
     */
    public List<String> getRoleNames() {
        return roles.stream()
                .map(Role::getName)
                .collect(Collectors.toList());
    }
}
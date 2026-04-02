package ma.gatekeeper.iam.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "audit_logs")
public class AuditLog {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    // L'action réalisée (Ex: LOGIN_SUCCESS, CREATE_USER, DELETE_ORDER)
    @Column(nullable = false, length = 50)
    private String action;

    // L'utilisateur qui a effectué l'action (peut être null si action système ou anonyme)
    @Column(name = "user_id")
    private UUID userId;

    @Column(name = "user_email")
    private String userEmail; // Utile pour garder une trace même si le user est supprimé

    // L'entité concernée par l'action (Ex: "User", "Product")
    @Column(name = "entity_name")
    private String entityName;

    // L'ID de l'entité concernée
    @Column(name = "entity_id")
    private String entityId;

    // Détails supplémentaires (JSON stringifié, payload, anciennes valeurs vs nouvelles valeurs)
    @Column(columnDefinition = "TEXT")
    private String details;

    // Informations contextuelles
    @Column(name = "ip_address", length = 45)
    private String ipAddress;

    @Column(name = "user_agent")
    private String userAgent;

    @Column(length = 20)
    private String status; // SUCCESS, FAILURE

    // --- Champs d'Audit ---

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
}
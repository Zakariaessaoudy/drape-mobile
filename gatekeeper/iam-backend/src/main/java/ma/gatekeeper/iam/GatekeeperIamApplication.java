package ma.gatekeeper.iam;

import lombok.RequiredArgsConstructor;
import ma.gatekeeper.iam.model.AuditLog;
import ma.gatekeeper.iam.model.Permission;
import ma.gatekeeper.iam.model.Role;
import ma.gatekeeper.iam.model.User;
import ma.gatekeeper.iam.repository.*;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Optional;
import java.util.Set;

@SpringBootApplication
@RequiredArgsConstructor // IMPORTANT: Génère le constructeur pour les champs final
public class GatekeeperIamApplication {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PermissionRepository permissionRepository;
    private final AuditLogRepository auditLogRepository;
    private final PasswordEncoder passwordEncoder;

    public static void main(String[] args) {
        SpringApplication.run(GatekeeperIamApplication.class, args);
    }

    @Bean
    public CommandLineRunner initData() {
        return args -> {
            System.out.println("🚀 [DataSeeder] Démarrage de l'initialisation des données...");
            seedData();
            System.out.println("✅ [DataSeeder] Initialisation terminée avec succès.");
        };
    }

    @Transactional
    public void seedData() {
        // --- 1. CRÉATION DES PERMISSIONS ---
        Permission pRead = createPermissionIfNotFound("USER:READ", "Lire les informations utilisateurs");
        Permission pWrite = createPermissionIfNotFound("USER:WRITE", "Modifier les utilisateurs");
        Permission pDelete = createPermissionIfNotFound("USER:DELETE", "Supprimer des utilisateurs");
        Permission pAudit = createPermissionIfNotFound("SYSTEM:AUDIT", "Accéder aux logs d'audit");

        // --- 2. CRÉATION DES RÔLES ---

        // Rôle ADMIN : A toutes les permissions
        Role roleAdmin = createRoleIfNotFound("ROLE_ADMIN", "Administrateur Système",
                new HashSet<>(Arrays.asList(pRead, pWrite, pDelete, pAudit)));

        // Rôle MANAGER : Peut lire et modifier, mais pas supprimer ni auditer
        Role roleManager = createRoleIfNotFound("ROLE_MANAGER", "Gestionnaire d'équipe",
                new HashSet<>(Arrays.asList(pRead, pWrite)));

        // Rôle USER : Peut seulement lire
        Role roleUser = createRoleIfNotFound("ROLE_USER", "Utilisateur Standard",
                new HashSet<>(Arrays.asList(pRead)));

        // --- 3. CRÉATION DES UTILISATEURS ---

        // Création de l'Admin
        User adminUser = createUserIfNotFound(
                "admin@gatekeeper.com", "admin", "admin123",
                new HashSet<>(Arrays.asList(roleAdmin, roleUser))
        );

        // Création du Manager
        User managerUser = createUserIfNotFound(
                "manager@gatekeeper.com", "manager", "manager123",
                new HashSet<>(Arrays.asList(roleManager))
        );

        // Création du User Lambda
        createUserIfNotFound(
                "user@gatekeeper.com", "user", "user123",
                new HashSet<>(Arrays.asList(roleUser))
        );

        // --- 4. CRÉATION D'UN LOG D'AUDIT DE TEST ---
        if (auditLogRepository.count() == 0) {
            AuditLog log = AuditLog.builder()
                    .action("INIT_SEEDING")
                    .userId(adminUser.getId()) // On lie l'action à l'admin créé
                    .userEmail(adminUser.getEmail())
                    .entityName("System")
                    .entityId("N/A")
                    .details("Initialisation automatique de la base de données via Spring Boot")
                    .ipAddress("127.0.0.1")
                    .status("SUCCESS")
                    .createdAt(LocalDateTime.now())
                    .build();

            auditLogRepository.save(log);
            System.out.println("   -> AuditLog de test créé.");
        }
    }

    // --- MÉTHODES UTILITAIRES ---

    private Permission createPermissionIfNotFound(String name, String description) {
        return permissionRepository.findByName(name)
                .orElseGet(() -> {
                    Permission perm = Permission.builder()
                            .name(name)
                            .description(description)
                            .build();
                    System.out.println("   -> Permission créée : " + name);
                    return permissionRepository.save(perm);
                });
    }

    private Role createRoleIfNotFound(String name, String description, Set<Permission> permissions) {
        return roleRepository.findByName(name)
                .orElseGet(() -> {
                    Role role = Role.builder()
                            .name(name)
                            .description(description)
                            .permissions(permissions)
                            .build();
                    System.out.println("   -> Rôle créé : " + name + " avec " + permissions.size() + " permissions.");
                    return roleRepository.save(role);
                });
    }

    private User createUserIfNotFound(String email, String username, String password, Set<Role> roles) {
        Optional<User> existingUser = userRepository.findByEmail(email);
        if (existingUser.isPresent()) {
            return existingUser.get();
        }

        // CORRECTION : Utilisation de 'username' au lieu de 'firstname'/'lastname'
        User user = User.builder()
                .username(username)
                .email(email)
                .passwordHash(passwordEncoder.encode(password)) // Hashage Argon2/BCrypt
                .roles(roles)
                .mfaEnabled(false) // Par défaut false
                .isLocked(false)
                .failedAttempts(0)
                .build();

        userRepository.save(user);
        System.out.println("   -> Utilisateur créé : " + email);
        return user;
    }
}
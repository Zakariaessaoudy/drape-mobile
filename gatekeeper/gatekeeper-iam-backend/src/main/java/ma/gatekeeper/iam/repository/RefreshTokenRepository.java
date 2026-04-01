package ma.gatekeeper.iam.repository;

import ma.gatekeeper.iam.model.RefreshToken;
import ma.gatekeeper.iam.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface RefreshTokenRepository extends JpaRepository<RefreshToken, UUID> {

    // --- LE FIX EST ICI ---
    // On utilise @Query pour forcer le chargement de l'utilisateur (JOIN FETCH)
    // Cela évite la LazyInitializationException plus tard.
    @Query("SELECT rt FROM RefreshToken rt JOIN FETCH rt.user WHERE rt.tokenHash = :tokenHash")
    Optional<RefreshToken> findByTokenHash(String tokenHash);

    // Pour le ménage : supprimer les tokens d'un utilisateur (logout global)
    @Modifying
    void deleteByUser(User user);
}
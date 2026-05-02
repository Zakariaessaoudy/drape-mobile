package ma.fst.gi.repository;

import ma.fst.gi.models.Outfit;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface OutfitRepository extends JpaRepository<Outfit, String> {

    List<Outfit> findAllByClosetId(String closetId);

    @EntityGraph(attributePaths = {"items", "items.categorie"})
    List<Outfit> findAllByClosetUserId(String userId);

    @EntityGraph(attributePaths = {"items", "items.categorie"})
    Optional<Outfit> findByIdAndClosetUserId(String id, String userId);
}

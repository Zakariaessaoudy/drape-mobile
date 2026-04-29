package ma.fst.gi.repository;

import ma.fst.gi.models.Outfit;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OutfitRepository extends JpaRepository<Outfit, String> {

    List<Outfit> findAllByClosetId(String closetId);

    List<Outfit> findAllByClosetUserId(String userId);
}

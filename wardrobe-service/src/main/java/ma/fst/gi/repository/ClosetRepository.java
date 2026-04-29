package ma.fst.gi.repository;

import ma.fst.gi.models.Closet;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ClosetRepository extends JpaRepository<Closet, String> {

    Optional<Closet> findByUserId(String userId);

    boolean existsByUserId(String userId);
}

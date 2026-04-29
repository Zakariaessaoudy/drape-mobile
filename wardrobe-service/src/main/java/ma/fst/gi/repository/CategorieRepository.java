package ma.fst.gi.repository;

import ma.fst.gi.models.Categorie;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CategorieRepository extends JpaRepository<Categorie, String> {

    Optional<Categorie> findByName(String name);

    boolean existsByName(String name);
}

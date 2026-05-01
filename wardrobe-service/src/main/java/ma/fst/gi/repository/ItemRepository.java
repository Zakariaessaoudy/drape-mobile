package ma.fst.gi.repository;

import ma.fst.gi.models.Item;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;

@Repository
public interface ItemRepository extends JpaRepository<Item, String> {

    List<Item> findAllByUserId(String userId);

    List<Item> findAllByCategorieId(String categorieId);

    List<Item> findAllByUserIdAndCategorieId(String userId, String categorieId);

    @Query("select i from Item i join fetch i.categorie where i.user.id = :userId order by i.createdAt desc")
    List<Item> findAllByUserIdWithCategorie(@Param("userId") String userId);

    @Query("select i from Item i join fetch i.categorie where i.user.id = :userId and upper(i.categorie.name) in :categories order by i.createdAt desc")
    List<Item> findAllByUserIdAndCategorieNames(
            @Param("userId") String userId,
            @Param("categories") Collection<String> categories
    );
}

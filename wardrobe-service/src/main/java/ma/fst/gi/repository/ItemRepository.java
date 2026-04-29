package ma.fst.gi.repository;

import ma.fst.gi.models.Item;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ItemRepository extends JpaRepository<Item, String> {

    List<Item> findAllByUserId(String userId);

    List<Item> findAllByCategorieId(String categorieId);

    List<Item> findAllByUserIdAndCategorieId(String userId, String categorieId);
}

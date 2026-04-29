package ma.fst.gi.repository;

import ma.fst.gi.models.ItemPhoto;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ItemPhotoRepository extends JpaRepository<ItemPhoto, String> {

    List<ItemPhoto> findAllByItemId(String itemId);

    void deleteAllByItemId(String itemId);
}

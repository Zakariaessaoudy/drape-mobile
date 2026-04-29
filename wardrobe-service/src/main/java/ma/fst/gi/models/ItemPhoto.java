package ma.fst.gi.models;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "item_photos")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ItemPhoto {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    // S3 object key; full path typically encodes {userId}/{itemId}/{photoId}
    @Column(nullable = false)
    private String s3Key;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "item_id", nullable = false)
    private Item item;
}

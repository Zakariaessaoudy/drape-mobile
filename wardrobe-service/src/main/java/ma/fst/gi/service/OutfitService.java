package ma.fst.gi.service;

import ma.fst.gi.dto.CreateOutfitRequest;
import ma.fst.gi.dto.OutfitItemResponse;
import ma.fst.gi.dto.OutfitResponse;
import ma.fst.gi.models.Closet;
import ma.fst.gi.models.Item;
import ma.fst.gi.models.Outfit;
import ma.fst.gi.models.User;
import ma.fst.gi.repository.ClosetRepository;
import ma.fst.gi.repository.ItemRepository;
import ma.fst.gi.repository.OutfitRepository;
import ma.fst.gi.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
public class OutfitService {

    private final OutfitRepository outfitRepository;
    private final ItemRepository itemRepository;
    private final UserRepository userRepository;
    private final ClosetRepository closetRepository;

    public OutfitService(
            OutfitRepository outfitRepository,
            ItemRepository itemRepository,
            UserRepository userRepository,
            ClosetRepository closetRepository
    ) {
        this.outfitRepository = outfitRepository;
        this.itemRepository = itemRepository;
        this.userRepository = userRepository;
        this.closetRepository = closetRepository;
    }

    @Transactional
    public OutfitResponse createOutfit(String userEmail, CreateOutfitRequest request) {
        User user = findUser(userEmail);
        Closet closet = findOrCreateCloset(user);

        List<String> itemIds = List.of(request.topId(), request.bottomId(), request.shoeId());
        if (itemIds.stream().distinct().count() != itemIds.size()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "outfit items must be different");
        }

        Map<String, Item> itemsById = itemRepository.findAllById(itemIds).stream()
                .collect(Collectors.toMap(Item::getId, Function.identity()));
        if (itemsById.size() != itemIds.size()) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "one or more outfit items were not found");
        }

        Item top = getOwnedItem(itemsById, request.topId(), user.getId());
        Item bottom = getOwnedItem(itemsById, request.bottomId(), user.getId());
        Item shoe = getOwnedItem(itemsById, request.shoeId(), user.getId());

        validateCategory(top, "TOP", "topId");
        validateCategory(bottom, "BOTTOM", "bottomId");
        validateCategory(shoe, "SHOE", "shoeId");
        validateNoDuplicateCategories(List.of(top, bottom, shoe));

        Outfit outfit = new Outfit();
        outfit.setName(request.name());
        outfit.setDescription(request.description());
        outfit.setCloset(closet);
        outfit.setItems(new HashSet<>(List.of(top, bottom, shoe)));

        return toResponse(outfitRepository.save(outfit));
    }

    @Transactional(readOnly = true)
    public List<OutfitResponse> getOutfits(String userEmail) {
        User user = findUser(userEmail);

        return outfitRepository.findAllByClosetUserId(user.getId()).stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional
    public void deleteOutfit(String userEmail, String outfitId) {
        User user = findUser(userEmail);
        Outfit outfit = outfitRepository.findByIdAndClosetUserId(outfitId, user.getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "outfit not found"));

        outfitRepository.delete(outfit);
    }

    private User findUser(String userEmail) {
        return userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "authenticated user not found"));
    }

    private Closet findOrCreateCloset(User user) {
        return closetRepository.findByUserId(user.getId())
                .orElseGet(() -> {
                    Closet closet = new Closet();
                    closet.setUser(user);
                    closet.setName(user.getName() + "'s Closet");
                    return closetRepository.save(closet);
                });
    }

    private Item getOwnedItem(Map<String, Item> itemsById, String itemId, String userId) {
        Item item = itemsById.get(itemId);
        if (!item.getUser().getId().equals(userId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "one or more outfit items were not found");
        }
        return item;
    }

    private void validateCategory(Item item, String expectedCategory, String fieldName) {
        String actualCategory = categoryName(item);
        if (!expectedCategory.equals(actualCategory)) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    fieldName + " must reference a " + expectedCategory + " item"
            );
        }
    }

    private void validateNoDuplicateCategories(List<Item> items) {
        Set<String> categories = new HashSet<>();
        for (Item item : items) {
            if (!categories.add(categoryName(item))) {
                throw new ResponseStatusException(
                        HttpStatus.BAD_REQUEST,
                        "two items of the same category cannot exist in the same outfit"
                );
            }
        }
    }

    private String categoryName(Item item) {
        return item.getCategorie().getName().trim().toUpperCase(Locale.ROOT);
    }

    private OutfitResponse toResponse(Outfit outfit) {
        Map<String, OutfitItemResponse> itemsByCategory = outfit.getItems().stream()
                .map(this::toItemResponse)
                .collect(Collectors.toMap(OutfitItemResponse::category, Function.identity()));

        return new OutfitResponse(
                outfit.getId(),
                outfit.getName(),
                outfit.getDescription(),
                itemsByCategory.get("TOP"),
                itemsByCategory.get("BOTTOM"),
                itemsByCategory.get("SHOE")
        );
    }

    private OutfitItemResponse toItemResponse(Item item) {
        return new OutfitItemResponse(
                item.getId(),
                item.getName(),
                categoryName(item),
                item.getColor(),
                item.getImageUrl(),
                item.getImageStatus()
        );
    }
}

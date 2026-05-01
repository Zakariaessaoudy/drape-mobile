package ma.fst.gi.service;

import ma.fst.gi.dto.CreateItemResponse;
import ma.fst.gi.dto.UpdateItemImageRequest;
import ma.fst.gi.models.Categorie;
import ma.fst.gi.models.ImageStatus;
import ma.fst.gi.models.Item;
import ma.fst.gi.models.User;
import ma.fst.gi.repository.CategorieRepository;
import ma.fst.gi.repository.ItemRepository;
import ma.fst.gi.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.Set;

@Service
public class ItemService {

    private static final Set<String> SUPPORTED_CATEGORIES = Set.of("SHOE", "TOP", "BOTTOM");

    private final ItemRepository itemRepository;
    private final UserRepository userRepository;
    private final CategorieRepository categorieRepository;
    private final AiServiceClient aiServiceClient;

    public ItemService(
            ItemRepository itemRepository,
            UserRepository userRepository,
            CategorieRepository categorieRepository,
            AiServiceClient aiServiceClient
    ) {
        this.itemRepository = itemRepository;
        this.userRepository = userRepository;
        this.categorieRepository = categorieRepository;
        this.aiServiceClient = aiServiceClient;
    }

    @Transactional
    public CreateItemResponse createItem(String userEmail, String name, String category, String color, MultipartFile image) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "authenticated user not found"));
        Categorie categorie = findOrCreateCategory(normalizeCategory(category));

        Item item = new Item();
        item.setUser(user);
        item.setName(name);
        item.setCategorie(categorie);
        item.setColor(color);
        item.setImageUrl(null);
        item.setImageStatus(ImageStatus.PROCESSING);

        Item saved = itemRepository.save(item);

        try {
            aiServiceClient.sendForBackgroundRemoval(saved.getId(), user.getId(), image);
        } catch (Exception e) {
            saved.setImageStatus(ImageStatus.FAILED);
            saved = itemRepository.save(saved);
        }

        return toResponse(saved);
    }

    @Transactional(readOnly = true)
    public List<CreateItemResponse> getItems(String userEmail, List<String> categories) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "authenticated user not found"));
        List<String> normalizedCategories = normalizeCategories(categories);

        List<Item> items = normalizedCategories.isEmpty()
                ? itemRepository.findAllByUserIdWithCategorie(user.getId())
                : itemRepository.findAllByUserIdAndCategorieNames(user.getId(), normalizedCategories);

        return items.stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional
    public CreateItemResponse updateItemImage(String itemId, UpdateItemImageRequest request) {
        Item item = itemRepository.findById(itemId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "item not found"));

        if (request.status() == ImageStatus.READY) {
            if (request.imageUrl() == null || request.imageUrl().isBlank()) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "imageUrl is required when status is READY");
            }
            item.setImageUrl(request.imageUrl());
            item.setImageStatus(ImageStatus.READY);
        } else if (request.status() == ImageStatus.FAILED) {
            item.setImageStatus(ImageStatus.FAILED);
        } else {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "status must be READY or FAILED");
        }

        return toResponse(itemRepository.save(item));
    }

    private Categorie findOrCreateCategory(String category) {
        return categorieRepository.findByName(category)
                .orElseGet(() -> {
                    Categorie categorie = new Categorie();
                    categorie.setName(category);
                    return categorieRepository.save(categorie);
                });
    }

    private List<String> normalizeCategories(List<String> categories) {
        if (categories == null || categories.isEmpty()) {
            return List.of();
        }

        return categories.stream()
                .flatMap(category -> Arrays.stream(category.split(",")))
                .map(this::normalizeCategory)
                .distinct()
                .toList();
    }

    private String normalizeCategory(String category) {
        if (category == null || category.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "category is required");
        }

        String normalized = category.trim().toUpperCase(Locale.ROOT);
        if (!SUPPORTED_CATEGORIES.contains(normalized)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "category must be one of SHOE, TOP, BOTTOM");
        }

        return normalized;
    }

    private CreateItemResponse toResponse(Item item) {
        return new CreateItemResponse(
                item.getId(),
                item.getName(),
                item.getCategorie().getName(),
                item.getColor(),
                item.getImageUrl(),
                item.getImageStatus()
        );
    }
}

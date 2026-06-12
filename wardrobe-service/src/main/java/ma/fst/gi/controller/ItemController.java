package ma.fst.gi.controller;

import jakarta.validation.Valid;
import ma.fst.gi.dto.CreateItemResponse;
import ma.fst.gi.dto.UpdateItemImageRequest;
import ma.fst.gi.service.ItemService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@RestController
@RequestMapping("/api/items")
public class ItemController {

    private final ItemService itemService;
    private final String aiCallbackSecret;

    public ItemController(
            ItemService itemService,
            @Value("${app.ai.callback-secret:local-ai-secret}") String aiCallbackSecret
    ) {
        this.itemService = itemService;
        this.aiCallbackSecret = aiCallbackSecret;
    }

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public CreateItemResponse createItem(
            @RequestParam String name,
            @RequestParam String category,
            @RequestParam String color,
            @RequestParam MultipartFile image,
            Authentication authentication
    ) {
        return itemService.createItem(authentication.getName(), name, category, color, image);
    }

    @GetMapping
    public List<CreateItemResponse> getItems(
            @RequestParam(required = false) List<String> categories,
            Authentication authentication
    ) {
        return itemService.getItems(authentication.getName(), categories);
    }

    @GetMapping("/tops")
    public List<CreateItemResponse> getTops(Authentication authentication) {
        return itemService.getItems(authentication.getName(), List.of("TOP"));
    }

    @GetMapping("/bottoms")
    public List<CreateItemResponse> getBottoms(Authentication authentication) {
        return itemService.getItems(authentication.getName(), List.of("BOTTOM"));
    }

    @GetMapping("/shoes")
    public List<CreateItemResponse> getShoes(Authentication authentication) {
        return itemService.getItems(authentication.getName(), List.of("SHOE"));
    }

    @DeleteMapping("/{itemId}")
    public void deleteItem(
            @PathVariable String itemId,
            Authentication authentication
    ) {
        itemService.deleteItem(authentication.getName(), itemId);
    }

    @PatchMapping("/{itemId}/image")
    public CreateItemResponse updateItemImage(
            @PathVariable String itemId,
            @Valid @RequestBody UpdateItemImageRequest request,
            @RequestHeader(value = "X-AI-Service-Secret", required = false) String aiServiceSecret
    ) {
        if (!aiCallbackSecret.equals(aiServiceSecret)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "invalid AI service secret");
        }
        return itemService.updateItemImage(itemId, request);
    }
}

package ma.fst.gi.controller;

import jakarta.validation.Valid;
import ma.fst.gi.dto.CreateOutfitRequest;
import ma.fst.gi.dto.OutfitResponse;
import ma.fst.gi.service.OutfitService;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/outfits")

public class OutfitController {

    private final OutfitService outfitService;

    public OutfitController(OutfitService outfitService) {
        this.outfitService = outfitService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public OutfitResponse createOutfit(
            @Valid @RequestBody CreateOutfitRequest request,
            Authentication authentication
    ) {
        return outfitService.createOutfit(authentication.getName(), request);
    }

    @GetMapping
    public List<OutfitResponse> getOutfits(Authentication authentication) {
        return outfitService.getOutfits(authentication.getName());
    }

    @DeleteMapping("/{outfitId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteOutfit(
            @PathVariable String outfitId,
            Authentication authentication
    ) {
        outfitService.deleteOutfit(authentication.getName(), outfitId);
    }
}

package ma.fst.gi.dto;

import jakarta.validation.constraints.NotBlank;

public record CreateOutfitRequest(
        @NotBlank String name,
        String description,
        @NotBlank String topId,
        @NotBlank String bottomId,
        @NotBlank String shoeId
) {}

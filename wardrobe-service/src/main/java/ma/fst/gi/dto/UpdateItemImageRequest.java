package ma.fst.gi.dto;

import jakarta.validation.constraints.NotNull;
import ma.fst.gi.models.ImageStatus;

public record UpdateItemImageRequest(
        String imageUrl,
        @NotNull ImageStatus status
) {}

package ma.fst.gi.dto;

import ma.fst.gi.models.ImageStatus;

public record CreateItemResponse(
        String id,
        String name,
        String category,
        String color,
        String imageUrl,
        ImageStatus imageStatus
) {}

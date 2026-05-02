package ma.fst.gi.dto;

public record OutfitResponse(
        String id,
        String name,
        String description,
        OutfitItemResponse top,
        OutfitItemResponse bottom,
        OutfitItemResponse shoe
) {}

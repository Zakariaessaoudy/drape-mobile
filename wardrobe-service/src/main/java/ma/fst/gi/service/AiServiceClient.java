package ma.fst.gi.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@Service
public class AiServiceClient {

    private final RestTemplate restTemplate = new RestTemplate();
    private final String aiServiceUrl;

    public AiServiceClient(@Value("${ai.service.url:http://localhost:8000}") String aiServiceUrl) {
        this.aiServiceUrl = aiServiceUrl;
    }

    public void sendForBackgroundRemoval(String itemId, String userId, MultipartFile image) {
        String url = aiServiceUrl + "/api/background-removal";

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.MULTIPART_FORM_DATA);

        MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
        body.add("itemId", itemId);
        body.add("userId", userId);
        body.add("image", buildImagePart(image));

        restTemplate.postForEntity(url, new HttpEntity<>(body, headers), Void.class);
    }

    private HttpEntity<ByteArrayResource> buildImagePart(MultipartFile image) {
        try {
            ByteArrayResource resource = new ByteArrayResource(image.getBytes()) {
                @Override
                public String getFilename() {
                    return image.getOriginalFilename();
                }
            };

            HttpHeaders headers = new HttpHeaders();
            String contentType = image.getContentType() == null
                    ? MediaType.APPLICATION_OCTET_STREAM_VALUE
                    : image.getContentType();
            headers.setContentType(MediaType.parseMediaType(contentType));

            return new HttpEntity<>(resource, headers);
        } catch (IOException e) {
            throw new IllegalStateException("could not read uploaded image", e);
        }
    }
}

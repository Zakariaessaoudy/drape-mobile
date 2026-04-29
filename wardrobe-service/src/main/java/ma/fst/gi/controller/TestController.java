package ma.fst.gi.controller;

import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/test")
public class TestController {

    @GetMapping("/public")
    public Map<String, String> publicEndpoint() {
        return Map.of("message", "hello, anyone can see this");
    }

    @GetMapping("/private")
    public Map<String, String> privateEndpoint(Authentication authentication) {
        return Map.of(
                "message", "you are authenticated",
                "subject", authentication.getName()
        );
    }
}

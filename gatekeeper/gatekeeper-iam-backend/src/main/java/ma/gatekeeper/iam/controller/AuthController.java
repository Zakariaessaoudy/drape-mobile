package ma.gatekeeper.iam.controller;

import ma.gatekeeper.iam.dto.request.LoginRequest;
import ma.gatekeeper.iam.dto.request.MfaVerificationRequest;
import ma.gatekeeper.iam.dto.request.RegisterRequest;
import ma.gatekeeper.iam.dto.response.TokenResponse;
import ma.gatekeeper.iam.service.AuthService;
import ma.gatekeeper.iam.service.JwtService;
import ma.gatekeeper.iam.service.RefreshTokenService;
import ma.gatekeeper.iam.model.RefreshToken;
import ma.gatekeeper.iam.model.User;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final RefreshTokenService refreshTokenService;
    private final JwtService jwtService;

//    @PostMapping("/register")
//    public ResponseEntity<TokenResponse> register(@Valid @RequestBody RegisterRequest request) {
//        return ResponseEntity.ok(authService.register(request));
//    }

    @PostMapping("/login")
    public ResponseEntity<TokenResponse> login(@Valid @RequestBody LoginRequest request) {
        TokenResponse response = authService.login(request);

        if (response.isMfaRequired()) {
            return ResponseEntity.status(202).body(response); // 202 Accepted (En attente de MFA)
        }
        return ResponseEntity.ok(response);
    }

    @PostMapping("/verify-mfa")
    public ResponseEntity<TokenResponse> verifyMfa(@Valid @RequestBody MfaVerificationRequest request) {
        return ResponseEntity.ok(authService.verifyMfa(request));
    }

    @PostMapping("/refresh")
    public ResponseEntity<TokenResponse> refresh(@RequestBody String requestRefreshToken) {
        // TODO: Mettre ça dans AuthService pour être propre
        RefreshToken storedToken = refreshTokenService.verifyRefreshToken(requestRefreshToken);
        User user = storedToken.getUser();
        String newAccessToken = jwtService.generateAccessToken(user);

        return ResponseEntity.ok(TokenResponse.builder()
                .accessToken(newAccessToken)
                .refreshToken(requestRefreshToken)
                .build());
    }

    @PostMapping("/logout")
    public ResponseEntity<Void> logout(@RequestBody String requestRefreshToken) {
        refreshTokenService.revokeRefreshToken(requestRefreshToken);
        return ResponseEntity.noContent().build();
    }
}
package ma.gatekeeper.iam.service;

import ma.gatekeeper.iam.dto.request.LoginRequest;
import ma.gatekeeper.iam.dto.request.MfaVerificationRequest;
import ma.gatekeeper.iam.dto.request.RegisterRequest;
import ma.gatekeeper.iam.dto.response.TokenResponse;
import ma.gatekeeper.iam.model.Role;
import ma.gatekeeper.iam.model.User;
import ma.gatekeeper.iam.repository.RoleRepository;
import ma.gatekeeper.iam.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Set;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final RefreshTokenService refreshTokenService;
    private final AuthenticationManager authenticationManager;
    private final MfaService mfaService;

    @Transactional
    public TokenResponse register(RegisterRequest request) {
        if (userRepository.findByUsername(request.getUsername()).isPresent()) {
            throw new IllegalArgumentException("Username déjà pris");
        }
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new IllegalArgumentException("Email déjà utilisé");
        }

        // Récupérer ou Créer le rôle par défaut USER
        Role userRole = roleRepository.findByName("USER")
                .orElseGet(() -> roleRepository.save(Role.builder().name("USER").description("Utilisateur standard").build()));

        // Générer un secret MFA pour le futur (sera activé plus tard)
        String mfaSecret = mfaService.generateSecret();

        User user = User.builder()
                .username(request.getUsername())
                .email(request.getEmail())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .mfaEnabled(false) // Par défaut désactivé
                .mfaSecret(mfaSecret) // Sera chiffré automatiquement par @Convert
                .roles(Set.of(userRole))
                .build();

        userRepository.save(user);

        // Connexion automatique après inscription
        String accessToken = jwtService.generateAccessToken(user);
        String refreshToken = refreshTokenService.createRefreshToken(user.getId());

        return TokenResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .mfaRequired(false)
                .build();
    }

    public TokenResponse login(LoginRequest request) {
        // 1. Vérification du mot de passe (Argon2)
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword())
        );

        // 2. Récupérer l'utilisateur
        User user = userRepository.findByUsername(request.getUsername())
                .orElseThrow(() -> new UsernameNotFoundException("Utilisateur introuvable"));

        // 3. Vérification MFA
        if (user.isMfaEnabled()) {
            // Si MFA activé -> On ne donne PAS les tokens finaux.
            // On donne un token temporaire "MFA_PENDING".
            String mfaToken = jwtService.generateMfaToken(user);
            return TokenResponse.builder()
                    .mfaRequired(true)
                    .mfaToken(mfaToken) // Le client devra renvoyer ce token avec le code
                    .build();
        }

        // 4. Si pas de MFA -> Tokens finaux
        String accessToken = jwtService.generateAccessToken(user);
        String refreshToken = refreshTokenService.createRefreshToken(user.getId());

        return TokenResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .mfaRequired(false)
                .build();
    }

    public TokenResponse verifyMfa(MfaVerificationRequest request) {
        // 1. Valider le token temporaire (Signature + Expiration + Type MFA_PENDING)
        String username = jwtService.validateTokenAndGetUsername(request.getMfaToken(), "MFA_PENDING");

        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("Utilisateur introuvable"));

        // 2. Vérifier le code TOTP avec le secret de l'utilisateur
        // Note: user.getMfaSecret() est déjà déchiffré par AttributeEncryptor
        if (!mfaService.isOtpValid(user.getMfaSecret(), request.getCode())) {
            throw new BadCredentialsException("Code MFA invalide");
        }

        // 3. Succès -> Générer les tokens finaux
        String accessToken = jwtService.generateAccessToken(user);
        String refreshToken = refreshTokenService.createRefreshToken(user.getId());

        return TokenResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .mfaRequired(false)
                .build();
    }
}
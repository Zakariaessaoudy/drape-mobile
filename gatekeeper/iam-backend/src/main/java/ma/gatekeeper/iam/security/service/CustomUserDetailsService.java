package ma.gatekeeper.iam.security.service;

import ma.gatekeeper.iam.model.User;
import ma.gatekeeper.iam.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;


@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        // 1. Chercher l'utilisateur dans NOTRE base de données
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("Utilisateur non trouvé : " + username));

        // 2. Traduire en objet Spring Security (UserDetails)
        // Note : Pour l'instant, on ne gère pas encore les rôles dans l'objet Spring,
        // on le fera quand on connectera les permissions.
        return org.springframework.security.core.userdetails.User
                .withUsername(user.getUsername())
                .password(user.getPasswordHash()) // Spring a besoin du Hash pour comparer
                .disabled(!true) // Actif par défaut
                .accountExpired(false)
                .credentialsExpired(false)
                .accountLocked(user.isLocked()) // On connecte notre sécurité passive !
                .roles("USER") // Placeholder pour l'instant
                .build();
    }
}
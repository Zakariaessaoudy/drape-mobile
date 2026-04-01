package ma.gatekeeper.iam.security.hashing;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.argon2.Argon2PasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

@Configuration
public class PasswordEncoderConfig {

    @Bean
    public PasswordEncoder passwordEncoder() {
        // --- PARAMÈTRES DE HACHAGE "EXTREME" ---
        // saltLength : 16 octets (Grain de sel aléatoire)
        // hashLength : 32 octets (Longueur du résultat final)
        // parallelism : 1 (Combien de threads CPU utiliser)
        // memory : 4096 KB (4 Mo de RAM minimum requis pour calculer 1 hash) ou moins
        // iterations : 3 (Le calcul est répété 3 fois) ou moins

        // Note : Cela rend le calcul un peu lent pour vous (c'est voulu !)
        // Mais cela rend le craquage impossible pour un GPU (manque de RAM).
        return new Argon2PasswordEncoder(16, 32, 1, 1024, 2);
    }
}
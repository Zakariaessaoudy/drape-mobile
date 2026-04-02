package ma.gatekeeper.iam.service;

import dev.samstevens.totp.code.*;
import dev.samstevens.totp.exceptions.QrGenerationException;
import dev.samstevens.totp.qr.QrData;
import dev.samstevens.totp.qr.QrGenerator;
import dev.samstevens.totp.qr.ZxingPngQrGenerator;
import dev.samstevens.totp.secret.DefaultSecretGenerator;
import dev.samstevens.totp.secret.SecretGenerator;
import dev.samstevens.totp.time.SystemTimeProvider;
import dev.samstevens.totp.time.TimeProvider;
import org.springframework.stereotype.Service;

import static dev.samstevens.totp.util.Utils.getDataUriForImage;

@Service
public class MfaService {

    // 1. Générer un Secret (Pour le setup)
    public String generateSecret() {
        SecretGenerator generator = new DefaultSecretGenerator();
        return generator.generate(); // 32 caractères
    }

    // 2. Générer l'image QR Code (Pour l'affichage Frontend)
    public String generateQrCodeImageUri(String secret, String email) {
        QrData data = new QrData.Builder()
                .label(email)
                .secret(secret)
                .issuer("Gatekeeper-IAM")
                .algorithm(HashingAlgorithm.SHA1)
                .digits(6)
                .period(30)
                .build();

        QrGenerator generator = new ZxingPngQrGenerator();
        byte[] imageData = new byte[0];
        try {
            imageData = generator.generate(data);
        } catch (QrGenerationException e) {
            throw new RuntimeException("Erreur génération QR Code", e);
        }

        return getDataUriForImage(imageData, generator.getImageMimeType());
    }

    // 3. Vérifier le code (Lors du Login)
    public boolean isOtpValid(String secret, String code) {
        TimeProvider timeProvider = new SystemTimeProvider();
        CodeGenerator codeGenerator = new DefaultCodeGenerator();
        CodeVerifier verifier = new DefaultCodeVerifier(codeGenerator, timeProvider);

        // Autoriser une légère marge d'erreur temporelle (si l'horloge du téléphone n'est pas synchro)
        // Mais attention, la méthode setAllowedTimePeriodDiscrepancy n'est pas toujours exposée directement sur l'interface
        // Pour faire simple, la config par défaut est souvent suffisante.

        return verifier.isValidCode(secret, code);
    }

    // Classe interne pour le générateur (car la librairie demande une instance spécifique)
    private static class DefaultCodeGenerator extends dev.samstevens.totp.code.DefaultCodeGenerator {
        public DefaultCodeGenerator() {
            super(HashingAlgorithm.SHA1, 6);
        }
    }
}
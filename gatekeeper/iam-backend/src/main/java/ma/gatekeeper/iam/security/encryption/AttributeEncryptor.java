package ma.gatekeeper.iam.security.encryption;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.util.Base64;

@Component
@Converter
public class AttributeEncryptor implements AttributeConverter<String, String> {

    // --- CONSTANTES DE SÉCURITÉ ---
    private static final String AES = "AES";
    // GCM = Galois/Counter Mode. C'est le mode le plus sûr actuellement.
    // Il garantit que personne n'a modifié le message en route (Intégrité).
    private static final String AES_GCM = "AES/GCM/NoPadding";

    // Taille du Tag d'authentification (128 bits)
    private static final int TAG_LENGTH_BIT = 128;

    // Taille du Vecteur d'Initialisation (IV).
    // 12 octets est la recommandation officielle du NIST pour GCM.
    private static final int IV_LENGTH_BYTE = 12;

    // --- LA CLÉ ---
    // Spring injecte la clé définie dans application.yml
    @Value("${application.security.encryption-key}")
    private String encryptionKey;

    // --- VERS LA BASE DE DONNÉES (Chiffrement) ---
    @Override
    public String convertToDatabaseColumn(String attribute) {
        if (attribute == null) return null; // On ne chiffre pas le vide

        try {
            // ÉTAPE 1 : Créer un IV aléatoire (Le "Grain de sel")
            // À chaque chiffrement, même pour le même mot, l'IV change.
            byte[] iv = new byte[IV_LENGTH_BYTE];
            new SecureRandom().nextBytes(iv);

            // ÉTAPE 2 : Préparer le Moteur (Cipher)
            // On prépare la clé physique (SecretKeySpec) et les paramètres GCM (IV)
            Cipher cipher = Cipher.getInstance(AES_GCM);
            SecretKeySpec keySpec = new SecretKeySpec(encryptionKey.getBytes(StandardCharsets.UTF_8), AES);
            GCMParameterSpec gcmSpec = new GCMParameterSpec(TAG_LENGTH_BIT, iv);

            // On met le moteur en mode "ENCRYPT"
            cipher.init(Cipher.ENCRYPT_MODE, keySpec, gcmSpec);

            // ÉTAPE 3 : Chiffrer
            byte[] cipherText = cipher.doFinal(attribute.getBytes(StandardCharsets.UTF_8));

            // ÉTAPE 4 : L'Assemblage (IV + Message)
            // Le destinataire aura besoin de l'IV pour déchiffrer.
            // Comme l'IV n'est pas secret (juste aléatoire), on le colle devant le message.
            byte[] ivAndCipherText = new byte[iv.length + cipherText.length];
            System.arraycopy(iv, 0, ivAndCipherText, 0, iv.length); // Copie l'IV au début
            System.arraycopy(cipherText, 0, ivAndCipherText, iv.length, cipherText.length); // Copie le message après

            // ÉTAPE 5 : Encodage Base64
            // Le résultat est binaire. La base de données veut du texte. Base64 traduit le binaire en lettres.
            return Base64.getEncoder().encodeToString(ivAndCipherText);

        } catch (Exception e) {
            throw new IllegalStateException("Erreur critique de chiffrement", e);
        }
    }

    // --- DEPUIS LA BASE DE DONNÉES (Déchiffrement) ---
    @Override
    public String convertToEntityAttribute(String dbData) {
        if (dbData == null) return null;

        try {
            // ÉTAPE 1 : Décoder le Base64 (Retour au binaire)
            byte[] decode = Base64.getDecoder().decode(dbData);

            // ÉTAPE 2 : Séparer l'IV du Message
            // On sait que les 12 premiers octets sont l'IV.
            byte[] iv = new byte[IV_LENGTH_BYTE];
            System.arraycopy(decode, 0, iv, 0, iv.length);

            // Le reste, c'est le message chiffré
            int cipherTextSize = decode.length - iv.length;
            byte[] cipherText = new byte[cipherTextSize];
            System.arraycopy(decode, iv.length, cipherText, 0, cipherTextSize);

            // ÉTAPE 3 : Préparer le Moteur (Cipher)
            Cipher cipher = Cipher.getInstance(AES_GCM);
            SecretKeySpec keySpec = new SecretKeySpec(encryptionKey.getBytes(StandardCharsets.UTF_8), AES);
            // IMPORTANT : On utilise l'IV qu'on vient d'extraire !
            GCMParameterSpec gcmSpec = new GCMParameterSpec(TAG_LENGTH_BIT, iv);

            // On met le moteur en mode "DECRYPT"
            cipher.init(Cipher.DECRYPT_MODE, keySpec, gcmSpec);

            // ÉTAPE 4 : Déchiffrer
            byte[] plainText = cipher.doFinal(cipherText);

            // Retourner le texte original
            return new String(plainText, StandardCharsets.UTF_8);

        } catch (Exception e) {
            throw new IllegalStateException("Erreur critique de déchiffrement. La clé a-t-elle changé ?", e);
        }
    }
}
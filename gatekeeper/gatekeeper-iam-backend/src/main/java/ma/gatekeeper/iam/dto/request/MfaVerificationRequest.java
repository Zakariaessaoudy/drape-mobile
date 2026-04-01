package ma.gatekeeper.iam.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class MfaVerificationRequest {
    @NotBlank(message = "Le code est obligatoire")
    private String code;

    @NotBlank(message = "Le token MFA est obligatoire")
    private String mfaToken;
}
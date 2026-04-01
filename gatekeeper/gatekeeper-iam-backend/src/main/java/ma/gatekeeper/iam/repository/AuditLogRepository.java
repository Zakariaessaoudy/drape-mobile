package ma.gatekeeper.iam.repository;

import ma.gatekeeper.iam.model.AuditLog;
import ma.gatekeeper.iam.model.RefreshToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface AuditLogRepository extends JpaRepository<AuditLog, UUID> {

}
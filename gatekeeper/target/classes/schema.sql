-- ============================================================
-- schema.sql
-- Initialisation de la base de données "Gatekeeper" (IAM)
-- Adapté aux modèles JPA (User, Role, Permission, AuditLog)
-- ============================================================

-- 1) Extensions nécessaires
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- TABLE: users
-- Correspondance : ma.gatekeeper.iam.model.User
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
                                     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(150),  -- Remplace firstname et lastname
    email VARCHAR(320) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL, -- Nom standard JPA 'password'

-- Sécurité & MFA
    mfa_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    mfa_secret TEXT NULL,

    -- Verrouillage de compte
    is_locked BOOLEAN NOT NULL DEFAULT FALSE,
    failed_attempts INTEGER NOT NULL DEFAULT 0,
    lock_time TIMESTAMPTZ NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ -- Souvent utile sur User aussi
    );

CREATE INDEX IF NOT EXISTS idx_users_email ON users (email);

-- ============================================================
-- TABLE: roles
-- Correspondance : ma.gatekeeper.iam.model.Role
-- ============================================================
CREATE TABLE IF NOT EXISTS roles (

                                     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL UNIQUE, -- @Column(length = 50)
    description VARCHAR(255),         -- @Column(length = 255)

-- Champs d'Audit
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID

    );

-- ============================================================
-- TABLE: permissions
-- Correspondance : ma.gatekeeper.iam.model.Permission
-- ============================================================
CREATE TABLE IF NOT EXISTS permissions (

                                           id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL UNIQUE, -- @Column(length = 50)
    description VARCHAR(255),         -- @Column(length = 255)

-- Champs d'Audit
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ
    );

-- ============================================================
-- TABLES DE JOINTURE (Many-to-Many)
-- ============================================================

-- role_permissions (Role <-> Permission)
CREATE TABLE IF NOT EXISTS role_permissions (
                                                role_id UUID NOT NULL,
                                                permission_id UUID NOT NULL,
                                                assigned_at TIMESTAMPTZ NOT NULL DEFAULT now(), -- Optionnel, non mappé dans l'entité par défaut mais utile
    PRIMARY KEY (role_id, permission_id),
    CONSTRAINT fk_roleperm_role FOREIGN KEY (role_id)
    REFERENCES roles (id) ON DELETE CASCADE,
    CONSTRAINT fk_roleperm_permission FOREIGN KEY (permission_id)
    REFERENCES permissions (id) ON DELETE CASCADE
    );

-- user_roles (User <-> Role)
-- Note: JPA s'attend souvent à user_id et role_id
CREATE TABLE IF NOT EXISTS user_roles (
                                          user_id UUID NOT NULL,
                                          role_id UUID NOT NULL,
                                          granted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, role_id),
    CONSTRAINT fk_userroles_user FOREIGN KEY (user_id)
    REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT fk_userroles_role FOREIGN KEY (role_id)
    REFERENCES roles (id) ON DELETE CASCADE
    );

-- ============================================================
-- TABLE: audit_logs
-- Correspondance : ma.gatekeeper.iam.model.AuditLog
-- ============================================================
CREATE TABLE IF NOT EXISTS audit_logs (
                                          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    action VARCHAR(50) NOT NULL,
    user_id UUID,                     -- Peut être NULL
    user_email VARCHAR(255),          -- Pour trace historique

    entity_name VARCHAR(255),         -- Ex: "User", "Product"
    entity_id VARCHAR(255),           -- ID de l'objet manipulé

    details TEXT,                     -- @Column(columnDefinition = "TEXT")

    ip_address VARCHAR(45),           -- @Column(length = 45)
    user_agent VARCHAR(255),
    status VARCHAR(20),               -- SUCCESS, FAILURE

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT fk_audit_user FOREIGN KEY (user_id)
    REFERENCES users (id) ON DELETE SET NULL
    );

CREATE INDEX IF NOT EXISTS idx_auditlogs_ip ON audit_logs (ip_address);
CREATE INDEX IF NOT EXISTS idx_auditlogs_created_at ON audit_logs (created_at);

-- ============================================================
-- TABLE: refresh_tokens
-- Nécessaire pour la gestion des sessions JWT
-- ============================================================
CREATE TABLE IF NOT EXISTS refresh_tokens (
                                              id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    token_hash VARCHAR(64) NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    revoked BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT fk_refresh_user FOREIGN KEY (user_id)
    REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT ux_refresh_tokenhash_user UNIQUE (user_id, token_hash)
    );

-- ============================================================
-- DONNÉES INITIALES (Optionnel, DataSeeder s'en charge aussi)
-- ============================================================
-- INSERT INTO roles (id, name, description, created_at)
-- SELECT uuid_generate_v4(), 'ROLE_ADMIN', 'Administrateurs système', now()
--     WHERE NOT EXISTS (SELECT 1 FROM roles WHERE name = 'ROLE_ADMIN');
--
-- INSERT INTO roles (id, name, description, created_at)
-- SELECT uuid_generate_v4(), 'ROLE_USER', 'Utilisateur standard', now()
--     WHERE NOT EXISTS (SELECT 1 FROM roles WHERE name = 'ROLE_USER');
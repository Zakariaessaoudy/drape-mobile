#!/bin/bash

# Définition du chemin de base
BASE_DIR="src/main/java/com/gatekeeper/iam"
BASE_PACKAGE="com.gatekeeper.iam"

echo "🚀 Création de la structure du projet dans $BASE_DIR..."

# Fonction pour créer un fichier avec le package et la classe
create_java_file() {
    local sub_package=$1
    local file_name=$2
    local dir_path="$BASE_DIR/$sub_package"

    # Convertir le chemin du dossier en package Java (remplacer / par .)
    local java_package="$BASE_PACKAGE.${sub_package//\//.}"

    # Créer le dossier s'il n'existe pas
    mkdir -p "$dir_path"

    # Nom du fichier complet
    local file_path="$dir_path/$file_name"

    # Nom de la classe sans l'extension .java
    local class_name="${file_name%.java}"

    # Écriture du contenu de base
    if [ ! -f "$file_path" ]; then
        echo "Creation de $file_path"
        echo "package $java_package;" > "$file_path"
        echo "" >> "$file_path"

        # Petite logique pour deviner si c'est une Interface ou une Class
        if [[ "$file_name" == *"Repository.java" ]]; then
            echo "public interface $class_name {" >> "$file_path"
        else
            echo "public class $class_name {" >> "$file_path"
        fi

        echo "" >> "$file_path"
        echo "}" >> "$file_path"
    else
        echo "⚠️  Le fichier $file_name existe déjà, ignoré."
    fi
}

# --- CONFIG ---
create_java_file "config" "SecurityConfig.java"
create_java_file "config" "OpenApiConfig.java"

# --- CONTROLLER ---
create_java_file "controller" "AuthController.java"
create_java_file "controller" "AdminController.java"
create_java_file "controller" "UserController.java"

# --- DTO ---
create_java_file "dto/request" "LoginRequest.java"
create_java_file "dto/request" "DPoPTokenRequest.java"
create_java_file "dto/response" "TokenResponse.java"

# --- EXCEPTION ---
create_java_file "exception" "GlobalExceptionHandler.java"

# --- MODEL ---
create_java_file "model" "User.java"
create_java_file "model" "Role.java"
create_java_file "model" "Permission.java"
create_java_file "model" "AuditLog.java"
create_java_file "model" "RefreshToken.java"

# --- REPOSITORY ---
create_java_file "repository" "UserRepository.java"
create_java_file "repository" "RefreshTokenRepository.java"
create_java_file "repository" "AuditLogRepository.java"

# --- SECURITY (CORE PILLARS) ---
# Pillar 2: DPoP
create_java_file "security/dpop" "DPoPAuthenticationFilter.java"
create_java_file "security/dpop" "DPoPTokenValidator.java"

# Pillar 3: Encryption
create_java_file "security/encryption" "AttributeEncryptor.java"
create_java_file "security/encryption" "KeyManagementService.java"

# Pillar 1: Hashing
create_java_file "security/hashing" "PasswordEncoderConfig.java"

# Security Service
create_java_file "security/service" "CustomUserDetailsService.java"

# --- SERVICE ---
create_java_file "service" "AuthService.java"
create_java_file "service" "AuditService.java"
create_java_file "service" "UserService.java"

echo "------------------------------------------------"
echo "✅ Structure terminée avec succès !"
echo "📁 Emplacement : $BASE_DIR"
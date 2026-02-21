#!/bin/bash

# Detectar el gestor de paquetes del sistema
detectar_gestor() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            echo "brew"
        else
            echo ""
        fi
    elif command -v apt &> /dev/null; then
        echo "apt"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    else
        echo ""
    fi
}

# Comando de instalación según gestor y herramienta
comando_instalacion() {
    local herramienta=$1
    local gestor=$2

    case "$gestor" in
        brew)
            case "$herramienta" in
                python3) echo "brew install python3" ;;
                uv)      echo "brew install uv" ;;
                java)    echo "brew install openjdk" ;;
                javac)   echo "brew install openjdk" ;;
                gradle)  echo "brew install gradle" ;;
            esac
            ;;
        apt)
            case "$herramienta" in
                python3) echo "sudo apt install -y python3" ;;
                uv)      echo "curl -LsSf https://astral.sh/uv/install.sh | sh" ;;
                java)    echo "sudo apt install -y default-jdk" ;;
                javac)   echo "sudo apt install -y default-jdk" ;;
                gradle)  echo "sudo apt install -y gradle" ;;
            esac
            ;;
        dnf)
            case "$herramienta" in
                python3) echo "sudo dnf install -y python3" ;;
                uv)      echo "curl -LsSf https://astral.sh/uv/install.sh | sh" ;;
                java)    echo "sudo dnf install -y java-17-openjdk-devel" ;;
                javac)   echo "sudo dnf install -y java-17-openjdk-devel" ;;
                gradle)  echo "sudo dnf install -y gradle" ;;
            esac
            ;;
    esac
}

gestor=$(detectar_gestor)
todo_bien=true
herramientas=("python3" "uv" "java" "javac" "gradle")

for herramienta in "${herramientas[@]}"; do
    if ! command -v "$herramienta" &> /dev/null; then
        todo_bien=false
        echo ""
        echo "No tienes instalado $herramienta, tienes que instalarla."

        if [ -z "$gestor" ]; then
            echo "No se detectó un gestor de paquetes compatible (brew, apt, dnf)."
            echo "Por favor instala $herramienta manualmente."
            continue
        fi

        read -rp "¿Quieres que lo haga por ti o lo haces tú solo? (si/no): " respuesta

        if [[ "$respuesta" == "si" || "$respuesta" == "sí" || "$respuesta" == "s" ]]; then
            cmd=$(comando_instalacion "$herramienta" "$gestor")
            echo "Ejecutando: $cmd"
            eval "$cmd"

            if command -v "$herramienta" &> /dev/null; then
                echo "$herramienta se instaló correctamente."
            else
                echo "Hubo un problema instalando $herramienta. Intenta instalarlo manualmente."
            fi
        else
            echo "Ok, instala $herramienta manualmente antes de continuar."
        fi
    fi
done

echo ""
# Revisar de nuevo después de las instalaciones
todo_bien=true
for herramienta in "${herramientas[@]}"; do
    if ! command -v "$herramienta" &> /dev/null; then
        todo_bien=false
    fi
done

if [ "$todo_bien" = true ]; then
    echo "¡Tienes todo listo para la mini-práctica!"
else
    echo "Aún faltan herramientas por instalar. Revisa los mensajes anteriores."
fi

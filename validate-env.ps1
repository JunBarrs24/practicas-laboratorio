# validate-env.ps1

# Detectar el gestor de paquetes disponible
function Get-Gestor {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        return "winget"
    } elseif (Get-Command choco -ErrorAction SilentlyContinue) {
        return "choco"
    } else {
        return ""
    }
}

# Comando de instalación según gestor y herramienta
function Get-ComandoInstalacion {
    param([string]$herramienta, [string]$gestor)

    switch ($gestor) {
        "winget" {
            switch ($herramienta) {
                "python3" { return "winget install -e --id Python.Python.3.12" }
                "uv"      { return "powershell -ExecutionPolicy ByPass -c `"irm https://astral.sh/uv/install.ps1 | iex`"" }
                "java"    { return "winget install -e --id EclipseAdoptium.Temurin.17.JDK" }
                "javac"   { return "winget install -e --id EclipseAdoptium.Temurin.17.JDK" }
                "gradle"  { return "winget install -e --id Gradle.Gradle" }
            }
        }
        "choco" {
            switch ($herramienta) {
                "python3" { return "choco install python3 -y" }
                "uv"      { return "powershell -ExecutionPolicy ByPass -c `"irm https://astral.sh/uv/install.ps1 | iex`"" }
                "java"    { return "choco install temurin17 -y" }
                "javac"   { return "choco install temurin17 -y" }
                "gradle"  { return "choco install gradle -y" }
            }
        }
    }
}

# En Windows, python3 no existe como comando; se usa "python"
function Test-Herramienta {
    param([string]$herramienta)

    if ($herramienta -eq "python3") {
        return [bool](Get-Command python -ErrorAction SilentlyContinue)
    }
    return [bool](Get-Command $herramienta -ErrorAction SilentlyContinue)
}

$gestor = Get-Gestor
$todoBien = $true
$herramientas = @("python3", "uv", "java", "javac", "gradle")

foreach ($herramienta in $herramientas) {
    if (-not (Test-Herramienta $herramienta)) {
        $todoBien = $false
        $nombre = if ($herramienta -eq "python3") { "python" } else { $herramienta }
        Write-Host ""
        Write-Host "No tienes instalado $nombre, tienes que instalarla."

        if ($gestor -eq "") {
            Write-Host "No se detectó un gestor de paquetes compatible (winget, choco)."
            Write-Host "Por favor instala $nombre manualmente."
            continue
        }

        $respuesta = Read-Host "¿Quieres que lo haga por ti o lo haces tú solo? (si/no)"

        if ($respuesta -eq "si" -or $respuesta -eq "sí" -or $respuesta -eq "s") {
            $cmd = Get-ComandoInstalacion $herramienta $gestor
            Write-Host "Ejecutando: $cmd"
            Invoke-Expression $cmd

            if (Test-Herramienta $herramienta) {
                Write-Host "$nombre se instaló correctamente."
            } else {
                Write-Host "Hubo un problema instalando $nombre. Intenta instalarlo manualmente."
                Write-Host "Es posible que necesites reiniciar la terminal para que se detecte."
            }
        } else {
            Write-Host "Ok, instala $nombre manualmente antes de continuar."
        }
    }
}

Write-Host ""

# Revisar de nuevo después de las instalaciones
$todoBien = $true
foreach ($herramienta in $herramientas) {
    if (-not (Test-Herramienta $herramienta)) {
        $todoBien = $false
    }
}

if ($todoBien) {
    Write-Host "¡Tienes todo listo para la mini-práctica!"
} else {
    Write-Host "Aún faltan herramientas por instalar. Revisa los mensajes anteriores."
}

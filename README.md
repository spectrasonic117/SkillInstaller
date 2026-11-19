# ⚡ Skill Installer

Herramienta CLI para **explorar, seleccionar e instalar skills** desde un almacén global
(`~/Documents/Skills`) hacia el proyecto actual (`.agents/skills/`).

El "binario" que se instala es en realidad un script Python 3 con interfaz de terminal
rico (Rich + Questionary): navegación con flechas, selección con barra espaciadora y
confirmación con `<ENTER>`.

---

## ✨ Características

| Característica | Descripción |
|---|---|
| 🖥️ Interfaz interactiva | Menú de selección múltiple con Rich + Questionary |
| 🔍 Filtro en vivo | Escribe para filtrar por nombre o descripción |
| 📊 Tabla de catálogo | Modo `--list` con estado, tamaño y archivos por skill |
| 🧠 Metadatos automáticos | Lee `SKILL.md`, `.metadata.json` o `README.md` |
| 🔁 Sincronización | Copia/actualiza skills (sobrescribe limpio) |
| ✅ Detección de duplicados | Marca las skills ya presentes en el proyecto |
| 📦 Ligero | Solo requiere `rich` y `questionary` (que incluye `prompt_toolkit`) |

---

## 📦 Instalación

### Requisitos

- **Python 3.8+**
- Las librerías `rich` y `questionary` (se pueden instalar automáticamente)
- Permiso de escritura en `~/bin` (o usa `--dir`)

### Instalación automática

```bash
git clone <url-del-repositorio>
cd SkillInstaller
chmod +x install.sh
./install.sh
```

El script:

1. Verifica que `python3` esté instalado y que el script exista.
2. Copia `skill-installer` a `~/bin` con permisos `0755`.
3. Comprueba si `rich` y `questionary` están instalados.
4. Te avisa si `~/bin` no está en tu `PATH` (con instrucciones exactas).
5. Verifica que `skill-installer --help` funcione tras la instalación.

#### Opciones de `install.sh`

| Opción | Descripción |
|---|---|
| `-d, --dir <ruta>` | Directorio de instalación (por defecto `$HOME/bin`) |
| `--deps` | Instala automáticamente `rich` y `questionary` con `pip` |
| `-f, --force` | Continúa aunque no se detecte `python3` |
| `-h, --help` | Muestra la ayuda del instalador |

#### Ejemplos

```bash
# Instalación en un directorio personalizado
./install.sh --dir ~/.local/bin

# Instalación con dependencias automáticas
./install.sh --deps

# Ver ayuda
./install.sh --help
```

### Instalación manual

```bash
cp skill-installer ~/bin/
chmod +x ~/bin/skill-installer
```

Asegúrate de que `~/bin` esté en tu `PATH` (añade a `~/.zshrc` o `~/.bashrc`):

```bash
export PATH="$HOME/bin:$PATH"
```

### Dependencias de Python

Si no se instalaron automáticamente:

```bash
python3 -m pip install --user rich questionary prompt_toolkit
```

> **Nota:** Usar un entorno virtual es recomendable:
> ```bash
> python3 -m venv ~/.skill-installer-venv
> source ~/.skill-installer-venv/bin/activate
> pip install rich questionary prompt_toolkit
> ```

---

## 🚀 Uso

### Sintaxis

```bash
skill-installer [opciones]
```

### Opciones

| Opción | Descripción |
|---|---|
| *(ninguna)* | Modo interactivo con menú de selección múltiple |
| `--list` | Muestra una tabla con todas las skills disponibles y sale |
| `--all` | Instala todas las skills disponibles sin preguntar |
| `--source <ruta>` | Ruta al almacén de skills (por defecto `~/Documents/Skills`) |
| `--dest <ruta>` | Ruta de destino en el proyecto (por defecto `./.agents/skills`) |
| `-h, --help` | Muestra la ayuda del programa |

### Modos de operación

#### 1. Modo interactivo (por defecto)

```bash
skill-installer
```

Abre un menú de selección múltiple. Controles:

| Tecla | Acción |
|---|---|
| `↑` / `↓` | Mover cursor |
| Escribir texto | Filtrar skills por nombre/descripción |
| `<ESPACIO>` | Seleccionar / desmarcar la skill enfocada |
| `<Ctrl-A>` | Seleccionar todas |
| `<Ctrl-I>` | Invertir selección |
| `<ENTER>` | Confirmar e instalar las seleccionadas |
| `<Ctrl-C>` | Cancelar |

Las skills **ya instaladas** aparecen pre-seleccionadas y con la etiqueta `[Ya en proyecto]`.

#### 2. Listar catálogo

```bash
skill-installer --list
```

Muestra una tabla con:

- Estado (✔ Instalada / —)
- Nombre de la carpeta/skill
- Número de archivos
- Tamaño total
- Descripción extraída de metadatos

#### 3. Instalar todo

```bash
skill-installer --all
```

Copia todas las skills del almacén global al destino actual sin pedir confirmación.

#### 4. Usar otra ruta de origen

```bash
skill-installer --source ~/Documents/MisSkills
```

#### 5. Usar otro destino

```bash
skill-installer --dest ./custom/skills
```

---

## 📁 Estructura esperada del almacén

El almacén global debe tener esta estructura:

```
~/Documents/Skills/
├── skill-a/
│   ├── SKILL.md          # Metadatos de la skill (recomendado)
│   ├── .metadata.json    # Alternativa si no hay SKILL.md
│   ├── README.md         # Alternativa si faltan los anteriores
│   └── ...archivos...
├── skill-b/
│   └── ...
└── skill-c/
    └── ...
```

### Extracción de metadatos

El script busca en este orden:

1. **`SKILL.md`** — lee los campos YAML `name:` y `description:`
2. **`.metadata.json`** — lee `{"name": "...", "description": "..."}`
3. **`README.md`** — usa la primera línea que no sea encabezado ni bloque de código

Si no encuentra descripción, muestra "Sin descripción disponible."

---

## 🛠️ Flujo de trabajo típico

```bash
# 1. Explora el catálogo global
skill-installer --list

# 2. Selecciona e instala las skills que quieras
cd /ruta/mi-proyecto
skill-installer

# 3. Confirma con ENTER cuando termines
```

Al terminar, las skills elegidas estarán en `.agents/skills/<nombre-skill>/`.

---

## 🔧 Solución de problemas

### `skill-installer: command not found`

Verifica que `~/bin` esté en tu `PATH`:

```bash
echo $PATH | grep ~/bin
# Si no aparece:
export PATH="$HOME/bin:$PATH"   # Añade a ~/.zshrc
```

### `ModuleNotFoundError: No module named 'rich'`

```bash
python3 -m pip install --user rich questionary prompt_toolkit
```

O reejecuta el instalador con dependencias:

```bash
./install.sh --deps
```

### `Directorio global de skills no encontrado`

Por defecto busca en `~/Documents/Skills`. Crea el directorio o especifica otro:

```bash
mkdir -p ~/Documents/Skills
# O:
skill-installer --source /tu/ruta/personalizada
```

### `Permission denied`

Dale permisos de ejecución:

```bash
chmod +x ~/bin/skill-installer
```

---

## 📋 Archivos del proyecto

| Archivo | Descripción |
|---|---|
| `skill-installer` | Script Python principal (el "binario") |
| `install.sh` | Instalador bash |
| `README.md` | Esta documentación |
| `.gitignore` | Archivos ignorados por Git |

---

## 📄 Licencia

Este proyecto forma parte del ecosistema RTK.
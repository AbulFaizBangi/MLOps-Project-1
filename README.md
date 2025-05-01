# Project Setup

Welcome to the **Project Setup** guide for your MLOps project. We’ll walk through structuring your repository and—using **uv**, a modern Python package & project manager—handling environments and dependencies without `setup.py` or `requirements.txt`.

---

## 📁 Directory Structure

```text
MLOps_Project_One/
├── pyproject.toml          # uv-managed project manifest
├── uv.lock                 # uv lockfile for reproducible installs
├── .venv/                  # virtual environment directory
├── src/
│   ├── __init__.py
│   ├── logger.py           # logging setup
│   └── custom_exception.py # custom error classes
├── config/
│   └── __init__.py         # configuration helpers
├── utils/
│   └── __init__.py         # utility functions
├── pipeline/               # training/inference pipelines
├── artifacts/              # models, datasets, outputs
├── notebooks/              # Jupyter notebooks for experimentation
├── templates/              # HTML templates (Flask UI)
└── static/                 # JS, CSS, images for UI
```

---

## Why **uv** Instead of `venv` + `requirements.txt` + `setup.py`?

- **All-in-One Manifest**: `pyproject.toml` replaces both `requirements.txt` and `setup.py`, centralizing metadata and dependencies.
- **Reproducible Environments**: Locks exact versions in `uv.lock`, guaranteeing consistency across machines.
- **Simplified Workflow**: One tool for init, dependency management, environment creation, and packaging.
- **Performance**: Written in Rust, uv is fast and low-overhead.

---

## Prerequisites

- Python 3.8+ installed
- VS Code or another code editor
- Basic familiarity with Python

---

## 1. Initialize with uv

```bash
# Create project directory and enter it
mkdir MLOps_Project_One && cd MLOps_Project_One

# Initialize uv (creates pyproject.toml & default settings)
uv init
```

This generates a `pyproject.toml` with your project name, version, and default settings.

---

## 2. Add Dependencies

Instead of editing `requirements.txt`, use:

```bash
uv add pandas numpy scikit-learn flask python-dotenv
```

This updates both `pyproject.toml` and the lockfile (`uv.lock`) automatically.

---

## 3. Create & Activate the Environment

```bash
# Install dependencies and create a virtual environment under .venv
uv install

# Activate the uv-managed environment
uv shell
```

Your packages are now isolated within `.venv/`.

---

## 4. Project Metadata & Packaging

All packaging info lives in **pyproject.toml**. You **do not** need `setup.py`:

```toml
[project]
name = "mlops_project_one"
version = "0.1.0"
description = "An MLOps project scaffolded with uv"
authors = [
  { name = "Your Name", email = "you@example.com" }
]

[tool.uv]
# uv-specific configuration goes here
```

---

## 5. Logger Setup (`src/logger.py`)

```python
import logging
import os
from datetime import datetime

LOG_DIR = os.getenv("LOG_DIR", "logs")
os.makedirs(LOG_DIR, exist_ok=True)

log_filename = datetime.now().strftime("app_%Y%m%d_%H%M%S.log")
logging.basicConfig(
    filename=os.path.join(LOG_DIR, log_filename),
    level=logging.INFO,
    format="%(asctime)s — %(name)s — %(levelname)s — %(message)s"
)
logger = logging.getLogger(__name__)
```

---

## 6. Custom Exceptions (`src/custom_exception.py`)

```python
class MLOpsError(Exception):
    """Base class for MLOps exceptions."""
    pass

class DataValidationError(MLOpsError):
    """Raised when input data fails validation."""
    def __init__(self, message, errors=None):
        super().__init__(message)
        self.errors = errors
```

---

## 7. Testing Your Setup

1. Create `src/test_setup.py`:

   ```python
   from src.logger import logger
   from src.custom_exception import DataValidationError

   def main():
       logger.info("Testing logger")
       try:
           raise DataValidationError("Invalid data format", errors={"field": "age"})
       except DataValidationError as e:
           logger.error(f"Caught an error: {e}, details: {e.errors}")

   if __name__ == "__main__":
       main()
   ```

2. Run within the uv environment:

   ```bash
   uv shell
   python src/test_setup.py
   ```

3. Confirm a new log file appears under `logs/` with INFO and ERROR entries.

---

## Recap

- **uv init** to bootstrap your project  
- **uv add** to manage dependencies  
- **uv install & uv shell** to create & activate your environment  
- **pyproject.toml** replaces `setup.py` & `requirements.txt`  
- Organized directories for maintainable MLOps workflows  

Happy coding! 🚀


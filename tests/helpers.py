import importlib.util
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
def load(path, name):
    spec = importlib.util.spec_from_file_location(name, ROOT / path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module
provision = load("bootstrap/provision.py", "provision")
pki = load("tools/lab_pki.py", "pki")

import skrf as rf
from pathlib import Path

def load_touchstone(file_path):
    """
    Loads a touchstone file using scikit-rf.
    Returns the skrf.Network object.
    """
    path = Path(file_path)
    if not path.exists():
        raise FileNotFoundError(f"File {file_path} not found.")
    
    try:
        network = rf.Network(str(path))
        return network
    except Exception as e:
        raise ValueError(f"Failed to parse Touchstone file: {e}")

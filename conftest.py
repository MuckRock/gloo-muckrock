import sys
from pathlib import Path

# Add gloo root to sys.path so baml_client is importable absolutely
# when tests are run directly (without the Django package hierarchy)
sys.path.insert(0, str(Path(__file__).parent))

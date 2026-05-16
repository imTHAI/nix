---
paths:
  - "**/*.py"
---

# Conventions Python

## Structure d'un script

Tout script autonome commence par :

```python
#!/usr/bin/env -S uv run
# -*- coding: utf-8 -*-

# /// script
# dependencies = [
#   "lib",
# ]
# ///

"""
Description courte du script : ce qu'il fait, pourquoi il existe.
"""
```

Le bloc `# /// script` n'est inclus que s'il y a des dépendances externes.
La docstring de module est toujours présente pour décrire l'intention du script.

## Type hints

Obligatoires sur toutes les fonctions et méthodes :

```python
# Non
def process(data, config):
    ...

# Oui
def process(data: list[dict], config: AppConfig) -> ProcessResult:
    ...
```

## Docstrings

Uniquement si le comportement est non-obvieux (invariant caché, workaround, convention surprenante).
Ne pas documenter ce que le nom de la fonction dit déjà.

## Gestion des exceptions

Pas de `except Exception` générique sans justification explicite.
Toujours cibler les exceptions attendues :

```python
# Non
except Exception:
    return None

# Oui
except (ConnectionError, TimeoutError) as e:
    logger.warning("API unreachable: %s", e)
    return None
```

## Ctrl+C

Toujours intercepter `KeyboardInterrupt` au point d'entrée principal pour éviter le traceback :

```python
if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print()
        sys.exit(0)
```

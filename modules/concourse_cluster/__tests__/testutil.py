
def find_module(path, statefile):
    for module in statefile['modules']:
        if "/".join(module['path']) == path:
            return module

    return None

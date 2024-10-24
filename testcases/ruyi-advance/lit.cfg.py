import pathlib
import platform

import lit.formats

config.name = "RuyiAdvance"
config.test_format = lit.formats.ShTest(True)
config.suffixes = ['.bash']

config.available_features.add(platform.machine())
if pathlib.Path("/etc/revyos-release").exists():
    config.available_features.add("revyos")

config.environment.update(os.environ)

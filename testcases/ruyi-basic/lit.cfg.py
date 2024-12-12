import pathlib
import platform

import lit.formats

config.name = "RuyiCommands"
config.test_format = lit.formats.ShTest(True)
config.suffixes = ['.bash']

rit_features = os.environ.get("RIT_CASE_FEATURES", "").split()

for f in rit_features:
    config.available_features.add(f)

config.environment.update(os.environ)
config.test_retry_attempts = 3
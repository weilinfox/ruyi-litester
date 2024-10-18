import platform

import lit.formats

config.name = "RuyiCommands"
config.test_format = lit.formats.ShTest(True)
config.suffixes = ['.bash']

config.available_features.add(platform.machine())
config.environment.update(os.environ)

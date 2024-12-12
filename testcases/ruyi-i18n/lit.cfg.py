import lit.formats

config.name = "RuyiI18N"
config.test_format = lit.formats.ShTest(True)
config.suffixes = ['.bash']

config.environment.update(os.environ)
config.test_retry_attempts = 3
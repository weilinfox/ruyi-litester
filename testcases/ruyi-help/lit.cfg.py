import lit.formats

config.name = "RuyiHelp"
config.test_format = lit.formats.ShTest(True)
config.suffixes = ['.bash']

if os.environ.get('PATH'):
    config.environment['PATH'] = os.environ.get('PATH')

config.environment['PYTHONPATH'] = os.environ.get('PYTHONPATH', '')

TEST_FILES = t/*.t
PLUGIN_DIR = plugins

test:
	prove -I$(PLUGIN_DIR) $(TEST_FILES)

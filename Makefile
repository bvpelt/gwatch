DEVICE ?= fr165
KEY = ~/.Garmin/developer_key
APP_NAME = gwatch

# do not set this to source!!!!! since it will be cleared!!!!!
OUTPUT_DIR = bin

# prg or iq
OUTPUT_EXT = prg

# BINDIR = ~/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-8.4.0-2025-12-03-5122605dc/bin

.PHONY: clean build run fresh kill-simulator

kill-simulator:
	@echo "Killing simulator and rogue processes..."
	killall -9 simulator monkeydo shell 2>/dev/null || true

clean: kill-simulator
	@echo "Cleaning build artifacts..."
	rm -rf $(OUTPUT_DIR)/ build/
	find . -name "*.$(OUTPUT_EXT)" -delete

build:
	@echo "Building $(OUTPUT_DIR)/$(APP_NAME).$(OUTPUT_EXT)..."
	monkeyc -o $(OUTPUT_DIR)/$(APP_NAME).$(OUTPUT_EXT) -f monkey.jungle -y $(KEY) -d $(DEVICE) -w

run: build
	@echo "Running in simulator..."
	pgrep simulator >/dev/null || connectiq &
	sleep 5
	monkeydo $(OUTPUT_DIR)/$(APP_NAME).$(OUTPUT_EXT) $(DEVICE) -a $(OUTPUT_DIR)/$(APP_NAME)-settings.json:GARMIN/Settings/$(APP_NAME)-settings.json

clean-storage: clean
	@echo "Cleaning simulator storage..."
	rm -rf $(OUTPUT_DIR)/ build/
	rm -rf source/mir/ source/gen/ source/internal-mir/	
	rm -rf /tmp/com.garmin.connectiq/ 
	rm -rf ~/.Garmin/ConnectIQ/Devices/$(DEVICE)/APPS/

fresh: clean clean-storage build run
	@echo "Fresh build complete!"
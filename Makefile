DEVICE ?= fr165
KEY = ~/.Garmin/developer_key
APP_NAME = MessengerApp
# BINDIR = ~/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-8.4.0-2025-12-03-5122605dc/bin


.PHONY: clean build run fresh kill-simulator

kill-simulator:
	@echo "Killing simulator..."
	killall simulator || true

clean: kill-simulator
	@echo "Cleaning build artifacts..."
	rm -rf bin/ build/
	find . -name "*.prg" -delete
	find . -name "*.iq" -delete

build:
	@echo "Building..."
	monkeyc -o build/$(APP_NAME).prg -f monkey.jungle -y $(KEY) -d $(DEVICE) -w


run: build
	@echo "Running in simulator..."
	pgrep simulator >/dev/null || connectiq &
	sleep 2
	monkeydo build/$(APP_NAME).prg $(DEVICE) 

clean-storage: clean
	@echo "Cleaning simulator storage..."
	rm -rf ~/.Garmin/ConnectIQ/Devices/$(DEVICE)/APPS/*

fresh: clean clean-storage build run
	@echo "Fresh build complete!"

.PHONY: build run_rtl run_all clean

build: clean
	./script/get_code.sh

#run_rtl:

#run_all:

clean:
	@rm -rf build/*
	@rm -rf sim/*.hex					


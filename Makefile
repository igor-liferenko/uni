uni: uni.c
	@gcc -g -c uni.c
	@gcc -g uni.o uni-to-utf-test.c -o uni
	@echo Test UNICODE to UTF-8 conversion:
	@./uni
	@echo ---------------------------------
	@gcc -g uni.o utf-to-uni-test.c -o uni
	@echo Test UTF-8 to UNICODE conversion:
	@./uni

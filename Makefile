uni: uni.c
	@gcc -g -c uni.c
	@gcc -g uni.o unicode-to-utf8-test.c -o uni
	@echo Test UNICODE to UTF-8 conversion:
	@./uni
	@echo ---------------------------------
	@gcc -g uni.o utf8-to-unicode-test.c -o uni
	@echo Test UTF-8 to UNICODE conversion:
	@./uni

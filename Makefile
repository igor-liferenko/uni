uniweb: uniweb.c
	@gcc -g -c uniweb.c
	@gcc -g uniweb.o uni-to-utf-test.c -o uniweb
	@echo Test UNICODE to UTF-8 conversion:
	@./uniweb
	@echo ---------------------------------
	@gcc -g uniweb.o utf-to-uni-test.c -o uniweb
	@echo Test UTF-8 to UNICODE conversion:
	@./uniweb

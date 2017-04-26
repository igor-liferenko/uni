uniweb: uniweb.c
	@gcc -g -Wall -Wextra -Wconversion -Wsign-compare -Wsign-conversion -c uniweb.c
	@gcc -g -Wall -Wextra -Wconversion -Wsign-compare -Wsign-conversion uniweb.o uni-to-utf-test.c -o uniweb
	@echo Test UNICODE to UTF-8 conversion:
	@./uniweb
	@echo ---------------------------------
	@gcc -g -Wall -Wextra -Wconversion -Wsign-compare -Wsign-conversion uniweb.o utf-to-uni-test.c -o uniweb
	@echo Test UTF-8 to UNICODE conversion:
	@./uniweb

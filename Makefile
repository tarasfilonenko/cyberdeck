# Forwards all targets to os/Makefile
%:
	$(MAKE) -C os $@

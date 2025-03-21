all:
		+$(MAKE) -C heat
		+$(MAKE) -C cholesky
		+$(MAKE) -C nbody
		+$(MAKE) -C dotp
		+$(MAKE) -C axpy
		+$(MAKE) -C hog

.PHONY: clean
clean:
		+$(MAKE) -C heat clean
		+$(MAKE) -C cholesky clean
		+$(MAKE) -C nbody clean
		+$(MAKE) -C dotp clean
		+$(MAKE) -C axpy clean
		+$(MAKE) -C hog clean

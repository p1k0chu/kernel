.SECONDEXPANSION:

# rule for making a directory
%/:
	@mkdir -p $@

# default way to build a c file
$(O)/%.c.o: %.c | $(O)/
	$(CC) $(CFLAGS) -c -o $@ $<


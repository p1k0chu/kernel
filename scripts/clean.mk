clean:
	$(RM) $(O)
	$(foreach dir,$(SUBDIRS),$(MAKE) -C $(dir) $@;)

.PHONY: clean

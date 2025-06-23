ifeq ($(OS),Windows_NT)
  ifeq ($(shell uname -s),) # not in a bash-like shell
	CLEANUP = del /F /Q
	MKDIR = mkdir
  else # in a bash-like shell, like msys
	CLEANUP = rm -f
	MKDIR = mkdir -p
  endif
	TARGET_EXTENSION=exe
else
	CLEANUP = rm -f
	MKDIR = mkdir -p
	TARGET_EXTENSION=out
endif

.PHONY: clean
.PHONY: test

PATHU = unity/src/
PATHS = src/
PATHT = test/
PATHB = build/
PATHD = build/depends/
PATHOT = build/objs/test/
PATHOS = build/objs/src/
PATHOU = build/objs/unity/
PATHR = build/results/
PATHI = include/

BUILD_PATHS = $(PATHB) $(PATHD) $(PATHO) $(PATHR)

# Find src code for program and tests
SRCS = $(shell find $(PATHS) -name "*.c" -not -name "main.c")
SRCT = $(shell find $(PATHT) -name "*.c")

# Create object names that must be made
SRC_OBJECTS = $(patsubst $(PATHS)%.c,$(PATHOS)%.o,$(SRCS))
TEST_OBJECTS = $(patsubst $(PATHT)%.c,$(PATHOT)%.o,$(SRCT))

# Test Executables here i am creating a list of the executables that need to be made
TEST_EXECUTABLES = $(patsubst $(PATHT)%.c,$(PATHB)%.$(TARGET_EXTENSION),$(SRCT))
RESULTS = $(patsubst $(PATHB)%.$(TARGET_EXTENSION),$(PATHR)%.txt,$(TEST_EXECUTABLES))


COMPILE=gcc -c
LINK=gcc
DEPEND=gcc -MM -MG -MF
CFLAGS=-I. -I$(PATHU) -I$(PATHS) -I$(PATHI) -DTEST



PASSED = `grep -s PASS $(PATHR)*.txt`
FAIL = `grep -s FAIL $(PATHR)*.txt`
IGNORE = `grep -s IGNORE $(PATHR)*.txt`

test: $(BUILD_PATHS) $(RESULTS)
	@echo "-----------------------\nIGNORES:\n-----------------------"
	@echo "$(IGNORE)"
	@echo "-----------------------\nFAILURES:\n-----------------------"
	@echo "$(FAIL)"
	@echo "-----------------------\nPASSED:\n-----------------------"
	@echo "$(PASSED)"
	@echo "\nDONE"

$(PATHR)%.txt: $(PATHB)%.$(TARGET_EXTENSION)
	@echo "pattern: $(PATHB)%.$(TARGET_EXTENSION)"
	-./$< > $@ 2>&1

# TODO: The % pattern includes "Test" because i cannot filter it out and still get full path
# But I need % without "Test" to match inside $(PATHOS)
# I need to do a secondary expansion on $(PATHOS)%.o and substitution of Test $(subst Test,,%)
$(TEST_EXECUTABLES): $(PATHB)%.$(TARGET_EXTENSION): $(PATHOT)%.o $(PATHOS)%.o $(PATHOU)unity.o #$(PATHD)Test%.d
	@echo "pattern: $(PATHB)%.$(TARGET_EXTENSION)"
	@$(MKDIR) $(dir $@)
	$(LINK) -o $@ $^


$(PATHOU)%.o:: $(PATHU)%.c $(PATHU)%.h
	@$(MKDIR) $(dir $@)
	$(COMPILE) $(CFLAGS) $< -o $@

$(PATHD)%.d:: $(PATHT)%.c
	@$(MKDIR) $(dir $@)
	$(DEPEND) $@ $<

# static rules once again
$(SRC_OBJECTS): $(PATHOS)%.o: $(PATHS)%.c
	@$(MKDIR) $(dir $@)
	$(COMPILE) $(CFLAGS) $< -o $@

$(TEST_OBJECTS): $(PATHOT)%.o: $(PATHT)%.c
	@$(MKDIR) $(dir $@)
	$(COMPILE) $(CFLAGS) $< -o $@

$(PATHB):
	$(MKDIR) $(PATHB)

$(PATHD):
	$(MKDIR) $(PATHD)

$(PATHO):
	$(MKDIR) $(PATHO)

$(PATHR):
	$(MKDIR) $(PATHR)

clean:
	$(CLEANUP) $(PATHO)*.o
	$(CLEANUP) $(PATHB)*.$(TARGET_EXTENSION)
	$(CLEANUP) $(PATHR)*.txt
	rm -r $(PATHB)

.PRECIOUS: $(PATHB)Test%.$(TARGET_EXTENSION)
.PRECIOUS: $(PATHD)%.d
.PRECIOUS: $(PATHO)%.o
.PRECIOUS: $(PATHR)%.txt
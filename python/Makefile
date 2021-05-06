
PYTHON  = python
MOVE    = mv
REMOVE  = rm -rf

INCLUDE = ../include
DATA    = ../data

all: $(INCLUDE)/weights.h $(INCLUDE)/test_images.h

$(INCLUDE)/weights.h: create_weights.py write_weights.py lenet.py
	$(PYTHON) create_weights.py
	$(MOVE) weights.h $(INCLUDE)
	$(MOVE) weights_float.bin $(DATA)

$(INCLUDE)/test_images.h: create_test_images.py
	$(PYTHON) create_test_images.py
	$(MOVE) test_images.h  $(INCLUDE)

clean:
	$(REMOVE) $(INCLUDE)/test_images.h
	$(REMOVE) $(INCLUDE)/weights.h
	$(REMOVE) $(DATA)/weights_float.bin

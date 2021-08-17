
PYTHON  = python
MOVE    = mv
REMOVE  = rm -rf

#dumb as fuck

INCLUDE = ../include
DATA    = ../data

all: $(INCLUDE)/weights.h $(INCLUDE)/test_images.h $(INCLUDE)/auto_infer.c $(INCLUDE)/regions.h $(DATA)/weights_float.bin 

$(INCLUDE)/weights.h: create_weights.py write_weights.py lenet.py
	$(PYTHON) create_weights.py
	$(MOVE) weights.h          $(INCLUDE)
	$(MOVE) auto_infer.c       $(INCLUDE)
	$(MOVE) regions.h          $(INCLUDE)
	$(MOVE) weights_float.bin  $(DATA)

$(INCLUDE)/auto_infer.c: create_weights.py write_weights.py lenet.py
	$(PYTHON) create_weights.py
	$(MOVE) weights.h          $(INCLUDE)
	$(MOVE) auto_infer.c       $(INCLUDE)
	$(MOVE) regions.h          $(INCLUDE)
	$(MOVE) weights_float.bin  $(DATA)

$(DATA)/weights_float.bin: create_weights.py write_weights.py lenet.py
	$(PYTHON) create_weights.py
	$(MOVE) weights.h          $(INCLUDE)
	$(MOVE) auto_infer.c       $(INCLUDE)
	$(MOVE) regions.h          $(INCLUDE)
	$(MOVE) weights_float.bin  $(DATA)

$(INCLUDE)/test_images.h: create_test_images.py
	$(PYTHON) create_test_images.py
	$(MOVE) test_images.h      $(INCLUDE)

clean:
	$(REMOVE) $(INCLUDE)/test_images.h
	$(REMOVE) $(INCLUDE)/weights.h
	$(REMOVE) $(INCLUDE)/auto_infer.cpp
	$(REMOVE) $(INCLUDE)/regions.cpp
	$(REMOVE) $(DATA)/weights_float.bin

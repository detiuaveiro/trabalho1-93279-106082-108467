# make              # to compile files and create the executables
# make pgm          # to download example images to the pgm/ dir
# make setup        # to setup the test files in test/ dir
# make tests        # to run basic tests
# make clean        # to cleanup object files and executables
# make cleanobj     # to cleanup object files only

CFLAGS = -Wall -O2 -g

PROGS = imageTool imageTest

TESTS = test1 test2 test3 test4 test5 test6 test7 test8 test9

# Default rule: make all programs
all: $(PROGS)

imageTest: imageTest.o image8bit.o instrumentation.o error.o

imageTest.o: image8bit.h instrumentation.h

imageTool: imageTool.o image8bit.o instrumentation.o error.o

imageTool.o: image8bit.h instrumentation.h

# Rule to make any .o file dependent upon corresponding .h file
%.o: %.h

pgm:
	wget -O- https://sweet.ua.pt/jmr/aed/pgm.tgz | tar xzf -

.PHONY: setup
setup: test/

test/:
	wget -O- https://sweet.ua.pt/jmr/aed/test.tgz | tar xzf -
	@#mkdir -p $@
	@#curl -s -o test/aed-trab1-test.zip https://sweet.ua.pt/mario.antunes/aed/test/aed-trab1-test.zip
	@#unzip -q -o test/aed-trab1-test.zip -d test/

test1: $(PROGS) setup
	./imageTool test/original.pgm neg save neg.pgm
	cmp neg.pgm test/neg.pgm

test2: $(PROGS) setup
	./imageTool test/original.pgm thr 128 save thr.pgm
	cmp thr.pgm test/thr.pgm

test3: $(PROGS) setup
	./imageTool test/original.pgm bri .33 save bri.pgm
	cmp bri.pgm test/bri.pgm

test4: $(PROGS) setup
	./imageTool test/original.pgm rotate save rotate.pgm
	cmp rotate.pgm test/rotate.pgm

test5: $(PROGS) setup
	./imageTool test/original.pgm mirror save mirror.pgm
	cmp mirror.pgm test/mirror.pgm

test6: $(PROGS) setup
	./imageTool test/original.pgm crop 100,100,100,100 save crop.pgm
	cmp crop.pgm test/crop.pgm

test7: $(PROGS) setup
	./imageTool test/small.pgm test/original.pgm paste 100,100 save paste.pgm
	cmp paste.pgm test/paste.pgm

test8: $(PROGS) setup
	./imageTool test/small.pgm test/original.pgm blend 100,100,.33 save blend.pgm
	cmp blend.pgm test/blend.pgm

test9: $(PROGS) setup
	./imageTool test/original.pgm blur 7,7 save blur.pgm
	cmp blur.pgm test/blur.pgm

testLocate: $(PROGS) setup
	# creates a crop in the best case (x = 0, y = 0)
	./imageTool test/original.pgm crop 0,0,100,100 save Locate/bestcrop.pgm
	# # creates a crop in the worst case ( x = with origina - with crop , y = heigt origina - heigt crop )
	./imageTool test/original.pgm crop 200,200,100,100 save Locate/worstcrop.pgm
	# Test
	./imageTool Locate/bestcrop.pgm test/original.pgm tic locate toc
	./imageTool Locate/worstcrop.pgm test/original.pgm tic locate toc

testBlur: $(PROGS) setup
	# Mean 3x3
	./imageTool pgm/small/bird_256x256.pgm tic blur 1,1 toc save Blur/test_3x3.pgm
	./imageTool pgm/small/bird_256x256.pgm tic betterblur 1,1 toc save Blur/testbetter_3x3.pgm
	cmp Blur/test_3x3.pgm Blur/testbetter_3x3.pgm
	# Mean 11x11
	./imageTool pgm/small/bird_256x256.pgm tic blur 5,5 toc save Blur/test_11x11.pgm
	./imageTool pgm/small/bird_256x256.pgm tic betterblur 5,5 toc save Blur/testbetter_11x11.pgm
	cmp Blur/test_11x11.pgm Blur/testbetter_11x11.pgm
	# Mean 21x21
	./imageTool pgm/small/bird_256x256.pgm tic blur 10,10 toc save Blur/test_21x21.pgm
	./imageTool pgm/small/bird_256x256.pgm tic betterblur 10,10 toc save Blur/testbetter_21x21.pgm
	cmp Blur/test_21x21.pgm Blur/testbetter_21x21.pgm

.PHONY: tests
tests: $(TESTS)

# Make uses builtin rule to create .o from .c files.

cleanobj:
	rm -f *.o

clean: cleanobj
	rm -f $(PROGS)


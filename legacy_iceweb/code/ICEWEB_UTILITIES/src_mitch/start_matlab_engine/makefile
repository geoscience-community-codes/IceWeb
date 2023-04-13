BIN= start_matlab_engine

MAN1=

CLEAN= 

ARCH= sol2

cflags= -mt -I$(MATLAB)/extern/include -D_SPARC -D_SOLARIS -I$(ANTELOPE)/contrib/include
fflags= 
ldflags= -L$(MATLAB)/extern/lib/$(ARCH) -R$(MATLAB)/extern/lib/$(ARCH) -L$(ANTELOPE)/contrib/lib -R$(ANTELOPE)/contrib/lib
#ldlibs= -lmat -lmx -leng -lmi -lut -lwormds -lwormsol -lwormutil $(TRLIBS) $(SVR4LIBS) -lm	
ldlibs= -lmat -lmx -leng -lut -lwormds -lwormsol -lwormutil $(TRLIBS) $(SVR4LIBS) -lm	

include $(ANTELOPEMAKE)
DIRS = 

OBJS= start_matlab_engine.o
$(BIN) : $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(OBJS) $(LDFLAGS) $(LDLIBS)



OBJS1=httpServer.cmo
OBJS2=api.cmo
NAME=server
OFIND=ocamlfind ocamlc -thread -package cohttp.lwt,cohttp.async,lwt.ppx

$(NAME).byte: $(OBJS1) $(OBJS2)
		$(OFIND) -linkpkg -o $@ $(OBJS1) $(OBJS2) $(NAME).ml

%.cmo: %.ml
		$(OFIND) -c $<i
		$(OFIND) -c $<

clean:
		ocamlbuild -clean
		rm *.cm*
		rm *.byte

server:
	make && ./server.byte

compile:
	# make clean && ocamlbuild -use-ocamlfind api.cmo httpServer.cmo main.cmo pool.cmo server.cmo student.cmo swipe.cmo
	ocamlbuild -use-ocamlfind api.cmo httpServer.cmo main.cmo pool.cmo server.cmo student.cmo swipe.cmo professor.cmo

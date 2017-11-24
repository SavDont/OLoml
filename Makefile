OBJS=httpServer.cmo
NAME=server
OFIND=ocamlfind ocamlc -thread -package cohttp.lwt,cohttp.async,lwt.ppx

$(NAME).byte: $(OBJS)
		$(OFIND) -linkpkg -o $@ $(OBJS) $(NAME).ml

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
	ocamlbuild -use-ocamlfind pool.cmo student.cmo

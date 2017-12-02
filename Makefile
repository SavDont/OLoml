OBJS1=httpServer.cmo
OBJS2=api.cmo
NAME=server
OFIND=ocamlfind ocamlc -thread -package cohttp.lwt,cohttp.async,lwt.ppx
PROJECT := db
LINK_PKG := pgocaml
COMP_PKG := pgocaml,pgocaml.syntax

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
	ocamlbuild -use-ocamlfind api.cmo backend_lib.cmo httpServer.cmo loml_client.cmo main.cmo oclient.cmo pool.cmo server.cmo student.cmo swipe.cmo professor.cmo command.cmo match.cmo

play:
	ocamlbuild -use-ocamlfind main.byte && ./main.byte

all: $(PROJECT)

$(PROJECT): $(PROJECT).cmo
	ocamlfind ocamlc -package $(LINK_PKG) -linkpkg -o $@ $<

$(PROJECT).cmo: $(PROJECT).ml
	ocamlfind ocamlc -package $(COMP_PKG) -syntax camlp4o -c $<

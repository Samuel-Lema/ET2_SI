// beliefs and rules
kqml::bel_no_source_self(NS::Content,Ans)[hide_in_mind_inspector] :- (NS::Content[|LA] & (kqml::clear_source_self(LA,NLA) & ((Content =.. [F,T,_172]) & (Ans =.. [NS,F,T,NLA])))).
kqml::clear_source_self([],[])[hide_in_mind_inspector].
kqml::clear_source_self([source(self)|T],NT)[hide_in_mind_inspector] :- kqml::clear_source_self(T,NT).
kqml::clear_source_self([A|T],[A|NT])[hide_in_mind_inspector] :- ((A \== source(self)) & kqml::clear_source_self(T,NT)).
stock(beer,0).
available(beer).
supermarket(super3)[source(super3)].
dir("./src/asl/gestor3Saved.asl")[source(super3)].
max_stock(beer,3).
precio(150)[source(super3)].
dinero(260).
precioTransporte(80)[source(super3)].


// initial goals


// plans from file:src/asl/gestor.asl

@p__77[source(self),url("file:src/asl/gestor.asl")] +!save : (.my_name(N) & dir(Dir)) <- .println("Guardando en ",Dir); .save_agent(Dir).
@p__78[source(self),url("file:src/asl/gestor.asl")] +processOrderFrom(Ag,Qtd) : (stock(beer,X) & (supermarket(Super) & (dinero(D) & precioTransporte(T)))) <- .if_then_else((Qtd < X),.print(Ag," ha comprado ",Qtd," cervezas."); .send(Super,tell,orderFrom(Ag,Qtd)); -+stock(beer,(X-Qtd)),.print(Ag," ha comprado ",X," cervezas."); .send(Super,tell,orderFrom(Ag,X)); -+stock(beer,0)); !cambiarDinero((D-T)); .abolish(processOrderFrom(Ag,Qtd)); !save.
@p__79[source(self),url("file:src/asl/gestor.asl")] +stock(beer,0) : (available(beer) & (supermarket(Super) & precio(P))) <- .send(Super,untell,hayStock(P)); .send(Super,tell,hayStock(no)); -available(beer); .println("Se necesita reponer."); !save.
@p__80[source(self),url("file:src/asl/gestor.asl")] +stock(beer,N) : ((N > 0) & not (available(beer))) <- -+available(beer); !save.
@p__81[source(self),url("file:src/asl/gestor.asl")] +!prepRestock(P) : (max_stock(beer,Max) & dinero(D)) <- (Posibles = ((D-(D mod P))/P)); .if_then_else((Posibles < Max),.print("Reponiendo ",Posibles," cervezas."); !restock(Posibles,P),.print("Reponiendo ",Max," cervezas."); !restock(Max,P)).
@p__82[source(self),url("file:src/asl/gestor.asl")] +!restock(X,B) : (dinero(D) & (supermarket(Super) & precio(P))) <- (Din = (D-(X*B))); !cambiarDinero(Din); .if_then_else((X == 0),.print("No hay dinero para reponer."),.print("Me quedan ",Din," céntimos."); .print("Se han repuesto ",X," cervezas."); .send(Super,untell,hayStock(no)); .send(Super,tell,hayStock(P))); -+stock(beer,X); !save.
@p__83[source(self),url("file:src/asl/gestor.asl")] +!cambiarDinero(Din) : supermarket(Super) <- .send(Super,tell,dinero(Din)); -+dinero(Din); !save.
@p__84[source(self),url("file:src/asl/gestor.asl")] +pagar(Pago) : (dinero(D) & stock(beer,X)) <- (Din = (D+Pago)); !cambiarDinero(Din); .println(Pago," céntimos recibidos. Tengo ",Din); .abolish(pagar(_161)); !save.


// beliefs and rules
kqml::bel_no_source_self(NS::Content,Ans)[hide_in_mind_inspector] :- (NS::Content[|LA] & (kqml::clear_source_self(LA,NLA) & ((Content =.. [F,T,_36]) & (Ans =.. [NS,F,T,NLA])))).
kqml::clear_source_self([],[])[hide_in_mind_inspector].
kqml::clear_source_self([source(self)|T],NT)[hide_in_mind_inspector] :- kqml::clear_source_self(T,NT).
kqml::clear_source_self([A|T],[A|NT])[hide_in_mind_inspector] :- ((A \== source(self)) & kqml::clear_source_self(T,NT)).
auction(1)[source(auctioneer)].
winner(super3)[source(auctioneer)].
consumed(2022,4,17,22,51,44,beer).
consumed(2022,4,17,22,51,36,beer).
consumed(2022,4,17,22,51,14,beer).
consumed(2022,4,17,22,50,57,beer).
consumed(2022,4,17,22,50,44,beer).
service(Answer,translating) :- checkTag("<translate>",Answer).
service(Answer,addingBot) :- checkTag("<botprop>",Answer).
hayStock(150)[source(super3)[source(gestor3)]].
hayStock(no)[source(super1),source(super2)].
limit(beer,5).
precio(150)[source(super3)].
precio(100)[source(super2)].
precio(120)[source(super1)].
has(myOwner,beer)[source(percept)].
dinero(500).
getValTag(Tag,String,Val) :- (.substring(Tag,String,Fst) & (.length(Tag,N) & (.delete(0,Tag,RestTag) & (.concat("</",RestTag,EndTag) & (.substring(EndTag,String,End) & .substring(String,Val,(Fst+N),End)))))).
bot("bot").
bot("bot")[artifact_id(cobj_2),artifact_name(cobj_2,BOT),percept_type(obs_prop),source(percept),workspace(cobj_2,main,cobj_0)].
too_much(B) :- (.date(YY,MM,DD) & (.count(consumed(YY,MM,DD,_19,_20,_21,B),QtdB) & (limit(B,Limit) & (QtdB > Limit)))).
delivered(Product,2,2)[source(super3)].
filter(Answer,translating,[To,Msg]) :- (getValTag("<to>",Answer,To) & getValTag("<msg>",Answer,Msg)).
filter(Answer,addingBot,[ToWrite,Route]) :- (getValTag("<name>",Answer,Name) & (getValTag("<val>",Answer,Val) & (.concat(Name,":",Val,ToWrite) & (bot(Bot) & (.concat("/bots/",Bot,BotName) & .concat(BotName,"/config/properties.txt",Route)))))).
mySupermarkets(super1).
mySupermarkets(super2).
mySupermarkets(super3).
joined(main,cobj_0)[artifact_id(cobj_1),artifact_name(cobj_1,myRobot_body),percept_type(obs_prop),source(percept),workspace(cobj_1,main,cobj_0)].
at(myRobot,myOwner)[source(percept)].
checkTag(Service,String) :- .substring(Service,String).
asked(beer).


// initial goals


// plans from file:src/asl/myRobot.asl

@p__20[source(self),url("file:src/asl/myRobot.asl")] +!initBot <- makeArtifact("BOT","bot.ChatBOT",["bot"],BOT); focus(BOT); +bot("bot").
@p__21[source(self),url("file:src/asl/myRobot.asl")] +!answerOwner : (msg(Msg)[source(Ag)] & bot(Bot)) <- chatSincrono(Msg,Answer); -msg(Msg)[source(Ag)]; .println("El agente ",Ag," ha dicho ",Msg); !doSomething(Answer,Ag); !answerOwner.
@p__22[source(self),url("file:src/asl/myRobot.asl")] +!answerOwner <- !answerOwner.
@p__23[source(self),url("file:src/asl/myRobot.asl")] +!doSomething(Answer,Ag) : service(Answer,Service) <- .println("Aqui debe ir el código del servicio:",Service," para el agente ",Ag).
@p__24[source(self),url("file:src/asl/myRobot.asl")] +!doSomething(Answer,Ag) : not (service(Answer,Service)) <- .println("Le contesto al ",Ag," ",Answer); .send(Ag,tell,answer(Answer)).
@p__25[source(self),url("file:src/asl/myRobot.asl")] +!bring(myOwner,beer)[source(myOwner)] <- +asked(beer); !save.
@p__26[source(self),url("file:src/asl/myRobot.asl")] +!bringBeer : healthMsg(_22) <- !go_at(myRobot,base); .println("El Robot descansa porque Owner ha bebido mucho hoy.").
@p__27[source(self),url("file:src/asl/myRobot.asl")] +!bringBeer : (asked(beer) & not (healthMsg(_23))) <- .println("Owner me ha pedido una cerveza."); !go_at(myRobot,fridge); !take(fridge,beer); !go_at(myRobot,myOwner); !hasBeer(myOwner); .println("Ya he servido la cerveza y elimino la petición."); .abolish(asked(Beer)); !bringBeer.
@p__28[source(self),url("file:src/asl/myRobot.asl")] +!bringBeer : (not (asked(beer)) & not (healthMsg(_24))) <- .wait(2000); .println("Robot esperando la petición de Owner."); !bringBeer.
@p__29[source(self),url("file:src/asl/myRobot.asl")] +!take(fridge,beer) : not (too_much(beer)) <- .println("El robot está cogiendo una cerveza."); !check(fridge,beer).
@p__30[source(self),url("file:src/asl/myRobot.asl")] +!take(fridge,beer) : (too_much(beer) & limit(beer,L)) <- .concat("The Department of Health does not allow me to give you more than ",L," beers a day! I am very sorry about that!",M); -+healthMsg(M).
@p__31[source(self),url("file:src/asl/myRobot.asl")] +!check(fridge,beer) : (not (ordered(beer)) & available(beer,fridge)) <- .println("El robot está en el frigorífico y coge una cerveza."); .wait(1000); open(fridge); .println("El robot abre la nevera."); get(beer); .println("El robot coge una cerveza."); close(fridge); .println("El robot cierra la nevera.").
@p__32[source(self),url("file:src/asl/myRobot.asl")] +!check(fridge,beer) : (not (ordered(beer)) & not (available(beer,fridge))) <- .println("El robot está en el frigorífico y hace un pedido de cerveza."); !comprobarStock; !check(fridge,beer).
@p__33[source(self),url("file:src/asl/myRobot.asl")] +!check(fridge,beer) <- .println("El robot está esperando ................"); .wait(5000); !check(fridge,beer).
@p__34[source(self),url("file:src/asl/myRobot.asl")] +!comprobarStock <- .abolish(hayStock(_25)); .send(super1,askOne,hayStock(A)); .send(super2,askOne,hayStock(B)); .send(super3,askOne,hayStock(C)); .wait(2000); !elegirSuper.
@p__35[source(self),url("file:src/asl/myRobot.asl")] +!elegirSuper : (not (ordered(beer)) & .findall(p(P,S),hayStock(P)[source(S)],L)) <- .min(L,p(Precio,Super)); .if_then_else((Precio = no),!orderBeer(sinStock),.println("Decidido ",Super," con precio de ",Precio); !orderBeer(Super)).
@p__36[source(self),url("file:src/asl/myRobot.asl")] +!elegirSuper.
@p__37[source(self),url("file:src/asl/myRobot.asl")] +!orderBeer(Supermarket) : (not (ordered(beer)) & (dinero(D) & hayStock(P)[source(Supermarket)])) <- .if_then_else((Supermarket == sinStock),.println("Ning�n super tiene stock. Esperando..."); .wait(5000); !comprobarStock,.if_then_else((D < P),.println("No tengo dinero para comprar en ",Supermarket); .wait(5000),.println("El robot realiza un pedido a ",Supermarket); !go_at(myRobot,delivery); .println("El robot va a la ZONA de ENTREGA."); .send(Supermarket,achieve,order(beer,3)); +ordered(beer))); !save.
@p__38[source(self),url("file:src/asl/myRobot.asl")] +!orderBeer(Supermarket).
@p__39[source(self),url("file:src/asl/myRobot.asl")] +!hasBeer(myOwner) : not (too_much(beer)) <- hand_in(beer); .println("He preguntado si Owner ha cogido la cerveza."); ?has(myOwner,beer); .println("Se que Owner tiene la cerveza."); .date(YY,MM,DD); .time(HH,NN,SS); +consumed(YY,MM,DD,HH,NN,SS,beer); !save.
@p__40[source(self),url("file:src/asl/myRobot.asl")] +!hasBeer(myOwner) : (too_much(beer) & healthMsg(M)) <- .send(myOwner,tell,msg(M)).
@p__41[source(self),url("file:src/asl/myRobot.asl")] +!go_at(myRobot,P) : at(myRobot,P).
@p__42[source(self),url("file:src/asl/myRobot.asl")] +!go_at(myRobot,P) : not (at(myRobot,P)) <- move_towards(P); !go_at(myRobot,P).
@p__43[source(self),url("file:src/asl/myRobot.asl")] +delivered(beer,Qtd,OrderId)[source(X)] : (mySupermarkets(X) & (hayStock(P)[source(X)] & dinero(D))) <- (PTotal = (P*Qtd)); .println("Ha llegado mi pedido de ",Qtd," cervezas, pagando ",PTotal," c�ntimos, me quedan ",(D-PTotal)); .send(X,tell,pagar(PTotal)); -+dinero((D-PTotal)); -ordered(beer); +available(beer,fridge); .wait(1000); !go_at(myRobot,fridge); !save.
@p__44[source(self),url("file:src/asl/myRobot.asl")] +stock(beer,0) : available(beer,fridge) <- -available(beer,fridge); !save.
@p__45[source(self),url("file:src/asl/myRobot.asl")] +stock(beer,N) : ((N > 0) & not (available(beer,fridge))) <- -+available(beer,fridge); !save.
@p__46[source(self),url("file:src/asl/myRobot.asl")] +!cleanHouse : trashcan(full) <- .send(myRoomba,tell,trashcan(full)); .send(myRoomba,achieve,emptyTrashcan); .send(myRoomba,untell,trashcan(full)); -trashcan(full); !cleanHouse.
@p__47[source(self),url("file:src/asl/myRobot.asl")] +!cleanHouse : canatfloor(can) <- !go_at(myRobot,can); pickup(can); .println("Se ha recogido una lata del suelo"); -canatfloor(can); !go_at(myRobot,trashCan); dropdown(can); .println("Se ha tirado la lata a la basura"); !cleanHouse.
@p__48[source(self),url("file:src/asl/myRobot.asl")] +!cleanHouse <- !cleanHouse.
@p__49[source(self),url("file:src/asl/myRobot.asl")] +?time(T) <- time.check(T).
@p__50[source(self),url("file:src/asl/myRobot.asl")] +dinero(X) : (X < 200) <- .println("Solo me quedan ",X," c�ntimos, pidiendo al owner."); .send(myOwner,achieve,darDinero(400)).
@p__51[source(self),url("file:src/asl/myRobot.asl")] +!recibirDinero(X) : dinero(D) <- .println("Recibidos ",X," c�ntimos del owner."); -+dinero((D+X)); !save.
@p__52[source(self),url("file:src/asl/myRobot.asl")] +!save <- .println("Guardando en ./src/asl/myRobot-saved.asl"); .save_agent("./src/asl/myRobot-saved.asl").


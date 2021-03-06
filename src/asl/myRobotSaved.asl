// beliefs and rules
kqml::bel_no_source_self(NS::Content,Ans)[hide_in_mind_inspector] :- (NS::Content[|LA] & (kqml::clear_source_self(LA,NLA) & ((Content =.. [F,T,_36]) & (Ans =.. [NS,F,T,NLA])))).
kqml::clear_source_self([],[])[hide_in_mind_inspector].
kqml::clear_source_self([source(self)|T],NT)[hide_in_mind_inspector] :- kqml::clear_source_self(T,NT).
kqml::clear_source_self([A|T],[A|NT])[hide_in_mind_inspector] :- ((A \== source(self)) & kqml::clear_source_self(T,NT)).
getValTag(Tag,String,Val) :- (.substring(Tag,String,Fst) & (.length(Tag,N) & (.delete(0,Tag,RestTag) & (.concat("</",RestTag,EndTag) & (.substring(EndTag,String,End) & .substring(String,Val,(Fst+N),End)))))).
too_much(B) :- (.date(YY,MM,DD) & (.count(consumed(YY,MM,DD,_19,_20,_21,B),QtdB) & (limit(B,Limit) & (QtdB > Limit)))).
filter(Answer,translating,[To,Msg]) :- (getValTag("<to>",Answer,To) & getValTag("<msg>",Answer,Msg)).
filter(Answer,addingBot,[ToWrite,Route]) :- (getValTag("<name>",Answer,Name) & (getValTag("<val>",Answer,Val) & (.concat(Name,":",Val,ToWrite) & (bot(Bot) & (.concat("/bots/",Bot,BotName) & .concat(BotName,"/config/properties.txt",Route)))))).
service(Answer,translating) :- checkTag("<translate>",Answer).
service(Answer,addingBot) :- checkTag("<botprop>",Answer).
mySupermarkets(super1).
mySupermarkets(super2).
mySupermarkets(super3).
joined(main,cobj_0)[artifact_id(cobj_1),artifact_name(cobj_1,myRobot_body),percept_type(obs_prop),source(percept),workspace(cobj_1,main,cobj_0)].
available(beer,fridge).
limit(beer,5).
checkTag(Service,String) :- .substring(Service,String).
dinero(0).


// initial goals


// plans from file:src/asl/myRobot.asl

@p__14[source(self),url("file:src/asl/myRobot.asl")] +!initBot <- makeArtifact("BOT","bot.ChatBOT",["bot"],BOT); focus(BOT); +bot("bot").
@p__15[source(self),url("file:src/asl/myRobot.asl")] +!answerOwner : (msg(Msg)[source(Ag)] & bot(Bot)) <- chatSincrono(Msg,Answer); -msg(Msg)[source(Ag)]; .println("El agente ",Ag," ha dicho ",Msg); !doSomething(Answer,Ag); !answerOwner.
@p__16[source(self),url("file:src/asl/myRobot.asl")] +!answerOwner <- !answerOwner.
@p__17[source(self),url("file:src/asl/myRobot.asl")] +!doSomething(Answer,Ag) : service(Answer,Service) <- .println("Aqui debe ir el c??digo del servicio:",Service," para el agente ",Ag).
@p__18[source(self),url("file:src/asl/myRobot.asl")] +!doSomething(Answer,Ag) : not (service(Answer,Service)) <- .println("Le contesto al ",Ag," ",Answer); .send(Ag,tell,answer(Answer)).
@p__19[source(self),url("file:src/asl/myRobot.asl")] +!bring(myOwner,beer)[source(myOwner)] <- +asked(beer).
@p__20[source(self),url("file:src/asl/myRobot.asl")] +!bringBeer : healthMsg(_22) <- !go_at(myRobot,base); .println("El Robot descansa porque Owner ha bebido mucho hoy.").
@p__21[source(self),url("file:src/asl/myRobot.asl")] +!bringBeer : (asked(beer) & not (healthMsg(_23))) <- .println("Owner me ha pedido una cerveza."); !go_at(myRobot,fridge); !take(fridge,beer); !go_at(myRobot,myOwner); !hasBeer(myOwner); .println("Ya he servido la cerveza y elimino la petici??n."); .abolish(asked(Beer)); !bringBeer.
@p__22[source(self),url("file:src/asl/myRobot.asl")] +!bringBeer : (not (asked(beer)) & not (healthMsg(_24))) <- .wait(2000); .println("Robot esperando la petici??n de Owner."); !bringBeer.
@p__23[source(self),url("file:src/asl/myRobot.asl")] +!take(fridge,beer) : not (too_much(beer)) <- .println("El robot est?? cogiendo una cerveza."); !check(fridge,beer).
@p__24[source(self),url("file:src/asl/myRobot.asl")] +!take(fridge,beer) : (too_much(beer) & limit(beer,L)) <- .concat("The Department of Health does not allow me to give you more than ",L," beers a day! I am very sorry about that!",M); -+healthMsg(M).
@p__25[source(self),url("file:src/asl/myRobot.asl")] +!check(fridge,beer) : (not (ordered(beer)) & available(beer,fridge)) <- .println("El robot est?? en el frigor??fico y coge una cerveza."); .wait(1000); open(fridge); .println("El robot abre la nevera."); get(beer); .println("El robot coge una cerveza."); close(fridge); .println("El robot cierra la nevera.").
@p__26[source(self),url("file:src/asl/myRobot.asl")] +!check(fridge,beer) : (not (ordered(beer)) & not (available(beer,fridge))) <- .println("El robot est?? en el frigor??fico y hace un pedido de cerveza."); !comprobarStock; !check(fridge,beer).
@p__27[source(self),url("file:src/asl/myRobot.asl")] +!check(fridge,beer) <- .println("El robot est?? esperando ................"); .wait(5000); !check(fridge,beer).
@p__28[source(self),url("file:src/asl/myRobot.asl")] +!comprobarStock <- .abolish(hayStock(_25)); .send(super1,askOne,hayStock(A)); .send(super2,askOne,hayStock(B)); .send(super3,askOne,hayStock(C)); .wait(2000); !elegirSuper.
@p__29[source(self),url("file:src/asl/myRobot.asl")] +!elegirSuper : (not (ordered(beer)) & .findall(p(P,S),hayStock(P)[source(S)],L)) <- .min(L,p(Precio,Super)); .if_then_else((Precio = no),!orderBeer(sinStock),.println("Decidido ",Super," con precio de ",Precio); !orderBeer(Super)).
@p__30[source(self),url("file:src/asl/myRobot.asl")] +!elegirSuper.
@p__31[source(self),url("file:src/asl/myRobot.asl")] +!orderBeer(Supermarket) : (not (ordered(beer)) & (dinero(D) & hayStock(P)[source(Supermarket)])) <- .if_then_else((Supermarket == sinStock),.println("Ning?n super tiene stock. Esperando..."); .wait(5000); !comprobarStock,.if_then_else((D < P),.println("No tengo dinero para comprar en ",Supermarket); .wait(5000),.println("El robot realiza un pedido a ",Supermarket); !go_at(myRobot,delivery); .println("El robot va a la ZONA de ENTREGA."); .send(Supermarket,achieve,order(beer,3)); +ordered(beer))).
@p__32[source(self),url("file:src/asl/myRobot.asl")] +!orderBeer(Supermarket).
@p__33[source(self),url("file:src/asl/myRobot.asl")] +!hasBeer(myOwner) : not (too_much(beer)) <- hand_in(beer); .println("He preguntado si Owner ha cogido la cerveza."); ?has(myOwner,beer); .println("Se que Owner tiene la cerveza."); .date(YY,MM,DD); .time(HH,NN,SS); +consumed(YY,MM,DD,HH,NN,SS,beer).
@p__34[source(self),url("file:src/asl/myRobot.asl")] +!hasBeer(myOwner) : (too_much(beer) & healthMsg(M)) <- .send(myOwner,tell,msg(M)).
@p__35[source(self),url("file:src/asl/myRobot.asl")] +!go_at(myRobot,P) : at(myRobot,P).
@p__36[source(self),url("file:src/asl/myRobot.asl")] +!go_at(myRobot,P) : not (at(myRobot,P)) <- move_towards(P); !go_at(myRobot,P).
@p__37[source(self),url("file:src/asl/myRobot.asl")] +delivered(beer,Qtd,OrderId)[source(X)] : (mySupermarkets(X) & (hayStock(P)[source(X)] & dinero(D))) <- (PTotal = (P*Qtd)); .println("Ha llegado mi pedido de ",Qtd," cervezas, pagando ",PTotal," c?ntimos, me quedan ",(D-PTotal)); .send(X,tell,pagar(PTotal)); -+dinero((D-PTotal)); -ordered(beer); +available(beer,fridge); .wait(1000); !go_at(myRobot,fridge).
@p__38[source(self),url("file:src/asl/myRobot.asl")] +stock(beer,0) : available(beer,fridge) <- -available(beer,fridge).
@p__39[source(self),url("file:src/asl/myRobot.asl")] +stock(beer,N) : ((N > 0) & not (available(beer,fridge))) <- -+available(beer,fridge).
@p__40[source(self),url("file:src/asl/myRobot.asl")] +?time(T) <- time.check(T).
@p__41[source(self),url("file:src/asl/myRobot.asl")] +dinero(X) : (X < 200) <- .println("Solo me quedan ",X," c?ntimos, pidiendo al owner."); .send(myOwner,achieve,darDinero(400)).
@p__42[source(self),url("file:src/asl/myRobot.asl")] +!recibirDinero(X) : dinero(D) <- .println("Recibidos ",X," c?ntimos del owner."); -+dinero((D+X)).
@p__43[source(self),url("file:src/asl/myRobot.asl")] +!save <- .println("Guardando en /src/asl/myRobot-saved.asl"); .save_agent("./src/asl/myRobot-saved.asl").


/* Initial beliefs and rules */

// initially, I believe that there is some beer in the fridge
available(beer,fridge).
mySupermarkets(super1).
mySupermarkets(super2).
mySupermarkets(super3).
dinero(0).

!save.

// my owner should not consume more than 10 beers a day :-)
limit(beer,5).

too_much(B) :-
   .date(YY,MM,DD) &
   .count(consumed(YY,MM,DD,_,_,_,B),QtdB) &
   limit(B,Limit) &
   QtdB > Limit.

// Check if bot answer requires a service
service(Answer, translating):- 			// Translating service
	checkTag("<translate>",Answer).
service(Answer, addingBot):- 			// Adding a bot property service
	checkTag("<botprop>",Answer).

	
// Checking a concrete service required by the bot ia as simple as find the required tag
// as a substring on the string given by the second parameter
checkTag(Service,String) :-
	.substring(Service,String).


// Gets into Val the first substring contained by a tag Tag into String
getValTag(Tag,String,Val) :- 
	.substring(Tag,String,Fst) &       // First: find the Fst Posicition of the tag string              
	.length(Tag,N) &                   // Second: calculate the length of the tag string
	.delete(0,Tag,RestTag) &     
	.concat("</",RestTag,EndTag) &     // Third: build the terminal of the tag string
	.substring(EndTag,String,End) &    // Four: find the Fst Position of the terminal tag string
	.substring(String,Val,Fst+N,End).  // Five: get the Val tagged
	
	/*
		Another way to get the value will consist to delete from String the prefix, sufix and tags
		in order to let only the required Val
	*/  


// Filter the answer to be showed when the service indicated as second arg is done
filter(Answer, translating, [To,Msg]):-
	getValTag("<to>",Answer,To) &
	getValTag("<msg>",Answer,Msg).
	
filter(Answer, addingBot, [ToWrite,Route]):-
	getValTag("<name>",Answer,Name) &
	getValTag("<val>",Answer,Val) &
	.concat(Name,":",Val,ToWrite) &
	bot(Bot) &
	.concat("/bots/",Bot,BotName) &
	.concat(BotName,"/config/properties.txt",Route).	

/* Initial goals */
!initBot.

!answerOwner.

!cleanHouse.

!bringBeer.

/* Plans */

+!initBot <-
	makeArtifact("BOT","bot.ChatBOT",["bot"],BOT);
	focus(BOT);
	+bot("bot").

+!answerOwner : msg(Msg)[source(Ag)] & bot(Bot) <-
	chatSincrono(Msg,Answer);
	//chat(Msg) // De manera as??ncrona devuelve una signal => answer(Answer)
	-msg(Msg)[source(Ag)];   
	.println("El agente ",Ag," ha dicho ",Msg);
	!doSomething(Answer,Ag);
	//.send(Ag,tell,answer(Answer));
	!answerOwner.
+!answerOwner <- !answerOwner.

+!doSomething(Answer,Ag) : service(Answer, Service) <-
	.println("Aqui debe ir el c??digo del servicio:", Service," para el agente ",Ag).
	
+!doSomething(Answer,Ag) : not service(Answer, Service) <-
	.println("Le contesto al ",Ag," ",Answer);
	.send(Ag,tell,answer(Answer)). //modificar adecuadamente

+!bring(myOwner, beer) [source(myOwner)] <-
	+asked(beer);
	!save.
	
+!bringBeer : healthMsg(_) <- 
	!go_at(myRobot,base);
	.println("El Robot descansa porque Owner ha bebido mucho hoy.").
+!bringBeer : asked(beer) & not healthMsg(_) <- 
	.println("Owner me ha pedido una cerveza.");
	!go_at(myRobot,fridge);
	!take(fridge,beer);
	!go_at(myRobot,myOwner);
	!hasBeer(myOwner);
	.println("Ya he servido la cerveza y elimino la petici??n.");
	.abolish(asked(Beer));
	!bringBeer.
+!bringBeer : not asked(beer) & not healthMsg(_) <- 
	.wait(2000);
	.println("Robot esperando la petici??n de Owner.");
	!bringBeer.

+!take(fridge, beer) : not too_much(beer) <-
	.println("El robot est?? cogiendo una cerveza.");
	!check(fridge, beer).
+!take(fridge,beer) : too_much(beer) & limit(beer, L) <-
	.concat("The Department of Health does not allow me to give you more than ", L," beers a day! I am very sorry about that!", M);
	-+healthMsg(M).
	
+!check(fridge, beer) : not ordered(beer) & available(beer,fridge) <-
	.println("El robot est?? en el frigor??fico y coge una cerveza.");
	.wait(1000);
	open(fridge);
	.println("El robot abre la nevera.");
	get(beer);
	.println("El robot coge una cerveza.");
	close(fridge);
	.println("El robot cierra la nevera.").
+!check(fridge, beer) : not ordered(beer) & not available(beer,fridge) <-
	.println("El robot est?? en el frigor??fico y hace un pedido de cerveza.");
	!comprobarStock;
	!check(fridge, beer).
+!check(fridge, beer) <-
	.println("El robot est?? esperando ................");
	.wait(5000);
	!check(fridge, beer).
	
+!comprobarStock <-
	.abolish(hayStock(_));
	.send(super1,askOne,hayStock(A));	//ver cu?les supermarkets tienen stock antes de elegir
	.send(super2,askOne,hayStock(B));
	.send(super3,askOne,hayStock(C));
	.wait(2000);
	!elegirSuper.
	
+!elegirSuper : not ordered(beer) & .findall(p(P,S),hayStock(P)[source(S)],L)
    //si el super tiene stock, P = precio, si no, P = "no" (los n?meros tienen prioridad en la funci?n .min)
 <- .min(L,p(Precio,Super));
    if(Precio = no){
	  !orderBeer(sinStock);
	} else {
	  .println("Decidido ", Super, " con precio de ", Precio);
	  !orderBeer(Super);
	}.
+!elegirSuper.

+!orderBeer(Supermarket) : not ordered(beer) & dinero(D) & hayStock(P)[source(Supermarket)] <-
	if (Supermarket == sinStock) {
		.println("Ning?n super tiene stock. Esperando...");
		.wait(5000);
		!comprobarStock;
	} else {
		if (D < P) {
			.println("No tengo dinero para comprar en ",Supermarket);
			.wait(5000);
		} else {
			.println("El robot realiza un pedido a ",Supermarket);
			!go_at(myRobot,delivery);
			.println("El robot va a la ZONA de ENTREGA.");
			.send(Supermarket, achieve, order(beer,3));
			+ordered(beer);
		}
	}
	!save.
+!orderBeer(Supermarket).

+!hasBeer(myOwner) : not too_much(beer) <-
	hand_in(beer);
	.println("He preguntado si Owner ha cogido la cerveza.");
	?has(myOwner,beer);
	.println("Se que Owner tiene la cerveza.");
	// remember that another beer has been consumed
	.date(YY,MM,DD); .time(HH,NN,SS);
	+consumed(YY,MM,DD,HH,NN,SS,beer);
	!save.
+!hasBeer(myOwner) : too_much(beer) & healthMsg(M) <- 
	//.abolish(msg(_));
	.send(myOwner,tell,msg(M)).

+!go_at(myRobot,P) : at(myRobot,P) <- true.
+!go_at(myRobot,P) : not at(myRobot,P)
  <- move_towards(P);
     !go_at(myRobot,P).

// when the supermarket makes a delivery, try the 'has' goal again
+delivered(beer,Qtd,OrderId)[source(X)] : mySupermarkets(X) & hayStock(P)[source(X)] & dinero(D) <- 
	PTotal=P*Qtd;
	.println("Ha llegado mi pedido de ",Qtd," cervezas, pagando ",PTotal," c?ntimos, me quedan ",D-PTotal);
	.send(X, tell, pagar(PTotal));
	-+dinero(D-PTotal);
	-ordered(beer);
	+available(beer,fridge);
	.wait(1000);
	!go_at(myRobot,fridge);
	!save.

// when the fridge is opened, the beer stock is perceived
// and thus the available belief is updated
+stock(beer,0) :  available(beer,fridge) <-
	-available(beer,fridge);
	!save.
+stock(beer,N) :  N > 0 & not available(beer,fridge) <-
	-+available(beer,fridge);
	!save.
	
// Cuando la basura este llena el agente myRoomba lo vacia	
+!cleanHouse : trashcan(full) <- 
	.send(myRoomba, tell, trashcan(full));
	.send(myRoomba, achieve, emptyTrashcan);
	.send(myRoomba, untell, trashcan(full));
	-trashcan(full);
	!cleanHouse.

+!cleanHouse: canatfloor(can) <- 
	!go_at(myRobot,can);
	pickup(can);
	.println("Se ha recogido una lata del suelo");
	-canatfloor(can);
	!go_at(myRobot,trashCan);
	dropdown(can);
	.println("Se ha tirado la lata a la basura");

	!cleanHouse.

+!cleanHouse <- !cleanHouse.

+?time(T) : true
  <-  time.check(T).

+dinero(X) : X<200
  <-  .println("Solo me quedan ",X," c?ntimos, pidiendo al owner.");
	  .send(myOwner, achieve, darDinero(400)).
	  
+!recibirDinero(X) : dinero(D)
  <-  .println("Recibidos ",X," c?ntimos del owner.");
  	  -+dinero(D+X);
	  !save.
	  
+!save <-
	.println("Guardando en ./src/asl/myRobot-saved.asl");
	.save_agent("./src/asl/myRobot-saved.asl").

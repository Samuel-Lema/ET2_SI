// Agent mySupermarket in project DomesticRobot.mas2j

/* Initial beliefs and rules */
// Identificador de la ?ltima orden entregada
last_order_id(1).
hayStock(no).

/* Initial goals */
!crearGestor.
!decirPrecio.
!deliverBeer.

/* Plans */
+!crearGestor : gestor(G) & .my_name(N) & dinero(D) & precio(P) & precioTransporte(T) & dir(Dir) <-
	.println("Creando gestor.");
	.create_agent(G,"gestor.asl"); //para usar las creencias iniciales
	//.create_agent(G,Dir); //para usar persistencia
	.abolish(dinero(_));
	.abolish(precio(_));
	.abolish(precioTransporte(_));
	.abolish(dir(_));
	.send(G, tell, supermarket(N));
	.send(G, achieve, cambiarDinero(D));
	.send(G, tell,precio(P));
	.send(G, tell,precioTransporte(T));
	.send(G, tell,dir(Dir));
	.send(G, achieve, save).
	
+!decirPrecio : precio(X) <-
	.send(myRobot, tell, precio(X)). //c?ntimos

+!deliverBeer : last_order_id(N) & tiempoEntrega(E) & orderFrom(Ag, Qtd) <-
	OrderId = N+1;
    -+last_order_id(OrderId);
	.println("Tiempo estimado de entrega: ", E/1000, " segundos.");
	.wait(E);
    deliver(Product,Qtd);
    .send(Ag, tell, delivered(Product, Qtd, OrderId));
	.abolish(orderFrom(Ag, Qtd));
	!deliverBeer.
	
+!deliverBeer <- !deliverBeer.
	
// plan to achieve the goal "order" for agent Ag
+!order(beer, Qtd)[source(Ag)] : gestor(G) <-
	.println("Pedido de ", Qtd, " cervezas recibido de ", Ag);
	.send(G, tell, processOrderFrom(Ag, Qtd)). //despu?s de esto, llegar? un orderFrom desde el gestor
	
+pagar(X)[source(myRobot)] : gestor(G) <-
	.send(G, tell, pagar(X));
	.abolish(pagar(_)).
	
+auction(N)[source(S)] : dinero(D) & default_bid_value(B)
   <- if(hayStock(no) & D > B){
   	  	?default_bid_value(B);
		.send(S, tell, place_bid(N,B));
	  } else{
	    .send(S, tell, place_bid(N,0));
	  }.
	  
+winner(I) : .my_name(I) & default_bid_value(P) & gestor(G)
   <- .abolish(winner(_));
	  .abolish(dinero(_));
      .send(G, achieve, prepRestock(P)).

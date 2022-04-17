import jason.environment.grid.GridWorldModel;
import jason.environment.grid.Location;
import jason.environment.grid.Area;
import java.io.*;
import java.util.*;

/** class that implements the Model of Domestic Robot application */
public class MyHouseModel extends GridWorldModel {

    // constants for the grid objects
    public static final int FRIDGE 		= 16;
    public static final int OWNER  		= 32;
    public static final int DELIVERY  	= 64;
	public static final int CAN  		= 128;
	public static final int TRASHCAN 	= 256;

    // the grid size
    public static final int GSize = 11;

    boolean fridgeOpen   = false; // whether the fridge is open
    boolean carryingBeer = false; // whether the robot is carrying beer
    int sipCount        = 0; // how many sip the owner did
    int availableBeers  = 3; // how many beers are available
	int trashCanCount = 0; // Contador de basura de la papelera
	int trashThrowed = 0;

	Stack<Location> stack = new Stack<Location>();

    Location lFridge = new Location(0,0);
    Location lOwner  = new Location(GSize-1, GSize-1); 
    Location lDelivery  = new Location(0, GSize-1); 
	Location lRobot = new Location(GSize/2, GSize/2);
	Location lTrashCan = new Location(GSize-1,0);
	Location lCan;
	
	Area aFridge = new Area(0,0,1,1);
	Area aTrashCan = new Area(9,0,10,1);
	Area aOwner = new Area(9,9,10,10);
	
	boolean atFridge = false;
	boolean atOwner = false;
	boolean atDelivery = false;
	boolean atBase = false;
	boolean atTrashCan = false;
	boolean atCan = false;

    public MyHouseModel() {
        // create a 7x7 grid with one mobile agent
        super(GSize, GSize, 1);

        // Base location of robot
        setAgPos(0, lRobot);

        // initial location of fridge and owner
        add(FRIDGE, lFridge);
        add(OWNER, lOwner);
		add(DELIVERY, lDelivery);
		add(TRASHCAN, lTrashCan);
    }
	
    boolean openFridge() {
        if (!fridgeOpen) {
            fridgeOpen = true;
            return true;
        } else {
            return false;
        }
    }

    boolean closeFridge() {
        if (fridgeOpen) {
            fridgeOpen = false;
            return true;
        } else {
            return false;
        }
    }
	
    boolean moveTowards(Location dest) {
        Location r1 = getAgPos(0);
        if (r1.x < dest.x)        r1.x++;
        else if (r1.x > dest.x)   r1.x--;                                                
        if (r1.y < dest.y)        r1.y++;
        else if (r1.y > dest.y)   r1.y--;
		
        setAgPos(0, r1); // move the robot in the grid

		atOwner = r1.isInArea(aOwner);
		atFridge = r1.isInArea(aFridge);
		atTrashCan = r1.isInArea(aTrashCan);
		atCan = r1.equals(lCan);
		atDelivery = r1.equals(lDelivery);
		atBase = r1.equals(lRobot);

        // repaint the fridge and owner locations
        if (view != null) {
            view.update(lFridge.x,lFridge.y);
            view.update(lOwner.x,lOwner.y);
            view.update(lDelivery.x,lDelivery.y);
        }
        return true;
    }

    boolean getBeer() {
        if (fridgeOpen && availableBeers > 0 && !carryingBeer) {
            availableBeers--;
            carryingBeer = true;
            if (view != null)
                view.update(lFridge.x,lFridge.y);
            return true;
        } else {
            return false;
        }
    }

    boolean addBeer(int n) {
        availableBeers += n;
        if (view != null)
            view.update(lFridge.x,lFridge.y);
        return true;
    }

    boolean handInBeer() {
        if (carryingBeer) {
            sipCount = 10;
            carryingBeer = false;
            if (view != null)
                view.update(lOwner.x,lOwner.y);
            return true;
        } else {
            return false;
        }
    }

    boolean sipBeer() {
        if (sipCount > 0) {
            sipCount--;
            if (view != null)
                view.update(lOwner.x,lOwner.y);
            return true;
        } else {
            return false;
        }
    }
	
		boolean throwBeer(){

		Random r1 = new Random();
		Random r2 = new Random();

		lCan  = new Location(9 - (r1.nextInt(2) + 1) , 7 - (r2.nextInt(2)+1));
		add(CAN, lCan);

		stack.push(lCan);
		trashThrowed++;

		return true;
	}

	boolean pickUpCan(){

		Location lCan = stack.pop();

		if(lCan != null){

			remove(CAN, lCan);
			return true;
		}

		return false;
	}

	boolean dropDownCan(){

		trashCanCount++;
		trashThrowed--;
		return true;
	}

	boolean emptyTrashCan(){

		if(trashCanCount == 3){
			trashCanCount = 0;
		}

		if (view != null){
            view.update(lTrashCan.x, lTrashCan.y);
		}

		 return true;
	}
}

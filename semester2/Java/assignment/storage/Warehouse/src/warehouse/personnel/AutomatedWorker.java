package warehouse.personnel;

import java.util.LinkedList;
import warehouse.StorageSector;

/**
 * Minden raktári robot absztrakt ősosztálya.
 * Kezeli a robot alapvető tulajdonságait és a hozzárendelt szektorokat.
 */
public abstract class AutomatedWorker {
    protected String name;
    protected int batteryLevel;
    protected LinkedList<StorageSector<?>> assignedSectors = new LinkedList<>();

    /**
     * Létrehoz egy automatizált munkást (robotot).
     *
     * @param name A robot azonosítója/neve.
     * @param batteryLevel A robot kezdő töltöttségi szintje (0-100).
     */
    public AutomatedWorker(String name, int batteryLevel) {
        this.name = name;
        this.batteryLevel = batteryLevel;
    }

    public int getAssignedSectorsCount(){
        return assignedSectors.size();
    }

    /**
     * Hozzárendel egy új szektort a robothoz.
     * Egy robot legfeljebb 5 szektort felügyelhet egyszerre.
     *
     * @param sector A hozzárendelendő szektor.
     */
    protected void addSector(StorageSector<?> sector){
        if(assignedSectors.size() >= 5){
            return;
        }
        assignedSectors.add(sector);
    }

    /**
     * Elvesz egy felügyelt szektort a robottól.
     *
     * @param sector Az elveendő szektor.
     */
    protected void removeSector(StorageSector<?> sector){
        if(!assignedSectors.contains(sector)){
            return;
        }
        assignedSectors.remove(sector);
    }

    public String getName(){ return name; }
    public int getBatteryLevel(){ return batteryLevel; }
}

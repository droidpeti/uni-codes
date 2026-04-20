package warehouse;

import java.util.ArrayList;
import java.util.List;

/**
 * A tárolószektort reprezentáló generikus osztály.
 * * @param <T> A szektorban tárolható rakomány típusa, amely a Cargo osztályból kell származzon.
 */
public class StorageSector<T extends Cargo> {
    private final String id;
    private SectorState state;
    private int maxCapacity;
    private int currentWeight = 0;
    private List<T> list;

    public String getId(){ return id; }
    public SectorState getState(){ return state; }
    public void setState(SectorState stateToSet){ state = stateToSet; }
    public int getMaxCapacity(){ return maxCapacity; }
    public int getCurrentWeight(){ return currentWeight; }

    private void updateWeight(int weightDifference){
        currentWeight += weightDifference; 
    }

    /**
     * Létrehoz egy új tárolószektort a megadott azonosítóval és kapacitással.
     * A szektor kezdeti állapota EMPTY.
     *
     * @param id A szektor egyedi azonosítója.
     * @param maxCapacity A szektor maximális teherbírása kilogrammban.
     */
    public StorageSector(String id, int maxCapacity) {
        list = new ArrayList<>();
        this.id = id;
        this.maxCapacity = maxCapacity;
        state = SectorState.EMPTY;
    }

    /**
     * Hozzáad egy rakományt a szektorhoz, amennyiben az nem lépi túl a maximális kapacitást.
     *
     * @param item A hozzáadandó rakomány.
     */
    public void addCargo(T item){
        if(currentWeight + item.getWeight() > maxCapacity){
            return;
        }
        list.add(item);
        updateWeight(item.getWeight());
    }

    /**
     * Kivesz egy rakományt a szektorból és frissíti a jelenlegi terhelést.
     *
     * @param item A kivételre szánt rakomány.
     */
    public void removeCargo(T item){
        updateWeight(-item.getWeight());
        list.remove(item);
    }

    @Override
    public int hashCode() {
        return id.hashCode() * 31;
    }

    /**
     * Két szektort akkor tekintünk egyenlőnek, ha az azonosítójuk (id) megegyezik.
     */
    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        return this.id.equals(((StorageSector<?>) obj).id);
    }

    /**
     * Elkészíti a szektor leltárát.
     * Végigiterál a rakományokon és szöveges formában visszaadja azokat, 
     * kiegészítve a szektor jelenlegi és maximális kapacitásával.
     *
     * @return A szektor leltárának szöveges reprezentációja.
     */
    public String printInventory(){
        StringBuilder text = new StringBuilder();
        for(T item : list){
            text.append(item.toString()).append(System.lineSeparator());
        }
        text.append("Össztömeg: ").append(currentWeight).append(" / ").append(maxCapacity).append(" kg"); 
        return text.toString();
    }
}

package warehouse.personnel;

import warehouse.Cargo;
import warehouse.StorageSector;
import warehouse.util.UnsuitableCargoException;

/**
 * A raktári robotok közös viselkedését definiáló interfész.
 */
public interface WarehouseRobot {
    /**
     * Eldönti, hogy a robot fel tudja-e emelni a megadott rakományt.
     *
     * @param cargo A vizsgálandó rakomány.
     * @return Igaz, ha a robot fel tudja emelni, egyébként hamis.
     */
    public boolean canLift(Cargo cargo);

    /**
     * Elhelyezi a rakományt a megadott tárolószektorban.
     *
     * @param cargo A mozgatandó rakomány.
     * @param sector A cél szektor, ahova a rakományt helyezzük.
     * @throws UnsuitableCargoException Ha a robot nem bírja el a rakományt.
     */
    public void moveCargo(Cargo cargo, StorageSector<?> sector) throws UnsuitableCargoException;

    /**
     * Visszaadja a robot által karbantartott (felügyelt) szektorok számát.
     *
     * @return A hozzárendelt szektorok száma.
     */
    public int getAssignedSectorsCount();
}

package warehouse.personnel;

import warehouse.Cargo;
import warehouse.CargoState;
import warehouse.SectorState;
import warehouse.StorageSector;
import warehouse.util.UnsuitableCargoException;

/**
 * Nehézrakodó mech (robot), amely rendkívül erős, bármilyen súlyt képes felemelni, 
 * de sok áramot fogyaszt.
 */
public class HeavyLifterMech extends AutomatedWorker implements WarehouseRobot {

    /**
     * Létrehoz egy új nehézrakodó mechet.
     *
     * @param name A mech azonosítója.
     * @param batteryLevel A mech akkumulátorszintje.
     */
    public HeavyLifterMech(String name, int batteryLevel) {
        super(name, batteryLevel);
    }

    @Override
    public boolean canLift(Cargo cargo) {
        return true;
    }

    @SuppressWarnings("unchecked")
    @Override
    public void moveCargo(Cargo cargo, StorageSector<?> sector) throws UnsuitableCargoException {
        ((StorageSector<Cargo>)sector).addCargo(cargo);
        cargo.setState(CargoState.STORED);
        batteryLevel -= 15;
    }

    /**
     * Karbantartást végez a megadott szektoron, átállítva annak állapotát.
     *
     * @param sector A karbantartandó szektor.
     */
    public void performMaintenance(StorageSector<?> sector){
        sector.setState(SectorState.MAINTENANCE);
    }
}

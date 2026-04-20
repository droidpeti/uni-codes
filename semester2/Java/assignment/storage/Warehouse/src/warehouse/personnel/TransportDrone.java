package warehouse.personnel;

import warehouse.Cargo;
import warehouse.CargoState;
import warehouse.StorageSector;
import warehouse.util.UnsuitableCargoException;

/**
 * Szállító drón, amely mozgékony, de csak kis teherbírású (20 kg alatti) rakományok mozgatására képes.
 */
public class TransportDrone extends AutomatedWorker implements WarehouseRobot {

    /**
     * Létrehoz egy új szállító drónt.
     *
     * @param name A drón azonosítója.
     * @param batteryLevel A drón akkumulátorszintje.
     */
    public TransportDrone(String name, int batteryLevel) {
        super(name, batteryLevel);
    }

    @Override
    public boolean canLift(Cargo cargo) {
        return cargo.getWeight() < 20;
    }

    @SuppressWarnings("unchecked")
    @Override
    public void moveCargo(Cargo cargo, StorageSector<?> sector) throws UnsuitableCargoException {
        if(!canLift(cargo)){
            throw new UnsuitableCargoException();
        }
        ((StorageSector<Cargo>)sector).addCargo(cargo);
        cargo.setState(CargoState.STORED);
        batteryLevel -= 5;
    }
}

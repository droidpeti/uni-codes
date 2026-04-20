import warehouse.*;
import warehouse.personnel.*;
import warehouse.util.UnsuitableCargoException;

public class Main {
    public static void main(String[] args) {
        System.out.println("--- Okos Raktárközpont Szimuláció Indítása ---\n");
        LogisticsCenter center = new LogisticsCenter();
        // 1. Szektorok létrehozása
        StorageSector<Cargo> generalSector = new StorageSector<>("SEC-GEN-01", 500);
        StorageSector<FragileCargo> fragileSector = new StorageSector<>("SEC-FRAG-01", 100);

        center.getSectors().put(generalSector.getId(), generalSector);
        center.getSectors().put(fragileSector.getId(), fragileSector);
        // 2. Robotok létrehozása
        TransportDrone drone = new TransportDrone("SwiftFly-01", 100);
        HeavyLifterMech mech = new HeavyLifterMech("Titan-01", 100);
        center.getRobots().add(drone);
        center.getRobots().add(mech);
        // 3. Rakományok létrehozása
        FragileCargo glass = new FragileCargo("Üvegkészlet", 200, 15); // 15 kg
        HeavyCargo engine = new HeavyCargo("Hajómotor", 5000, 450); // 450 kg
        // 4. Szimuláció: Mozgatás
        System.out.println("Szimuláció: Drón próbálkozik a nehéz motorral...");
        try {
            drone.moveCargo(engine, generalSector);
        } catch (UnsuitableCargoException e) {
            System.err.println("Hiba: " + e.getMessage());
        }
        System.out.println("\nSzimuláció: Mech elhelyezi a motort...");
        try {
            mech.moveCargo(engine, generalSector);
            System.out.println("Sikeres mozgatás!");
        } catch (UnsuitableCargoException e) {
            System.err.println("Hiba történt!");
        }
            System.out.println("\nSzimuláció: Drón elhelyezi az üveget...");
        try {
            drone.moveCargo(glass, fragileSector);
            System.out.println("Sikeres mozgatás!");
        } catch (UnsuitableCargoException e) {
            System.err.println("Hiba történt!");
        }
        // 5. Leltár nyomtatása
        System.out.println("\n--- RAKTÁR LELTÁR ---");
        System.out.println(generalSector.printInventory());
        System.out.println(fragileSector.printInventory());
        System.out.println("\nRobotok állapota:");
        for (WarehouseRobot robot : center.getRobots()){
            AutomatedWorker worker = (AutomatedWorker) robot;
            System.out.println(worker.getName() + " töltöttsége: " + worker.getBatteryLevel() + "%");
        }
    }
}

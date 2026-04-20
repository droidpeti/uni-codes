package warehouse;

import java.util.Map;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import warehouse.personnel.WarehouseRobot;

/**
 * A logisztikai központot reprezentáló osztály, amely a szimulációt végzi.
 * Tárolja a szektorokat és a robotokat.
 */
public class LogisticsCenter {
    private final Map<String, StorageSector<?>> sectors;
    private final List<WarehouseRobot> robots;

    public Map<String, StorageSector<?>> getSectors(){ return sectors; }
    public List<WarehouseRobot> getRobots(){ return robots; }

    /**
     * Inicializálja a logisztikai központot üres adatszerkezetekkel.
     */
    public LogisticsCenter() {
        sectors = new HashMap<String, StorageSector<?>>();
        robots = new ArrayList<WarehouseRobot>();
    }
}

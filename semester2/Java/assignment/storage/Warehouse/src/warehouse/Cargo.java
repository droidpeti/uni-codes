package warehouse;

/**
 * Absztrakt ősosztály a raktárban tárolt rakományok reprezentálására.
 * Megvalósítja a Comparable interfészt a rakományok súly szerinti összehasonlításához.
 */
public abstract class Cargo implements Comparable<Cargo>{
    protected int baseValue;
    protected int weight;
    protected CargoState state;
    protected String name;

    /** A logisztikai adó mértéke százalékban. */
    public static final int LOGISTICS_TAX = 10;

    /**
     * Védett konstruktor a rakomány alapvető adatainak beállítására.
     * Az állapot alapértelmezetten IN_TRANSIT lesz.
     *
     * @param name A rakomány neve.
     * @param baseValue A rakomány alapértéke.
     * @param weight A rakomány súlya kilogrammban.
     */
    protected Cargo(String name, int baseValue, int weight){
        this.baseValue = baseValue;
        this.weight = weight;
        state = CargoState.IN_TRANSIT;
        this.name = name;
    }

    public int getBaseValue(){ return baseValue; }
    public int getWeight(){ return weight; }
    public CargoState getState(){ return state; }
    public String getName(){ return name; }

    /**
     * Összehasonlítja ezt a rakományt egy másikkal a súlyuk alapján.
     * A nehezebb rakomány számít "nagyobbnak".
     *
     * @param cargo A másik rakomány, amivel összehasonlítjuk.
     * @return Negatív szám, ha ez a rakomány könnyebb; pozitív, ha nehezebb; 0, ha egyenlőek.
     */
    @Override
    public int compareTo(Cargo cargo) {
        if(cargo.getWeight() > weight){
            return -1;
        }
        else if(cargo.getWeight() < weight){
            return 1;
        }
        return 0;
    }

    /**
     * Kiszámolja a rakomány végső értékét a specifikus szabályok alapján.
     *
     * @return A rakomány végső értéke EUR-ban.
     */
    public abstract int calculateFinalValue();

    @Override
    public String toString() {
        return name + " [Súly: " + weight + " kg]: " + calculateFinalValue() + " EUR";
    }

    /**
     * Beállítja a rakomány új állapotát a megadott szabályrendszer szerint.
     * Illegális állapotváltás esetén az állapot nem változik.
     *
     * @param state Az új beállítandó állapot.
     */
    public void setState(CargoState state){
        if(this.state == CargoState.IN_TRANSIT && state == CargoState.PROCESSING){
            this.state = CargoState.PROCESSING;
        }
        else if(this.state == CargoState.PROCESSING && state == CargoState.STORED){
            this.state = CargoState.STORED;
        }
        else if(this.state == CargoState.STORED && state == CargoState.DELIVERED){
            this.state = CargoState.DELIVERED;
        }
        else if(state == CargoState.DAMAGED){
            this.state = CargoState.DAMAGED;
        }
    }
}

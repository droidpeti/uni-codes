package warehouse;

/**
 * Törékeny árukat reprezentáló osztály.
 * Extra törékenységi biztosítási díjat számol fel a végső értékhez.
 */
public class FragileCargo extends Cargo {
    @Override
    public int calculateFinalValue() {
        return (int)(baseValue * (LOGISTICS_TAX + 100) / 100 + (baseValue * 0.15));
    }

    public FragileCargo(String name, int baseValue, int weight){
        super(name, baseValue, weight);
    }
}

package warehouse;

/**
 * Nehézgépeket és nagy súlyú árukat reprezentáló osztály.
 * Súlyalapú plusz mozgatási díjat számol fel a végső értékhez.
 */
public class HeavyCargo extends Cargo {

    @Override
    public int calculateFinalValue() {
        return baseValue * (LOGISTICS_TAX + 100) / 100 + (weight * 5);
    }

    public HeavyCargo(String name, int baseValue, int weight){
        super(name, baseValue, weight);
    }
}

/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 03/09/2018
 * @description For measuring governor limit usage, each subclass represents a particular limit to measure
 */
global abstract class LimitDatum {

    global Long headroom;
    global Long costPerIteration {global get; private set;}
    global Long lastMeasure {global get; private set;}

    global abstract Long getCurrentValue();

    global abstract Long getLimitValue();

    global abstract String getName();

    public LimitDatum(Long headroom) {
        this.headroom = headroom;
        this.costPerIteration = 0;
        this.lastMeasure = 0;
    }

    public void updateValue() {
        Long currentValue = getCurrentValue();
        costPerIteration = Math.max(costPerIteration, currentValue - lastMeasure);
        lastMeasure = currentValue;
    }

    public Boolean withinLimit() {
        return lastMeasure <= getLimitValue() - costPerIteration - headroom;
    }

    public void clear() {
        costPerIteration = 0;
        lastMeasure = getCurrentValue();
    }

    public void sumHeadroom(LimitDatum other) {
        headroom = headroom + other.headroom;
    }
}
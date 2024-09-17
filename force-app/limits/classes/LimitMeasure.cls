/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 06/08/2018
 * @description Checks governor limits so that we can, for example, see if we have enough allowance to do another
 * iteration in a Queueable, or we need to break and and requeue to start a fresh transaction
 *
 */
global class LimitMeasure {

    global class CalloutLimitDatum extends LimitDatum {
        global CalloutLimitDatum(Long headroom) {
            super(headroom);
        }
        public override Long getCurrentValue() {
            return Limits.getCallouts();
        }
        public override Long getLimitValue() {
            return Limits.getLimitCallouts();
        }
        public override String getName() {
            return CalloutLimitDatum.class.getName();
        }
    }

    global class DmlStatementsLimitDatum extends LimitDatum {
        global DmlStatementsLimitDatum(Long headroom) {
            super(headroom);
        }
        public override Long getCurrentValue() {
            return Limits.getDmlStatements();
        }
        public override Long getLimitValue() {
            return Limits.getLimitDmlStatements();
        }
        public override String getName() {
            return DmlStatementsLimitDatum.class.getName();
        }
    }

    global class SoqlQueriesLimitDatum extends LimitDatum {
        global SoqlQueriesLimitDatum(Long headroom) {
            super(headroom);
        }
        public override Long getCurrentValue() {
            return Limits.getQueries();
        }
        public override Long getLimitValue() {
            return Limits.getLimitQueries();
        }
        public override String getName() {
            return SoqlQueriesLimitDatum.class.getName();
        }
    }

    global class CpuTimeLimitDatum extends LimitDatum {
        global CpuTimeLimitDatum(Long headroom) {
            super(headroom);
        }
        public override Long getCurrentValue() {
            return Limits.getCpuTime();
        }
        public override Long getLimitValue() {
            return Limits.getLimitCpuTime();
        }
        public override String getName() {
            return CpuTimeLimitDatum.class.getName();
        }
    }

    private Map<String, LimitDatum> limitData;

    global LimitMeasure(List<LimitDatum> limitData) {
        this.limitData = new Map<String, LimitDatum>();
        for(LimitDatum thisLimitDatum : limitData) {
            this.limitData.put(thisLimitDatum.getName(), thisLimitDatum);
        }
        clear();
    }

    global void sumLimits(LimitMeasure other) {
        for(String thisLimitType : other.limitData.keySet()) {
            LimitDatum otherLimitDatum = other.limitData.get(thisLimitType);
            LimitDatum thisLimitDatum = limitData.get(thisLimitType);
            if(thisLimitDatum == null) {
                limitData.put(thisLimitType, otherLimitDatum);
            } else {
                thisLimitDatum.sumHeadroom(otherLimitDatum);
            }
        }
    }

    global Boolean hasEnoughForAnotherIteration() {
        for(LimitDatum thisLimitDatum : limitData.values()) {
            thisLimitDatum.updateValue();
            if(!thisLimitDatum.withinLimit()) {
                return false;
            }
        }
        return true;
    }

    global void clear() {
        for(LimitDatum thisLimitDatum : limitData.values()) {
            thisLimitDatum.clear();
        }
    }
}
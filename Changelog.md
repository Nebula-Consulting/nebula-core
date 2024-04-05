# Nebula Core

 0.81.0-1
------------
 - [General] **DeployableMetadataFromSObject** is now namespace accessible
 - ---
 - [LazyIterator] **IsLessThan**, **IsEqual** and **IsGreater** than now support passing in fields for both left and right parameters, e.g. new nebc.IsGreaterThan(Event.ActivityDate, Event.RecurrenceEndDateOnly)
 - ---
 - [LazyIterator] new **filterFieldBecameEqual** and **filterFieldBecameNotEqual** to simplify:
   - nebc.filterBecameTrue(new nebc.IsSObjectFieldEqual(Opportunity.IsWon, true)) to 
   - nebc.filterFieldBecameEqual(Opportunity.IsWon, true)
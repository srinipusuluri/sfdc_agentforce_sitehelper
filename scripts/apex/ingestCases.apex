Map<String,Id> acc = new Map<String,Id>();
for (Account a : [SELECT Id, Name FROM Account WHERE Name IN ('Edge Communications','Burlington Textiles Corp of America','Pyramid Construction Inc.','Dickenson plc','Grand Hotels & Resorts Ltd','United Oil & Gas Corp.','Express Logistics and Transport','University of Arizona')]) acc.put(a.Name, a.Id);
List<List<String>> rows = new List<List<String>>{
 new List<String>{'Edge Communications','Generator fails to start after power outage','High','Breakdown','Electrical','Phone'},
 new List<String>{'Burlington Textiles Corp of America','Unusual vibration from rotor during peak load','High','Performance','Mechanical','Email'},
 new List<String>{'Pyramid Construction Inc.','Request for GC5060 wiring diagram','Medium','Installation','Electrical','Web'},
 new List<String>{'Dickenson plc','Control panel display flickers intermittently','Medium','Equipment Complexity','Electronic','Phone'},
 new List<String>{'Grand Hotels & Resorts Ltd','Backup generator overheating after 2 hours','High','Breakdown','Mechanical','Phone'},
 new List<String>{'United Oil & Gas Corp.','Question about scheduled maintenance intervals','Low','Other','Other','Web'},
 new List<String>{'Express Logistics and Transport','Warranty coverage for replaced alternator','Medium','Feedback','Other','Email'},
 new List<String>{'University of Arizona','Fuel line corrosion found during inspection','High','Equipment Design','Structural','Email'},
 new List<String>{'Edge Communications','Need replacement air filter part numbers','Low','Other','Other','Web'},
 new List<String>{'Pyramid Construction Inc.','Noise level higher than specification','Medium','Performance','Mechanical','Phone'}
};
List<Case> cs = new List<Case>();
for (List<String> r : rows) {
  cs.add(new Case(AccountId=acc.get(r[0]), Subject=r[1], Priority=r[2], Reason=r[3], Type=r[4], Origin=r[5], Status='New', Description='Sample ingested case: ' + r[1]));
}
insert cs;
System.debug('Inserted ' + cs.size());

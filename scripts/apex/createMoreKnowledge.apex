// Nine more sample public Knowledge articles. Run once: a second run fails on the duplicate URL names.
// Sample content for demos only. It is not engineering guidance for real equipment.
List<Map<String,String>> arts = new List<Map<String,String>>{
  new Map<String,String>{'t'=>'Generator Fails to Start After a Power Outage: Quick Checks','u'=>'generator-wont-start','s'=>'Work through these checks before you call support.',
    'b'=>'<h2>Check in this order</h2><ol><li><b>Fuel:</b> confirm there is fuel and the shut-off valve is open.</li><li><b>Battery:</b> check the connections and charge. A weak battery is the most common cause.</li><li><b>Transfer switch:</b> make sure it is in the correct position for automatic mode.</li><li><b>Controller:</b> look for fault codes and note them down.</li></ol><p>If it still will not start, open a case with the model, serial number and any fault codes.</p>'},
  new Map<String,String>{'t'=>'Backup Generator Overheating: Causes and What to Do','u'=>'generator-overheating','s'=>'Why a generator overheats under load and how to respond safely.',
    'b'=>'<h2>Immediate steps</h2><p>Reduce the load, let the unit run without load for a few minutes, then shut it down and let it cool before opening any panel.</p><h2>Common causes</h2><ul><li>Blocked air intake or exhaust</li><li>Low coolant or oil</li><li>A dirty radiator or air filter</li><li>Running above rated load for long periods</li></ul><p>If it overheats again after these checks, stop using it and contact support.</p>'},
  new Map<String,String>{'t'=>'Fuel Line Corrosion: Inspection and Prevention','u'=>'fuel-line-corrosion','s'=>'How to spot corrosion early and reduce the risk.',
    'b'=>'<h2>What to look for</h2><ul><li>Rust or white powder on fittings</li><li>Damp spots or fuel smell near lines</li><li>Stiff, cracked or swollen hoses</li></ul><h2>Prevention</h2><p>Inspect the lines at every scheduled service, keep the enclosure dry and ventilated, and replace any line that shows damage. Do not run a unit with a leaking fuel line.</p>'},
  new Map<String,String>{'t'=>'Control Panel Display Flickers: Quick Checks','u'=>'panel-display-flicker','s'=>'Simple checks for an unstable control panel display.',
    'b'=>'<ol><li>Check the battery voltage and terminal connections.</li><li>Look for loose or corroded connectors behind the panel.</li><li>Note whether the flicker happens only under load.</li><li>Record any fault codes shown before the flicker starts.</li></ol><p>Share what you find when you open a case. It shortens the time to a fix.</p>'},
  new Map<String,String>{'t'=>'Finding the Right Replacement Air Filter','u'=>'replacement-air-filter','s'=>'How to identify the correct filter for your generator.',
    'b'=>'<p>Filters differ by model, so always order using your model and serial number, not by size alone.</p><ol><li>Find the nameplate on the unit and note the model and serial number.</li><li>Check the parts list for your model for the air filter listing.</li><li>Contact support with those details if you cannot find it.</li></ol><p>Replace the filter at the interval in your maintenance schedule, or sooner in dusty conditions.</p>'},
  new Map<String,String>{'t'=>'Reducing Generator Noise: Placement and Maintenance','u'=>'reducing-generator-noise','s'=>'Why noise rises above the stated level and what helps.',
    'b'=>'<h2>Common reasons</h2><ul><li>Loose panels or mounting bolts that rattle</li><li>A worn or damaged muffler</li><li>Placement against hard, reflective walls</li><li>Worn bearings or an imbalanced rotor</li></ul><p>Tighten fixings, inspect the exhaust, and leave clear space around the unit. If the noise is still above the specification, open a case and describe when it occurs.</p>'},
  new Map<String,String>{'t'=>'Safe Shutdown Procedure','u'=>'safe-shutdown','s'=>'The correct order for stopping a generator.',
    'b'=>'<ol><li>Remove the load or switch the transfer switch to the utility supply.</li><li>Let the unit run without load for a few minutes to cool down.</li><li>Switch the controller to off and wait for the engine to stop.</li><li>Close the fuel valve if the unit will be idle for a long time.</li></ol><p>Stopping a heavily loaded unit abruptly can stress the motor and the alternator.</p>'},
  new Map<String,String>{'t'=>'First-Time Startup Checklist','u'=>'first-time-startup','s'=>'What to check before and during the first run.',
    'b'=>'<h2>Before starting</h2><ul><li>Confirm oil, coolant and fuel levels.</li><li>Check all electrical connections against the wiring guide.</li><li>Make sure the area is ventilated and clear.</li></ul><h2>First run</h2><p>Run without load first and watch for unusual noise, smell or vibration. Add load in steps. Record the readings and keep them for your first service.</p>'},
  new Map<String,String>{'t'=>'Alternator Replacement and Warranty: What Is Covered','u'=>'alternator-replacement-warranty','s'=>'How a replaced alternator is treated under the warranty.',
    'b'=>'<p>A replacement alternator fitted by an authorised technician is normally covered for the remainder of the original equipment warranty. Fitting by anyone else, or skipping scheduled maintenance, can affect cover.</p><p>Keep the service record and the replacement paperwork. Contact support with your model and serial number to confirm what applies to your unit.</p>'}
};
List<Knowledge__kav> recs = new List<Knowledge__kav>();
for (Map<String,String> a : arts) {
  recs.add(new Knowledge__kav(Title=a.get('t'), UrlName=a.get('u'), Summary=a.get('s'), Article_Body__c=a.get('b'), Language='en_US', IsVisibleInPkb=true, IsVisibleInCsp=true));
}
insert recs;
for (Knowledge__kav k : [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id IN :recs]) {
  KbManagement.PublishingService.publishArticle(k.KnowledgeArticleId, true);
}
System.debug('Published ' + recs.size());

List<Map<String,String>> arts = new List<Map<String,String>>{
  new Map<String,String>{'t'=>'How to Perform Routine Generator Maintenance','u'=>'generator-routine-maintenance','s'=>'A simple schedule for keeping your generator reliable.',
    'b'=>'<h2>Maintenance schedule</h2><ul><li><b>Weekly:</b> check oil, coolant and fuel levels; run the unit for 10 minutes.</li><li><b>Every 100 hours:</b> change the oil and inspect air filters.</li><li><b>Annually:</b> replace spark plugs or fuel filters and test the battery.</li></ul><p>Always switch the generator off and let it cool before servicing.</p>'},
  new Map<String,String>{'t'=>'Electrical Wiring Installation Guidelines for the GC5060','u'=>'gc5060-wiring-installation','s'=>'Key safety and wiring steps before installing the GC5060.',
    'b'=>'<h2>Before you start</h2><ol><li>Isolate power and lock out the supply.</li><li>Use cable rated for the unit load and run it in conduit.</li><li>Connect protective earth first, then neutral, then phases.</li><li>Have a licensed electrician inspect the installation before commissioning.</li></ol>'},
  new Map<String,String>{'t'=>'Troubleshooting Mechanical Rotor Vibration','u'=>'rotor-vibration-troubleshooting','s'=>'Common causes of excessive rotor vibration and how to fix them.',
    'b'=>'<h2>Common causes</h2><ul><li>Worn or damaged bearings</li><li>Imbalanced rotor or loose mounting bolts</li><li>Shaft misalignment</li></ul><p>Stop the machine, inspect mountings, and contact support if vibration persists after re-tightening.</p>'},
  new Map<String,String>{'t'=>'How to Contact Support and What to Include in a Case','u'=>'contacting-support','s'=>'Get faster answers by including the right details.',
    'b'=>'<p>When you open a case, include the product model, serial number, a clear description, and any error codes or photos. Cases are prioritised as High, Medium or Low based on business impact.</p>'},
  new Map<String,String>{'t'=>'Warranty and Service Coverage FAQ','u'=>'warranty-faq','s'=>'Answers to common warranty questions.',
    'b'=>'<h2>FAQ</h2><p><b>How long is the warranty?</b> Standard equipment carries a 12-month warranty from delivery.</p><p><b>What voids it?</b> Unauthorised modification or skipped scheduled maintenance.</p>'}
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

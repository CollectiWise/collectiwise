import pronto


#nmr = pronto.Ontology('http://nmrml.org/cv/v1.1.0/nmrCV.owl')
#ms  = pronto.Ontology('https://raw.githubusercontent.com/HUPO-PSI/psi-ms-CV/master/psi-ms.obo')
#ms.merge(nmr)
#print(nmr.json)	
#gaz = pronto.Ontology('http://ontologies.berkeleybop.org/gaz.owl')
#print "printing thar last thing"
#print 'NMR:1400302' in ms
#print ms.json
#thing= ms['UO:0010039']
#print thing.json
#print thing.obo #json should be a method for a term just as it is a method for the whole ontology 


sd   = pronto.Ontology('https://raw.githubusercontent.com/SDG-InterfaceOntology/sdgio/master/sdgio.owl')
print('SDGIO:00000061' in sd)
   
#gaz = pronto.Ontology('http://ontologies.berkeleybop.org/gaz.obo')

envo = pronto.Ontology('https://raw.githubusercontent.com/EnvironmentOntology/envo/master/envo.obo')
print('SDGIO:00000061' in envo)
envo.merge(sd)
print('SDGIO:00000061' in envo)

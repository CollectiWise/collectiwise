#!/usr/bin/env python3
# 2019-01
# Script to convert envo.obd to atomspace representation in scheme
# Requires: file envo.obo from http://www.berkeleybop.org/ontologies/envo.obo
from opencog.atomspace import types
from opencog.type_constructors import *
from opencog.utilities import initialize_opencog
from opencog.scheme_wrapper import scheme_eval
import string
from os.path import join
import json
import pronto

atomspace = AtomSpace()

initialize_opencog(atomspace)

scheme_eval(atomspace, """
                        (load "/home/ubuntu/collectiwise/load_all.scm")
                        (add-to-load-path "/home/ubuntu/collectiwise")
                        (load "/home/ubuntu/collectiwise/math.scm")
                        (load "/home/ubuntu/collectiwise/statements.scm")
                        (load "/home/ubuntu/collectiwise/collectiwise.scm")
                        """)

       
class SchemeRouter(object):
    
    def __init__(self, ontology=None):
        assert type(ontology) == pronto.Ontology
        self.ontology = ontology
    
    def process(self, json_data):
        self.ontology.include_json(json_data)

    def _predicate_scheme_eval(self, prop_name, predicate, thing1, thing2):
       
        return scheme_eval(atomspace, '(' +prop_name + ' "'+predicate + '" "' 
                             + thing1 + '" "' + thing2 + '" 1)').decode("utf-8").strip()

    def _relation_properties(self, relation, thing1, things2, indicators):
        if relation=='is_a': 
            return [scheme_eval(atomspace, '(' + relation + ' "' + thing1 + '" "' + thing2 + '" 1)') for thing2 in things2]
       
        for label in indicators:
            if indicators[label]:
                [self._predicate_scheme_eval(label, relation, thing1, thing2) for thing2 in things2]     


    def term_to_scheme(self, term, write=True):
        known_relations={'is_a',} 
        scheme_eval(atomspace, ConceptNode(term.id).long_string()).decode("utf-8").strip()
        scheme_eval(atomspace, '(has_name "'+ term.id + '" "'+ term.name +'")').decode("utf-8").strip()
        scheme_eval(atomspace, '(has_desc "'+ term.id + '" "'+ term.desc +'")').decode("utf-8").strip()
        for rel in term.relations:
            self._relation_properties(rel.obo_name, term.id, [t.id for t in term.relations[rel]], rel.properties)
        #still have to deal with term.synonyms and term.other.
 
    def predicate_to_scheme(self, predicate):
        for prop in predicate.properties:
            if predicate.properties[prop]:
                print(scheme_eval(atomspace, '(variable_'+ prop + ' "' + predicate.obo_name + '" 1)').decode("utf-8").strip())
        '''
        #still have to deal with these properties:
        print(predicate.complementary)
        print(predicate.prefix)
        print(predicate.direction)
        print(predicate.comment)
        print(predicate.aliases)
        '''
#-----------------------------------------------------------------------------------
def main():
    
    sample_json = json.dumps({"UO:0010039":
        {
        "desc": "An imperial gravitational unit which is equivalent to a mass that accelerates by 1ft/s\u00b2 when a force of one pound (lbf) is exerted on it.",
        "id": "UO:0010039",
        "name": "slug",
        "other": {
            "created_by": [
                "Luke Slater"
            ],
            "id": [
                "UO:0010039"
            ],
            "is_a": [
                "UO:0000111"
            ],
            "namespace": [
                "unit.ontology"
            ],
            "subset": [
                "unit_slim"
            ]
        },
        "synonyms":{'EXACT':['term1', 'term2'], 'BROAD':['term3', 'term4']
        },
        "relations": {
            "is_a": [
                "UO:0000111"
            ]
        }
     }})

    sample_decoded = json.loads(sample_json) 
     
    all_keys=set(['id','name', 'desc', 'other', 'relations'])
    sd   = pronto.Ontology('https://raw.githubusercontent.com/SDG-InterfaceOntology/sdgio/master/sdgio.owl')
    print('SDGIO:00000061' in sd)
    #print(sd['SDGIO:00000061'].json)
    #gaz = pronto.Ontology('http://ontologies.berkeleybop.org/gaz.obo')

    envo = pronto.Ontology('https://raw.githubusercontent.com/EnvironmentOntology/envo/master/envo.obo')
    print('SDGIO:00000061' in envo)
    envo.merge(sd)
    print('SDGIO:00000061' in envo)
    random_term=envo[list(envo.terms.keys())[7952]]
                                                                                                                                                                                
    router=SchemeRouter(envo)
    router.process(sample_json)
    same_term = router.ontology["UO:0010039"]
      
    #print(scheme_eval(atomspace, '(cog-execute! (find-users))').decode("utf-8"))
    router.term_to_scheme(random_term)
    pred_names={}
    for pred in envo.typedefs:
        print('predicate: '+ pred.obo_name)
        router.predicate_to_scheme(pred) 
        pred_names[pred.obo_name] = pred_names.get(pred.obo_name, 0) + 1

    print('is_a' in pred_names)
    print('disjoint_from' in pred_names) 
if __name__ == "__main__":
    main()




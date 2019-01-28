#!/usr/bin/env python3
# 2019-01
# Script to convert envo.obd to atomspace representation in scheme
# Requires: file envo.obo from http://www.berkeleybop.org/ontologies/envo.obo
from os.path import join
import json
import pronto
       
class SchemeWriter(object):
    
    def __init__(self, ontology=None, format='json'):
        self.ontology = ontology


    def write_all(self):
        [self.term_to_scheme(term) for term in self.input]
    
    def all_to_terms(self, list_of_json):
        return [self.to_term(json_term) for json_term in list_of_json]

    def to_term(self, json_term):
        return json_term

    def print_all(self):
        [self.term_to_scheme(term, write=False) for term in self.input]

    def term_to_scheme(self, term, write=True): 
        [self.one_to_scheme(statement, write) for statement in term]   

    def one_to_scheme(self, statement, write):

        key, idd, value, indicator= statement
        mainstream[key] = mainstream.get(key, 0) + 1

        args = [idd, value]
        try:
            if write:
                self.write(key, args, indicator)
            else:
                self.prnt(key, args, indicator)
        except:
            weird_cases[key]=value

    def writeOne(self, strings):
        for st in strings:
            self.file.write(st)

    def printOne(self, strings):
        print(''.join(strings))

    # methods to write on file or print scheme code:
    def inLink(self, node1 , node2, typ, link="inheritance", write=True):
        link_dict={"inheritance":"InheritanceLink", "subset":"SubsetLink"}
	
        strings   = ["("+ link_dict[link] + " \n", 
		"\t ("+typ+ " \"" + node1 + "\")\n", 
		"\t ("+typ+" \""+ node2 + "\")\n", 
		")\n\n"]

        if not write:
            self.printOne(strings)		
        else:
            self.writeOne(strings)
    
    	
    def evaLink(self, predicateName ,node1 , node2 , node1_type, node2_type, write=True):
        strings=["(EvaluationLink \n", 
		"\t (PredicateNode \"" + predicateName + "\")\n", 
		"\t (ListLink \n", 
		"\t\t (" + node1_type + " \"" + node1 + "\")\n",
    		"\t\t (" + node2_type + " \"" + node2 + "\")\n",
    		"\t )\n",
    		")\n\n"]

        if not write:
            self.printOne(strings)
        else:
            self.writeOne(strings)



    def to_scheme(self, key, args, indicator=1, write=True):
        typ ="ConceptNode" if indicator else "PredicateNode"
        """Dispatch method"""
        method_name = 'envo_' + str(key)
        # Get the method from 'self'. Default to a lambda.
        method = getattr(self, method_name, lambda: "invalid key")
        # Call the method as we return it
        return method(*args, typ=typ, write=write)	#nd_assertion_to' # 'expand_expression_to' 
  
    def write(self, key, args, indicator=1):
        self.to_scheme(key, args, indicator, write=True)
    
    def prnt(self, key, args, indicator=1):
        self.to_scheme(key, args, indicator, write=False) 

    def envo_id(self, idd, value, typ="ConceptNode", write=True):
        typp="ENVO_term" if (typ=="ConceptNode") else "ENVO_pred"
        self.inLink(idd, typp, typ=typ, write=write)
    
    def envo_name(self, idd, name, typ="ConceptNode", write=True):
        self.evaLink("ENVO_name", idd, name, typ, "ConceptNode", write=write)

    def envo_subset(self, idd, superset, typ="ConceptNode", write=True):
        self.inLink(idd, superset, typ = typ, link='subset', write=write)

    def envo_namespace(self, idd, namespace, typ="ConceptNode", write=True):
        self.evaLink("ENVO_namespace", idd, namespace , typ, "ConceptNode", write=write)

    def envo_definition(self, idd, definition, typ="ConceptNode", write=True):
        self.evaLink("ENVO_definition", idd, definition ,typ, "ConceptNode", write=write)

    def envo_comment(self, idd, comment, typ="ConceptNode", write=True):
        self.evaLink("ENVO_comment", idd, comment, typ, "ConceptNode", write=write)
 
    def envo_is_a(self, idd, is_a, typ="ConceptNode", write=True):	
        self.inLink(idd, is_a, typ=typ, write=write)

    def envo_alt_id(self, idd, alt_id, typ="ConceptNode", write=True):
        self.evaLink("ENVO_alt_id", idd, alt_id, typ, typ, write=write)

    def envo_relationship(self, idd, relate_id_type, typ="ConceptNode", write=True):
        relate_id, relation_type =relate_id_type

        self.evaLink(relation_type, idd, relate_id, typ , typ, write=write)

    def envo_disjoint_from(self, idd, relate_id, typ="ConceptNode", write=True):
        self.envo_relationship(idd, relate_id, "disjoint_from", typ, write=write)
        self.envo_relationship(relate_id, idd, "disjoint_from", typ, write=write)

    def envo_xref(self, idd, xref, typ="ConceptNode", write=True):
        self.evaLink("ENVO_xref", idd, xref, typ, typ, write=write)

    def envo_synonym(self, idd, syn, typ="ConceptNode", write=True):
        self.evaLink('synonym', idd, syn, typ, typ, write=write)
        self.evaLink('synonym', syn, idd, typ, typ, write=write)

    def envo_intersection_of(self, idd, sett, typ="ConceptNode", write=True):
        self.evaLink('intersection_of', idd, sett, typ, typ, write=write)

    def envo_property_value(self, idd, sett, typ="ConceptNode", write=True):
        for s in sett:
            self.evaLink('property_value', idd, s, typ, typ, write=write)

    def envo_domain(self, idd, domain, typ, write=True):
        self.evaLink('domain', idd, domain, typ, typ, write=write)

    def envo_is_transitive(self, idd, b, typ, write=True):
        pass

    def envo_created_by(self, idd, creator, typ, write=True):
        self.evaLink('created_by', idd, creator, typ, "ConceptNode", write=write)

    def envo_inverse_of(self, idd, other, typ, write=True):
    	self.evaLink('inverse_of', idd, other, typ, typ, write=write)

    def envo_creation_date(self, idd, date, typ, write=True):
    	self.evaLink('creation_date', idd, date, typ, "ConceptNode", write=write)

    def envo_range(self, idd, rang, typ, write=True):
        self.evaLink('range', idd, rang, typ, typ, write=write)

    def envo_holds_over_chain(self, idd, chain, typ, write=True):
        pass # don't know what to do here? noticed that chain is always of length 2 or 3 in our sample. 

    def envo_union_of(self, idd, sets, typ, write=True):
        pass

    def envo_is_symmetric(self, idd, b, typ, write=True):
        pass

    def envo_is_reflexive(self, idd, b, typ, write=True):
        pass

    def envo_transitive_over(self, idd, over, typ, write=True):
        self.evaLink('transitive_over', idd, over, typ, 'PredicateNode', write=write)

    def envo_is_metadata_tag(self, idd, tag, typ, write=True):
        pass

    def envo_is_class_level(self, idd, level, typ, write=True):
        pass

    def envo_is_inverse_functional(self, idd, b, typ, write=True):
        pass


#some simple logging:
mainstream={}
all_else ={}
weird_cases ={}
relationships={}

def main():
    #fi = InputFile()
    #processor =Processor(fi)

#    #some simple logging:
#    mainstream={}
#    all_else ={}
#    weird_cases ={}

    #terms=processor.process_all()
    #fo=OutputFile()
    #writer=SchemeWriter(fo, terms)
    #writer.write_all()

    #print("things not included in the previous definitions:")
    #for key in all_else:
    #    if all_else[key] > 4 and key!="\n":
    #        print(key+ "  " + str(all_else[key]))

    #print "previous insignificant statements:"
    #for key in mainstream:
    #    print(key + "  " + str(mainstream[key]))

    #print "weird cases:"
    #for key in weird_cases:
    #    print key, weird_cases[key]
    
    sample_json = json.dumps({
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
        "relations": {
            "is_a": [
                "UO:0000111"
            ]
        }
     })
    sd   = pronto.Ontology('https://raw.githubusercontent.com/SDG-InterfaceOntology/sdgio/master/sdgio.owl')
    print('SDGIO:00000061' in sd)

    #gaz = pronto.Ontology('http://ontologies.berkeleybop.org/gaz.obo')

    envo = pronto.Ontology('https://raw.githubusercontent.com/EnvironmentOntology/envo/master/envo.obo')
    print('SDGIO:00000061' in envo)
    envo.merge(sd)
    print('SDGIO:00000061' in envo)
    force, parsers = envo._get_parsers(None)

    print("force: ", force)
    print("parsers: ", parsers)                                                                                                                                                                              
    writer=SchemeWriter(envo, [sample_json])
    for inpt in writer.ontology:
        #print('term: ', eval(inpt.json)[inpt.id].keys())
	
        relation_names=set([key.obo_name for key in inpt.relations])
        other_names = set(inpt.other.keys())-relation_names-set(['id', 'name', 'desc'])
       
        #for name in ['id', 'name', 'desc']:
            
        print(inpt.id, 'id', inpt.id)
        print(inpt.id, 'name', inpt.name)
        print(inpt.id, 'description', inpt.desc)
        print(relation_names, other_names)
        #print([(inpt.id, 'id', inpt.id)] + [(inpt.id, key, val) for key, value in inpt.other.items() for val in value if key!='id'])
    #for r in relationships:
    #    print(r.__dict__)
    

if __name__ == "__main__":
    main()




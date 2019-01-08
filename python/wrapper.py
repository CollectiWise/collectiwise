from opencog.atomspace import types
from opencog.type_constructors import *
from opencog.utilities import initialize_opencog
from opencog.scheme_wrapper import scheme_eval 

atomspace = AtomSpace()

initialize_opencog(atomspace)

scheme_eval(atomspace, """
			(load "/home/ubuntu/collectiwise/load_all.scm")
			(add-to-load-path "/home/ubuntu/collectiwise")
			(load "/home/ubuntu/collectiwise/math.scm")
			(load "/home/ubuntu/collectiwise/collectiwise.scm")
 			""")


atom = ConceptNode("handle bar")

line =atom.long_string()

print(line)
print(atom.type_name)

conditionz =[PredicateNode("is_fast"), PredicateNode("is-big")]

andStatement = lambda conditions: AndLink(*conditions).long_string()

print(andStatement(conditionz))

def neg_and(statements):
	return OrLink(*[NotLink(statement) for statement in statements]).long_string()

#print(neg_and([PredicateNode("is-fast"), PredicateNode("is-big"), PredicateNode("is-funny")]))

John = ConceptNode("John")

scheme_eval(atomspace, "(mk-binary-statement "+John.long_string()+ andStatement(conditionz)+ neg_and(conditionz)+ "0.3 10)")

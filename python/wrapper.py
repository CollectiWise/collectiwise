from opencog.atomspace import types
from opencog.type_constructors import *
from opencog.utilities import initialize_opencog
from opencog.scheme_wrapper import scheme_eval 
import string
atomspace = AtomSpace()

initialize_opencog(atomspace)

scheme_eval(atomspace, """
			(load "/home/ubuntu/collectiwise/load_all.scm")
			(add-to-load-path "/home/ubuntu/collectiwise")
			(load "/home/ubuntu/collectiwise/math.scm")
			(load "/home/ubuntu/collectiwise/collectiwise.scm")
 			""")



def alphabet_cycle(): #this generator generates labels for variables. 
    while 1:
        for c in string.ascii_lowercase: 
            yield c	 
 	
	

#preventing double negation
def negdouble(statement, stringify=True):
	if stringify:
		return NotLink(statement).long_string() if statement.type_name!="NotLink" else statement.out[0].long_string()
	else:
		return NotLink(statement) if statement.type_name!="NotLink" else statement.out[0]

#binding statements together via AndLink or OrLink
bind = lambda conditions, stringify=True, link=AndLink: link(*conditions).long_string() if stringify==True else link(*conditions)

#a negation of a binding AndLinkn or an OrLink
def neg_bind(statements, stringify=True, link=AndLink):
	reverse_dict ={AndLink : OrLink, OrLink: AndLink}
	if stringify:
		return reverse_dict[link](*[negdouble(statement, False) for statement in statements]).long_string() 
	else:
		return reverse_dict[link](*[negdouble(statement, False) for statement in statements])
 

#making it easy to turn a list of strings of the form ["statement", "not-statement",...] into a list of predicates and negated predicates 
notify = lambda string: NotLink(PredicateNode(string[len("not")+1:])) if "not"==string[:len("not")] else PredicateNode(string)

#actually doing the conversion from a list of strings to a list of predicates and negated predicates.
predicates =lambda strings: [notify(string) for string in strings]

def variableStatement(types, statements, p, link=AndLink):
	#such statements have a list of types (such as "developer", "church", "ice-cream-truck" 
	#and attribute one statement to each type (ice-cream-truck is-slow) connecting the statements with either an and or an or statement 

	iter = alphabet_cycle()
	variables = [VariableNode("$"+next(iter)) for ty in types]
	wrappedVars =VariableList(*[TypedVariableLink(var, TypeNode("ConceptNode")) for var in variables])
	inheritance =AndLink(*[InheritanceLink(var, typ) for var, typ in zip(variables, types)])
	statement   =link(*[EvaluationLink(statement, var) for statement, var in zip(statements, variables)])
 	
	return LambdaLink(wrappedVars, inheritance, statement).truth_value(p, 1).long_string()


conditionz = predicates(["is-fast", "not-is-big", "is-cleaver"])

print(variableStatement([ConceptNode("Developer"), ConceptNode("User")], [PredicateNode("is-fast"), PredicateNode("is-clean")], 0.4, link=OrLink))
#print(neg_bind(conditionz))
#print(bind(conditionz, link=OrLink))
print(neg_bind(conditionz, link=OrLink))
John = ConceptNode("John")

scheme_eval(atomspace, "(mk-binary-statement "+John.long_string()+ bind(conditionz)+ neg_bind(conditionz)+ "0.3 10)")

LambdaLink(VariableList(TypedVariableLink(VariableNode("$X"), TypeNode("ConceptNode")), TypedVariableLink(VariableNode("$Y"), TypeNode("ConceptNode"))), AndLink(EvaluationLink(PredicateNode("is-honest"), VariableNode("$X"))))

#for i in range(30):
#	print(next(iter))

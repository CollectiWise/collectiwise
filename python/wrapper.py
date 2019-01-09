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

def variableTypedAndOr(types, statements, p, link=AndLink, neg=False):
	#such statements have a list of types (such as "developer", "church", "ice-cream-truck" 
	#and attribute one statement to each type (ice-cream-truck is-slow) connecting the statements with either an and or an or statement 
	reverse_dict ={AndLink : OrLink, OrLink: AndLink}
	if neg: 
		p=1-p

	iter = alphabet_cycle()
	variables = [VariableNode("$"+next(iter)) for ty in types]
	wrappedVars =VariableList(*[TypedVariableLink(var, TypeNode("ConceptNode")) for var in variables])
	inheritance =AndLink(*[InheritanceLink(var, typ) for var, typ in zip(variables, types)])
	if not neg:	
		statement =bind([EvaluationLink(statement, var) for statement, var in zip(statements, variables)], False, link)
	else:
		statement =reverse_dict[link](*[EvaluationLink(negdouble(statement, False), var) for statement, var in zip(statements, variables)]) 		
	return LambdaLink(wrappedVars, inheritance, statement).truth_value(p, 1).long_string()



#--------------------------------------------examples-------------------------------------------------------------------
conditionz = predicates(["is-fast", "not-is-big", "is-cleaver"])

John = ConceptNode("John")

scheme_eval(atomspace, "(mk-binary-statement "+John.long_string()+ bind(conditionz)+ neg_bind(conditionz)+ "0.3 10)")

print(variableTypedAndOr([ConceptNode("user"), ConceptNode("ice-cream-truck"), ConceptNode("Developer")], conditionz, 0.4, neg=True))

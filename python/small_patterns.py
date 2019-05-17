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
# (load "load_all.scm") #
scheme_eval(atomspace, """
                        (add-to-load-path "collectiwise")
                        (load "math.scm")
                        (load "statements.scm")
                        (load "collectiwise.scm")
                        """)



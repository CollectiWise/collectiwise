import json
concepts ='[{"name": "User", "relations": {}, "is_a": ["CW:0000003", "CW:0000002"], "predicates": [], "Type": "Concept", "id": "CW:0000001"}, {"name": "Human", "relations": {}, "is_a": ["CW:0000003"], "predicates": [], "Type": "Concept", "id": "CW:0000002"}, {"name": "Animal", "relations": {}, "is_a": [], "predicates": [], "Type": "Concept", "id": "CW:0000003"}, {"name": "Johannes", "relations": {"studied_at": ["CW:0000007"], "in_team_with": ["CW:0000005", "CW:0000006"]}, "is_a": ["CW:0000001", "CW:0000002", "CW:0000003"], "predicates": [{"stv": 0.75, "id": "CW:0000009", "context": "CW:0001000", "name": "is_fast"}, {"stv": 0.35, "id": "CW:0000010", "context": "CW:0001001", "name": "is_fast"}], "Type": "Concept", "id": "CW:0000004"}, {"name": "Naireen", "relations": {"studied_at": ["CW:0000007"], "in_team_with": ["CW:0000004", "CW:0000006"]}, "is_a": ["CW:0000001", "CW:0000002", "CW:0000003"], "predicates": [{"stv": 0.45, "id": "CW:0000009", "context": "CW:0001000", "name": "is_fast"}, {"stv": 0.85, "id": "CW:0000010", "context": "CW:0001001", "name": "is_fast"}], "Type": "Concept", "id": "CW:0000005"}, {"name": "Austin", "relations": {"studied_at": ["CW:0000007"], "in_team_with": ["CW:0000004", "CW:0000005"]}, "is_a": ["CW:0000001", "CW:0000002", "CW:0000003"], "predicates": [{"stv": 0.65, "id": "CW:0000009", "context": "CW:0001000", "name": "is_fast"}, {"stv": 0.95, "id": "CW:0000010", "context": "CW:0001001", "name": "is_fast"}], "Type": "Concept", "id": "CW:0000006"}, {"Type": "Concept", "id": "CW:0000007", "name": "University1"}]'
university1 = json.loads(concepts)[-1]
university1["relations"]={"has_alumni": ["CW:0000004", "CW:0000005", "CW:0000006"]}
university1["is_a"] =["CW:0000008"]
university ={"id":"CW:0000008", "name":"University", "is_a":[], "relations":[], "predicates":[]}
concepts =json.loads(concepts)
concepts[-1]=university1
concepts.append(university)
#print(json.dumps(concepts))
relations =[{'id':"CW:0000010", 'name': 'team_mates_with', 'domain':["CW:0000001"], 'range':["CW:0000001"], 'is_a':[], 'relations':[], "predicates":[], 'properties':{'symmetry':True, 'reflexivity':None, 'transitivity':False}}]

starts_with ={'id':"ENVO:?", "name": 'starts_with', 'domain':["ENVO:??", "ENVO???"], 'range':["ENVO:??", "ENVO:???"], 'is_a':['temporal_relation'], 'predicates':[], 'properties':{'symmetry':False, 'reflexivity':False, 'transitivity':True}}

relations.append(starts_with)
#print(json.dumps(relations))
predicates =[{'id':'CW:0000011', 'name':'is_fast', 'stv':0.88, 'context':"CW:0001000", 'is_a':[], 'relations':[], 'predicates':[]}, {'id':'CW:0000012', 'name':'is_fast', 'stv':0.55, 'context':"CW:0001001", 'is_a':[], 'relations':[], 'predicates':[]}, {'id':'CW:0000013', 'name':'is_high_quality', 'stv':0.99, 'context':"CW:0001000", 'is_a':[], 'relations':[], 'predicates':[]}]

#print(json.dumps(predicates))
implications=[{'id':'CW:0000014', 'name':'projectXimplied', 'if':{'AND':[('CW:0000001', 'is_a', 'CW:0000023'), ('CW:0000001', 'is_fast(>0.6)', 'CW:0001000')], 'OR':[],'AND_NOT':[], 'OR_NOT':[]}, 'then':{'AND':[('CW:0000001', 'is_good_for', 'PRJCTX')], 'OR':[('CW:0000001', 'caught_virus', 'VRSX')], 'AND_NOT':[], 'OR_NOT':[]}}, {'id':'CW:0000015', 'name':'some_implication', 'if':{'AND':[('A', 'does_action', 'B'), ('A', 'is_a', 'C')], 'OR':[('A', 'is_not', 'Z'), ('B', 'goes_wrong', {'stv':0.666})], 'AND_NOT':('A', 'eats', 'D'), 'OR_NOT':[]}}]
print(json.dumps(implications))

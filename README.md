# family-tree-chatbot
A Prolog and Python-based chatbot for inferring family relationships. It uses a predefined set of patterns to recognize and process statements and questions about family members. The chatbot can handle relationships such as siblings, parents, children, aunts, uncles, and grandparents.

## Features
- **Input Statements**: Define family relationships with statements.
- **Input Questions**: Ask questions to infer and explore relationships.
- **Pattern Recognition**: Uses regular expressions to map input to relationship types.
- **Inference Engine**: Prolog backend to infer relationships based on input statements.

## Supported Patterns

### Statement Patterns:
- ___ and ___ are siblings.
- ___ is a brother of ___.
- ___ is a sister of ___. 
- ___ is the father of ___.
- ___ is the mother of ___. 
- ___ and ___ are the parents of ___.
- ___ is a grandmother of ___. 
- ___ is a grandfather of ___.
- ___ is a child of ___.
- ___, ___, and ___ are children of ___. (can be any number of children)
- ___ is a daughter of ___.
- ___ is a son of ___.
- ___ is an uncle of ___.
- ___ is an aunt of ___.

### Question Patterns:
- Are ___ and ___ siblings? 
- Who are the siblings of ___?
- Is ___ a sister of ___? 
- Who are the sisters of ___?
- Is ___ a brother of ___? 
- Who are the brothers of ___?
- Is ___ the mother of ___? 
- Who is the mother of ___?
- Is ___ the father of ___? 
- Who is the father of ___?
- Are ___ and ___ the parents of ___? 
- Who are the parents of ___?
- Is ___ a grandmother of ___? 
- Is ___ a grandfather of ___?
- Is ___ a daughter of ___? 
- Who are the daughters of ___?
- Is ___ a son of ___? 
- Who are the sons of ___?
- Is ___ a child of ___? 
- Who are the children of ___?
- Are ___, ___, and ___ children of ___? (can be any number of children)
- Is ___ an aunt of ___?
- Is ___ an uncle of ___? 
- Are ___ and ___ relatives?

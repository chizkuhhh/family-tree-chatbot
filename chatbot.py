from pyswip import Prolog
import re

# array of possible statement patterns
statements = [
    (r"^(\w+) and (\w+) are siblings\.$", "sibling_of"),
    (r"^(\w+) is a sister of (\w+)\.$", "sister"),
    (r"^(\w+) is the mother of (\w+)\.$", "mother"),
    (r"^(\w+) is a grandmother of (\w+)\.$", "grandmother"),
    (r"^(\w+) is a child of (\w+)\.$", "child"),
    (r"^(\w+) is a daughter of (\w+)\.$", "daughter"),
    (r"^(\w+) is an uncle of (\w+)\.$", "uncle"),
    (r"^(\w+) is a brother of (\w+)\.$", "brother"),
    (r"^(\w+) is the father of (\w+)\.$", "father"),
    (r"^(\w+) and (\w+) are the parents of (\w+)\.$", "parents"),
    (r"^(\w+) is a grandfather of (\w+)\.$", "grandfather"),
    (r"^([\w+, ]+), and (\w+) are children of (\w+)\.$", "children"),
    (r"^(\w+) is a son of (\w+)\.$", "son"),
    (r"^(\w+) is an aunt of (\w+)\.$", "aunt")
]


questions = [
    (r"^Are (\w+) and (\w+) siblings\?$", "siblings"),
    (r"^Is (\w+) a sister of (\w+)\?$", "is_sister"),
    (r"^Is (\w+) a brother of (\w+)\?$", "is_brother"),
    (r"^Is (\w+) the mother of (\w+)\?$", "is_mother"),
    (r"^Is (\w+) the father of (\w+)\?$", "is_father"),
    (r"^Are (\w+) and (\w+) the parents of (\w+)\?$", "parents"),
    (r"^Is (\w+) a grandmother of (\w+)\?$", "is_grandmother"),
    (r"^Is (\w+) a daughter of (\w+)\?$", "is_daughter"),
    (r"^Is (\w+) a son of (\w+)\?$", "is_son"),
    (r"^Is (\w+) a child of (\w+)\?$", "is_child"),
    (r"^Are ([\w+, ]+), and (\w+) children of (\w+)\?$", "children"),
    (r"^Is (\w+) an uncle of (\w+)\?$", "is_uncle"),
    (r"^Who are the siblings of (\w+)\?$", "siblings_of"),
    (r"^Who are the sisters of (\w+)\?$", "sisters_of"),
    (r"^Who are the brothers of (\w+)\?$", "brothers_of"),
    (r"^Who is the mother of (\w+)\?$", "mother_of"),
    (r"^Who is the father of (\w+)\?$", "father_of"),
    (r"^Who are the parents of (\w+)\?$", "parents_of"),
    (r"^Is (\w+) a grandfather of (\w+)\?$", "is_grandfather"),
    (r"^Who are the daughters of (\w+)\?$", "daughters_of"),
    (r"^Who are the sons of (\w+)\?$", "sons_of"),
    (r"^Who are the children of (\w+)\?$", "children_of"),
    (r"^Is (\w+) an aunt of (\w+)\?$", "is_aunt"),
    (r"^Are (\w+) and (\w+) relatives\?$", "relatives")
]

check_possible = ["brother", "father", "uncle", "grandfather", "son", "sister", "mother", "aunt", "grandmother", "daughter"]
check_possible_q = ["is_brother", "is_father", "is_uncle", "is_grandfather", "is_son", "is_sister", "is_mother", "is_aunt", "is_grandmother", "is_ daughter"]

prolog = Prolog()
prolog.consult('chatbot_engine.pl')

# validate input and check if it's a statement or a question
def validate_input(input):
    input = input.lower()

    # loop through statement patterns and find matching relationship
    for pattern, relationship in statements:
        match = re.match(pattern, input, re.IGNORECASE)
        if match:
            return "statement", match.groups(), relationship

    # loop through question patterns and find matching relationship    
    for pattern, relationship in questions:
        match = re.match(pattern, input, re.IGNORECASE)
        if match:
            return "question", match.groups(), relationship
    
    return "invalid", None, None

# check if statement/fact is already in the knowledge database, add if not
def is_present(fact):
    result = list(prolog.query(fact))
    if result:
        return 0
    else:
        # append into prolog knowledge base
        with open('chatbot_engine.pl', 'a') as engine_file:
            engine_file.write(fact + '\n')

        # re-consult the updated knowledge base
        prolog.consult('chatbot_engine.pl')

        return 1

# main program/loop or whtvr
print("Welcome to Chatbot")
while True:
    prompt = input("\nEnter a statement or question (or type 'exit' to quit):\n > ")


    # Check if the user wants to exit
    if prompt == 'exit':
        break

    input_type, names, relationship = validate_input(prompt)
    
    if input_type == "statement":
    # convert to prolog fact
        if relationship == "children":
            parent = names[len(names) - 1]
            children = names[0].split(", ")
            children.append(names[len(names) - 2])

            for child in children:
                can_be = f"\+ can_be(child,{child}, {parent})."
                is_possible = list(prolog.query(can_be))
                if is_possible:
                    print(f"\n{child} cannot be a child of {parent}!")
                else:
                    fact = f"child({child}, {parent})."
                    if is_present(fact) == 0:
                        print(f"\n{child} is already a child of {parent}!")
                    else:
                        print(f"\nOK! I've marked {child} as a child of {parent}!")

        else:
            if len(names) == 1:
                fact = f"{relationship}({names[0]})."
                if is_present(fact) == 0:
                        print("\nI'm already aware of that!")
                else:
                    print("\nOK! I learned something new today!")

            elif len(names) == 2:
                if relationship in check_possible:
                    can_be = f"\+ can_be({relationship}, {names[0]}, {names[1]})."
                    is_possible = list(prolog.query(can_be))
                    if is_possible:
                        print("\nThat's impossible!")
                    else:
                        fact = f"{relationship}({names[0]}, {names[1]})."
                        if is_present(fact) == 0:
                            print("\nI'm already aware of that!")
                        else:
                            # declare gender when needed
                            if relationship == "brother" or relationship == "father" or relationship == "uncle" or relationship == "grandfather" or  relationship == "son":
                                check_gender = f"male({names[0]})." 
                                is_present(check_gender)
                            elif relationship == "sister" or relationship == "mother" or relationship == "aunt" or relationship == "grandmother" or  relationship == "daughter":
                                check_gender = f"female({names[0]})." 
                                is_present(check_gender)

                            print("\nOK! I learned something new today!")
                else:
                    fact = f"{relationship}({names[0]}, {names[1]})."
                    if is_present(fact) == 0:
                        print("\nI'm already aware of that!")
                    else:
                        print("\nOK! I learned something new today!")

            elif len(names) == 3:
                fact = f"{relationship}({names[0]}, {names[1]}, {names[2]})."
                if is_present(fact) == 0:
                        print("\nI'm already aware of that!")
                else:
                    print("\nOK! I learned something new today!")

            else:
                fact = f"{relationship}({names[0]}, {names[1]}, {names[2]}, {names[3]})."
                if is_present(fact) == 0:
                        print("\nI'm already aware of that!")
                else:
                    print("\nOK! I learned something new today!")

        # check if fact already exists in knowledge base
        # is_present(fact)

    elif input_type == "question":
        # check knowledge base if answerable
        # construct the Prolog query
        if relationship == "children":
            parent = names[len(names) - 1]
            children = names[0].split(", ")
            children.append(names[len(names) - 2])

            for child in children:
                can_be = f"\+ can_be(child,{child}, {parent})."
                is_possible = list(prolog.query(can_be))
                if is_possible:
                    print(f"\n{child} cannot be a child of {parent}!")
                else:
                    query = f"is_child({child}, {parent})."
                    result = list(prolog.query(query))
                    if result:
                        print(f"\nYes. {child} is a child of {parent}!")
                    else:
                        print(f"\nI'm sorry, I don't have enough information to confirm if {child} as a child of {parent}.")
        else:
            if len(names) == 1:
                query = f"{relationship}({names[0]}, X)"
                # execute the query
                result = list(prolog.query(query))

                # check if the result is not empty
                if result:
                    # get the values of Y in each solution
                    values = [solution["X"] for solution in result]
                    
                    # remove duplicates by converting to a set and then back to a list
                    unique_values = list(set(values))
                    
                    # print the unique values
                    for value in unique_values:
                        if isinstance(value, str) and not value.startswith("_"):
                            print(value)
                else:
                    print("\nI'm sorry, I don't have enough information to answer your question.")

            elif len(names) == 2:
                if relationship in check_possible_q:
                    can_be = f"\+ can_be_q({relationship}, {names[0]}, {names[1]})."
                    is_possible = list(prolog.query(can_be))
                    if is_possible:
                        print("\nNo. That's not possible!")
                    else:
                        query = f"{relationship}({names[0]}, {names[1]})."

                        # execute the query
                        result = list(prolog.query(query))
                        
                        if result:
                            print("\nYes.")
                        else:
                            print("\nI'm sorry, I don't have enough information to answer your question.")
                else:
                        query = f"{relationship}({names[0]}, {names[1]})."

                        # execute the query
                        result = list(prolog.query(query))
                        
                        if result:
                            print("\nYes.")
                        else:
                            print("\nI'm sorry, I don't have enough information to answer your question.")
            elif len(names) == 3:
                query = f"{relationship}({names[0]}, {names[1]}, {names[2]})."
                # execute the query
                result = list(prolog.query(query))
                
                if result:
                    print("\nYes.")
                else:
                    print("\nI'm sorry, I don't have enough information to answer your question.")
            
            else:
                query = f"{relationship}({names[0]}, {names[1]}, {names[2]}, {names[3]})."
                # execute the query
                result = list(prolog.query(query))
                
                if result:
                    print("\nYes.")
                else:
                    print("\nI'm sorry, I don't have enough information to answer your question.")


    else:
        print("\nInvalid input. Please enter a statement or question in the correct format.")
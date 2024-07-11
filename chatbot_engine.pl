/* avoid warnings when user inputs a new fact */
:- dynamic brother/2, sister/2, mother/2.   
:- discontiguous sister/2, brother/2, parents/3, grandmother/2, grandfather/2, 
                parents/3, children/4, mother/2, father/2, male/1, female/1, siblings/2,
                sibling_of/2, uncle/2, son/2, daughter/2, child/2, creates_cycle/2, clause/1,
                aunt/2.

% helper funcs or whatevr
known_gender(X) :- female(X); male(X), !.
can_be(Relationship, X, Y) :-
    Relationship = sister, can_be_sister(X, Y);
    Relationship = brother, can_be_brother(X, Y);
    Relationship = mother, can_be_mother(X, Y);
    Relationship = father, can_be_father(X, Y);
    Relationship = daughter, can_be_daughter(X, Y);
    Relationship = son, can_be_son(X, Y);
    Relationship = grandmother, can_be_grandmother(X, Y);
    Relationship = grandfather, can_be_grandfather(X, Y);
    Relationship = aunt, can_be_aunt(X, Y);
    Relationship = uncle, can_be_uncle(X, Y);
    Relationship = child, can_be_child(X, Y).

can_be_q(Relationship, X, Y) :-
    Relationship = is_sister, can_be_sister(X, Y);
    Relationship = is_brother, can_be_brother(X, Y);
    Relationship = is_mother, can_be_mother(X, Y);
    Relationship = is_father, can_be_father(X, Y);
    Relationship = is_daughter, can_be_daughter(X, Y);
    Relationship = is_son, can_be_son(X, Y);
    Relationship = is_grandmother, can_be_grandmother(X, Y);
    Relationship = is_grandfather, can_be_grandfather(X, Y);
    Relationship = is_aunt, can_be_aunt(X, Y);
    Relationship = is_uncle, can_be_uncle(X, Y);
    Relationship = is_child, can_be_child(X, Y).


/* sister */
can_be_sister(X, Y) :-
    X \= Y, % can't be her own sister
    (known_gender(X), female(X), \+ male(X); \+ known_gender(X)),   % has to be female or gender is unknown
    \+ parent(X, Y).    

sister(X, Y) :- \+ can_be_sister(X, Y). % add a sister

is_sister(X, Y) :- 
    (female(X), siblings(X, Y)).

/* brother */
can_be_brother(X, Y) :-
    X \= Y, % can't be his own brother
    (known_gender(X), male(X), \+ female(X); \+ known_gender(X)),
    \+ parent(X, Y).

brother(X, Y) :- \+ can_be_brother(X, Y).

is_brother(X, Y) :- 
    (male(X), siblings(X, Y)).

/* siblings */
siblings(X, Y) :- sibling_of(X, Y), !.
siblings(X, Y) :- sibling_of(Y, X), !.
siblings(X, Y) :- parent(Z, X), parent(Z, Y), X \= Y.
siblings(X, Y) :- clause(child(X, Z), true), clause(child(Y, Z), true), X \= Y.

sibling_of(X, Y) :- clause(sister(X, Y), true); clause(brother(X, Y), true).

/* mother */
can_be_mother(Mother, Y) :-
    Mother \= Y, % can't be her own mother
    ((known_gender(Mother), female(Mother), \+ male(Mother)); \+ known_gender(Mother)),
    \+ creates_cycle_mother(Mother, Y),
    \+ (clause(mother(X, Y), true), X \= Mother).    % Y does not have a mother yet.

mother(Mother, Y) :- \+ can_be_mother(Mother, Y).

is_mother(Mother, Y) :-
    Mother \= Y, % can't be her own mother
    (clause(mother(Mother, Y), true);   % fact is already present OR
    (female(Mother), child(Y, Mother))).    % Mother input is female and Y is a child of Mother

/* Check for cycles in the mother relationship */
creates_cycle_mother(Mother, Child) :-
    is_mother(Child, Mother), % Check if adding the new fact creates a direct cycle
    !.
creates_cycle_mother(Mother, Child) :-
    is_mother(Child, X),
    creates_cycle_mother(Mother, X). % Check if adding the new fact creates an indirect cycle

/* father */
can_be_father(Father, Y) :-
    Father \= Y, % can't be his own father
    ((known_gender(Father), male(Father), \+ female(Father)); \+ known_gender(Father)),
    \+ creates_cycle_father(Father, Y),    % Y can't be an ancestor of Father
    \+ (clause(father(X, Y), true), X \= Father).    % Y does not have a father yet

father(Father, Y) :- \+ can_be_father(Father, Y).

is_father(Father, Y) :-
    Father \= Y, % can't be his own father
    (clause(father(Father, Y), true);
    male(Father), child(Y, Father)).

/* Check for cycles in the father relationship */
creates_cycle_father(Father, Child) :-
    is_father(Child, Father), % Check if adding the new fact creates a direct cycle
    !.
creates_cycle_father(Father, Child) :-
    is_father(Child, X),
    creates_cycle_father(Father, X). % Check if adding the new fact creates an indirect cycle

can_be_child(Child, Y) :-
    Child \= Y,
    \+ creates_cycle_child_exp(Child, Y).

child(Child, Y) :- \+ can_be_child(Child, Y).

is_child(Child, Y) :-
    clause(child(Child, Y), true);
    child(Child, Y).

/* Check for cycles in the daughter relationship */
creates_cycle_child_exp(Child, Parent) :-
    clause(child(Parent, Child), true), % Check if adding the new fact creates a direct cycle
    !.
creates_cycle_child_exp(Child, Parent) :-
    clause(child(X, Child), true),
    creates_cycle_child_exp(X, Parent). % Check if adding the new fact creates an indirect cycle

/* daughter */
can_be_daughter(Daughter, Y) :-
    Daughter \= Y, % can't be her own daughter
    ((known_gender(Daughter), female(Daughter), \+ male(Daughter)); \+ known_gender(Daughter)).

daughter(Daughter, Y) :- \+ can_be_daughter(Daughter, Y).

is_daughter(Daughter, Parent) :-
    clause(daughter(Daughter, Parent), true);
    (female(Daughter), is_child(Daughter, Parent)).

/* son */
can_be_son(Son, Y) :-
    Son \= Y, % can't be his own son
    ((known_gender(Son), male(Son), \+ female(Son)); \+ known_gender(Son)).

son(Son, Y) :- \+ can_be_son(Son, Y).

is_son(Son, Parent) :-
    clause(son(Son, Parent), true);
    (male(Son), is_child(Son, Parent)).

/* grandfather */
can_be_grandfather(Grandfather, Y) :-
    Grandfather \= Y, % can't be his own grandfather
    (known_gender(Grandfather), male(Grandfather), \+ female(Grandfather); \+ known_gender(Grandfather)).

grandfather(Grandfather, Y) :- \+ can_be_grandfather(Grandfather, Y).

is_grandfather(Grandfather, Y) :-
    clause(grandfather(Grandfather, Y), true);
    (male(Grandfather), child(Y, Parent), child(Parent, Grandfather)).

/* grandmother */
can_be_grandmother(Grandmother, Y) :-
    Grandmother \= Y, % can't be her own grandmother
    (known_gender(Grandmother), female(Grandmother), \+ male(Grandmother); \+ known_gender(Grandmother)).

grandmother(Grandmother, Y) :- \+ can_be_grandmother(Grandmother, Y).

is_grandmother(Grandmother, Y) :-
    clause(grandmother(Grandmother, Y), true);
    (female(Grandmother), child(Y, Parent), child(Parent, Grandmother)).

/* aunt */
can_be_aunt(Aunt, NieceNephew) :-
    Aunt \= NieceNephew, % Aunt can't be her own niece/nephew
    (known_gender(Aunt), female(Aunt), \+ male(Aunt); \+ known_gender(Aunt)),   % female or gender is unknown
    \+ creates_cycle_aunt(Aunt, NieceNephew).   

aunt(Aunt, NieceNephew) :- \+ can_be_aunt(Aunt, NieceNephew).

is_aunt(Aunt, NieceNephew) :-
    clause(aunt(Aunt, NieceNephew), true);
    (female(Aunt), is_child(NieceNephew, Parent), siblings(Aunt, Parent)).

/* Check for cycles in the mother relationship */
creates_cycle_aunt(Aunt, Y) :-
    is_aunt(Y, Aunt), % Check if adding the new fact creates a direct cycle
    !.
creates_cycle_aunt(Aunt, Y) :-
    is_aunt(Y, X),
    creates_cycle_aunt(Aunt, X). % Check if adding the new fact creates an indirect cycle

/* uncle */
can_be_uncle(Uncle, NieceNephew) :-
    Uncle \= NieceNephew, % Uncle can't be his own niece/nephew
    (known_gender(Uncle), male(Uncle), \+ female(Uncle); \+ known_gender(Uncle)),
    \+ creates_cycle_uncle(Uncle, NieceNephew).

uncle(Uncle, NieceNephew) :- \+ can_be_uncle(Uncle, NieceNephew).

is_uncle(Uncle, NieceNephew) :-
    clause(uncle(Uncle, NieceNephew), true);
    (male(Uncle), is_child(NieceNephew, Parent), siblings(Uncle, Parent)).

/* Check for cycles in the mother relationship */
creates_cycle_uncle(Uncle, Y) :-
    is_uncle(Y, Uncle), % Check if adding the new fact creates a direct cycle
    !.
creates_cycle_uncle(Uncle, Y) :-
    is_uncle(Y, X),
    creates_cycle_uncle(Uncle, X). % Check if adding the new fact creates an indirect cycle

/* child or children */
child(X, Y) :- clause(daughter(X, Y), true), !.
child(X, Y) :- clause(son(X, Y), true), !.
child(X, Y) :- parent(Y, X), !.

/* parent or parents */
parent(P, C) :- clause(mother(P, C), true).
parent(P, C) :- clause(father(P, C), true).

parents(X, Y, Z) :- clause(father(X, Z), true), clause(mother(Y, Z), true).
parents(X, Y, Z) :- clause(mother(X, Z), true), clause(father(Y, Z), true).

/* rules for questions */
siblings_of(X, Sibling) :- siblings(X, Sibling).
sisters_of(X, Y) :- is_sister(Y, X).
brothers_of(X, Y) :- is_brother(Y, X).
mother_of(Child, Mother) :- clause(mother(Mother, Child), true); is_mother(Mother, Child).
father_of(Child, Father) :- clause(father(Father, Child), true); is_father(Father, Child).
parents_of(Child, Parent) :- parent(Parent, Child).
grandfather_of(Grandfather, Grandchild) :- is_grandfather(Grandfather, Grandchild).
daughters_of(Parent, Daughter) :- is_daughter(Daughter, Parent).
sons_of(Parent, Son) :- is_son(Son, Parent).
children_of(Parent, Child) :- is_child(Child, Parent); clause(child(Child, Parent), true).
children_of(Parent, Sibling) :- is_mother(Parent, Child), siblings(Child, Sibling).
children_of(Parent, Sibling) :- is_father(Parent, Child), siblings(Child, Sibling).

relatives(X, Y) :- is_mother(X, Y).
relatives(X, Y) :- is_mother(Y, X).
relatives(X, Y) :- is_father(X, Y).
relatives(X, Y) :- is_father(Y, X).
relatives(X, Y) :- siblings(X, Y).
relatives(X, Y) :- is_aunt(X, Y).
relatives(X, Y) :- is_aunt(Y, X).
relatives(X, Y) :- is_uncle(X, Y).
relatives(X, Y) :- is_uncle(Y, X).
relatives(X, Y) :- is_grandmother(X, Y).
relatives(X, Y) :- is_grandfather(X, Y).
relatives(X, Y) :- child(X, Y); child(Y, X).

/* facts from user */
child(alice, mary).
child(bob, mary).
child(charlie, mary).

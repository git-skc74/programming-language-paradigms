plan(plan(Morning, Evening, Night)) :-
    findall(E, employee(E), Employees),

    schedule(morning, Employees, RemainingAfterMorning, Morning),

    schedule(evening, RemainingAfterMorning, RemainingAfterEvening, Evening),

    schedule(night, RemainingAfterEvening, [], Night).

schedule(Shift, InputEmps, OutputEmps, Schedule) :-
    % find all workstation available during shift
    % \+ except for idle workstations
    findall(W, (workstation(W, _, _), \+ workstation_idle(W, Shift)), WSList),

    assign_workstations(Shift, WSList, InputEmps, OutputEmps, Schedule).

% empty workstation
assign_workstations(_, [], Emps, Emps, []).

assign_workstations(Shift, [W|RestWS], InputEmps, FinalRemaining, [workstation(W, Selected)|RestSched]) :-
    workstation(W, Min, Max),
    
    pick_group(W, Shift, Min, Max, InputEmps, NewRemaining, Selected),

    assign_workstations(Shift, RestWS, NewRemaining, FinalRemaining, RestSched).

pick_group(W, Shift, Min, Max, InEmps, OutEmps, Selected) :-
    between(Min, Max, N),

    pick_n_employees(N, W, Shift, InEmps, OutEmps, Selected).

% base case
pick_n_employees(0, _, _, Emps, Emps, []).

pick_n_employees(N, W, Shift, [Emp|RestEmps], FinalRemaining, [Emp|RestSelected]) :-
    N > 0,

    \+ avoid_workstation(Emp, W),
    \+ avoid_shift(Emp, Shift),

    N1 is N - 1,
    pick_n_employees(N1, W, Shift, RestEmps, FinalRemaining, RestSelected).

pick_n_employees(N, W, Shift, [Emp|RestEmps], [Emp|FinalRemaining], Selected) :-
    N > 0,

    % pass if applies
    (avoid_workstation(Emp, W) ; avoid_shift(Emp, Shift)),

    pick_n_employees(N, W, Shift, RestEmps, FinalRemaining, Selected).
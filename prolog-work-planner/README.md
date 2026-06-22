# CS4337 Project 2 - Work Schedule Planner

## Files
| File | Role |
|------|------|
|`project2.pl` | Main implementation. Contains `plan/1` and all supporting predicates. |
| `testing.pl` | Provided test helper predicates (`no_work/2`, `double_work/2`, `works_at/4`, etc.). |
| `example-input-N.pl` | Sample input files defining `employee/1`, `workstation/3`, `workstation_idle/2`, `avoid_workstation/2`, and `avoid_shift/2` facts. |

---

## How to Run
You can run the program from the command line using SWI-Prolog. Make sure Prolog is installed on your device properly.

1. Open your terminal or command prompt.
2. Run SWI-Prolog with the necessary files:  
If you want to test example 1,
    ```bash
    swipl project2.pl testing.pl example-input-1.pl
    ```
    `prolog project2.pl testing.pl example-input-1.pl` also worked for me. Use this command instead, if swipl does not work.
3. Once the prolog interactive shell (`?-`) is running you can query the plan:
    ```bash
    ?- plan(Plan).
    ```
4. To check for any unassigned employees or duplicated assignments, use the testing predicates:
    ```bash
    ?- plan(Plan), no_work(Plan, _).
    ?- plan(Plan), double_work(Plan, _).
    ```
(Press `;` to explore alternative schedules if available, or `.` to terminate the search.)

## Notes
The program assigns employes in order and only skips an employee if they have a specific constraint (`avoid_workstation` or `avoid_shift`). This prevented the common "infinite loop".